# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Validate CA/EU Disagg parity and shared SQL locally; no warehouse queries or Looker compiler."""
import sys
sys.dont_write_bytecode = True
import argparse
import json
from pathlib import Path
import statistics

import duckdb
import lkml
import sqlglot
import yaml
import validate_bre_models as base


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=Path('/private/tmp/bre-disagg-validation'))
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    views, _, dimensions, measures, sets = base.parse_project()
    fields = dimensions | measures
    dashboard = yaml.safe_load((base.ROOT/'dashboards/bre_ca_disagg.dashboard.lookml').read_text())[0]
    eu_dashboard = yaml.safe_load((base.ROOT/'dashboards/bre_eu_disagg.dashboard.lookml').read_text())[0]
    normalized_eu = json.loads(json.dumps(eu_dashboard).replace('bre_eu', 'bre_ca').replace('BRE EU', 'BRE CA').replace('EU disaggregation', 'CA disaggregation'))
    assert normalized_eu == dashboard, 'Regional Disagg definitions differ beyond environment identifiers'
    tiles = {tile['name']: tile for tile in dashboard['elements']}
    controls = {control['name']: control for control in dashboard['filters']}
    assert set(tiles['active_uuid']['listen']) == {'Pilot ID', 'Pilot Name'}
    assert controls['Time Period']['field'] == 'bre_dashboard.reporting_date'
    model = lkml.load((base.ROOT/'models/bre_ca.model.lkml').open())
    assert '/dashboards/bre_ca_disagg.dashboard.lookml' in model['includes']
    exposed = {name for member in model['explores'][0]['fields'] for name in sets[member.split('.')[1][:-1]]}
    suggestion_fixtures = 0
    for env in ('ca', 'eu'):
        region_model = lkml.load((base.ROOT/f'models/bre_{env}.model.lkml').open())
        region_dashboard = dashboard if env == 'ca' else eu_dashboard
        assert f'/dashboards/bre_{env}_disagg.dashboard.lookml' in region_model['includes']
        other = 'eu' if env == 'ca' else 'ca'
        assert f'/dashboards/bre_{other}_disagg.dashboard.lookml' not in region_model['includes']
        assert region_model['connection'] == f'starburst_prod_{env}'
        assert region_model['explores'][0]['from'] == f'bre_dashboard_{env}'
        region_fields = {name for member in region_model['explores'][0]['fields'] for name in sets[member.split('.')[1][:-1]]}
        for tile in region_dashboard['elements']:
            assert tile['model'] == f'bre_{env}' and tile['explore'] == 'bre_dashboard'
            for ref in tile['fields'] + list(tile['filters']) + list(tile['listen'].values()):
                assert ref.removeprefix('bre_dashboard.') in region_fields, (env, ref)
        assert all(control['model'] == f'bre_{env}' for control in region_dashboard['filters'])
        helper = next(e for e in region_model['explores'] if e['name'] == 'bre_invoice_filters')
        source = views[helper['view_name']]
        source_fields = {d['name']: d for d in source['dimensions']}
        for title, field in (('Meter Type','meter_type'), ('Fuel Type','fuel_type'), ('Module Name','module_name')):
            control = controls[title]
            assert control['explore'] == helper['name']
            assert control['field'] == 'bre_invoice_statistics.'+field
            assert control['field'] in helper['fields'] and field in source_fields
            for name, tile in tiles.items():
                supported = name != 'active_uuid' and not (name == 'daily_disagg_quality' and field == 'module_name')
                assert (title in tile['listen']) == supported
                if supported:
                    assert tile['listen'][title] == 'bre_dashboard.'+field
            route = base.expand(helper['view_name'], views, env, 'invoicestatistics', 'Daily', 'All')
            selected = source_fields[field]['sql'].replace('${TABLE}', 'q')
            sql = 'SELECT DISTINCT '+selected+' FROM ('+route+') q WHERE '+selected+' IS NOT NULL'
            sqlglot.parse_one(sql, read='trino')
            assert f'delta_prod{env}' in sql and f'delta_prod{"eu" if env=="ca" else "ca"}' not in sql
            (args.output_dir/f'{env}_disagg_{field}_suggestions.sql').write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+';\n')
            suggestion_fixtures += 1

    def expression(name, env='ca', start='2026-09-06', end='2026-09-13', family='invoicestatistics', period='Daily'):
        sql = base.render(fields[name]['sql'], env, family, period, 'All', start, end).replace('${TABLE}', 'q')
        return base.FIELD_REF.sub(lambda m: base.reference_sql(m, expression(m.group(1), env, start, end, family, period), fields), sql)

    fixtures = 0
    for kind in ('average', 'median'):
        tile = tiles['invoices_'+kind]
        assert tile['model'] == 'bre_ca' and tile['explore'] == 'bre_dashboard'
        assert tile['listen']['Time Period'] == 'bre_dashboard.invoice_comparison_date_range'
        assert tile['filters']['bre_dashboard.source_family'] == 'invoicestatistics'
        assert tile['filters']['bre_dashboard.invoice_in_comparison_window'] == 'Yes'
        assert not {'bre_dashboard.analysis_date', 'bre_dashboard.reporting_date'} & tile['filters'].keys()
        for ref in tile['fields'] + list(tile['filters']) + list(tile['listen'].values()):
            assert ref.removeprefix('bre_dashboard.') in exposed, ref
        for env in ('ca', 'eu'):
            route = base.expand('bre_dashboard_'+env, views, env, 'invoicestatistics', 'Daily', 'All')
            names = [ref.removeprefix('bre_dashboard.') for ref in tile['fields']]
            sql = 'SELECT '+', '.join(expression(name, env)+' AS '+name for name in names)
            sql += ' FROM ('+route+') q WHERE '+expression('invoice_in_comparison_window', env)
            sqlglot.parse_one(sql, read='trino')
            assert '${' not in sql and '{%' not in sql
            assert f'delta_prod{env}' in sql and f'delta_prod{"eu" if env=="ca" else "ca"}' not in sql
            (args.output_dir/f'{env}_invoices_{kind}.sql').write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+';\n')
            fixtures += 1
    db = duckdb.connect(':memory:')
    def run(sql):
        return db.execute(sqlglot.transpile(sql, read='trino', write='duckdb')[0]).fetchall()
    checks = 0
    success_date_where = "q.reporting_date >= DATE '2026-09-06' AND q.reporting_date < DATE '2026-09-13'"
    success_data = """(VALUES
      (7, 'SCHEDULED', 20, DATE '2026-09-06', 1),
      (7, 'SCHEDULED', 80, DATE '2026-09-12', 999),
      (2, 'SCHEDULED', 0, DATE '2026-09-06', 1),
      (2, 'SCHEDULED', 90, DATE '2026-09-12', 999),
      (7, 'ADHOC', 100, DATE '2026-09-07', 1),
      (2, 'ADHOC', 100, DATE '2026-09-07', 1),
      (3, 'SCHEDULED', 100, DATE '2026-09-07', 1),
      (7, 'SCHEDULED', 100, DATE '2026-09-05', 1),
      (2, 'SCHEDULED', 100, DATE '2026-09-13', 1)
    ) q(delay_in_days, trigger_flag, invoice_statistics_successful_itemisation_pct, reporting_date, invoice_statistics_total_invoices)"""
    for delay, expected in ((7, 50), (2, 45)):
        tile = tiles[f'success_t_{delay}']
        name = f'invoice_statistics_successful_itemisation_t_{delay}_pct_average'
        assert tile['fields'] == ['bre_dashboard.'+name] and name in exposed
        assert tile['listen']['Time Period'] == 'bre_dashboard.reporting_date'
        assert tile['filters'] == {'bre_dashboard.source_family': 'invoicestatistics', 'bre_dashboard.reporting_date': '7 days ago for 7 days'}
        assert tile['show_comparison'] is False
        for env in ('ca', 'eu'):
            route = base.expand('bre_dashboard_'+env, views, env, 'invoicestatistics', 'Daily', 'All')
            sql = 'SELECT '+expression(name, env)+' AS success_pct FROM ('+route+') q WHERE '+success_date_where
            sqlglot.parse_one(sql, read='trino')
            assert '${' not in sql and '{%' not in sql
            (args.output_dir/f'{env}_success_t_{delay}.sql').write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+';\n')
            fixtures += 1
        assert run('SELECT '+expression(name)+' FROM '+success_data+' WHERE '+success_date_where)[0][0] == expected
        assert run('SELECT '+expression(name)+' FROM '+success_data+" WHERE trigger_flag = 'ADHOC'")[0][0] is None
        checks += 2
    combo = tiles['daily_invoice_disagg_statistics']
    assert combo['listen']['Time Period'] == 'bre_dashboard.reporting_date'
    assert combo['fields'][0] == 'bre_dashboard.disagg_period_date'
    assert combo['listen']['Period'] == 'bre_dashboard.period'
    assert controls['Period']['field'] == 'bre_dashboard.period'
    assert controls['Period']['default_value'] == 'Daily'
    assert all('Period' not in tile['listen'] for name, tile in tiles.items() if name not in ('daily_invoice_disagg_statistics', 'daily_disagg_quality', 'disagg_failure_reasons'))
    assert combo['filters'] == {'bre_dashboard.source_family':'invoicestatistics', 'bre_dashboard.reporting_date':'7 days ago for 7 days', 'bre_dashboard.period':'Daily'}
    assert combo['type'] == 'looker_column'
    assert combo['series_types'] == {name:'line' for name in combo['fields'][2:]}
    assert all(name.removeprefix('bre_dashboard.') in exposed for name in combo['fields'])
    for env in ('ca','eu'):
        for period in ('Daily','Weekly','Monthly'):
            route = base.expand('bre_dashboard_'+env, views, env, 'invoicestatistics', period, 'All')
            date_sql = "date_format(("+expression('disagg_period_date',env,period=period)+"), '%Y-%m-%d')"
            sql = 'SELECT '+date_sql+' AS analysis_date, '+', '.join(expression(name.removeprefix('bre_dashboard.'),env,period=period)+' AS '+name.removeprefix('bre_dashboard.') for name in combo['fields'][1:])
            sql += ' FROM ('+route+') q WHERE '+success_date_where+' GROUP BY 1'
            sqlglot.parse_one(sql,read='trino')
            assert '${' not in sql and '{%' not in sql
            (args.output_dir/f'{env}_invoice_disagg_combo_{period.lower()}.sql').write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+';\n')
            fixtures += 1
    quality = tiles['daily_disagg_quality']
    quality_fixtures = 0
    for ref in quality['fields'] + list(quality['filters']) + list(quality['listen'].values()):
        assert ref.removeprefix('bre_dashboard.') in exposed, ref
    for env in ('ca', 'eu'):
        for period in ('Daily', 'Weekly', 'Monthly'):
            route = base.expand('bre_dashboard_'+env, views, env, 'disaggquality', period, 'All')
            date_sql = "date_format(("+expression('disagg_period_date', env, family='disaggquality', period=period)+"), '%Y-%m-%d')"
            sql = 'SELECT '+date_sql+' AS analysis_date, '+', '.join(expression(ref.removeprefix('bre_dashboard.'), env, family='disaggquality', period=period)+' AS '+ref.removeprefix('bre_dashboard.') for ref in quality['fields'][1:])
            sql += ' FROM ('+route+') q WHERE '+success_date_where+' GROUP BY 1'
            sqlglot.parse_one(sql, read='trino')
            assert '${' not in sql and '{%' not in sql
            assert f'delta_prod{env}' in sql and f'delta_prod{"eu" if env=="ca" else "ca"}' not in sql
            (args.output_dir/f'{env}_disagg_quality_{period.lower()}.sql').write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+';\n')
            quality_fixtures += 1
    failure = tiles['disagg_failure_reasons']
    failure_fixtures = 0
    for ref in failure['fields'] + list(failure['filters']) + list(failure['listen'].values()):
        assert ref.removeprefix('bre_dashboard.') in exposed, ref
    for env in ('ca', 'eu'):
        for period in ('Daily', 'Weekly', 'Monthly'):
            route = base.expand('bre_dashboard_'+env, views, env, 'processingfailures', period, failure['filters']['bre_dashboard.failure_scope'])
            assert 'f.source_rank <= 3' in route
            date_sql = "date_format(("+expression('disagg_period_date', env, family='processingfailures', period=period)+"), '%Y-%m-%d')"
            sql = 'SELECT '+date_sql+' AS period_date, '+expression('failure_reason', env, family='processingfailures')+' AS failure_reason, '+expression('processing_failures_failure_percentage_average', env, family='processingfailures')+' AS failure_pct'
            sql += ' FROM ('+route+') q WHERE '+success_date_where+' GROUP BY 1, 2'
            sqlglot.parse_one(sql, read='trino')
            assert '${' not in sql and '{%' not in sql
            assert f'delta_prod{env}' in sql and f'delta_prod{"eu" if env=="ca" else "ca"}' not in sql
            (args.output_dir/f'{env}_disagg_failures_{period.lower()}.sql').write_text('EXPLAIN (TYPE VALIDATE)\n'+sql+';\n')
            failure_fixtures += 1
    volume = expression('invoice_statistics_daily_total_invoices')
    period_data = """(VALUES
      (DATE '2026-08-29', DATE '2026-09-06', 10),
      (DATE '2026-08-29', DATE '2026-09-06', 30),
      (DATE '2026-08-30', DATE '2026-09-06', 40),
      (DATE '2026-08-31', DATE '2026-09-06', 60),
      (DATE '2026-09-01', DATE '2026-09-06', 80),
      (DATE '2026-09-01', DATE '2026-09-13', 999)
    ) q(analysis_date,reporting_date,invoice_statistics_total_invoices)"""
    expected_periods = {
        'Daily': [('2026-08-29',20),('2026-08-30',40),('2026-08-31',60),('2026-09-01',80)],
        'Weekly': [('2026-08-23',20),('2026-08-30',180)],
        'Monthly': [('2026-08-01',140),('2026-09-01',80)],
    }
    for period,expected in expected_periods.items():
        date_sql = "date_format(("+expression('disagg_period_date',period=period)+"), '%Y-%m-%d')"
        actual = run('SELECT '+date_sql+', '+volume+' FROM '+period_data+' WHERE '+success_date_where+' GROUP BY 1 ORDER BY 1')
        assert actual == expected, (period,actual)
        checks += 1
    for rows,expected in [
        ("(DATE '2026-09-01',100),(DATE '2026-09-01',300)",200),
        ("(DATE '2026-09-01',100),(DATE '2026-09-01',300),(DATE '2026-09-02',500)",900),
        ("(CAST(NULL AS DATE),100),(CAST(NULL AS DATE),300)",400),
        ("(DATE '2026-09-01',CAST(NULL AS INTEGER))",None),
    ]:
        assert run('SELECT '+volume+' FROM (VALUES '+rows+') q(analysis_date,invoice_statistics_total_invoices)')[0][0] == expected
        checks += 1
    correction = expression('invoice_statistics_successful_itemisation_correction_pct_max')
    corrections = "(VALUES ('ADHOC',20),('ADHOC',80),('SCHEDULED',100)) q(trigger_flag,invoice_statistics_successful_itemisation_pct)"
    assert run('SELECT '+correction+' FROM '+corrections)[0][0] == 80
    assert run('SELECT '+correction+' FROM '+corrections+" WHERE trigger_flag = 'SCHEDULED'")[0][0] is None
    checks += 2
    # Old analysis dates still appear when their reporting dates are in the selected window.
    reporting_data = """(VALUES
      (DATE '2026-08-01', DATE '2026-09-06', 100),
      (DATE '2026-08-01', DATE '2026-09-12', 300),
      (DATE '2026-09-07', DATE '2026-09-13', 999)
    ) q(analysis_date,reporting_date,invoice_statistics_total_invoices)"""
    actual = run('SELECT CAST(q.analysis_date AS VARCHAR), '+volume+' FROM '+reporting_data+' WHERE '+success_date_where+' GROUP BY 1')
    assert actual == [('2026-08-01',200)]
    checks += 1
    rectangles = [(t['col'],t['row'],t['col']+t['width'],t['row']+t['height']) for t in tiles.values()]
    for i,a in enumerate(rectangles):
        assert 0 <= a[0] < a[2] <= 24
        for b in rectangles[i+1:]:
            assert a[2] <= b[0] or b[2] <= a[0] or a[3] <= b[1] or b[3] <= a[1]
    for values in ([1], [1,2], [1,2,99], [1,2,99,100], [0,0,9,None], [None], []):
        rows = ','.join("(DATE '2026-09-07', "+('NULL' if v is None else str(v))+')' for v in (values or [None]))
        sql = 'SELECT '+expression('invoice_statistics_invoices_selected_median')+' FROM (VALUES '+rows+') q(reporting_date, invoice_statistics_total_invoices)'
        valid = [v for v in values if v is not None]
        assert run(sql)[0][0] == (statistics.median(valid) if valid else None)
        checks += 1
    # Analysis dates deliberately conflict with reporting dates: only reporting determines membership.
    data = """(VALUES
      (DATE '2026-08-29', DATE '2026-09-07', 999),
      (DATE '2026-08-30', DATE '2026-09-07', 2),
      (DATE '2026-09-05', DATE '2026-09-07', 6),
      (DATE '2026-09-06', DATE '2026-08-01', 10),
      (DATE '2026-09-12', DATE '2026-08-01', 30),
      (DATE '2026-09-13', DATE '2026-09-07', 999)
    ) q(reporting_date, analysis_date, invoice_statistics_total_invoices)"""
    names = ['selected_average','previous_average','selected_median','previous_median','average_change','median_change']
    sql = 'SELECT '+','.join(expression('invoice_statistics_invoices_'+name) for name in names)
    assert run(sql+' FROM '+data+' WHERE '+expression('invoice_in_comparison_window'))[0] == (20,4,20,4,4,4)
    checks += 1
    for previous in ('0','NULL'):
        data = "(VALUES (DATE '2026-09-07',10), (DATE '2026-09-01',"+previous+')) q(reporting_date,invoice_statistics_total_invoices)'
        for kind in ('average','median'):
            assert run('SELECT '+expression('invoice_statistics_invoices_'+kind+'_change')+' FROM '+data)[0][0] is None
            checks += 1
    for start,end in ((None,'2026-09-13'),('2026-09-06',None),(None,None)):
        assert run('SELECT '+expression('invoice_is_previous_period',start=start,end=end)+" FROM (VALUES (DATE '2026-09-01')) q(reporting_date)")[0][0] is False
        checks += 1
    result = dict(result='PASS',dashboard='bre_ca_disagg',confirmed_tiles=len(tiles),rendered_invoice_sql_cases=fixtures,
                  dashboards=['bre_ca_disagg', 'bre_eu_disagg'],regional_parity='PASS',
                  rendered_quality_sql_cases=quality_fixtures,rendered_failure_sql_cases=failure_fixtures,
                  rendered_suggestion_sql_cases=suggestion_fixtures,dashboard_controls=len(controls),
                  synthetic_checks=checks,no_pdts=base.check_no_pdts(),source_data_read=False,
                  looker_validation={'ca': 'USER ACCEPTED', 'eu': 'PENDING USER WEB UI'},limitations='Local SQL renderer and translated DuckDB fixtures do not replace native Looker validation or Trino execution.')
    (args.output_dir/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__ == '__main__':
    main()
