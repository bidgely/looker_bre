include: "/views/bre_na/bre_na_disaggregation_fields.view.lkml"

# SRC-51: source period calculations and ranking preserved; dashboard filters remain outside them.
view: bre_na_disaggregation_failures {
  extends: [bre_na_disaggregation_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        WITH bounds AS (
            SELECT
                MIN(analysis_date) AS min_date,
                MAX(analysis_date) AS max_date
            FROM delta_prodna.reporting.sre_failure_statistics
        ),

        anchors AS (
            SELECT
                CAST(date_add('day', -1 * (day_of_week(MIN(min_date)) % 7), MIN(min_date)) AS DATE) AS week_anchor,
                CAST(date_trunc('month', MIN(min_date)) AS DATE) AS month_anchor
            FROM bounds
        ),

        daily AS (
            SELECT
                pilot_id,
                'Daily' AS period,
                meter_type,
                fuel_type,
                reporting_date,
                analysis_date,
                reporting_frequency,
                module_name,
                event_type,
                failure_reason,
                failure_percentage,
                failure_count,
                total_failure_count,
                delay_in_days,
                trigger_flag,
                last_updated_timestamp
            FROM delta_prodna.reporting.sre_failure_statistics
        ),

        weekly_totals AS (
            SELECT
                pilot_id,
                meter_type,
                fuel_type,
                CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) AS week_start,
                reporting_frequency,
                module_name,
                event_type,
                delay_in_days,
                trigger_flag,
                SUM(failure_count) AS total_failure_count
            FROM delta_prodna.reporting.sre_failure_statistics s
            CROSS JOIN anchors a
            GROUP BY
                pilot_id, meter_type, fuel_type,
                CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE),
                reporting_frequency, module_name, event_type, delay_in_days, trigger_flag
        ),

        weekly AS (
            SELECT
                s.pilot_id,
                'Weekly' AS period,
                s.meter_type,
                s.fuel_type,
                MAX(s.analysis_date) AS reporting_date,  -- Latest date in the week
                CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) AS analysis_date,  -- Week start
                s.reporting_frequency,
                s.module_name,
                s.event_type,
                s.failure_reason,
                ROUND(100.0 * SUM(s.failure_count) / NULLIF(wt.total_failure_count, 0), 2) AS failure_percentage,
                SUM(s.failure_count) AS failure_count,
                wt.total_failure_count,
                s.delay_in_days,
                s.trigger_flag,
                MAX(s.last_updated_timestamp) AS last_updated_timestamp
            FROM delta_prodna.reporting.sre_failure_statistics s
            CROSS JOIN anchors a
            JOIN weekly_totals wt
                ON s.pilot_id = wt.pilot_id
                AND s.meter_type = wt.meter_type
                AND s.fuel_type = wt.fuel_type
                AND CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) = wt.week_start
                AND s.event_type = wt.event_type
                AND s.delay_in_days = wt.delay_in_days
                and s.trigger_flag = wt.trigger_flag
                AND s.module_name = wt.module_name
            GROUP BY
                s.pilot_id, s.meter_type, s.fuel_type,
                CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE),
                s.reporting_frequency, s.module_name, s.event_type, s.failure_reason,
                s.delay_in_days, s.trigger_flag, wt.total_failure_count
        ),

        monthly_totals AS (
            SELECT
                pilot_id,
                meter_type,
                fuel_type,
                CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE) AS month_start,
                reporting_frequency,
                module_name,
                event_type,
                delay_in_days,
                trigger_flag,
                SUM(failure_count) AS total_failure_count
            FROM delta_prodna.reporting.sre_failure_statistics s
            CROSS JOIN anchors a
            GROUP BY
                pilot_id, meter_type, fuel_type,
                CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE),
                reporting_frequency, module_name, event_type, delay_in_days, trigger_flag
        ),

        monthly AS (
            SELECT
                s.pilot_id,
                'Monthly' AS period,
                s.meter_type,
                s.fuel_type,
                MAX(s.analysis_date) AS reporting_date,
                CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE) AS analysis_date,
                s.reporting_frequency,
                s.module_name,
                s.event_type,
                s.failure_reason,
                ROUND(100.0 * SUM(s.failure_count) / NULLIF(mt.total_failure_count, 0), 2) AS failure_percentage,
                SUM(s.failure_count) AS failure_count,
                mt.total_failure_count,
                s.delay_in_days,
                s.trigger_flag,
                MAX(s.last_updated_timestamp) AS last_updated_timestamp
            FROM delta_prodna.reporting.sre_failure_statistics s
            CROSS JOIN anchors a
            JOIN monthly_totals mt
                ON s.pilot_id = mt.pilot_id
                AND s.meter_type = mt.meter_type
                AND s.fuel_type = mt.fuel_type
                AND CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE) = mt.month_start
                AND s.event_type = mt.event_type
                AND s.delay_in_days = mt.delay_in_days
                and s.trigger_flag = mt.trigger_flag
                AND s.module_name = mt.module_name
            GROUP BY
                s.pilot_id, s.meter_type, s.fuel_type,
                CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE),
                s.reporting_frequency, s.module_name, s.event_type, s.failure_reason,
                s.delay_in_days, s.trigger_flag, mt.total_failure_count
        ),

        stats AS (
            SELECT * FROM daily
            UNION ALL
            SELECT * FROM weekly
            UNION ALL
            SELECT * FROM monthly
        ),

        joined_data AS (
            SELECT
                s.*,
                m.pilot_name,
                s.pilot_id || ' : ' || COALESCE(m.pilot_name, '') AS pilot_id_name
            FROM stats s
            LEFT JOIN (
                SELECT
                    pilot_id,
                    CASE
                        WHEN POSITION('(' IN pilot_name) > 0
                        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                        ELSE pilot_name
                    END AS pilot_name
                FROM delta_prodna.reporting.pilot_consolidated_product_type_events
            ) m ON s.pilot_id = CAST(m.pilot_id AS VARCHAR)
        ),

        ranked_data AS (
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY analysis_date, pilot_id, module_name, period
                    ORDER BY failure_percentage DESC
                ) AS rank
            FROM joined_data
        )

        SELECT *
        FROM ranked_data
        ORDER BY analysis_date DESC, pilot_id, module_name, period, failure_percentage DESC
      ) q
      WHERE q.period = {% parameter period %}
        AND {% condition date_range %} CAST(q.reporting_date AS DATE) {% endcondition %}
        AND {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition meter_type %} q.meter_type {% endcondition %}
        AND {% condition fuel_type %} q.fuel_type {% endcondition %}
        AND {% condition module_name %} q.module_name {% endcondition %}
    ;;
  }
  dimension: module_name {
    type: string
    description: "Source module name; filtering occurs after source failure ranking."
    sql: ${TABLE}.module_name ;;
  }
  dimension: failure_reason {
    type: string
    description: "Raw failure reason; NULLs are preserved."
    sql: ${TABLE}.failure_reason ;;
  }
  dimension: source_rank {
    type: number
    description: "Original ROW_NUMBER rank by analysis date, pilot, module, and period, before dashboard filters."
    sql: ${TABLE}.rank ;;
  }
  dimension: failure_percentage {
    type: number
    description: "Source failure_percentage; original period-level calculation retained."
    hidden: yes
    sql: ${TABLE}.failure_percentage ;;
  }
  measure: failure_percentage_average {
    type: average
    description: "Unweighted average of failure_percentage over selected source rows."
    value_format: "0.00\"%\""
    sql: ${failure_percentage} ;;
  }
}
