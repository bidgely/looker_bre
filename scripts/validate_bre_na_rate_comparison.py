# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate the NA Rate Comparison dashboard locally; export Trino planning SQL.

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
START,END='2026-09-27','2026-10-04'
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
    # Match the supplied SQL after only catalog qualification, explicit pilot
    # projections, and the documented zero-denominator safeguard.
    specification=(ROOT/'data_studio_files/bre_na_model_base_data.md').read_text()
    for source_id,view in [(28,'bre_na_rate_comparison'),(21,'bre_na_rate_comparison_triggers')]:
        original=specification.split(f'### SRC-{source_id:02d}\n',1)[1].split('```sql\n',1)[1].split('```',1)[0]
        original='\n'.join(line for line in original.splitlines() if not line.lstrip().startswith('--'))
        original=re.sub(r'\breporting\.', 'delta_prodna.reporting.', original)
        actual=views[view]['derived_table']['sql'].split('FROM (',1)[1].rsplit(') q',1)[0]
        if source_id==28:
            actual=actual.replace('m.pilot_name, CAST(m.pilot_id','CAST(m.pilot_id',1).replace('NULLIF(total_invoices, 0)','total_invoices')
        else:
            actual=actual.replace('rd.pilot_id, m.pilot_name, CAST(rd.pilot_id','CAST(rd.pilot_id',1)
        assert sqlglot.parse_one(actual,read='trino')==sqlglot.parse_one(original,read='trino'),source_id
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
        return ENV.from_string(raw).render(period={'_parameter_value':"'"+period+"'"},comparison_date_range={'_is_filtered':comparison},excluded_email_types={'_is_filtered':bool(conditions and 'excluded_email_types' in conditions)},excluded_promotions={'_is_filtered':bool(conditions and 'excluded_promotions' in conditions)},_model={'_name':'bre_na'})
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
    for suffix,count in [('rate_comparison',8)]:
        ident='bre_na_rate_comparison';path='/dashboards/'+ident+'.dashboard.lookml'
        assert path in model['includes'];d=yaml.safe_load((ROOT/path.lstrip('/')).read_text())[0]
        assert d['dashboard']==ident and len(d['elements'])==count
        controls={f['name'] for f in d['filters']};used=set();rectangles=[]
        for t in d['elements']:
            assert t['model']=='bre_na';used.update(t['listen']);assert set(t['listen'])<=controls
            a=(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']);assert 0<=a[0]<a[2]<=24
            assert not any(max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]) for b in rectangles);rectangles.append(a)
            if t['name']=='na_5a_t01':
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
                assert fs[t['fields'][1].split('.')[1]]['type']=='average'
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
    db=duckdb.connect()
    def execute(sql):return db.execute(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    view='bre_na_rate_comparison'
    fixture="""(VALUES
      (DATE '2026-09-27',20,0.8,0.2),
      (DATE '2026-09-28',80,0.92,0.08),
      (DATE '2026-09-29',NULL,NULL,NULL),
      (DATE '2026-09-30',0,NULL,NULL),
      (DATE '2026-09-20',5,0.5,0.5),
      (DATE '2026-09-21',15,0.5,0.5)
    ) q(analysis_date,rc_missing_anomaly,accuracy_perc,deviation_perc)"""
    def calc(n,rows=fixture,where=''):return execute('SELECT '+expr(view,n,comparison=True)+' FROM '+rows+where)[0][0]
    selected=' WHERE '+expr(view,'is_selected_period',comparison=True)
    assert abs(calc('missing_load_shift_selected_average')-100/3)<1e-10
    assert calc('missing_load_shift_selected_median')==20
    assert calc('missing_load_shift_previous_median')==10
    assert abs(calc('missing_load_shift_average_change')-7/3)<1e-10
    assert calc('missing_load_shift_median_change')==1
    assert calc('missing_load_shift_selected_median',fixture.replace('80,0.92','NULL,0.92'))==10
    assert calc('missing_load_shift_average_change',fixture.replace(',5,0.5',',0,0.5').replace(',15,0.5',',0,0.5')) is None
    assert calc('accuracy_perc_average',where=selected)==86
    assert calc('deviation_perc_average',where=selected)==14
    assert calc('rc_missing_anomaly_sum',where=selected)==100
    assert str(execute('SELECT '+expr(view,'period_date',period='Weekly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-20'
    assert str(execute('SELECT '+expr(view,'period_date',period='Monthly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-01'
    # Exercise the real SRC-28 and SRC-21 SQL against synthetic source tables.
    # Present rows: normal, low load-shift value, out-of-order trigger, and sub-hour trigger.
    # Absent rows: <3 days is anomalous; exactly 3 days is not. NULL ID is not counted.
    db.execute("CREATE TABLE facts(pilot_id INTEGER, user_id VARCHAR, notification_type VARCHAR, notification_id VARCHAR, billing_start_time TIMESTAMP, billing_end_time TIMESTAMP, analysis_date DATE, reporting_date DATE, loadshiftamount VARCHAR, invoice_ingested_timestamp BIGINT, tou_run_timestamp BIGINT, rc_run_timestamp BIGINT, email_generation_timestamp BIGINT)")
    import datetime
    epoch=int(datetime.datetime(2026,9,27,tzinfo=datetime.timezone.utc).timestamp()*1000)
    rows=[]
    definitions=[('normal','MS','30',1,2),('low','MS','10',1,2),('ooo','MS','30',2,1),('early','MS','30',0.1,0.5),('missing','MS','',1,2),('boundary','MS','',1,72),('nullid','BP',None,None,None)]
    for ident,email,amount,tou,rc in definitions:
        rows.append((10037,ident,email,None if ident=='nullid' else ident,'2026-09-01','2026-10-01','2026-09-27','2026-09-28',amount,epoch,None if tou is None else epoch+int(tou*3600000),None if rc is None else epoch+int(rc*3600000),epoch+96*3600000))
    db.executemany('INSERT INTO facts VALUES ('+','.join(['?']*13)+')',rows)
    db.execute("CREATE TABLE pilots AS SELECT 10037 AS pilot_id, 'PSEG' AS pilot_name")
    db.execute("CREATE TABLE dates_map AS SELECT 10037 AS pilot_id, 'MS' AS notification_type, DATE '2026-09-27' AS analysis_date, DATE '2026-09-28' AS reporting_date UNION ALL SELECT 10037, 'BP', DATE '2026-09-27', DATE '2026-09-28' UNION ALL SELECT 10037, 'NO_DATA', DATE '2026-09-27', DATE '2026-09-28'")
    def fixture_source(v,conditions=None):
        return source(v,conditions=conditions).replace('delta_prodna.reporting.sre_notification_report','facts').replace('delta_prodna.reporting.pilot_consolidated_product_type_events','pilots').replace('delta_prodna.reporting.reporting_dates_map','dates_map')
    src=fixture_source(view)
    assert execute('SELECT SUM(total_invoices),SUM(anomaly_count),SUM(favourable_count),SUM(rc_missing_anomaly),SUM(rc_ooo_trigger_anomaly),SUM(rc_early_trigger_anomally),SUM(ls_low_value_anomally) FROM ('+src+')')==[(6,2,4,1,1,1,1)]
    assert execute("SELECT accuracy_perc, deviation_perc FROM ("+src+") WHERE email_type='BP'")==[(None,None)]
    assert execute("SELECT accuracy_perc, deviation_perc FROM ("+src+") WHERE email_type='MS' AND missing_promotion_flag='Present'")==[(0.75,0.25)]
    # Select values to remove, not values to keep; blank leaves every source group.
    excluded=fixture_source(view,{'excluded_promotions':"{value} = 'Absent'"})
    assert execute('SELECT SUM(total_invoices),SUM(rc_missing_anomaly) FROM ('+excluded+')')==[(4,0)]
    excluded=fixture_source(view,{'excluded_email_types':"{value} IN ('MS', 'BP')"})
    assert execute('SELECT COUNT(*) FROM ('+excluded+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+fixture_source(view,{'pilot_id':"{value} = '10038'"})+')')==[(0,)]
    trigger='bre_na_rate_comparison_triggers'
    src2=fixture_source(trigger)
    assert execute("SELECT total_records,missing_tou_count,missing_rc_count,avg_invoice_to_tou_latency_hrs,avg_tou_to_rc_latency_hrs FROM ("+src2+") WHERE email_type='NO_DATA'")==[(0,0,0,0,0)]
    assert execute("SELECT total_records,missing_tou_count,missing_rc_count,avg_invoice_to_tou_latency_hrs,avg_tou_to_rc_latency_hrs FROM ("+src2+") WHERE email_type='BP'")==[(1,1,1,0,0)]
    assert execute("SELECT SUM(total_records) FROM ("+src2+") WHERE email_type='MS'")==[(6,)]
    # Different analysis and reporting dates prove the trigger filter uses reporting_date.
    assert execute('SELECT COUNT(*) FROM ('+fixture_source(trigger,{'date_range':"{value} = DATE '2026-09-27'"})+')')==[(0,)]
    assert execute('SELECT SUM(total_records) FROM ('+fixture_source(trigger,{'excluded_email_types':"{value} = 'MS'"})+')')==[(1,)]
    # Latencies are averaged at source row grain, rather than weighted by invoice count.
    assert execute('SELECT '+expr(trigger,'avg_invoice_to_tou_latency_hrs_average')+' FROM (VALUES (1,100),(9,1)) q(avg_invoice_to_tou_latency_hrs,total_records)')==[(5,)]
    controls={f['name']:f for f in dashboards[0]['filters']}
    for name in ['Email Type (Exclude)','Promotion (Exclude)']:
        assert controls[name]['default_value']=='' and name not in dashboards[0]['elements'][0]['listen']
    # Export populated exclusions for real Trino planning as well as default queries.
    for v in [view,trigger]:
        sql='SELECT COUNT(*) FROM ('+source(v,conditions={'excluded_email_types':"{value} IN ('MS','BP')",'excluded_promotions':"{value} = 'Absent'"})+') q'
        sqlglot.parse_one(sql,read='trino')
        path=output/(v+'_exclusions.sql');path.write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+'\n')
        cases.append(dict(tile=v,period='exclusions',path=str(path)))
    report=dict(result='PASS',tiles=8,rendered_query_variants=len(cases),semantic_fixtures=24,source_contract_checks=2,native_looker_validation='NOT RUN: no connected Looker tools',queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-rate-comparison-validation'));run(p.parse_args().output_dir)
