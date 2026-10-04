# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate NA Ingestion references, rendered Trino SQL and semantic fixtures.

Run with uv run. Local rendering is a focused simulator, not Looker's compiler.
Exports planning queries for optional EXPLAIN (TYPE VALIDATE) on Starburst.
"""
import argparse
import copy
import json
from pathlib import Path
import re
import subprocess
import sys
sys.dont_write_bytecode = True
import duckdb
import lkml
from liquid import Environment, StrictUndefined
import sqlglot
from sqlglot import exp
import yaml

ROOT = Path(__file__).resolve().parents[1]
REF = re.compile(r'\$\{([a-z_][a-z0-9_]*)(?:::(date|datetime|string))?\}')
TABLE = re.compile(r'\$\{([a-z_]+)\.SQL_TABLE_NAME\}')
ENV = Environment(undefined=StrictUndefined)
START, END = '2026-09-26', '2026-10-03'
GROUPS = ('dimensions', 'measures', 'parameters', 'filters', 'dimension_groups', 'sets')


def run(output):
    output.mkdir(parents=True, exist_ok=True)
    model = lkml.load((ROOT/'models/bre_na.model.lkml').open())
    assert model['connection'] == 'starburst_prod_na'
    views, loaded = {}, set()
    def load(path):
        if path in loaded: return
        loaded.add(path)
        data = lkml.load(path.open())
        for v in data.get('views', []):
            assert v['name'] not in views, v['name']
            views[v['name']] = v
        for inc in data.get('includes', []):
            assert '*' not in inc
            target = ROOT/inc.lstrip('/')
            assert target.exists(), target
            if target.suffix == '.lkml': load(target)
    load(ROOT/'models/bre_na.model.lkml')
    resolved = {}
    def resolve(name):
        if name in resolved: return resolved[name]
        merged = {}
        for group in views[name].get('extends__all', []):
            for parent in group:
                for kind, values in resolve(parent).items():
                    if kind in GROUPS: merged.setdefault(kind, {}).update(copy.deepcopy(values))
        for kind in GROUPS:
            for f in views[name].get(kind, []):
                merged.setdefault(kind, {}).setdefault(f['name'], {}).update(f)
        resolved[name] = merged
        return merged
    explores = {e['name']: e for e in model['explores']}
    def view_for(explore):
        e=explores[explore]
        return e.get('from', e.get('view_name', explore))
    def fields_for(view):
        fields={}
        for kind, values in resolve(view).items():
            if kind == 'sets': continue
            for name, f in values.items():
                if kind == 'dimension_groups':
                    for frame in f['timeframes']:
                        sql=f['sql']
                        if frame=='date': sql=f'CAST({sql} AS DATE)'
                        if frame=='hour': sql=f"date_trunc('hour', {sql})"
                        fields[name+'_'+frame]=dict(f, sql=sql,type='date' if frame=='date' else 'date_time',kind='dimensions')
                else: fields[name]=f | {'kind':kind}
        return fields
    for name, v in views.items():
        f=fields_for(name)
        assert any(x.get('primary_key')=='yes' for x in f.values()), name
        assert set(v.get('derived_table',{})) <= {'sql'}, name
        if name.startswith('bre_na_') or name=='bre_dashboard_na':
            for kind in ('dimensions','measures','parameters','filters','dimension_groups'):
                for x in v.get(kind,[]):
                    assert f[x['name'] if kind!='dimension_groups' else x['name']+'_raw'].get('description'), (name,x['name'])
        for x in v.get('measures',[]): assert '${TABLE}' not in x.get('sql',''), (name,x['name'])

    def render(raw, family='ingestionaudit', period='Daily', metric='percentage', region='na'):
        raw=re.sub(r'\{%\s*date_start\s+[\w.]+\s*%\}',f"DATE '{START}'",raw)
        raw=re.sub(r'\{%\s*date_end\s+[\w.]+\s*%\}',f"DATE '{END}'",raw)
        def condition(m):
            field=m[1].split('.')[-1]; value=m[2].strip()
            if field in ['date_range','ingestion_comparison_date_range']:
                return f"({value} >= DATE '{START}' AND {value} < DATE '{END}')"
            if field in ['pilot_id','selected_pilot_id']: return f"{value} = '10037'"
            if field in ['pilot_name','selected_pilot_name']: return f"{value} = 'PSEG'"
            return 'TRUE'
        raw=re.sub(r'\{%\s*condition\s+([\w.]+)\s*%\}(.*?)\{%\s*endcondition\s*%\}',condition,raw,flags=re.S)
        values=dict(source_family=family,period=period,failure_scope='All',na_failure_metric=metric)
        context={k:{'_parameter_value':"'"+v+"'"} for k,v in values.items()}
        context['bre_dashboard']=dict(context);context['_model']={'_name':'bre_'+region}
        result=ENV.from_string(raw).render(**context)
        assert '{%' not in result
        return result
    def expand(name, family='ingestionaudit', period='Daily', region='na'):
        raw=render(views[name]['derived_table']['sql'],family,period,region=region)
        return TABLE.sub(lambda m:'(\n'+expand(m[1],family,period,region)+'\n)',raw)
    dashboards=[]
    for suffix, count in [('governance', 8), ('queue_metrics', 10)]:
        identifier='bre_na_ingestion_'+suffix
        path='/dashboards/'+identifier+'.dashboard.lookml'
        assert path in model['includes']
        dashboard=yaml.safe_load((ROOT/path.lstrip('/')).read_text())[0]
        assert dashboard['dashboard']==identifier
        assert len(dashboard['elements'])==count
        controls={f['name'] for f in dashboard['filters']}
        used={name for tile in dashboard['elements'] for name in tile['listen']}
        assert used==controls, (identifier, used, controls)
        assert min(t['row'] for t in dashboard['elements'])==0
        dashboards.append(dashboard)
    elements=[t for dashboard in dashboards for t in dashboard['elements']]
    assert len({t['name'] for t in elements})==18
    # Native solid-gauge overrides retain live query data and visible center values.
    gauges={t['name']:t for t in elements if 'advanced_vis_config' in t}
    assert set(gauges)=={'daily_users','daily_success'}
    for name,tile in gauges.items():
        config=json.loads(tile['advanced_vis_config'])
        assert tile['type']=='looker_column' and tile['limit']==1
        assert tile['fields'][0]=='bre_dashboard.na_gauge_label' and len(tile['fields'])==2
        assert config['chart']['type']=='solidgauge'
        assert config['series'][0]['type']=='solidgauge' and 'data' not in config['series'][0]
        assert config['pane']['startAngle']==-90 and config['pane']['endAngle']==90
        axis=config['yAxis'][0]
        assert axis['min']==0
        assert axis['max']==(100 if name=='daily_success' else 20)
        labels=config['plotOptions']['solidgauge']['dataLabels']
        assert labels['enabled'] and '{point.y:' in labels['format']
        assert labels['nullFormat']=='No data'
    controls={f['name']:f for dashboard in dashboards for f in dashboard['filters']}
    assert controls['Pilot ID']['default_value']=='10037'
    assert controls['Pilot Name']['default_value']=='PSEG'
    selector=fields_for('bre_dashboard_na')['na_failure_metric']
    allowed={v['value'] for v in selector['allowed_values']}
    assert all('_' not in v for v in allowed)
    assert controls['Failure Metric']['default_value']==selector['default_value']
    assert selector['default_value'] in allowed
    def check_ref(ref, explore):
        alias, field=ref.split('.',1)
        assert alias in (explore,view_for(explore)), ref
        assert field in fields_for(view_for(explore)),ref
        if explores[explore].get('fields'):
            allowed=set()
            for member in explores[explore]['fields']:
                fieldname=member.split('.')[1]
                if fieldname.endswith('*'):
                    allowed.update(resolve(view_for(explore))['sets'][fieldname[:-1]]['fields'])
                else:
                    allowed.add(fieldname)
            assert field in allowed,ref
    for c in controls.values():
        assert c['model']=='bre_na'
        check_ref(c['field'], c['explore'])
    cases=[]
    compiled_fields={}
    for tile in elements:
        explore=tile['explore']; view=view_for(explore); fields=fields_for(view)
        refs=tile['fields']+list(tile['filters'])+list(tile['listen'].values())+tile.get('pivots',[])
        assert tile['model']=='bre_na'
        for ref in refs: check_ref(ref,explore)
        assert set(tile['listen']) <= set(controls)
        family=tile['filters'].get('bre_dashboard.source_family','ingestionaudit')
        if tile['name']=='ingestion_failure_reasons': assert tile['filters']['bre_dashboard.source_rank']=='<=3'
        if explore.startswith('bre_na_ingestion_queue_'):
            assert tile['filters'][explore+'.module_name']=='Ingestion'
            assert 'Pilot ID' not in tile['listen'] and 'Time Period' not in tile['listen']
        periods=['Daily','Weekly','Monthly'] if explore in ['bre_dashboard','bre_na_ingestion_rate_comparison'] else ['Daily']
        metrics=['percentage','count'] if tile['name']=='ingestion_failure_reasons' else ['percentage']
        for period in periods:
            for metric in metrics:
                cache={}
                def field_sql(name):
                    if name in cache: return cache[name]
                    f=fields[name]; raw=render(f['sql'],family,period,metric).replace('${TABLE}','q')
                    def reference(m):
                        value=field_sql(m[1])
                        if m[2]: return f"CAST(({value}) AS "+{'date':'DATE','datetime':'TIMESTAMP','string':'VARCHAR'}[m[2]]+')'
                        if fields[m[1]].get('type')=='date': return f"date_format(({value}), '%Y-%m-%d')"
                        return '('+value+')'
                    raw=REF.sub(reference,raw)
                    if f['kind']=='measures' and f.get('type') in ['sum','average','max','min']:
                        raw={'sum':'SUM','average':'AVG','max':'MAX','min':'MIN'}[f['type']]+'('+raw+')'
                    cache[name]=raw
                    return raw
                selects=[];group=[]
                for ref in tile['fields']:
                    name=ref.split('.')[1]; selects.append(field_sql(name)+' AS '+name)
                    if fields[name]['kind']=='dimensions': group.append(str(len(selects)))
                where=[]
                for ref,value in tile['filters'].items():
                    name=ref.split('.')[1]
                    if fields[name]['kind'] in ['parameters','filters']:continue
                    expression=field_sql(name)
                    if value=='7 days ago for 7 days': where.append(f"({expression}) >= DATE '{START}' AND ({expression}) < DATE '{END}'")
                    elif value=='Yes': where.append('('+expression+')')
                    elif value.startswith('<='): where.append('('+expression+') '+value)
                    else: where.append('('+expression+") = '"+value.replace("'","''")+"'")
                source=expand(view,family,period)
                query='SELECT\n'+',\n'.join(selects)+'\nFROM (\n'+source+'\n) q'
                if where: query+='\nWHERE '+' AND '.join(where)
                if group: query+='\nGROUP BY '+', '.join(group)
                assert '${' not in query
                tree=sqlglot.parse_one(query,read='trino')
                assert {t.catalog for t in tree.find_all(exp.Table) if t.catalog} <= {'delta_prodna'}
                path=output/(tile['name']+'_'+period.lower()+'_'+metric+'.sql')
                path.write_text('EXPLAIN (TYPE VALIDATE)\n'+query+'\n')
                cases.append({'tile':tile['name'],'period':period,'metric':metric,'path':str(path)})
                compiled_fields[(tile['name'],period,metric)]=cache
    # Source SQL for each distinct dependency can be checked without executing data scans.
    for view in ['bre_active_users','bre_ingestion_audit','bre_ingestion_failures','bre_post_ingestion','bre_na_ingestion_queue_hourly','bre_na_ingestion_queue_daily','bre_na_ingestion_queue_health','bre_na_rate_plan_tracker','bre_na_ingestion_rate_comparison']:
        (output/(view+'_source.sql')).write_text('EXPLAIN (TYPE VALIDATE)\n'+expand(view)+'\n')
    # Existing CA/EU source SQL must render identically after adding the NA branch.
    for name in ['bre_pilots','bre_active_users','bre_ingestion_audit','bre_ingestion_failures','bre_post_ingestion']:
        path='views/bre/'+name+'.view.lkml'
        old=lkml.load(subprocess.check_output(['git','show','HEAD:'+path],cwd=ROOT,text=True))['views'][0]['derived_table']['sql']
        for region in ['ca','eu']:
            assert render(old,region=region)==render(views[name]['derived_table']['sql'],region=region), (name,region)
    # Test actual NA expressions against non-null zeros and zero/null source buckets.
    def execute(sql):
        return duckdb.sql(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    post_cache=compiled_fields[('post_ingestion_quality','Daily','percentage')]
    assert execute('SELECT '+post_cache['na_raw_delay_0_3_count']+' FROM (VALUES (0), (8), (NULL)) q(post_ingestion_user_raw_with_delay_0_3)')==[(2,)]
    users=compiled_fields[('daily_users','Daily','percentage')]['na_users_millions_sum']
    fixture="""FROM (VALUES ('CONSUMPTION',1000000,1000000,1000000,1000000,0,0,0,0),
      ('CONSUMPTION',0,1000000,1000000,1000000,0,0,0,0),
      ('BILLING',0,0,0,0,1000000,1000000,1000000,1000000),
      ('OPOWER',0,0,0,0,1000000,1000000,1000000,1000000))
      q(ingestion_type,post_ingestion_user_raw_with_delay_0_3,post_ingestion_user_raw_with_delay_4_7,
        post_ingestion_user_raw_with_delay_8_15,post_ingestion_user_raw_with_delay_gt_15,
        post_ingestion_user_invoice_with_delay_0_7,post_ingestion_user_invoice_with_delay_7_15,
        post_ingestion_user_invoice_with_delay_15_30,post_ingestion_user_invoice_with_delay_gt_30)"""
    assert execute('SELECT '+users+' '+fixture)==[(8.0,)]
    for metric,expected in [('percentage',20.0),('count',8)]:
        raw=compiled_fields[('ingestion_failure_reasons','Daily',metric)]['na_failure_metric_value']
        assert execute('SELECT '+raw+' FROM (VALUES (10,2),(30,6)) q(ingestion_failures_failure_percentage,ingestion_failures_failed_record_count)')==[(expected,)]
    # Exercise original queue aggregation math, including ELSE 0 and zero denominators.
    queue_rows=[]
    for queue, received, deleted, backlog, latency in [('a',100,50,100,3600),('b',10,10,0,0),('c',0,0,0,0)]:
        for metric_name, value in [('NumberOfMessagesReceived',received),('NumberOfMessagesDeleted',deleted),('ApproximateNumberOfMessagesVisible',backlog),('ApproximateAgeOfOldestMessage',latency)]:
            queue_rows.append(f"(TIMESTAMP '2026-10-01 12:00:00 UTC', 'Ingestion', 'NA', '{queue}', 'STANDARD', '{metric_name}', CAST({value} AS DOUBLE))")
    facts='(VALUES '+','.join(queue_rows)+') AS facts(analysis_date,module_name,environment,queue_name,queue_type,metric_name,metric_value)'
    queue_sql=expand('bre_na_ingestion_queue_hourly').replace('delta_prodna.reporting.sre_queue_metrics_fact',facts).replace('current_timestamp',"TIMESTAMP '2026-10-03 00:00:00 UTC'")
    assert execute('SELECT AVG(success_rate), MAX(avg_queue_backlog), MAX(max_latency / 86400.0) FROM ('+queue_sql+')')==[(75.0,25.0,1/24)]
    health_sql=expand('bre_na_ingestion_queue_health').replace('delta_prodna.reporting.sre_queue_metrics_fact',facts)
    assert execute('SELECT queue_name, health_score FROM ('+health_sql+') ORDER BY queue_name')==[('a',54.0),('b',100.0),('c',None)]
    # Exact timestamp matching, unmatched left rows, duplicate matches and post-join plan filtering.
    blend_name='bre_na_ingestion_rate_comparison'
    tile=next(t for t in elements if t['name']=='daily_ingestion_statistics')
    assert tile['explore']==blend_name
    assert tile['listen']['Rate Plan ID']==blend_name+'.current_plan_number'
    assert len(tile['fields'])==8 and len(tile['series_types'])==2
    assert all('Rate Plan ID' not in t['listen'] for t in elements if t is not tile)
    raw=render(views[blend_name]['derived_table']['sql'])
    audit_fixture="""SELECT * FROM (VALUES
      ('10037','PSEG',DATE '2026-09-28','BILLING',TIMESTAMP '2026-09-29 01:00:00.123',10,20,100,90),
      ('10037','PSEG',DATE '2026-09-29','BILLING',TIMESTAMP '2026-09-30 01:00:00.124',15,30,150,80),
      ('10037','PSEG',DATE '2026-09-30','CONSUMPTION',CAST(NULL AS TIMESTAMP),7,14,70,70),
      ('10038','OTHER',DATE '2026-09-28','BILLING',TIMESTAMP '2026-09-29 01:00:00.123',999,999,999,99)
      ) a(pilot_id,pilot_name,analysis_date,ingestion_type,last_updated_timestamp,
        total_files_processed,total_chunks_processed,total_records_count,success_percentage)"""
    rc_fixture="""SELECT * FROM (VALUES
      ('10037',TIMESTAMP '2026-09-29 01:00:00.123','1',40,30,25),
      ('10037',TIMESTAMP '2026-09-29 01:00:00.123','2',60,40,35),
      ('10037',TIMESTAMP '2026-09-30 01:00:00.125','1',999,999,99),
      ('10037',TIMESTAMP '2026-09-30 04:00:00.124','1',999,999,99),
      ('10037',CAST(NULL AS TIMESTAMP),'1',999,999,99),
      ('10038',TIMESTAMP '2026-09-29 01:00:00.123','1',999,999,99)
      ) r(pilot_id,last_updated_timestamp,current_plan_number,expected_total_rate_plan_count,
        successful_total_rate_plan_count,missing_total_rate_plan_pct)"""
    fixture_sql=raw.replace('${bre_ingestion_audit.SQL_TABLE_NAME}','('+audit_fixture+')').replace('${bre_na_rate_plan_tracker.SQL_TABLE_NAME}','('+rc_fixture+')')
    assert execute('SELECT COUNT(*), SUM(total_files_processed), SUM(expected_total_rate_plan_count), AVG(missing_total_rate_plan_pct) FROM ('+fixture_sql+')')==[(4,42,100,30.0)]
    assert execute("SELECT COUNT(*), SUM(total_files_processed) FROM ("+fixture_sql+") WHERE current_plan_number IS NULL")==[(2,22)]
    assert execute("SELECT SUM(total_files_processed), SUM(expected_total_rate_plan_count) FROM ("+fixture_sql+") WHERE current_plan_number = '1'")==[(10,40)]
    assert execute("SELECT COUNT(*) FROM ("+fixture_sql+") WHERE current_plan_number = '999'")==[(0,)]
    for dashboard in dashboards:
        rectangles=[(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']) for t in dashboard['elements']]
        for i,a in enumerate(rectangles):
            assert 0<=a[0]<a[2]<=24
            for b in rectangles[i+1:]: assert not (max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]))
    report=dict(result='PASS',tiles=18,dashboards={d['dashboard']:len(d['elements']) for d in dashboards},rendered_tile_queries=len(cases),regional_source_regressions=10,
      semantic_fixtures=10,gauge_configurations=2,lookml_validator='NOT RUN: Looker connection unavailable',
      incomplete=['NA-1A-T06 original-report input grain and result parity', 'NA-1B-T03 chart success-rate aggregation confirmation'],queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-ingestion-validation'))
    run(parser.parse_args().output_dir)
