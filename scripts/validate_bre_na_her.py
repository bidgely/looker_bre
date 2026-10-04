# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate the NA HER dashboard locally; export Trino planning SQL.

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
    selected_metric='failure_percentage'
    dashboards=[];cases=[]
    for suffix,count in [('governance',7),('queue_metrics',10)]:
        ident='bre_na_her_'+suffix;path='/dashboards/'+ident+'.dashboard.lookml'
        assert path in model['includes'];d=yaml.safe_load((ROOT/path.lstrip('/')).read_text())[0]
        assert d['dashboard']==ident and len(d['elements'])==count
        controls={f['name'] for f in d['filters']};used=set();rectangles=[]
        for t in d['elements']:
            assert t['model']=='bre_na';used.update(t['listen']);assert set(t['listen'])<=controls
            a=(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']);assert 0<=a[0]<a[2]<=24
            assert not any(max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]) for b in rectangles);rectangles.append(a)
            if t['name']=='na_7a_t01':
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
            for period,selected_metric in itertools.product(['Daily','Weekly','Monthly'] if 'Period' in t['listen'] else ['Daily'], ['failure_percentage','failure_count'] if t['name']=='na_7a_t07' else ['failure_percentage']):
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
                path=output/(t['name']+'_'+period.lower()+('_'+selected_metric if t['name']=='na_7a_t07' else '')+'.sql');path.write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+'\n')
                cases.append(dict(tile=t['name'],period=period,metric=selected_metric if t['name']=='na_7a_t07' else None,path=str(path)))
        assert used==controls;dashboards.append(d)
    db=duckdb.connect()
    def execute(sql):return db.execute(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    specification=(ROOT/'data_studio_files/bre_na_model_base_data.md').read_text()
    for ident,v in [(22,'schedules'),(48,'quality'),(6,'failures'),(34,'generation')]:
        original=specification.split(f'### SRC-{ident:02d}\n',1)[1].split('```sql\n',1)[1].split('```',1)[0]
        original='\n'.join(line for line in original.splitlines() if not line.lstrip().startswith('--'))
        original=re.sub(r'\b(reporting|public)\.',r'delta_prodna.\1.',original)
        actual=views['bre_na_her_'+v]['derived_table']['sql'].split('FROM (',1)[1].rsplit(') q',1)[0]
        actual=actual.replace('m.pilot_name, m.pilot_id, CAST(m.pilot_id','m.pilot_id, CAST(m.pilot_id',1) if ident==22 else actual.replace('m.pilot_name, CAST(m.pilot_id','CAST(m.pilot_id',1)
        assert sqlglot.parse_one(actual,read='trino')==sqlglot.parse_one(original,read='trino'),ident
    pilots="(VALUES (10037,'PSEG')) pilots(pilot_id,pilot_name)"
    # Failure denominators and rank must be calculated before controls and source-period selection.
    facts="""(VALUES
      (DATE '2026-09-28',DATE '2026-09-29',10037,'A',DATE '2026-01-01',DATE '2026-12-31','reason',30,TIMESTAMP '2026-09-29 00:00:00','ELECTRIC'),
      (DATE '2026-09-28',DATE '2026-09-29',10037,'A',DATE '2026-01-01',DATE '2026-12-31',NULL,70,TIMESTAMP '2026-09-29 00:00:00','ELECTRIC'),
      (DATE '2026-09-29',DATE '2026-09-30',10037,'A',DATE '2026-01-01',DATE '2026-12-31','reason',10,TIMESTAMP '2026-09-30 00:00:00','ELECTRIC'),
      (DATE '2026-09-29',DATE '2026-09-30',10037,'A',DATE '2026-01-01',DATE '2026-12-31',NULL,10,TIMESTAMP '2026-09-30 00:00:00','ELECTRIC')
    ) facts(analysis_date,reporting_date,pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,failure_count,last_updated_timestamp,measurement_type)"""
    failure='bre_na_her_failures'
    def fs(period='Daily',conditions=None):return source(failure,period,conditions=conditions).replace('delta_prodna.reporting.sre_her_schedule_errors',facts).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT SUM(failure_count),SUM(total_failure_count) FROM ('+fs()+')')==[(120,240)]
    selected_metric='failure_percentage'
    assert execute('SELECT '+expr(failure,'metric_toggle')+' FROM ('+fs()+') q')==[(50,)]
    selected_metric='failure_count'
    assert execute('SELECT '+expr(failure,'metric_toggle')+' FROM ('+fs()+') q')==[(120,)]
    assert execute('SELECT '+expr(failure,'calc_failure_reason')+', '+expr(failure,'metric_toggle')+' FROM ('+fs()+') q GROUP BY 1 ORDER BY 1')==[('UNKNOWN',80),('reason',40)]
    assert execute('SELECT COUNT(*),MIN(analysis_date),SUM(failure_count) FROM ('+fs('Weekly')+')')[0]==(2,__import__('datetime').date(2026,9,28),120)
    assert execute('SELECT COUNT(*) FROM ('+fs(conditions={'fuel_type':"{value} = 'GAS'"})+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+fs(conditions={'cluster_id':"{value} = 'B'"})+')')==[(0,)]
    # Preserve SUM of repeated source denominators, including zero safeguards.
    assert execute('SELECT '+expr(failure,'calc_failure_perc')+' FROM (VALUES (0,0)) q(failure_count,total_failure_count)')==[(None,)]
    # Quality source counts bad checks, not every report, and filters reporting_date.
    raw=views['bre_na_her_quality']['derived_table']['sql']
    checks=list(dict.fromkeys(re.findall(r"WHEN (\w+) = 'bad'",raw)))
    epoch="date_diff('day',DATE '1970-01-01',DATE '2026-09-27')"
    qfacts="(SELECT 10037 AS pilot_id, "+epoch+" AS epoch_day, "+', '.join("'bad' AS "+n for n in checks)+')'
    def qs(conditions=None):return source('bre_na_her_quality',conditions=conditions).replace('delta_prodna.public.her_automation_query_results',qfacts).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT COUNT(*),SUM(overall_report_count),SUM(nbi_non_null_insight_cnt) FROM ('+qs()+')')==[(1,1,1)]
    assert execute('SELECT COUNT(*) FROM ('+qs({'date_range':"{value} = DATE '2026-09-27'"})+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+qs({'date_range':"{value} = DATE '2026-09-28'"})+')')==[(1,)]
    # PSEG is selected latest per quarter before filtering; revoked-only rows survive FULL JOIN.
    count_cols=['total_eligible_users','total_generated_notification_id','total_scheduled_notification_id','total_queued_notification_id','total_printed_notification_id','total_mailed_notification_id','total_failed_notification_id','total_swept_notification_id']
    tracker=[]
    for analysis,report,eligible,generated in [('2026-09-26','2026-09-27',100,70),('2026-09-28','2026-09-29',120,90),('2026-10-01','2026-10-02',130,100)]:
        tracker.append("SELECT '10037' AS pilot_id, 'A' AS cluster_id, 'ELECTRIC' AS measurement_type, DATE '2026-01-01' AS schedule_start, DATE '2026-12-31' AS schedule_end, DATE '"+analysis+"' AS analysis_date, DATE '"+report+"' AS reporting_date, TIMESTAMP '2026-10-02 00:00:00' AS last_updated_timestamp, "+', '.join(str(eligible if col=='total_eligible_users' else generated if col=='total_generated_notification_id' else 0)+' AS '+col for col in count_cols))
    tf='('+' UNION ALL '.join(tracker)+')'
    revoked=[]
    for cluster,count in [('A',5),('B',3)]:
        revoked.append("SELECT 10037 AS pilot_id, '"+cluster+"' AS cluster_id, 'ELECTRIC' AS fuel_type, DATE '2026-01-01' AS schedule_start, DATE '2026-12-31' AS schedule_end, DATE '2026-09-29' AS analysis_date, DATE '2026-09-30' AS reporting_date, TIMESTAMP '2026-09-30 00:00:00' AS last_updated_timestamp, "+str(count)+' AS total_revoked_users')
    rv='('+' UNION ALL '.join(revoked)+')'
    def ss(conditions=None):return source('bre_na_her_schedules',conditions=conditions).replace('delta_prodna.reporting.sre_daily_her_tracker',tf).replace('delta_prodna.reporting.sre_her_revoked_users',rv).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT COUNT(*),SUM(total_eligible_users),SUM(total_generated_notification_id),SUM(total_revoked_notification_id) FROM ('+ss()+')')==[(3,250,190,8)]
    assert execute("SELECT schedule_start,schedule_end,total_generated_notification_id FROM ("+ss()+") WHERE cluster_id='A' ORDER BY schedule_start")==[(__import__('datetime').date(2026,7,1),__import__('datetime').date(2026,9,30),90),(__import__('datetime').date(2026,10,1),__import__('datetime').date(2026,12,31),100)]
    assert execute("SELECT total_eligible_users,total_revoked_notification_id FROM ("+ss()+") WHERE cluster_id='B'")==[(0,3)]
    assert execute('SELECT COUNT(*) FROM ('+ss({'date_range':"{value} = DATE '2026-09-26'"})+')')==[(0,)]
    # Actual source FULL JOIN and weekly/monthly MAX eligibility versus SUM generation.
    generation='bre_na_her_generation'
    eligible=[];generated=[]
    for date,expected,actual,gen in [('2026-09-28',100,80,40),('2026-09-29',150,100,60)]:
        key="10037 AS pilot_id, 'A' AS cluster_id, DATE '"+date+"' AS analysis_date, DATE '"+date+"' AS reporting_date, DATE '2026-01-01' AS schedule_start, DATE '2026-12-31' AS schedule_end, 'ELECTRIC' AS measurement_type"
        eligible.append('SELECT '+key+', '+str(expected)+" AS eligible_users, TIMESTAMP '2026-09-30 00:00:00' AS last_updated_timestamp")
        generated.append('SELECT '+key+', '+str(actual)+' AS total_cluster_users, 0 AS total_missing_notification, '+str(gen)+' AS total_generated_notification')
    # An eligibility-only row remains; it must not disappear in a changed INNER JOIN.
    eligible.append("SELECT 10037, 'B', DATE '2026-09-28', DATE '2026-09-28', DATE '2026-01-01', DATE '2026-12-31', 'ELECTRIC', 50, TIMESTAMP '2026-09-30 00:00:00'")
    ef='('+' UNION ALL '.join(eligible)+')';gf='('+' UNION ALL '.join(generated)+')'
    def gs(period='Daily',conditions=None):return source(generation,period,conditions=conditions).replace('delta_prodna.reporting.sre_cluster_eligible_users',ef).replace('delta_prodna.reporting.sre_her_schedule_tracker',gf).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT COUNT(*),SUM(expected_eligible_users),SUM(actual_eligible_users),SUM(actual_generation_count) FROM ('+gs()+')')==[(3,300,180,100)]
    assert abs(execute('SELECT '+expr(generation,'success_pct')+' FROM ('+gs()+') q')[0][0]-100*100/180)<1e-10
    assert execute('SELECT SUM(expected_eligible_users),SUM(actual_eligible_users),SUM(actual_generation_count) FROM ('+gs('Weekly')+')')==[(200,100,100)]
    assert execute('SELECT '+expr(generation,'success_pct')+' FROM ('+gs('Weekly')+') q')==[(100,)]
    assert execute('SELECT COUNT(*) FROM ('+gs('Monthly')+')')==[(0,)]
    assert execute('SELECT SUM(expected_eligible_users),SUM(actual_eligible_users),SUM(actual_generation_count) FROM ('+gs('Monthly',{'date_range':'TRUE'})+')')==[(200,100,100)]
    assert execute('SELECT '+expr(generation,'success_pct')+' FROM (VALUES (1,3)) q(actual_generation_count,actual_eligible_users)')[0][0]==100/3
    assert execute('SELECT '+expr(generation,'success_pct')+' FROM (VALUES (0,0)) q(actual_generation_count,actual_eligible_users)')==[(None,)]
    # Real queue source formulas must reject other modules and environments.
    rows=[]
    for module,env,received,empty,delayed in [('HER','prod',100,100,7),('Ingestion','prod',999,999,999),('HER','other',999,999,999)]:
        for metric,value in [('NumberOfMessagesReceived',received),('NumberOfEmptyReceives',empty),('ApproximateNumberOfMessagesDelayed',delayed)]:
            rows.append("(TIMESTAMP '2026-09-29 12:00:00 UTC', '"+module+"', '"+env+"', 'queue', 'main', '"+metric+"', CAST("+str(value)+" AS DOUBLE))")
    facts='(VALUES '+','.join(rows)+') facts(analysis_date,module_name,environment,queue_name,queue_type,metric_name,metric_value)'
    def queue_source(grain):
        return source('bre_na_her_queue_'+grain,conditions={'environment':"{value} = 'prod'"}).replace('delta_prodna.reporting.sre_queue_metrics_fact',facts).replace('current_timestamp',"TIMESTAMP '2026-10-04 00:00:00 UTC'")
    assert execute('SELECT SUM(total_messages_received), SUM(delayed_messages) FROM ('+queue_source('hourly')+')')==[(100,7)]
    assert execute('SELECT AVG(empty_receives_ratio) FROM ('+queue_source('daily')+')')==[(50,)]
    for grain in ['hourly','daily','health']:
        assert "module_name = 'HER'" in source('bre_na_her_queue_'+grain)
    report=dict(result='PASS',tiles=17,dashboards={d['dashboard']:len(d['elements']) for d in dashboards},rendered_query_variants=len(cases),semantic_fixtures=25,source_contract_checks=4,native_looker_validation='NOT RUN: no connected Looker tools',queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-her-validation'));run(p.parse_args().output_dir)
