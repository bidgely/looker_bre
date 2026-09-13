# /// script
# requires-python = ">=3.10"
# dependencies = ["lkml==1.3.7", "python-liquid==2.3.1", "sqlglot==30.18.0", "pyyaml==6.0.2", "duckdb==1.4.3"]
# ///
"""Local Email dashboard checks; synthetic data only, no warehouse execution."""
import sys
sys.dont_write_bytecode = True
import argparse
import json
import statistics

import duckdb
import lkml
import sqlglot
import yaml
from pathlib import Path
import validate_bre_models as base


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=Path('/private/tmp/bre-email-validation'))
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    views, _, dimensions, measures, sets = base.parse_project()
    fields = dimensions | measures
    dashboard = yaml.safe_load((base.ROOT/'dashboards/bre_ca_email.dashboard.lookml').read_text())[0]
    reference = yaml.safe_load((base.ROOT/'dashboards/bre_ca_disagg.dashboard.lookml').read_text())[0]
    uuid = dashboard['elements'][0]
    assert uuid['listen'] == {}
    assert {k:v for k,v in uuid.items() if k not in ('listen','note_text')} == {k:v for k,v in reference['elements'][0].items() if k not in ('listen','note_text')}
    model = lkml.load((base.ROOT/'models/bre_ca.model.lkml').read_text())
    assert '/dashboards/bre_ca_email.dashboard.lookml' in model['includes']
    exposed = {name for member in model['explores'][0]['fields'] for name in sets[member.split('.')[1][:-1]]}
    controls = {c['name']: c for c in dashboard['filters']}
    assert controls['Time Period']['default_value'] == '7 days ago for 7 days'
    assert controls['Time Period']['field'] == 'bre_dashboard.reporting_date'
    assert controls['Email Type']['explore'] == 'bre_email_type_filters'
    assert controls['Email Type']['field'] == 'bre_email_tracker.email_type'
    assert controls['BC End Week#']['explore'] == 'bre_email_week_filters'
    assert controls['BC End Week#']['field'] == 'bre_email_statistics.bc_end_week_number'
    for env in ('ca', 'eu'):
        regional = lkml.load((base.ROOT/f'models/bre_{env}.model.lkml').read_text())
        helpers = {e['name']: e for e in regional['explores']}
        for helper, view, field in (
            ('bre_email_type_filters', 'bre_email_tracker', 'email_type'),
            ('bre_email_week_filters', 'bre_email_statistics', 'bc_end_week_number'),
        ):
            assert helpers[helper]['view_name'] == view
            assert helpers[helper]['fields'] == [view+'.'+field]
            assert helpers[helper]['hidden'] == 'yes'
            assert field in {d['name'] for d in views[view]['dimensions']}
    assert sum('Email Type' in t['listen'] for t in dashboard['elements']) == 7
    assert sum('BC End Week#' in t['listen'] for t in dashboard['elements']) == 7
    for tile in dashboard['elements']:
        if tile['explore'] == 'bre_email_delivery':
            continue  # Validated with its inherited field contract below.
        assert tile['model'] == 'bre_ca' and tile['explore'] == 'bre_dashboard'
        for ref in tile['fields'] + list(tile['filters']) + list(tile['listen'].values()):
            assert ref.removeprefix('bre_dashboard.') in exposed, ref
        assert set(tile['listen']) <= controls.keys()

    def expression(name, env='ca', start='2026-09-06', end='2026-09-13'):
        sql = base.render(fields[name]['sql'], env, 'emailstatistics', 'Daily', 'All', start, end).replace('${TABLE}', 'q')
        return base.FIELD_REF.sub(lambda m: base.reference_sql(m, expression(m.group(1), env, start, end), fields), sql)

    fixtures = 0
    for kind in ('average', 'median'):
        tile = next(t for t in dashboard['elements'] if t['name'] == 'emails_'+kind)
        assert tile['listen']['Time Period'] == 'bre_dashboard.email_comparison_date_range'
        assert tile['filters'] == {
            'bre_dashboard.source_family': 'emailstatistics',
            'bre_dashboard.email_comparison_date_range': '7 days ago for 7 days',
            'bre_dashboard.email_in_comparison_window': 'Yes',
        }
        assert tile['show_comparison'] and tile['comparison_type'] == 'change'
        for env in ('ca', 'eu'):
            route = base.expand('bre_dashboard_'+env, views, env, 'emailstatistics', 'Daily', 'All')
            sql = 'SELECT '+', '.join(expression(ref.removeprefix('bre_dashboard.'), env) for ref in tile['fields'])
            sql += ' FROM ('+route+') q WHERE '+expression('email_in_comparison_window', env)
            sqlglot.parse_one(sql, read='trino')
            assert '${' not in sql and '{%' not in sql
            assert f'delta_prod{env}.reporting.sre_quality_email_stats' in sql
            assert f'delta_prod{"eu" if env == "ca" else "ca"}' not in sql
            (args.output_dir/f'{env}_emails_{kind}.sql').write_text(sql+';\n')
            fixtures += 1

    db = duckdb.connect(':memory:')
    def run(sql):
        return db.execute(sqlglot.transpile(sql, read='trino', write='duckdb')[0]).fetchone()

    checks = 0
    for values in ([1], [1, 2], [1, 2, 99], [1, 2, 99, 100], [0, 0, 9, None], [None], []):
        rows = ','.join("(DATE '2026-09-07', "+('NULL' if v is None else str(v))+')' for v in (values or [None]))
        valid = [v for v in values if v is not None]
        for kind, aggregate in (('average', statistics.mean), ('median', statistics.median)):
            sql = 'SELECT '+expression('email_statistics_emails_selected_'+kind)+' FROM (VALUES '+rows+') q(reporting_date,email_statistics_cnt_bills_emails_sent)'
            assert run(sql)[0] == (aggregate(valid) if valid else None)
            checks += 1
    # Boundary rows and conflicting analysis dates ensure membership uses reporting_date only.
    data = """(VALUES
      (DATE '2026-08-29', DATE '2026-09-07', 999),
      (DATE '2026-08-30', DATE '2026-09-07', 2),
      (DATE '2026-09-05', DATE '2026-09-07', 6),
      (DATE '2026-09-06', DATE '2026-08-01', 10),
      (DATE '2026-09-12', DATE '2026-08-01', 30),
      (DATE '2026-09-13', DATE '2026-09-07', 999)
    ) q(reporting_date,analysis_date,email_statistics_cnt_bills_emails_sent)"""
    names = ['selected_average', 'previous_average', 'selected_median', 'previous_median', 'average_change', 'median_change']
    sql = 'SELECT '+','.join(expression('email_statistics_emails_'+name) for name in names)
    assert run(sql+' FROM '+data+' WHERE '+expression('email_in_comparison_window')) == (20, 4, 20, 4, 4, 4)
    checks += 1
    for prior in ('0', 'NULL'):
        data = "(VALUES (DATE '2026-09-07',10),(DATE '2026-09-01',"+prior+')) q(reporting_date,email_statistics_cnt_bills_emails_sent)'
        for kind in ('average', 'median'):
            assert run('SELECT '+expression('email_statistics_emails_'+kind+'_change')+' FROM '+data)[0] is None
            checks += 1
    for start, end in ((None, '2026-09-13'), ('2026-09-06', None), (None, None)):
        assert run('SELECT '+expression('email_is_previous_period', start=start, end=end)+" FROM (VALUES (DATE '2026-09-01')) q(reporting_date)")[0] is False
        checks += 1
    date_where = "q.reporting_date >= DATE '2026-09-06' AND q.reporting_date < DATE '2026-09-13'"
    # Unequal denominators distinguish AVG(row ratios) from a ratio of sums.
    # Conflicting analysis dates and boundary rows verify reporting-date membership.
    percentage_data = """(VALUES
      (DATE '2026-09-06', DATE '2026-08-01', 1, 2, 20),
      (DATE '2026-09-12', DATE '2026-08-01', 9, 10, 80),
      (DATE '2026-09-07', DATE '2026-08-01', 0, 5, 0),
      (DATE '2026-09-07', DATE '2026-08-01', 10, 0, NULL),
      (DATE '2026-09-07', DATE '2026-08-01', 10, NULL, NULL),
      (DATE '2026-09-07', DATE '2026-08-01', NULL, 10, NULL),
      (DATE '2026-09-05', DATE '2026-09-07', 999, 1, 999),
      (DATE '2026-09-13', DATE '2026-09-07', 999, 1, 999)
    ) q(reporting_date,analysis_date,email_statistics_cnt_bills_emails_sent,email_statistics_cnt_expected_invoices,email_statistics_email_sent_pct)"""
    for suffix, name, expected in (
        ('expected', 'email_statistics_email_sent_pct_vs_expected_average', 140 / 3),
        ('eligible', 'email_statistics_email_sent_pct_average', 100 / 3),
    ):
        tile = next(t for t in dashboard['elements'] if t['name'] == 'sent_pct_vs_'+suffix)
        assert tile['fields'] == ['bre_dashboard.'+name]
        assert tile['show_comparison'] is False
        assert tile['single_value_title'] == 'vs '+suffix.title()+' #'
        assert tile['value_format'] == '0.00"%"'
        assert tile['listen']['Time Period'] == 'bre_dashboard.reporting_date'
        assert tile['filters'] == {'bre_dashboard.source_family': 'emailstatistics', 'bre_dashboard.reporting_date': '7 days ago for 7 days'}
        for env in ('ca', 'eu'):
            route = base.expand('bre_dashboard_'+env, views, env, 'emailstatistics', 'Daily', 'All')
            sql = 'SELECT '+expression(name, env)+' FROM ('+route+') q WHERE '+date_where
            sqlglot.parse_one(sql, read='trino')
            assert '${' not in sql and '{%' not in sql
            (args.output_dir/f'{env}_sent_pct_vs_{suffix}.sql').write_text(sql+';\n')
            fixtures += 1
        assert abs(run('SELECT '+expression(name)+' FROM '+percentage_data+' WHERE '+date_where)[0] - expected) < 1e-10
        assert run('SELECT '+expression(name)+' FROM '+percentage_data+' WHERE FALSE')[0] is None
        checks += 2
    assert run('SELECT '+expression('email_statistics_email_sent_pct_vs_expected_average')+' FROM '+percentage_data+' WHERE email_statistics_cnt_expected_invoices = 0')[0] is None
    checks += 1
    # Failure tile: keep source ranking, filter reporting dates, then average by analysis period.
    failure_tile = next(t for t in dashboard['elements'] if t['name'] == 'weekly_email_failure_reasons')
    assert failure_tile['filters']['bre_dashboard.source_rank'] == '<=3'
    assert failure_tile['listen']['Time Period'] == 'bre_dashboard.reporting_date'
    assert failure_tile['pivots'] == ['bre_dashboard.failure_reason']
    failure_data = """(VALUES
      (DATE '2026-08-02', DATE '2026-09-06', 'A', 1, 10),
      (DATE '2026-08-03', DATE '2026-09-12', 'A', 2, 20),
      (DATE '2026-08-03', DATE '2026-09-12', 'A', 3, 0),
      (DATE '2026-08-03', DATE '2026-09-12', 'A', 4, 999),
      (DATE '2026-08-03', DATE '2026-09-12', 'B', 1, 8),
      (DATE '2026-08-03', DATE '2026-09-12', 'B', 2, NULL),
      (DATE '2026-09-07', DATE '2026-09-05', 'A', 1, 999),
      (DATE '2026-09-07', DATE '2026-09-13', 'A', 1, 999)
    ) q(analysis_date,reporting_date,failure_reason,source_rank,email_failures_failure_count)"""
    for env in ('ca', 'eu'):
        for period in ('Daily', 'Weekly', 'Monthly'):
            def failure_expression(name):
                sql = base.render(fields[name]['sql'], env, 'emailfailures', period, 'All').replace('${TABLE}', 'q')
                return base.FIELD_REF.sub(lambda m: base.reference_sql(m, failure_expression(m.group(1)), fields), sql)
            selection = ','.join(failure_expression(name) for name in (
                'email_period_date', 'failure_reason', 'email_failures_failure_count_average'))
            tail = ' WHERE '+date_where+' AND q.source_rank <= 3 GROUP BY 1,2 ORDER BY 1,2'
            route = base.expand('bre_dashboard_'+env, views, env, 'emailfailures', period, 'All')
            sql = 'SELECT '+selection+' FROM ('+route+') q'+tail
            sqlglot.parse_one(sql, read='trino')
            assert f'delta_prod{env}.reporting.sre_email_failure_reasons' in sql
            assert '${' not in sql and '{%' not in sql
            (args.output_dir/f'{env}_email_failures_{period.lower()}.sql').write_text(sql+';\n')
            fixtures += 1
            rows = db.execute(sqlglot.transpile('SELECT '+selection+' FROM '+failure_data+tail, read='trino', write='duckdb')[0]).fetchall()
            if period == 'Daily':
                assert [(str(d), reason, value) for d, reason, value in rows] == [
                    ('2026-08-02', 'A', 10), ('2026-08-03', 'A', 10), ('2026-08-03', 'B', 8)]
            else:
                expected_date = '2026-08-02' if period == 'Weekly' else '2026-08-01'
                assert [(str(d), reason, value) for d, reason, value in rows] == [
                    (expected_date, 'A', 10), (expected_date, 'B', 8)]
            checks += 1
    from validate_bre_email_delivery import validate_delivery
    blend_result = validate_delivery(args.output_dir)
    result = dict(delivery_blend=blend_result, result='PASS', dashboard='bre_ca_email', implemented_tiles=len(dashboard['elements']),
                  rendered_sql_cases=fixtures, synthetic_checks=checks, no_pdts=base.check_no_pdts(),
                  source_data_read=False, looker_validation='PENDING USER WEB UI',
                  limitations='Local rendering, Trino parsing and translated DuckDB fixtures do not replace native Looker validation or Trino execution.')
    (args.output_dir/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
