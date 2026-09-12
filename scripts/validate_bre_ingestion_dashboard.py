# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate dashboard wiring and Trino SQL locally using synthetic fixtures only.

No warehouse connection is opened. DuckDB executes SQLGlot-translated expressions
against literal VALUES fixtures; this does not replace Looker's native validator
or execution on the Trino connection.
"""
import sys
sys.dont_write_bytecode = True
import argparse
import datetime as dt
import json
from pathlib import Path
import re
import statistics

import duckdb
import lkml
import sqlglot
import yaml
import validate_bre_models as base

ROOT = base.ROOT
D = 'bre_dashboard.'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=Path('/private/tmp/bre-ingestion-dashboard-validation'))
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    views, paths, dimensions, measures, sets = base.parse_project()
    fields = dimensions | measures
    filters = {x['name'] for x in views['bre_dashboard_fields']['filters']}
    params = {x['name'] for x in views['bre_dashboard_fields']['parameters']}
    dashboard = yaml.safe_load((ROOT/'dashboards/bre_ca_ingestion.dashboard.lookml').read_text())[0]
    controls = {f['name']: f for f in dashboard['filters']}
    assert set(controls) == {'Time Period', 'Period', 'Pilot ID', 'Pilot Name', 'File Type'}
    assert controls['Time Period']['default_value'] == '7 days ago for 7 days'
    assert controls['File Type']['field'] == D+'ingestion_file_type'
    assert 'options' not in controls['File Type']['ui_config']
    assert controls['Pilot ID']['field'] != controls['Pilot Name']['field']
    tiles = {t['name']: t for t in dashboard['elements']}
    assert len(tiles) == 8
    assert tiles['post_ingestion_quality']['type'] == 'looker_line'
    assert len(tiles['post_ingestion_quality']['fields']) == 11
    assert tiles['ingestion_failure_reasons']['filters'][D+'source_rank'] == '<=20'
    assert tiles['ingestion_failure_reasons']['pivots'] == [D+'application_error_code']
    assert tiles['daily_ingestion_statistics']['series_types'] == {D+'ingestion_audit_success_percentage_average': 'line'}
    for tile in tiles.values():
        assert tile['model'] == 'bre_ca' and tile['explore'] == 'bre_dashboard'
        for ref in tile['fields'] + list(tile['filters']) + list(tile['listen'].values()) + tile.get('pivots', []):
            assert ref.startswith(D) and ref[len(D):] in fields.keys() | filters | params, ref
        assert tile['listen']['Pilot Name'] == D+'pilot_name'
        assert tile['listen']['Pilot ID'] == D+'pilot_id'
        if tile['name'] == 'active_uuid':
            assert set(tile['listen']) == {'Pilot ID', 'Pilot Name'}
        else:
            assert tile['listen']['File Type'] == D+'ingestion_file_type'
            if tile['name'].startswith('files_'):
                assert tile['listen']['Time Period'] == D+'ingestion_comparison_date_range'
                assert D+'analysis_date' not in tile['filters']
                assert tile['filters'][D+'ingestion_in_comparison_window'] == 'Yes'
            else:
                assert tile['listen']['Time Period'] == D+'analysis_date'
        if tile['name'] in {'daily_users', 'daily_success'}:
            assert tile['show_comparison'] is False
    rectangles = [(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']) for t in tiles.values()]
    for i,a in enumerate(rectangles):
        assert 0 <= a[0] < a[2] <= 24
        for b in rectangles[i+1:]:
            assert a[2] <= b[0] or b[2] <= a[0] or a[3] <= b[1] or b[3] <= a[1], (a,b)
    for env in ['ca','eu']:
        model = lkml.load((ROOT/f'models/bre_{env}.model.lkml').open())
        assert ('/dashboards/bre_ca_ingestion.dashboard.lookml' in model['includes']) == (env=='ca')
        available = {item for member in model['explores'][0]['fields'] for item in sets[member.split('.')[1][:-1]]}
        assert all(ref[len(D):] in available for t in tiles.values() for ref in t['fields']+list(t['listen'].values())+list(t['filters']))
    assert dimensions['ingestion_file_type']['sql'] == views['bre_ingestion_filter_values']['dimensions'][1]['sql']

    def compile_field(name, family='ingestionaudit', period='Daily', env='ca', start='2026-09-06', end='2026-09-13', stack=()):
        assert name not in stack
        raw = base.render(fields[name]['sql'], env, family, period, 'All', start, end).replace('${TABLE}', 'q')
        return base.FIELD_REF.sub(lambda m: '('+compile_field(m.group(1),family,period,env,start,end,stack+(name,))+')',raw)

    fixtures = []
    for env in ['ca','eu']:
        for period in ['Daily','Weekly','Monthly']:
            for tile in tiles.values():
                family=tile['filters'][D+'source_family']
                names=[x[len(D):] for x in tile['fields']]
                group=[n for n in names if n in dimensions]
                select=',\n'.join(compile_field(n,family,period,env)+' AS '+n for n in names)
                route=base.expand('bre_dashboard_'+env,views,env,family,period,'All')
                if tile['name']=='active_uuid': where='TRUE'
                elif tile['name'].startswith('files_'): where=compile_field('ingestion_in_comparison_window',family,period,env)
                else: where="q.analysis_date >= DATE '2026-09-06' AND q.analysis_date < DATE '2026-09-13'"
                if tile['name']=='ingestion_failure_reasons': where+=' AND q.source_rank <= 20'
                sql='SELECT '+select+'\nFROM ('+route+') q\nWHERE '+where
                if group: sql+='\nGROUP BY '+', '.join(str(names.index(n)+1) for n in group)
                sqlglot.parse_one(sql,read='trino')
                assert '${' not in sql and '{%' not in sql
                path=args.output_dir/f'{env}_{tile["name"]}_{period.lower()}.sql'
                path.write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+';\n')
                fixtures.append(str(path))
        helper=base.expand('bre_ingestion_filter_values',views,env,'ingestionaudit','Daily','All')
        sqlglot.parse_one(helper,read='trino')
        assert f'delta_prod{env}' in helper
        (args.output_dir/f'{env}_filter_suggestions.sql').write_text('EXPLAIN (TYPE VALIDATE)\n'+helper+';\n')
    db=duckdb.connect(':memory:')
    checks=0
    def run(sql):
        return db.execute(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    def expr(name, family='ingestionaudit', period='Daily', start='2026-09-06',end='2026-09-13'):
        return compile_field(name,family,period,'ca',start,end)
    # Exact median: odd/even counts, duplicates, NULLs, zeros and no valid values.
    for values in [[1],[1,2],[1,2,99],[1,2,99,100],[0,0,9,None],[None],[]]:
        vals=values or [None]
        rows=','.join("(DATE '2026-09-07',"+('CAST(NULL AS BIGINT)' if x is None else str(x))+')' for x in vals)
        source=f'(VALUES {rows}) q(analysis_date,ingestion_audit_total_files_processed)'
        result=run('SELECT '+expr('ingestion_audit_files_selected_median')+' FROM '+source)[0][0]
        good=[x for x in values if x is not None]
        assert result == (statistics.median(good) if good else None),(values,result)
        checks+=1
    # Bounds include current start and exclude current end, with prior range retained.
    data="""(VALUES (DATE '2026-08-29',999), (DATE '2026-08-30',2),
      (DATE '2026-09-05',6), (DATE '2026-09-06',10),
      (DATE '2026-09-12',30), (DATE '2026-09-13',999)) q(analysis_date,ingestion_audit_total_files_processed)"""
    names=['ingestion_audit_files_selected_average','ingestion_audit_files_previous_average',
           'ingestion_audit_files_selected_median','ingestion_audit_files_previous_median',
           'ingestion_audit_files_average_change','ingestion_audit_files_median_change']
    result=run('SELECT '+','.join(expr(n) for n in names)+' FROM '+data+' WHERE '+expr('ingestion_in_comparison_window'))[0]
    assert result==(20,4,20,4,4,4),result
    checks+=1
    for start,end in [('2026-09-05','2026-09-06'),('2026-08-28','2026-09-09'),('2026-08-01','2026-09-01'),(None,'2026-09-13'),('2026-09-06',None),(None,None)]:
        actual=run('SELECT q.analysis_date,'+expr('ingestion_is_selected_period',start=start,end=end)+','+expr('ingestion_is_previous_period',start=start,end=end)+' FROM '+data)
        lo=dt.date.fromisoformat(start) if start else None
        hi=dt.date.fromisoformat(end) if end else None
        for day,current,previous in actual:
            assert current == ((lo is None or day>=lo) and (hi is None or day<hi))
            assert previous == (bool(lo and hi) and lo-(hi-lo)<=day<lo)
        checks+=1
    for previous in [0,None]:
        rows=f"(VALUES (DATE '2026-09-07',10), (DATE '2026-09-01',{previous if previous is not None else 'NULL'})) q(analysis_date,ingestion_audit_total_files_processed)"
        for kind in ['average','median']:
            assert run('SELECT '+expr('ingestion_audit_files_'+kind+'_change')+' FROM '+rows)[0][0] is None
        checks+=1
    # Sunday boundaries, including month and year transitions.
    dates=['2026-09-05','2026-09-06','2026-09-07','2026-09-30','2026-10-01','2027-01-01']
    data='(VALUES '+','.join("(DATE '"+d+"')" for d in dates)+') q(analysis_date)'
    for period in ['Daily','Weekly','Monthly']:
        actual=run('SELECT q.analysis_date,'+expr('ingestion_period_date',period=period)+' FROM '+data)
        for day,bucket in actual:
            expected=day if period=='Daily' else day.replace(day=1) if period=='Monthly' else day-dt.timedelta(days=(day.weekday()+1)%7)
            assert bucket==expected,(day,bucket,expected)
        checks+=1
    types=['BILLING','OPOWER','CONSUMPTION','USER_META','FUTURE_TYPE']
    source='(VALUES '+','.join("('"+t+"')" for t in types)+') q(ingestion_type)'
    assert [r[0] for r in run('SELECT '+expr('ingestion_file_type')+' FROM '+source)]==['Billing','Billing','Consumption','User_Meta','FUTURE_TYPE']
    checks+=1
    # NULLIF row arithmetic, OPOWER, unknown types, and no day denominator.
    raw=['post_ingestion_user_raw_with_delay_'+b for b in ['0_3','4_7','8_15','gt_15']]
    invoice=['post_ingestion_user_invoice_with_delay_'+b for b in ['0_7','7_15','15_30','gt_30']]
    rows=[('CONSUMPTION',[1,2,3,4],[10,20,30,40]),('BILLING',[1,2,3,4],[10,20,30,40]),
          ('OPOWER',[1,2,3,4],[10,20,30,40]),('USER_META',[1,2,3,4],[10,20,30,40]),
          ('CONSUMPTION',[0,2,3,4],[10,20,30,40]),('BILLING',[1,2,3,4],[None,20,30,40])]
    literal=','.join("('"+t+"',"+','.join('NULL' if v is None else str(v) for v in a+b)+')' for t,a,b in rows)
    source='(VALUES '+literal+') q(ingestion_type,'+','.join(raw+invoice)+')'
    values=run('SELECT '+expr('post_ingestion_users_per_day_millions','postingestion')+' FROM '+source)
    expected=[0.00001,0.0001,0.0001,None,None,None]
    assert all((a[0] is None and b is None) or (a[0] is not None and b is not None and abs(float(a[0])-b)<1e-12) for a,b in zip(values,expected)),values
    avg=run('SELECT '+expr('post_ingestion_users_per_day_millions_average','postingestion')+' FROM '+source)[0][0]
    assert abs(float(avg)-0.00007)<1e-12,avg
    totals=run('SELECT '+expr('post_ingestion_users_receiving_raw_sum','postingestion')+','+expr('post_ingestion_users_receiving_invoice_sum','postingestion')+' FROM '+source)[0]
    assert totals==(50,500),totals
    checks+=3
    result=dict(result='PASS',dashboard='bre_ca_ingestion',query_tiles=len(tiles),filters=len(controls),
                rendered_tile_sql_cases=len(fixtures),suggestion_sql_cases=2,synthetic_checks=checks,
                no_pdts=base.check_no_pdts(),source_data_read=False,looker_validation='PENDING USER WEB UI',
                limitations='Local renderer simulates bounded date tags; DuckDB tests translated expressions, not the Trino execution engine.')
    (args.output_dir/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__': main()
