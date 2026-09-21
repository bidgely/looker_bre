"""Email full-outer blend checks, called by validate_bre_email_dashboard.py."""
import re
import math
import duckdb
import lkml
import yaml
import sqlglot
import validate_bre_models as base


def validate_delivery(output_dir):
    views, _, dimensions, measures, _ = base.parse_project()
    blend = views['bre_email_delivery']
    fields = dimensions | measures | {f['name']: f for kind in ('dimensions','measures') for f in blend[kind]}
    dashboard = yaml.safe_load((base.ROOT/'dashboards/bre_ca_email.dashboard.lookml').read_text())[0]
    tile = next(t for t in dashboard['elements'] if t['name']=='email_delivery_statistics')
    metric_names = ['daily_eligible','daily_generated','daily_sent','weekly_expected','weekly_eligible','weekly_sent','weekly_sent_vs_eligible','weekly_sent_vs_expected']
    assert tile['fields'] == ['bre_email_delivery.email_period_date'] + ['bre_email_delivery.'+n for n in metric_names]
    assert tile['series_types'] == {'bre_email_delivery.'+n:'line' for n in ('daily_eligible','daily_generated','weekly_sent')}
    assert tile['stacking'] == ''
    assert tile['series_value_format'] == {'bre_email_delivery.'+n:'0.00"%"' for n in ('weekly_sent_vs_eligible','weekly_sent_vs_expected')}
    assert tile['listen'] == {'Pilot ID':'bre_email_delivery.blend_pilot_id','Pilot Name':'bre_email_delivery.blend_pilot_name','Time Period':'bre_email_delivery.blend_date_range','Period':'bre_email_delivery.period','Email Type':'bre_email_delivery.email_type','BC End Week#':'bre_email_delivery.blend_bc_end_week_number'}
    assert tile['filters'] == {'bre_email_delivery.blend_date_range':'7 days ago for 7 days','bre_email_delivery.period':'Daily'}
    assert [len(a['series']) for a in tile['y_axes']] == [6,2]
    for env in ('ca','eu'):
        model = lkml.load((base.ROOT/f'models/bre_{env}.model.lkml').read_text())
        explore = next(e for e in model['explores'] if e['name']=='bre_email_delivery')
        for ref in tile['fields'] + list(tile['filters']) + list(tile['listen'].values()):
            assert ref in explore['fields'], ref
        assert '/views/bre/bre_email_delivery.view.lkml' in model['includes']

    def expr(name, period):
        sql = base.render(fields[name]['sql'],'ca','emailstatistics',period,'All').replace('${TABLE}','q')
        return base.FIELD_REF.sub(lambda m: base.reference_sql(m,expr(m.group(1),period),fields),sql)

    def blend_sql(env, replacements=None, weeks=None):
        def condition(m):
            field, value = m.group(1), m.group(2).strip()
            if field == 'blend_bc_end_week_number':
                return 'TRUE' if weeks is None else value+" IN ("+', '.join("'"+w+"'" for w in weeks)+')'
            if field == 'blend_date_range':
                return f"({value} >= DATE '2026-09-06' AND {value} < DATE '2026-09-13')"
            return f"{value} = '"+('1' if field == 'blend_pilot_id' else 'Pilot One')+"'"
        sql = re.sub(r'\{% condition bre_email_delivery\.(\w+) %\}(.*?)\{% endcondition %\}',condition,blend['derived_table']['sql'],flags=re.S)
        return base.TABLE_REF.sub(lambda m: '('+(replacements[m.group(1)] if replacements else base.expand(m.group(1),views,env,'emailstatistics','Daily','All'))+')',sql)

    def query(sql, period, email_where='TRUE'):
        return 'SELECT '+expr('email_period_date',period)+' AS period_date, '+', '.join(expr(n,period)+' AS '+n for n in metric_names)+' FROM ('+sql+') q WHERE '+email_where+' GROUP BY 1 ORDER BY 1'

    for env in ('ca','eu'):
        raw = blend_sql(env)
        assert f'delta_prod{env}' in raw and f'delta_prod{"eu" if env=="ca" else "ca"}' not in raw
        assert 'FULL OUTER JOIN' in raw
        for period in ('Daily','Weekly','Monthly'):
            sql = query(raw,period)
            sqlglot.parse_one(sql,read='trino')
            assert '${' not in sql and '{%' not in sql
            (output_dir/f'{env}_email_delivery_{period.lower()}.sql').write_text(sql+';\n')

    # Multiple raw rows at a matching key must not multiply daily sums.
    stats = """SELECT * FROM (VALUES
      ('1','Pilot One','A',DATE '2026-09-06',DATE '2026-08-01',10,20,8,50),
      ('1','Pilot One','A',DATE '2026-09-06',DATE '2026-08-01',30,100,25,30),
      ('1','Pilot One','A',DATE '2026-09-07',DATE '2026-08-01',90,100,80,90),
      ('1','Pilot One','B',DATE '2026-09-09',DATE '2026-08-01',40,80,30,50),
      ('2','Other','A',DATE '2026-09-06',DATE '2026-09-07',999,1,999,999),
      ('1','Pilot One','A',DATE '2026-09-13',DATE '2026-09-07',999,1,999,999)
    ) s(pilot_id,pilot_name,email_type,analysis_date,reporting_date,cnt_bills_emails_sent,cnt_expected_invoices,cnt_bills_item_available,email_sent_pct)"""
    tracker = """SELECT * FROM (VALUES
      ('1','Pilot One','A',DATE '2026-09-06',DATE '2026-08-01',3,2,1),
      ('1','Pilot One','A',DATE '2026-09-06',DATE '2026-08-01',5,4,3),
      ('1','Pilot One','A',DATE '2026-09-07',DATE '2026-08-01',6,5,4),
      ('1','Pilot One','C',DATE '2026-09-08',DATE '2026-08-01',10,9,8),
      ('2','Other','A',DATE '2026-09-06',DATE '2026-09-07',999,999,999),
      ('1','Pilot One','A',DATE '2026-09-13',DATE '2026-09-07',999,999,999)
    ) t(pilot_id,pilot_name,email_type,analysis_date,reporting_date,invoice_ingested,generated_notification_id,delivered_notification_id)"""
    db=duckdb.connect(':memory:')
    def run(sql): return db.execute(sqlglot.transpile(sql,read='trino',write='duckdb')[0]).fetchall()
    replacements={'bre_email_statistics':stats,'bre_email_tracker':tracker}
    raw=blend_sql('ca',replacements)
    rows=run(query(raw,'Daily'))
    expected=[(8,6,4,60,16.5,20,40,40),(6,5,4,100,80,90,90,90),(10,9,8,None,None,None,None,None),(None,None,None,80,30,40,50,50)]
    assert [str(row[0]) for row in rows] == ['2026-09-06','2026-09-07','2026-09-08','2026-09-09']
    assert [row[1:] for row in rows] == expected
    # Filtering the coalesced join key retains only the selected types on both sides,
    # including types occurring on just one side of the full outer join.
    assert [row[1:] for row in run(query(raw,'Daily',"q.email_type = 'A'"))] == expected[:2]
    assert [row[1:] for row in run(query(raw,'Daily',"q.email_type IN ('B','C')"))] == expected[2:]
    for period,date in [('Weekly','2026-09-06'),('Monthly','2026-09-01')]:
        rows=run(query(raw,period))
        assert len(rows)==1 and str(rows[0][0])==date
        assert all(math.isclose(a,b) for a,b in zip(rows[0][1:],(24,20,16,75,35.75,42.5,55,55)))
    # Unmatched NULL email types stay distinct under SQL equality, preserving source metrics.
    nulls={key:value.replace("'A'","CAST(NULL AS VARCHAR)") for key,value in replacements.items()}
    null_raw=blend_sql('ca',nulls)
    assert run('SELECT COUNT(*) FROM ('+null_raw+") q WHERE email_type IS NULL AND analysis_date = DATE '2026-09-06'")[0][0]==2
    assert run(query(null_raw,'Weekly'))[0][1:]==run(query(raw,'Weekly'))[0][1:]
    # Empty sides and zero expected counts do not erase the other source or divide by zero.
    empty_stats='SELECT * FROM ('+stats+') s WHERE FALSE'
    rows=run(query(blend_sql('ca',replacements|{'bre_email_statistics':empty_stats}),'Weekly'))
    assert rows[0][1:]==(24,20,16,None,None,None,None,None)
    zero_stats=stats.replace('10,20,8,50','10,0,8,50').replace('30,100,25,30','30,0,25,30')
    rows=run(query(blend_sql('ca',replacements|{'bre_email_statistics':zero_stats}),'Daily'))
    assert rows[0][-1] is None
    # Different BC weeks within the same join key must filter before source aggregation.
    stats_with_weeks = "SELECT s.*, CASE WHEN cnt_bills_emails_sent IN (10,90) THEN '1' ELSE '2' END AS bc_end_week_number FROM ("+stats+") s"
    week_sources = replacements | {'bre_email_statistics':stats_with_weeks}
    for period in ('Daily','Weekly','Monthly'):
        selected = run(query(blend_sql('ca',week_sources,['1']),period))
        assert [row[1:4] for row in selected] == [row[1:4] for row in run(query(raw,period)) if row[1] is not None]
        if period == 'Daily':
            assert [row[4:] for row in selected] == [(20,8,10,50,50),(100,80,90,90,90),(None,)*5]
        else:
            assert selected[0][4:] == (60,44,50,70,70)
    assert run(query(blend_sql('ca',week_sources,['1','2']),'Weekly')) == run(query(raw,'Weekly'))
    assert run(query(blend_sql('ca',week_sources,['missing']),'Weekly'))[0][1:] == (24,20,16,None,None,None,None,None)
    for env in ('ca','eu'):
        sql = query(blend_sql(env,weeks=['1','2']),'Weekly')
        sqlglot.parse_one(sql,read='trino')
        (output_dir/f'{env}_email_delivery_bc_week.sql').write_text(sql+';\n')
    return {'result':'PASS','rendered_sql_cases':8,'synthetic_checks':15,'warehouse_data_read':False}
