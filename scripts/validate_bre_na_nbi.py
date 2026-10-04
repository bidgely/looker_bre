# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate the NA NBI dashboard locally; export Trino planning SQL.

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
    # SQL_TABLE_NAME embeds SQL in another Explore. The renderer must not mask
    # missing parameter scope by supplying a universal period variable.
    def assert_parameter_scope(view,available,seen=None):
        seen=set() if seen is None else seen
        if view in seen:return
        seen.add(view)
        sql=views[view]['derived_table']['sql']
        names=set(re.findall(r'(?<![\w.])(\w+)\._parameter_value',sql))
        names.update(re.findall(r'{%\s*parameter\s+(\w+)\s*%}',sql))
        missing=names-available
        assert not missing,(view,'parameters unavailable in consuming Explore',sorted(missing))
        for target in TABLE.findall(sql):assert_parameter_scope(target,available,seen)
    for view in ['bre_na_nbi_emr_blend','bre_na_nbi_emr_scatter']:
        assert_parameter_scope(view,set(resolve(view).get('parameters',{})))
    # The common SQL must be independent of every consuming Explore's Liquid
    # scope: parameters AND templated filters. Only root consumer SQL has filters.
    def assert_filter_free_dependencies(view,seen=None):
        seen=set() if seen is None else seen
        if view in seen:return
        seen.add(view)
        for target in TABLE.findall(views[view]['derived_table']['sql']):
            sql=views[target]['derived_table']['sql']
            assert '{%' not in sql and '{{' not in sql,(target,'Liquid in shared SQL dependency')
            assert_filter_free_dependencies(target,seen)
    for view in ['bre_na_nbi_emr_blend','bre_na_nbi_emr_scatter']:
        assert_filter_free_dependencies(view)
        conditions=re.findall(r'{%\s*condition\s+([\w.]+)\s*%}',views[view]['derived_table']['sql'])
        assert set(conditions)=={view+'.'+name for name in ['date_range','pilot_id','pilot_name']}
    dashboards=[];cases=[]
    for suffix,count in [('nbi_governance',8),('nbi_emr_metrics',8)]:
        ident='bre_na_'+suffix;path='/dashboards/'+ident+'.dashboard.lookml'
        assert path in model['includes'];d=yaml.safe_load((ROOT/path.lstrip('/')).read_text())[0]
        assert d['dashboard']==ident and len(d['elements'])==count
        controls={f['name'] for f in d['filters']};used=set();rectangles=[]
        for t in d['elements']:
            assert t['model']=='bre_na';used.update(t['listen']);assert set(t['listen'])<=controls
            a=(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']);assert 0<=a[0]<a[2]<=24
            assert not any(max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]) for b in rectangles);rectangles.append(a)
            if t['name']=='na_8a_t01':
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
                    elif val=='-RUNNING':where.append('('+expr(view,n,period,comparison)+") != 'RUNNING'")
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
    view='bre_na_nbi_generation'
    fixture="""(VALUES
      (DATE '2026-09-27',20,1,3,20),
      (DATE '2026-09-28',80,30,10,40),
      (DATE '2026-09-29',NULL,NULL,NULL,NULL),
      (DATE '2026-09-30',0,0,0,0),
      (DATE '2026-09-20',5,0,0,0),
      (DATE '2026-09-21',15,0,0,0)
    ) q(analysis_date,total_users_successful,total_users_with_200_errorcode,total_users_with_300_errorcode,nbi_error_pct)"""
    def calc(n,rows=fixture,where=''):return execute('SELECT '+expr(view,n,comparison=True)+' FROM '+rows+where)[0][0]
    selected=' WHERE '+expr(view,'is_selected_period',comparison=True)
    assert abs(calc('successful_users_selected_average')-100/3)<1e-10
    assert calc('successful_users_selected_median')==20
    assert calc('successful_users_previous_median')==10
    assert abs(calc('successful_users_average_change')-7/3)<1e-10
    assert calc('successful_users_median_change')==1
    assert calc('successful_users_selected_median',fixture.replace('80,30','NULL,30'))==10
    assert calc('successful_users_average_change',fixture.replace(',5,0',',0,0').replace(',15,0',',0,0')) is None
    assert calc('nbi_200_error_pct_average',where=selected)==50
    assert calc('nbi_300_error_pct_average',where=selected)==50
    assert calc('nbi_200_error_pct_average',"(VALUES (0,0)) q(total_users_with_200_errorcode,total_users_with_300_errorcode)") is None
    assert abs(calc('nbi_200_error_pct_average',"(VALUES (1,2)) q(total_users_with_200_errorcode,total_users_with_300_errorcode)")-100/3)<1e-10
    assert calc('failure_count_sum',where=selected)==44
    assert calc('total_users_nbi_generated_average',where=selected)==48
    assert calc('nbi_success_pct_average',where=selected)==80
    assert str(execute('SELECT '+expr(view,'period_date',period='Weekly')+" FROM (VALUES (DATE '2026-09-27')) q(analysis_date)")[0][0])[:10]=='2026-09-27'
    assert str(execute('SELECT '+expr(view,'period_date',period='Monthly')+" FROM (VALUES (DATE '2026-09-27')) q(analysis_date)")[0][0])[:10]=='2026-09-01'
    emr='bre_na_nbi_emr'
    rows="""(VALUES ('10037','TERMINATED','ALL_STEPS_COMPLETED',100),
    ('10037','RUNNING',NULL,NULL),('10037','FAILED',NULL,20),
    ('10037','TERMINATED_WITH_ERRORS',NULL,30),('10037','CANCELLED',NULL,40),
    ('10037','INTERRUPTED',NULL,50),('10037','TERMINATED','USER_REQUEST',60),
    ('10037',NULL,NULL,80)) q(pilot_id,metric_value,reason_code,duration_seconds)"""
    def metric(n,r=rows):return execute('SELECT '+expr(emr,n)+' FROM '+r)[0][0]
    assert metric('record_count')==8
    assert abs(metric('success_rate_perc')-200/7)<1e-10
    assert abs(metric('failure_rate_perc')-400/7)<1e-10
    assert abs(metric('duration_seconds_average')-380/7)<1e-10
    assert metric('success_rate_perc',"(VALUES (NULL,NULL)) q(metric_value,reason_code)") is None
    assert metric('failure_rate_perc',"(VALUES (NULL)) q(metric_value)") is None
    assert execute('SELECT '+expr(emr,'cluster_id_count')+" FROM (VALUES ('a'),('a'),(NULL)) q(cluster_id)")==[(2,)]
    for seconds,expected in [(0,'00:00:00'),(3182.6666666667,'00:53:03'),(90061,'25:01:01'),(360000,'100:00:00'),(-61,'-00:01:01'),(None,None)]:
        raw='NULL' if seconds is None else str(seconds)
        assert execute('SELECT '+expr(emr,'duration_hh_mm_ss')+' FROM (VALUES ('+raw+')) q(duration_seconds)')==[(expected,)],(seconds,expected)
    # Source-contract checks: preserve every supplied source query, including pilot joins.
    specification=(ROOT/'data_studio_files/bre_na_model_base_data.md').read_text()
    for source_id,v in [(41,view),(20,'bre_na_nbi_generic_tags'),(32,emr),(18,'bre_na_nbi_failed_jobs')]:
        original=specification.split(f'### SRC-{source_id:02d}\n',1)[1].split('```sql\n',1)[1].split('```',1)[0]
        original='\n'.join(line for line in original.splitlines() if not line.lstrip().startswith('--'))
        original=re.sub(r'\breporting\.', 'delta_prodna.reporting.', original)
        actual=views[v]['derived_table']['sql'].split('FROM (',1)[1].rsplit(') q',1)[0]
        if source_id==32:actual=actual.split('FROM (',1)[1].rsplit(') source_rows',1)[0]
        actual=actual.replace('m.pilot_name, CAST(m.pilot_id','CAST(m.pilot_id',1)
        assert sqlglot.parse_one(actual,read='trino')==sqlglot.parse_one(original,read='trino'),source_id
    # Actual failed-stage source: missing stages and explicit failure statuses stay distinct.
    facts="""(VALUES
      ('10037',DATE '2026-09-27','A','TERMINATED'),('10037',DATE '2026-09-27','B','TERMINATED'),('10037',DATE '2026-09-27','C','RUNNING'),
      ('10037',DATE '2026-09-28','A','TERMINATED'),('10037',DATE '2026-09-28','B','TERMINATED'),
      ('10037',DATE '2026-09-29','A','FAILED'),('10037',DATE '2026-09-29','B','TERMINATED'),('10037',DATE '2026-09-29','C','TERMINATED')
    ) facts(pilot_id,analysis_date,cluster_type,metric_value)"""
    pilots="(VALUES (10037,'PSEG')) pilots(pilot_id,pilot_name)"
    actual=source('bre_na_nbi_failed_jobs').replace('delta_prodna.reporting.sre_emr_metrics_fact',facts).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    got=execute('SELECT stages_present,has_failed_stage,is_failed FROM ('+actual+') ORDER BY analysis_date')
    assert got==[(3,0,0),(2,0,1),(3,1,1)],got
    # UTC ISO strings are parsed to a DATE; the documented %Y%m parser cannot parse this source format.
    assert execute("SELECT CAST(substr('2026-09-27T23:59:00',1,10) AS DATE)")[0][0].isoformat()=='2026-09-27'
    for v in [emr,'bre_na_nbi_failed_jobs']:
        names=['record_count','success_rate_perc','failure_rate_perc','duration_seconds_average'] if v==emr else ['is_failed_sum','stages_present_sum']
        query='SELECT '+','.join(expr(v,n)+' AS '+n for n in names)+' FROM ('+source(v)+') q'
        path=output/(v+'_metrics.sql');path.write_text('EXPLAIN (TYPE VALIDATE)\n'+query+'\n')
        cases.append(dict(tile=v,period='source_metrics',path=str(path)))
    blend='bre_na_nbi_emr_blend';scatter='bre_na_nbi_emr_scatter'
    # Independently exercise the screenshot's source-box grouping, then its three-key joins.
    fixture_sources={
      'generation_source': """SELECT * FROM (VALUES
        (DATE '2026-09-27',10,2,3,'10037 : PSEG',10037,'PSEG'),
        (DATE '2026-09-27',10,2,3,'10037 : PSEG',10037,'PSEG'),
        (DATE '2026-09-28',90,1,2,'10037 : PSEG',10037,'PSEG')
      ) z(analysis_date,nbi_error_pct,total_users_with_200_errorcode,total_users_with_300_errorcode,pilot_id_name,pilot_id,pilot_name)""",
      'emr_source': """SELECT * FROM (VALUES
        (DATE '2026-09-27','a','NBI','stage 1','status','FAILED','10037 : PSEG','10037','PSEG',10),
        (DATE '2026-09-27','a','NBI','stage 1','status','FAILED','10037 : PSEG','10037','PSEG',30),
        (DATE '2026-09-27','b','NBI','stage 2','status','TERMINATED','10037 : PSEG','10037','PSEG',100),
        (DATE '2026-09-27','b','NBI','stage 2','other','TERMINATED','10037 : PSEG','10037','PSEG',200),
        (DATE '2026-09-29','c','NBI','stage 1','status','FAILED','10037 : PSEG','10037','PSEG',400)
      ) z(analysis_date,cluster_id,module_name,cluster_type,metric_name,metric_value,pilot_id_name,pilot_id,pilot_name,duration_seconds)""",
      'failed_jobs_source': """SELECT * FROM (VALUES
        (DATE '2026-09-27','10037',1,2,'10037 : PSEG','PSEG',1),
        (DATE '2026-09-27','10037',1,2,'10037 : PSEG','PSEG',1),
        (DATE '2026-09-29','10037',1,1,'10037 : PSEG','PSEG',1)
      ) z(analysis_date,pilot_id,has_failed_stage,stages_present,pilot_id_name,pilot_name,is_failed)"""}
    from sqlglot import exp
    def blend_fixture(v=blend,period='Daily',changes=None,conditions=None):
        tree=sqlglot.parse_one(source(v,period=period,conditions=conditions),read='trino')
        for cte in tree.find_all(exp.CTE):
            if cte.alias_or_name in fixture_sources:
                value=(changes or {}).get(cte.alias_or_name,fixture_sources[cte.alias_or_name])
                cte.set('this',sqlglot.parse_one(value,read='trino'))
        return tree.sql(dialect='trino')
    b=blend_fixture()
    # Duplicate generation dimensions collapse; duplicate EMR groups average; failed input sums.
    assert execute('SELECT COUNT(*),SUM(failure_count),SUM(is_failed),SUM(stages_present) FROM ('+b+')')==[(3,15,6,6)]
    assert execute('SELECT duration_seconds,failure_rate_perc,failed_job_cnt FROM ('+b+") WHERE cluster_id='a'")==[(20,100,0)]
    assert abs(execute('SELECT '+expr(blend,'duration_seconds_average')+' FROM ('+b+') q')[0][0]-320/3)<1e-10
    assert abs(execute('SELECT '+expr(blend,'failure_rate_perc_average')+' FROM ('+b+') q')[0][0]-100/3)<1e-10
    assert execute('SELECT '+expr(blend,'nbi_error_pct_average')+' FROM ('+b+') q')==[(10,)]
    assert execute('SELECT COUNT(DISTINCT analysis_date) FROM ('+b+')')==[(1,)]
    for input_name in ['emr_source','failed_jobs_source']:
        other=blend_fixture(changes={input_name:fixture_sources[input_name].replace('10037 : PSEG','10037 : DIFFERENT')})
        assert execute('SELECT COUNT(*) FROM ('+other+')')==[(0,)],input_name
    assert execute('SELECT COUNT(*) FROM ('+blend_fixture(conditions={'pilot_id':"{value} = '10038'"})+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+blend_fixture(conditions={'date_range':"{value} = DATE '2026-09-29'"})+')')==[(0,)]
    assert str(execute('SELECT DISTINCT '+expr(blend,'period_date',period='Weekly')+' FROM ('+blend_fixture(period='Weekly')+') q')[0][0])[:10]=='2026-09-27'
    assert str(execute('SELECT DISTINCT '+expr(blend,'period_date',period='Monthly')+' FROM ('+blend_fixture(period='Monthly')+') q')[0][0])[:10]=='2026-09-01'
    point=blend_fixture(scatter)
    assert execute('SELECT failed_jobs,total_runs,nbi_error_pct FROM ('+point+')')==[(6,6,10)]
    assert execute('SELECT COUNT(*) FROM ('+blend_fixture(scatter,conditions={'pilot_id':"{value} = '10038'"})+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+blend_fixture(scatter,conditions={'pilot_name':"{value} = 'OTHER'"})+')')==[(0,)]
    assert execute('SELECT COUNT(*) FROM ('+blend_fixture(scatter,conditions={'date_range':"{value} = DATE '2026-09-29'"})+')')==[(0,)]
    # Every input SQL copy remains identical to the independently source-contracted view.
    raw_tree=sqlglot.parse_one(views['bre_na_nbi_emr_blend_source']['derived_table']['sql'],read='trino')
    ctes={c.alias_or_name:c.this for c in raw_tree.find_all(exp.CTE)}
    for suffix in ['generation','emr','failed_jobs']:
        original=views['bre_na_nbi_'+suffix]['derived_table']['sql'].split('FROM (',1)[1].rsplit(') q',1)[0]
        assert ctes[suffix+'_source']==sqlglot.parse_one(original,read='trino'),suffix
    t7=next(t for t in dashboards[1]['elements'] if t['name']=='na_8b_t07')
    assert t7['hidden_fields']==[scatter+'.analysis_date'] and t7['size_by_field']==scatter+'.nbi_error_pct_value'
    assert not t7['plot_size_by_field'] and t7['fields'][1]==scatter+'.failed_jobs'
    report=dict(result='PASS',tiles=16,rendered_query_variants=len(cases),semantic_fixtures=47,source_contract_checks=7,liquid_scope_checks=6,native_looker_validation='NOT RUN: no connected Looker tools',queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-nbi-validation'));run(p.parse_args().output_dir)
