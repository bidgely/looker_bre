include: "/views/bre_na/bre_na_disaggregation_invoice_fields.view.lkml"

# SRC-36: calendar-based daily and original weekly/monthly aggregates.
# Filters stay outside source aggregation, preserving complete source periods.
view: bre_na_disaggregation_invoices_new {
  extends: [bre_na_disaggregation_invoice_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        WITH bounds AS (
            SELECT
                MIN(analysis_date) AS min_date,
                MAX(analysis_date) AS max_date
            FROM delta_prodna.reporting.sre_invoice_statistics
        ),

        anchors AS (
            SELECT
                CAST(date_add('day', -1 * (day_of_week(MIN(min_date)) % 7), MIN(min_date)) AS DATE) AS week_anchor,
                CAST(date_trunc('month', MIN(min_date)) AS DATE) AS month_anchor
            FROM bounds
        ),

        calendar AS (
            -- generate all dates from min_date to max_date (not from anchor)
            SELECT
                date_add('day', seq, (SELECT min_date FROM bounds)) AS calendar_date
            FROM (
                SELECT ROW_NUMBER() OVER () - 1 AS seq
                FROM delta_prodna.reporting.sre_invoice_statistics
                LIMIT 5000
            ) n
            WHERE date_add('day', seq, (SELECT min_date FROM bounds)) <= (SELECT max_date FROM bounds)
        ),

        daily AS (
            SELECT
                c.calendar_date AS reporting_date,
                c.calendar_date AS analysis_date,
                s.pilot_id,
                s.meter_type,
                s.fuel_type,
                s.reporting_frequency,
                s.module_name,
                COALESCE(SUM(s.total_invoices),0) AS total_invoices,
                ROUND(100.0 * SUM(s.failed_itemisation_cnt) / NULLIF(SUM(s.total_invoices),0),2) AS failed_itemisation_pct,
                ROUND(100.0 * SUM(s.successful_itemisation_cnt) / NULLIF(SUM(s.total_invoices),0),2) AS successful_itemisation_pct,
                s.delay_in_days,
                MAX(s.last_updated_timestamp) AS last_updated_timestamp,
                s.trigger_flag,
                COALESCE(SUM(s.failed_itemisation_cnt),0) AS failed_itemisation_cnt,
                COALESCE(SUM(s.successful_itemisation_cnt),0) AS successful_itemisation_cnt,
                'Daily' AS period
            FROM calendar c
            LEFT JOIN delta_prodna.reporting.sre_invoice_statistics s
              ON s.analysis_date = c.calendar_date
            GROUP BY
                c.calendar_date, s.pilot_id, s.meter_type, s.fuel_type, s.reporting_frequency, s.module_name, s.trigger_flag, s.delay_in_days
        ),

        weekly_base AS (
            SELECT
                s.analysis_date,
                CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) AS week_start,
                s.pilot_id,
                s.meter_type,
                s.fuel_type,
                s.reporting_frequency,
                s.module_name,
                s.delay_in_days,
                s.trigger_flag,
                s.total_invoices,
                s.failed_itemisation_cnt,
                s.successful_itemisation_cnt,
                s.last_updated_timestamp
            FROM delta_prodna.reporting.sre_invoice_statistics s
            CROSS JOIN anchors a
        ),

        weekly AS (
            SELECT
                -- Use the MAX date in the week period as reporting_date so it appears in Looker filters
                MAX(wb.analysis_date) AS reporting_date,
                wb.week_start AS analysis_date,
                wb.pilot_id,
                wb.meter_type,
                wb.fuel_type,
                wb.reporting_frequency,
                wb.module_name,
                COALESCE(SUM(wb.total_invoices),0) AS total_invoices,
                ROUND(100.0 * SUM(wb.failed_itemisation_cnt) / NULLIF(SUM(wb.total_invoices),0),2) AS failed_itemisation_pct,
                ROUND(100.0 * SUM(wb.successful_itemisation_cnt) / NULLIF(SUM(wb.total_invoices),0),2) AS successful_itemisation_pct,
                wb.delay_in_days,
                MAX(wb.last_updated_timestamp) AS last_updated_timestamp,
                wb.trigger_flag,
                COALESCE(SUM(wb.failed_itemisation_cnt),0) AS failed_itemisation_cnt,
                COALESCE(SUM(wb.successful_itemisation_cnt),0) AS successful_itemisation_cnt,
                'Weekly' AS period
            FROM weekly_base wb
            GROUP BY
                wb.week_start,
                wb.pilot_id, wb.meter_type, wb.fuel_type, wb.reporting_frequency, wb.module_name, wb.trigger_flag, wb.delay_in_days
        ),

        monthly_base AS (
            SELECT
                s.analysis_date,
                CAST(date_add('month', date_diff('month', a.month_anchor, s.analysis_date), a.month_anchor) AS DATE) AS month_start,
                s.pilot_id,
                s.meter_type,
                s.fuel_type,
                s.reporting_frequency,
                s.module_name,
                s.delay_in_days,
                s.trigger_flag,
                s.total_invoices,
                s.failed_itemisation_cnt,
                s.successful_itemisation_cnt,
                s.last_updated_timestamp
            FROM delta_prodna.reporting.sre_invoice_statistics s
            CROSS JOIN anchors a
        ),

        monthly AS (
            SELECT
                -- Use the MAX date in the month period as reporting_date so it appears in Looker filters
                MAX(mb.analysis_date) AS reporting_date,
                mb.month_start AS analysis_date,
                mb.pilot_id,
                mb.meter_type,
                mb.fuel_type,
                mb.reporting_frequency,
                mb.module_name,
                COALESCE(SUM(mb.total_invoices),0) AS total_invoices,
                ROUND(100.0 * SUM(mb.failed_itemisation_cnt) / NULLIF(SUM(mb.total_invoices),0),2) AS failed_itemisation_pct,
                ROUND(100.0 * SUM(mb.successful_itemisation_cnt) / NULLIF(SUM(mb.total_invoices),0),2) AS successful_itemisation_pct,
                mb.delay_in_days,
                MAX(mb.last_updated_timestamp) AS last_updated_timestamp,
                mb.trigger_flag,
                COALESCE(SUM(mb.failed_itemisation_cnt),0) AS failed_itemisation_cnt,
                COALESCE(SUM(mb.successful_itemisation_cnt),0) AS successful_itemisation_cnt,
                'Monthly' AS period
            FROM monthly_base mb
            GROUP BY
                mb.month_start,
                mb.pilot_id, mb.meter_type, mb.fuel_type, mb.reporting_frequency, mb.module_name, mb.trigger_flag, mb.delay_in_days
        ),

        stats AS (
            SELECT * FROM daily
            UNION ALL
            SELECT * FROM weekly
            UNION ALL
            SELECT * FROM monthly
        )

        SELECT
            stats.*, m.pilot_name,
            CAST(stats.pilot_id AS VARCHAR) || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name
        FROM stats
        JOIN (
            SELECT
                pilot_id,
                CASE
                    WHEN POSITION('(' IN pilot_name) > 0 THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                    ELSE pilot_name
                END AS pilot_name
            FROM delta_prodna.reporting.pilot_consolidated_product_type_events
        ) m
          ON CAST(m.pilot_id AS VARCHAR) = stats.pilot_id
      ) q
      WHERE q.period = {% parameter period %}
        AND {% condition date_range %} q.reporting_date {% endcondition %}
        AND {% condition pilot_id %} q.pilot_id {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition meter_type %} q.meter_type {% endcondition %}
        AND {% condition fuel_type %} q.fuel_type {% endcondition %}
        AND {% condition module_name %} q.module_name {% endcondition %}
    ;;
  }
  dimension: period_date {
    description: "Original source analysis date: daily date or the preaggregated week/month start."
    sql: ${analysis_date::date} ;;
  }
}
