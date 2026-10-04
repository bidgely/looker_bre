# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate the NA TOU dashboard locally; export Trino planning SQL.

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
            if n=='tou_mode':return f"{v} = 'COMPLETE_BILLING_CYCLE'"
            if n=='delay_in_days':return f"{v} = 1"
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
    for suffix,count in [('tou',6)]:
        ident='bre_na_tou';path='/dashboards/'+ident+'.dashboard.lookml'
        assert path in model['includes'];d=yaml.safe_load((ROOT/path.lstrip('/')).read_text())[0]
        assert d['dashboard']==ident and len(d['elements'])==count
        controls={f['name'] for f in d['filters']};used=set();rectangles=[]
        for t in d['elements']:
            assert t['model']=='bre_na';used.update(t['listen']);assert set(t['listen'])<=controls
            a=(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']);assert 0<=a[0]<a[2]<=24
            assert not any(max(a[0],b[0])<min(a[2],b[2]) and max(a[1],b[1])<min(a[3],b[3]) for b in rectangles);rectangles.append(a)
            if t['name']=='na_4a_t01':
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
                    elif n=='tou_mode':where.append('('+expr(view,n,period,comparison)+") = 'COMPLETE_BILLING_CYCLE'")
                    elif n=='delay_in_days':where.append('('+expr(view,n,period,comparison)+') = 1')
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
    view='bre_na_tou'
    fixture="""(VALUES
      (DATE '2026-09-26',20,100),
      (DATE '2026-09-27',80,1000),
      (DATE '2026-09-28',NULL,50),
      (DATE '2026-09-29',0,0),
      (DATE '2026-09-19',5,10),
      (DATE '2026-09-20',15,30)
    ) q(analysis_date,successful_tou_eligible_invoices,total_tou_eligible_invoices)"""
    def calc(n,rows=fixture,where=''):return execute('SELECT '+expr(view,n,comparison=True)+' FROM '+rows+where)[0][0]
    selected=' WHERE '+expr(view,'is_selected_period',comparison=True)
    assert abs(calc('successful_invoices_selected_average')-100/3)<1e-10
    assert calc('successful_invoices_selected_median')==20
    assert calc('successful_invoices_previous_median')==10
    assert abs(calc('successful_invoices_average_change')-7/3)<1e-10
    assert calc('successful_invoices_median_change')==1
    assert calc('successful_invoices_selected_median',fixture.replace('80,1000','NULL,1000'))==10
    assert calc('successful_invoices_average_change',fixture.replace('5,10','0,10').replace('15,30','0,30')) is None
    assert calc('tou_success_pct_average',where=selected)==14
    assert calc('tou_failure_pct_average',where=selected)==86
    assert abs(calc('tou_success_pct_average',"(VALUES (1,3)) q(successful_tou_eligible_invoices,total_tou_eligible_invoices)")-100/3)<1e-10
    assert calc('tou_failure_pct_average',"(VALUES (0,0)) q(successful_tou_eligible_invoices,total_tou_eligible_invoices)") is None
    assert calc('successful_tou_eligible_invoices_sum',where=selected)==100
    assert calc('total_tou_eligible_invoices_sum',where=selected)==1150
    assert str(execute('SELECT '+expr(view,'period_date',period='Weekly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-20'
    assert str(execute('SELECT '+expr(view,'period_date',period='Monthly')+" FROM (VALUES (DATE '2026-09-26')) q(analysis_date)")[0][0])[:10]=='2026-09-01'
    # Use the actual source SQL to prove the report fractions do not use its alternative denominator.
    rows=[]
    for mode,delay,pilot in [('COMPLETE_BILLING_CYCLE',1,10037),('OTHER_MODE',1,10037),('COMPLETE_BILLING_CYCLE',2,10037),('COMPLETE_BILLING_CYCLE',1,10038)]:
        rows.append("("+str(pilot)+",DATE '2026-09-26',DATE '2026-09-27',"+str(delay)+",'test','"+mode+"',100,50,50,TIMESTAMP '2026-09-27 01:00:00','SCHEDULED',50)")
    facts='(VALUES '+','.join(rows)+') facts(pilot_id,analysis_date,reporting_date,delay_in_days,trigger_name,tou_mode,total_tou_eligible_invoices,actual_total_tou_invoices,successful_tou_eligible_invoices,last_updated_timestamp,trigger_flag,total_disagg_tou_invoices)'
    pilots="(VALUES (10037,'PSEG'),(10038,'OTHER')) pilots(pilot_id,pilot_name)"
    src=source(view).replace('delta_prodna.reporting.sre_tou_appliance_batch_aggregation',facts).replace('delta_prodna.reporting.pilot_consolidated_product_type_events',pilots)
    assert execute('SELECT COUNT(*), MAX(successful_tou_eligible_invoices_pct) FROM ('+src+')')==[(1,100)]
    assert execute('SELECT '+expr(view,'tou_success_pct_average')+', '+expr(view,'tou_failure_pct_average')+' FROM ('+src+') q')==[(50,50)]
    filters={f['name']:f for f in dashboards[0]['filters']}
    assert filters['TOU Mode']['default_value']=='COMPLETE_BILLING_CYCLE' and filters['Delay (Days)']['default_value']=='1'
    assert 'TOU Mode' not in dashboards[0]['elements'][0]['listen']
    report=dict(result='PASS',tiles=6,rendered_query_variants=len(cases),semantic_fixtures=17,native_looker_validation='NOT RUN: no connected Looker tools',queries=cases)
    (output/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='queries'},indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output-dir',type=Path,default=Path('/private/tmp/bre-na-tou-validation'));run(p.parse_args().output_dir)
