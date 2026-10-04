# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate the NA Email dashboard locally; export Trino planning SQL.

The focused renderer is not Looker's compiler. Native validation remains required.
"""
import argparse
import copy
import itertools
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
            if n=='delivery_mode':return f"{v} = 'Daily'"
            return 'TRUE'
        raw=re.sub(r'\{%\s*condition\s+([\w.]+)\s*%\}(.*?)\{%\s*endcondition\s*%\}',condition,raw,flags=re.S)
        return ENV.from_string(raw).render(metric={'_parameter_value':"'"+selected_metric+"'"},period={'_parameter_value':"'"+period+"'"},comparison_date_range={'_is_filtered':comparison},_model={'_name':'bre_na'})
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
    selected_metric='percentage'
    dashboards=[];cases=[]
    for suffix,count in [('governance',8),('queue_metrics',10)]:
        ident='bre_na_email_'+suffix;path='/dashboards/'+ident+'.dashboard.lookml'
        assert path in model['includes'];d=yaml.safe_load((ROOT/path.lstrip('/')).read_text())[0]
        assert d['dashboard']==ident and len(d['elements'])==count
        controls={f['name'] for f in d['filters']};used=set();rectangles=[]
        for t in d['elements']:
            assert t['model']=='bre_na';used.update(t['listen']);assert set(t['listen'])<=controls
            a=(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']);assert 0<=a[0]<a[2]<=24
            assert not any(max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]) for b in rectangles);rectangles.append(a)
            if t['name']=='na_6a_t01':
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
                assert fs[t['fields'][1].split('.')[1]]['type']=='number'
            comparison='comparison_date_range' in str(t['filters'])
            for period,selected_metric in itertools.product(['Daily','Weekly','Monthly'] if 'Period' in t['listen'] else ['Daily'], ['percentage','count'] if t['name']=='na_6a_t08' else ['percentage']):
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
                    elif n=='delivery_mode':where.append('('+expr(view,n,period,comparison)+") = 'Daily'")
                    else:raise AssertionError((ref,val))
                if where:sql+='\nWHERE '+' AND '.join(where)
                if group:sql+='\nGROUP BY '+','.join(group)
                assert '${' not in sql and '{%' not in sql
                sqlglot.parse_one(sql,read='trino')
                path=output/(t['name']+'_'+period.lower()+('_'+selected_metric if t['name']=='na_6a_t08' else '')+'.sql');path.write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+'\n')
                cases.append(dict(tile=t['name'],period=period,metric=selected_metric if t['name']=='na_6a_t08' else None,path=str(path)))
        assert used==controls;dashboards.append(d)
    selector=fields('bre_na_email_failures')['metric']
    allowed={v['value'] for v in selector['allowed_values']}
    assert all('_' not in v for v in allowed)
    control=next(f for f in dashboards[0]['filters'] if f['name']=='Failure Metric')
    assert control['default_value']==selector['default_value']
    assert selector['default_value'] in allowed
    for tile in dashboards[0]['elements']:
        value=tile.get('filters',{}).get('bre_na_email_failures.metric')
        if value is not None: assert value in allowed
    db=duckdb.connect()
    def execute(sql):return db.execute(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    view='bre_na_email_delivery'
    fixture="""(VALUES
      (DATE '2026-09-27',20,40,100),
      (DATE '2026-09-28',80,100,1000),
      (DATE '2026-09-29',NULL,NULL,50),
      (DATE '2026-09-30',0,0,0),
      (DATE '2026-09-20',5,10,20),
      (DATE '2026-09-21',15,30,40)
    ) q(analysis_date,delivery_cnt,generation_cnt,invoice_ingested)"""
    def calc(n,rows=fixture,where=''):return execute('SELECT '+expr(view,n,comparison=True)+' FROM '+rows+where)[0][0]
    selected=' WHERE '+expr(view,'is_selected_period',comparison=True)
    assert abs(calc('emails_delivered_selected_average')-100/3)<1e-10
    assert calc('emails_delivered_selected_median')==20
    assert calc('emails_delivered_previous_median')==10
    assert abs(calc('emails_delivered_average_change')-7/3)<1e-10
    assert calc('emails_delivered_median_change')==1
    assert calc('emails_delivered_selected_median',fixture.replace('80,100,1000','NULL,100,1000'))==10
    assert calc('emails_delivered_average_change',fixture.replace(',5,10,20',',0,10,20').replace(',15,30,40',',0,30,40')) is None
    assert abs(calc('calc_generation_perc',where=selected)-100*140/1150)<1e-10
    assert abs(calc('calc_delivery_perc',where=selected)-100*100/140)<1e-10
    assert abs(calc('calc_generation_perc',"(VALUES (1,3)) q(generation_cnt,invoice_ingested)")-100/3)<1e-10
    assert calc('calc_delivery_perc',"(VALUES (0,0)) q(delivery_cnt,generation_cnt)") is None
    assert calc('calc_generation_perc',"(VALUES (0,0)) q(generation_cnt,invoice_ingested)") is None
    assert calc('calc_delivery_perc',"(VALUES (NULL,100)) q(delivery_cnt,generation_cnt)") is None
    assert calc('calc_delivery_perc',"(VALUES (120,100)) q(delivery_cnt,generation_cnt)")==120
    assert calc('delivery_cnt_sum',where=selected)==100
    assert calc('invoice_ingested_sum',where=selected)==1150
    assert str(execute('SELECT '+expr(view,'period_date',period='Weekly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-20'
    assert str(execute('SELECT '+expr(view,'period_date',period='Monthly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-01'
    daily="(VALUES ('10037',DATE '2026-09-27',DATE '2026-09-28','BP',20,40,100,TIMESTAMP '2026-09-28 01:00:00'),('10037',NULL,DATE '2026-09-28','BP',9,9,9,TIMESTAMP '2026-09-28 01:00:00')) facts(pilot_id,analysis_date,reporting_date,email_type,delivered_notification_id,generated_notification_id,invoice_ingested,last_updated_timestap)"
    weekly="(VALUES ('10037','2026-09-27','2026-09-28','BP','30','50','100',TIMESTAMP '2026-09-28 01:00:00')) facts(pilot_id,analysis_date,reporting_date,email_type,cnt_bills_emails_delivered,cnt_bills_emails_sent,cnt_bills_ingested,last_updated_timestamp)"
    pilots="(VALUES (10037,'PSEG')) pilots(pilot_id,pilot_name)"
    def fixture_source(conditions=None):
        return source(view,conditions=conditions).replace('delta_prodna.reporting.sre_email_daily_tracker',daily).replace('delta_prodna.reporting.sre_quality_email_stats',weekly).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT COUNT(*),SUM(delivery_cnt),MAX(generation_rate) FROM ('+fixture_source()+')')==[(1,20,0.4)]
    assert execute('SELECT COUNT(*),SUM(delivery_cnt),MAX(generation_rate) FROM ('+fixture_source({'delivery_mode':"{value} = 'Weekly'"})+')')==[(1,30,0.5)]
    assert execute('SELECT COUNT(*),SUM(delivery_cnt) FROM ('+fixture_source({'delivery_mode':'TRUE'})+')')==[(2,50)]
    assert execute('SELECT COUNT(*) FROM ('+fixture_source({'email_type':"{value} = 'OTHER'"})+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+fixture_source({'pilot_id':"{value} = '10038'"})+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+fixture_source({'date_range':"{value} = DATE '2026-09-28'"})+')')==[(0,)]
    # The source formula and join must stay identical to the supplied query.
    specification=(ROOT/'data_studio_files/bre_na_model_base_data.md').read_text()
    original=specification.split('### SRC-05\n',1)[1].split('```sql\n',1)[1].split('```',1)[0]
    original='\n'.join(line for line in original.splitlines() if not line.lstrip().startswith('--'))
    original=re.sub(r'\breporting\.', 'delta_prodna.reporting.', original)
    actual=views[view]['derived_table']['sql'].split('FROM (',1)[1].rsplit(') q',1)[0].replace('m.pilot_name, CAST(m.pilot_id','CAST(m.pilot_id',1)
    assert sqlglot.parse_one(actual,read='trino')==sqlglot.parse_one(original,read='trino')
    filters={f['name']:f for f in dashboards[0]['filters']}
    assert filters['Reporting Frequency']['default_value']=='Daily'
    assert 'Reporting Frequency' not in dashboards[0]['elements'][0]['listen']
    # Preserve SRC-26's LEFT JOIN and SRC-33's rank after the pilot INNER JOIN.
    for ident,v in [(26,'bre_na_email_recommendations'),(33,'bre_na_email_failures')]:
        original=specification.split(f'### SRC-{ident:02d}\n',1)[1].split('```sql\n',1)[1].split('```',1)[0]
        original='\n'.join(line for line in original.splitlines() if not line.lstrip().startswith('--'))
        original=re.sub(r'\breporting\.', 'delta_prodna.reporting.', original)
        actual=views[v]['derived_table']['sql'].split('FROM (',1)[1].rsplit(') q',1)[0]
        actual=actual.replace('m.pilot_name, s.pilot_id','s.pilot_id',1) if ident==26 else actual.replace('m.pilot_name, CAST(m.pilot_id','CAST(m.pilot_id',1)
        assert sqlglot.parse_one(actual,read='trino')==sqlglot.parse_one(original,read='trino'),ident
    reco='bre_na_email_recommendations';failure='bre_na_email_failures'
    rf="(VALUES ('10037', DATE '2026-09-27','BP','quality',10.0),('10037',DATE '2026-09-27','BP','quality',30.0),('99999',DATE '2026-09-27','BP','quality',99.0)) facts(pilot_id,analysis_date,email_type,metric_name,notification_pct)"
    rf='(SELECT * FROM '+rf+')'
    rsrc=source(reco).replace('delta_prodna.reporting.sre_quality_reco_stats',rf).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT '+expr(reco,'notification_pct_average')+' FROM ('+rsrc+') q')==[(20,)]
    rsrc=source(reco,conditions={'pilot_id':'TRUE','pilot_name':'TRUE'}).replace('delta_prodna.reporting.sre_quality_reco_stats',rf).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT COUNT(*) FROM ('+rsrc+')')==[(3,)]
    ff="(VALUES ('10037','2026-09-27','BP','A',10,10.0),('10037','2026-09-27','BP','B',30,30.0),('10037','2026-09-27','BP','C',60,60.0),('10037','2026-09-27','BP','D',5,5.0),('99999','2026-09-27','BP','orphan',9,9.0)) facts(pilot_id,analysis_date,email_type,failure_reason,failure_count,failure_pct)"
    ff='(SELECT * FROM '+ff+')'
    fsrc=source(failure).replace('delta_prodna.reporting.sre_email_failure_reasons',ff).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT failure_reason,rank FROM ('+fsrc+') ORDER BY rank')==[('C',1),('B',2),('A',3),('D',4)]
    selected_metric='percentage'
    assert execute('SELECT '+expr(failure,'metric_toggle')+' FROM ('+fsrc+') q')==[(26.25,)]
    selected_metric='count'
    assert execute('SELECT '+expr(failure,'metric_toggle')+' FROM ('+fsrc+') q')==[(105,)]
    assert execute('SELECT '+expr(failure,'period_date','Weekly')+' FROM ('+fsrc+') q LIMIT 1')[0][0].isoformat()[:10]=='2026-09-27'
    # Real queue source formulas must reject other modules and environments.
    rows=[]
    for module,env,received,empty,delayed in [('Emailer','prod',100,100,7),('Ingestion','prod',999,999,999),('Emailer','other',999,999,999)]:
        for metric,value in [('NumberOfMessagesReceived',received),('NumberOfEmptyReceives',empty),('ApproximateNumberOfMessagesDelayed',delayed)]:
            rows.append("(TIMESTAMP '2026-09-29 12:00:00 UTC', '"+module+"', '"+env+"', 'queue', 'main', '"+metric+"', CAST("+str(value)+" AS DOUBLE))")
    facts='(VALUES '+','.join(rows)+') facts(analysis_date,module_name,environment,queue_name,queue_type,metric_name,metric_value)'
    def queue_source(grain):
        return source('bre_na_email_queue_'+grain,conditions={'environment':"{value} = 'prod'"}).replace('delta_prodna.reporting.sre_queue_metrics_fact',facts).replace('current_timestamp',"TIMESTAMP '2026-10-04 00:00:00 UTC'")
    assert execute('SELECT SUM(total_messages_received), SUM(delayed_messages) FROM ('+queue_source('hourly')+')')==[(100,7)]
    assert execute('SELECT AVG(empty_receives_ratio) FROM ('+queue_source('daily')+')')==[(50,)]
    for grain in ['hourly','daily','health']:
        assert "module_name = 'Emailer'" in source('bre_na_email_queue_'+grain)
    for tile in dashboards[0]['elements'][6:]:
        assert 'Reporting Frequency' not in tile['listen']
    report=dict(result='PASS',tiles=18,dashboards={d['dashboard']:len(d['elements']) for d in dashboards},rendered_query_variants=len(cases),semantic_fixtures=32,source_contract_checks=3,native_looker_validation='NOT RUN: no connected Looker tools',queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-email-validation'));run(p.parse_args().output_dir)
