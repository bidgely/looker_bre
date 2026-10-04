# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Local NA Aggregation checks and exported Trino plans; not the Looker compiler."""
import argparse
import json
from pathlib import Path
import re
import duckdb
import lkml
from liquid import Environment, StrictUndefined
import sqlglot
import yaml

ROOT=Path(__file__).resolve().parents[1]
VIEW='bre_na_aggregation'
START,END='2026-09-26','2026-10-03'
REF=re.compile(r'\$\{(\w+)(?:::(date|datetime|string))?\}')
ENV=Environment(undefined=StrictUndefined)


def run(output):
    output.mkdir(parents=True,exist_ok=True)
    model=lkml.load((ROOT/'models/bre_na.model.lkml').open())
    assert model['connection']=='starburst_prod_na'
    for p in ['/views/bre_na/bre_na_aggregation.view.lkml','/dashboards/bre_na_aggregation.dashboard.lookml']:
        assert p in model['includes']
    assert any(e['name']==VIEW for e in model['explores'])
    view=lkml.load((ROOT/'views/bre_na/bre_na_aggregation.view.lkml').open())['views'][0]
    assert set(view['derived_table'])=={'sql'}
    fields={f['name']:dict(f,kind=k) for k in ['dimensions','measures','filters','parameters'] for f in view.get(k,[])}
    assert len(fields)==sum(len(view.get(k,[])) for k in ['dimensions','measures','filters','parameters'])
    assert view['dimensions'][0]['primary_key']=='yes'
    assert all(f.get('description') for f in fields.values())
    d=yaml.safe_load((ROOT/'dashboards/bre_na_aggregation.dashboard.lookml').read_text())[0]
    assert d['dashboard']==VIEW and len(d['elements'])==8
    controls={f['name'] for f in d['filters']}
    assert controls=={'Time Period','Period','Pilot ID','Pilot Name','File Granularity'}
    original=yaml.safe_load((ROOT/'dashboards/bre_na_ingestion_governance.dashboard.lookml').read_text())[0]['elements'][0]
    assert all(d['elements'][0][k]==original[k] for k in ['model','explore','fields','filters','listen'])
    assert 'File Granularity' not in d['elements'][0]['listen']
    rectangles=[]
    for t in d['elements']:
        a=(t['col'],t['row'],t['col']+t['width'],t['row']+t['height'])
        assert 0<=a[0]<a[2]<=24
        assert not any(max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]) for b in rectangles)
        rectangles.append(a)
        assert set(t['listen'])<=controls
    source_pilots=lkml.load((ROOT/'views/bre/bre_pilots.view.lkml').open())['views'][0]['derived_table']['sql']
    def render(raw,comparison=False,period='Daily',duration=None):
        raw=re.sub(r'\{%\s*date_start\s+\w+\s*%\}',f"DATE '{START}'",raw)
        raw=re.sub(r'\{%\s*date_end\s+\w+\s*%\}',f"DATE '{END}'",raw)
        def condition(m):
            n,v=m[1],m[2].strip()
            if n in ['date_range','comparison_date_range']:return f"({v} >= DATE '{START}' AND {v} < DATE '{END}')"
            if n=='pilot_id':return f"{v} = '10037'"
            if n=='pilot_name':return f"{v} = 'PSEG'"
            if n=='duration':return 'TRUE' if duration is None else f'{v} = {duration}'
            raise AssertionError(n)
        raw=re.sub(r'\{%\s*condition\s+(\w+)\s*%\}(.*?)\{%\s*endcondition\s*%\}',condition,raw,flags=re.S)
        return ENV.from_string(raw).render(comparison_date_range={'_is_filtered':comparison},period={'_parameter_value':"'"+period+"'"},_model={'_name':'bre_na'})
    def source(comparison=False,period='Daily',duration=None):
        return render(view['derived_table']['sql'],comparison,period,duration).replace('${bre_pilots.SQL_TABLE_NAME}','('+render(source_pilots)+')')
    def expression(name,comparison=False,period='Daily'):
        f=fields[name];raw=render(f['sql'],comparison,period).replace('${TABLE}','q')
        def replace(m):
            v=expression(m[1],comparison,period)
            return f'CAST(({v}) AS '+{'date':'DATE','datetime':'TIMESTAMP','string':'VARCHAR'}[m[2]]+')' if m[2] else '('+v+')'
        raw=REF.sub(replace,raw)
        if f['kind']=='measures' and f['type'] in ['sum','average']:
            raw={'sum':'SUM','average':'AVG'}[f['type']]+'('+raw+')'
        return raw
    cases=[]
    for t in d['elements'][1:]:
        assert t['model']=='bre_na' and t['explore']==VIEW
        refs=t['fields']+list(t['filters'])+list(t['listen'].values())
        for ref in refs:
            alias,f=ref.split('.'); assert alias==VIEW and f in fields,ref
        comparison='comparison_date_range' in str(t['filters'])
        if 'advanced_vis_config' in t:
            c=json.loads(t['advanced_vis_config']);maximum=1500000 if t['name']=='na_2_t04' else 100
            assert c['chart']['type']=='solidgauge' and c['yAxis'][0]['max']==maximum
            assert c['yAxis'][0]['min']==0 and c['plotOptions']['solidgauge']['dataLabels']['enabled']
            assert 'data' not in c['series'][0]
        for period in (['Daily','Weekly','Monthly'] if 'Period' in t['listen'] else ['Daily']):
            select=[];groups=[]
            for ref in t['fields']:
                n=ref.split('.')[1];select.append(expression(n,comparison,period)+' AS '+n)
                if fields[n]['kind']=='dimensions':groups.append(str(len(select)))
            query='SELECT '+',\n'.join(select)+'\nFROM ('+source(comparison,period)+') q'
            if comparison:query+='\nWHERE '+expression('in_comparison_window',comparison,period)
            if groups:query+='\nGROUP BY '+','.join(groups)
            assert '${' not in query and '{%' not in query
            sqlglot.parse_one(query,read='trino')
            path=output/(t['name']+'_'+period.lower()+'.sql');path.write_text('EXPLAIN (TYPE VALIDATE)\n'+query+'\n')
            cases.append({'tile':t['name'],'period':period,'path':str(path)})
    stats=d['elements'][5]
    assert stats['series_labels'][VIEW+'.total_negative_consumption_datapoints_sum']=='Unique Users #'
    # Unequal reporting and analysis dates distinguish the filter and grouping dates.
    fixture="""(VALUES
      (DATE '2026-09-19', DATE '2026-09-26', 10, 100, 1),
      (DATE '2026-09-20', DATE '2026-09-27', 30, 50, 3),
      (DATE '2026-09-21', DATE '2026-09-28', NULL, 0, 5),
      (DATE '2026-09-12', DATE '2026-09-19', 5, 10, 1),
      (DATE '2026-09-13', DATE '2026-09-20', 15, 30, 1)
    ) q(analysis_date,reporting_date,total_datapoints,total_expected_datapoints,total_negative_consumption_datapoints)"""
    db=duckdb.connect()
    def execute(sql):return db.execute(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    def calc(n,rows=fixture):return execute('SELECT '+expression(n,True)+' FROM '+rows)[0][0]
    assert calc('datapoints_selected_average')==20
    assert calc('datapoints_selected_median')==20
    assert calc('datapoints_previous_median')==10
    assert calc('datapoints_average_change')==1
    assert calc('datapoints_median_change')==1
    assert calc('datapoints_selected_median',fixture.replace('30, 50','NULL, 50'))==10
    assert calc('datapoints_selected_median',fixture.replace('30, 50','NULL, 50').replace('10, 100','NULL, 100')) is None
    assert calc('datapoints_average_change',fixture.replace('5, 10','0, 10').replace('15, 30','0, 30')) is None
    selected='('+expression('is_selected_period',True)+')'
    assert execute('SELECT '+expression('success_perc_average')+' FROM '+fixture+' WHERE '+selected)==[(35.0,)]
    assert abs(execute('SELECT '+expression('success_perc')+' FROM (VALUES (1, 3)) q(total_datapoints,total_expected_datapoints)')[0][0]-100/3)<1e-10
    assert execute('SELECT '+expression('total_negative_consumption_datapoints_sum')+' FROM '+fixture+' WHERE '+selected)==[(9,)]
    assert str(execute('SELECT '+expression('period_date',period='Weekly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-20'
    assert str(execute('SELECT '+expression('period_date',period='Monthly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-01'
    assert 's.duration = 900' in source(duration=900)
    report=dict(result='PASS',tiles=8,rendered_query_variants=len(cases),semantic_fixtures=13,source_query='SRC-29',availability_formula='user-confirmed: 100 * actual / expected; implementation returns NULL for zero denominator',native_looker_validation='NOT RUN: no connected Looker tools',queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-aggregation-validation'))
    run(p.parse_args().output_dir)
