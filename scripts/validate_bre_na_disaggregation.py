# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate the two NA Disaggregation dashboards locally; export Trino planning SQL.

The focused renderer is not Looker's compiler. Native validation remains required.
"""
import argparse
import copy
import json
from pathlib import Path
import re
import duckdb
import lkml
from liquid import Environment,StrictUndefined
import sqlglot
import yaml
ROOT=Path(__file__).resolve().parents[1]
START,END='2026-09-26','2026-10-03'
REF=re.compile(r'\$\{(\w+)(?:::(date|datetime|string))?\}')
TABLE=re.compile(r'\$\{(\w+)\.SQL_TABLE_NAME\}')
ENV=Environment(undefined=StrictUndefined)


def run(output):
    output.mkdir(parents=True,exist_ok=True)
    views={};loaded=set()
    def load(path):
        if path in loaded:return
        loaded.add(path);d=lkml.load(path.open())
        for v in d.get('views',[]):
            assert v['name'] not in views,v['name'];views[v['name']]=v
        for p in d.get('includes',[]):
            target=ROOT/p.lstrip('/');assert target.exists(),p
            if target.suffix=='.lkml':load(target)
    load(ROOT/'models/bre_na.model.lkml')
    model=lkml.load((ROOT/'models/bre_na.model.lkml').open())
    explores={e['name']:e for e in model['explores']}
    resolved={}
    def resolve(name):
        if name in resolved:return resolved[name]
        out={}
        for parents in views[name].get('extends__all',[]):
            for parent in parents:
                for key,val in resolve(parent).items():out.setdefault(key,{}).update(copy.deepcopy(val))
        for kind in ['dimensions','dimension_groups','measures','parameters','filters']:
            for f in views[name].get(kind,[]):out.setdefault(kind,{}).setdefault(f['name'],{}).update(f)
        resolved[name]=out;return out
    def fields(name):
        result={}
        for kind,group in resolve(name).items():
            for n,f in group.items():
                if kind=='dimension_groups':
                    for frame in f['timeframes']:
                        sql=f['sql']
                        if frame=='date':sql=f'CAST({sql} AS DATE)'
                        if frame=='hour':sql=f"date_trunc('hour', {sql})"
                        result[n+'_'+frame]=dict(f,kind='dimensions',sql=sql,type='date' if frame=='date' else 'date_time')
                else:result[n]=dict(f,kind=kind)
        return result
    def render(raw,period='Daily',comparison=False,conditions=None):
        raw=re.sub(r'\{%\s*date_start\s+[\w.]+\s*%\}',f"DATE '{START}'",raw)
        raw=re.sub(r'\{%\s*date_end\s+[\w.]+\s*%\}',f"DATE '{END}'",raw)
        raw=re.sub(r'\{%\s*parameter\s+period\s*%\}',"'"+period+"'",raw)
        def condition(m):
            n=m[1].split('.')[-1];v=m[2].strip()
            if conditions and n in conditions:return conditions[n].format(value=v)
            if n in ['date_range','comparison_date_range']:return f"({v} >= DATE '{START}' AND {v} < DATE '{END}')"
            if n=='pilot_id':return f"{v} = '10037'"
            if n=='pilot_name':return f"{v} = 'PSEG'"
            return 'TRUE'
        raw=re.sub(r'\{%\s*condition\s+([\w.]+)\s*%\}(.*?)\{%\s*endcondition\s*%\}',condition,raw,flags=re.S)
        return ENV.from_string(raw).render(period={'_parameter_value':"'"+period+"'"},comparison_date_range={'_is_filtered':comparison},_model={'_name':'bre_na'})
    def source(view,period='Daily',comparison=False,conditions=None):
        raw=render(views[view]['derived_table']['sql'],period,comparison,conditions)
        return TABLE.sub(lambda m:'('+source(m[1],period,comparison,conditions)+')',raw)
    def expr(view,name,period='Daily',comparison=False):
        fs=fields(view);f=fs[name];raw=render(f['sql'],period,comparison).replace('${TABLE}','q')
        def ref(m):
            val=expr(view,m[1],period,comparison)
            return 'CAST(('+val+') AS '+{'date':'DATE','datetime':'TIMESTAMP','string':'VARCHAR'}[m[2]]+')' if m[2] else '('+val+')'
        raw=REF.sub(ref,raw)
        if f['kind']=='measures' and f['type'] in ['sum','average','max','min']:raw={'sum':'SUM','average':'AVG','max':'MAX','min':'MIN'}[f['type']]+'('+raw+')'
        return raw
    dashboards=[];cases=[]
    for suffix,count in [('governance',8),('queue_metrics',10)]:
        ident='bre_na_disaggregation_'+suffix;path='/dashboards/'+ident+'.dashboard.lookml'
        assert path in model['includes'];d=yaml.safe_load((ROOT/path.lstrip('/')).read_text())[0]
        assert d['dashboard']==ident and len(d['elements'])==count
        controls={f['name'] for f in d['filters']};used=set();rectangles=[]
        for t in d['elements']:
            assert t['model']=='bre_na';used.update(t['listen']);assert set(t['listen'])<=controls
            a=(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']);assert 0<=a[0]<a[2]<=24
            assert not any(max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]) for b in rectangles);rectangles.append(a)
            if t['name']=='na_3a_t01':
                old=yaml.safe_load((ROOT/'dashboards/bre_na_aggregation.dashboard.lookml').read_text())[0]['elements'][0]
                assert all(t[k]==old[k] for k in ['model','explore','fields','filters','listen']);continue
            view=t['explore'];assert view in explores
            fs=fields(view);assert any(f.get('primary_key')=='yes' for f in fs.values())
            assert all(f.get('description') for f in fs.values())
            assert set(views[view]['derived_table'])=={'sql'}
            for ref in t['fields']+list(t['filters'])+list(t['listen'].values())+t.get('pivots',[]):
                alias,n=ref.split('.');assert alias==view and n in fs,ref
            if 'advanced_vis_config' in t:
                cfg=json.loads(t['advanced_vis_config']);assert cfg['yAxis'][0]['min']==0 and cfg['yAxis'][0]['max']==100
                assert cfg['plotOptions']['solidgauge']['dataLabels']['enabled'];assert 'data' not in cfg['series'][0]
                assert fs[t['fields'][1].split('.')[1]]['type']=='sum'
            comparison='comparison_date_range' in str(t['filters'])
            for period in (['Daily','Weekly','Monthly'] if 'Period' in t['listen'] else ['Daily']):
                select=[];group=[]
                for ref in t['fields']:
                    n=ref.split('.')[1];select.append(expr(view,n,period,comparison)+' AS '+n)
                    if fs[n]['kind']=='dimensions':group.append(str(len(select)))
                sql='SELECT '+',\n'.join(select)+'\nFROM ('+source(view,period,comparison)+') q'
                where=[]
                for ref,val in t['filters'].items():
                    n=ref.split('.')[1]
                    if fs[n]['kind'] in ['parameters','filters']:continue
                    if val=='Yes':where.append(expr(view,n,period,comparison))
                    elif val=='<=3':where.append('('+expr(view,n,period,comparison)+') <= 3')
                    else:raise AssertionError((ref,val))
                if where:sql+='\nWHERE '+' AND '.join(where)
                if group:sql+='\nGROUP BY '+','.join(group)
                assert '${' not in sql and '{%' not in sql
                sqlglot.parse_one(sql,read='trino')
                path=output/(t['name']+'_'+period.lower()+'.sql');path.write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+'\n')
                cases.append(dict(tile=t['name'],period=period,path=str(path)))
        assert used==controls;dashboards.append(d)
    # Source-row calculations, NULL behavior, exact median, and arbitrary date windows.
    db=duckdb.connect()
    def execute(sql):return db.execute(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    inv='bre_na_disaggregation_invoices'
    fixture="""(VALUES
      (DATE '2026-09-26',10,2,'SCHEDULED',90.0,'10037'),
      (DATE '2026-09-27',30,7,'SCHEDULED',80.0,'10037'),
      (DATE '2026-09-28',NULL,7,'SCHEDULED',95.0,'10037'),
      (DATE '2026-09-29',20,7,'ADHOC',50.0,'10037'),
      (DATE '2026-09-19',5,2,'SCHEDULED',75.0,'10037'),
      (DATE '2026-09-20',15,7,'SCHEDULED',70.0,'10037')
    ) q(analysis_date,total_invoices,delay_in_days,trigger_flag,successful_itemisation_pct,pilot_id)"""
    def calc(n,rows=fixture,where=''):return execute('SELECT '+expr(inv,n,comparison=True)+' FROM '+rows+where)[0][0]
    selected=' WHERE '+expr(inv,'is_selected_period',comparison=True)
    assert calc('invoices_selected_average')==20
    assert calc('invoices_selected_median')==20
    assert calc('invoices_previous_median')==10
    assert calc('invoices_average_change')==1
    assert calc('invoices_median_change')==1
    assert calc('invoices_selected_median',fixture.replace('30,7','NULL,7'))==15
    assert calc('invoices_average_change',fixture.replace('5,2','0,2').replace('15,7','0,7')) is None
    assert calc('success_t7_sum',where=selected)==175
    assert calc('success_t7_average',where=selected)==87.5
    assert calc('success_t2_sum',where=selected)==90
    assert calc('success_correction_max',where=selected)==50
    assert calc('daily_total_invoices',where=selected)==60
    one_date=fixture.replace("'2026-09-27'","'2026-09-26'").replace("'2026-09-28'","'2026-09-26'").replace("'2026-09-29'","'2026-09-26'")
    assert calc('daily_total_invoices',one_date,selected)==20
    assert calc('record_count',where=selected)==4
    # Original ranking must run before dashboard filters. Validate query structure as well as values.
    failure=source('bre_na_disaggregation_failures',conditions={'meter_type':"{value} = 'AMI'"})
    assert failure.index('AS rank')<failure.index("q.meter_type = 'AMI'")
    quality=source('bre_na_disaggregation_quality','Weekly')
    assert quality.index('AVG(appliances_kwh_variance_pct_1)')<quality.index('CAST(q.reporting_date AS DATE)')
    assert 'q.period = \'Weekly\'' in quality
    # The source chooses latest scheduled rows per delay, but latest ADHOC across delays.
    invoice_facts="""(VALUES
      ('10037','AMI','ELECTRIC',DATE '2026-09-27',DATE '2026-09-26','Daily','Disaggregation',10,0.0,60.0,7,'SCHEDULED',TIMESTAMP '2026-09-27 01:00:00'),
      ('10037','AMI','ELECTRIC',DATE '2026-09-28',DATE '2026-09-26','Daily','Disaggregation',30,0.0,90.0,7,'SCHEDULED',TIMESTAMP '2026-09-28 01:00:00'),
      ('10037','AMI','ELECTRIC',DATE '2026-09-28',DATE '2026-09-26','Daily','Disaggregation',40,0.0,80.0,2,'SCHEDULED',TIMESTAMP '2026-09-28 01:00:00'),
      ('10037','AMI','ELECTRIC',DATE '2026-09-27',DATE '2026-09-26','Daily','Disaggregation',20,0.0,60.0,2,'ADHOC',TIMESTAMP '2026-09-27 01:00:00'),
      ('10037','AMI','ELECTRIC',DATE '2026-09-28',DATE '2026-09-26','Daily','Disaggregation',50,0.0,70.0,7,'ADHOC',TIMESTAMP '2026-09-28 01:00:00')
    ) facts(pilot_id,meter_type,fuel_type,reporting_date,analysis_date,reporting_frequency,module_name,total_invoices,failed_itemisation_pct,successful_itemisation_pct,delay_in_days,trigger_flag,last_updated_timestamp)"""
    pilot_facts="(VALUES (10037, 'PSEG')) pilots(pilot_id,pilot_name)"
    src=source(inv).replace('delta_prodna.reporting.sre_invoice_statistics',invoice_facts).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilot_facts)
    assert execute('SELECT COUNT(*), SUM(total_invoices) FROM ('+src+')')==[(3,120)]
    assert execute('SELECT '+expr(inv,'success_t7_sum')+', '+expr(inv,'success_t2_sum')+', '+expr(inv,'success_correction_max')+' FROM ('+src+') q')==[(90,80,70)]
    # Exercise module membership and environment filtering using the real source formulas.
    rows=[]
    for module,env,received,empty,delayed in [('Disaggregation','prod',100,100,7),('Aggregation','prod',50,50,3),('UploadEventSplitter','prod',20,0,2),('Ingestion','prod',999,999,999),('Aggregation','other',999,999,999)]:
        for metric,value in [('NumberOfMessagesReceived',received),('NumberOfEmptyReceives',empty),('ApproximateNumberOfMessagesDelayed',delayed)]:
            rows.append("(TIMESTAMP '2026-09-29 12:00:00 UTC', '"+module+"', '"+env+"', 'queue', 'main', '"+metric+"', CAST("+str(value)+" AS DOUBLE))")
    facts='(VALUES '+','.join(rows)+') facts(analysis_date,module_name,environment,queue_name,queue_type,metric_name,metric_value)'
    def queue_source(grain):
        return source('bre_na_disaggregation_queue_'+grain,conditions={'environment':"{value} = 'prod'"}).replace('delta_prodna.reporting.sre_queue_metrics_fact',facts).replace('current_timestamp',"TIMESTAMP '2026-10-03 00:00:00 UTC'")
    assert execute('SELECT SUM(total_messages_received), SUM(delayed_messages) FROM ('+queue_source('hourly')+')')==[(170,12)]
    assert abs(execute('SELECT AVG(empty_receives_ratio) FROM ('+queue_source('daily')+')')[0][0]-100/3)<1e-10
    report=dict(result='PASS',dashboards={d['dashboard']:len(d['elements']) for d in dashboards},rendered_query_variants=len(cases),semantic_fixtures=18,source_order_checks=3,native_looker_validation='NOT RUN: no connected Looker tools',queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-disaggregation-validation'));run(p.parse_args().output_dir)
