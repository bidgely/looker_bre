# HER Generation Failures. Pilot, cluster, schedule, fuel, reason and both analysis/reporting periods; ranking retains the original partition.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_her_failures {
  derived_table: {
    sql:
      SELECT
        ROW_NUMBER() OVER () AS row_id,
        CAST(s.pilot_id AS VARCHAR) AS pilot_id,
        CAST(p.pilot_name AS VARCHAR) AS pilot_name,
        CAST(CAST(s.pilot_id AS VARCHAR) || ' : ' || p.pilot_name AS VARCHAR) AS pilot_id_name,
        CAST(p.time_zone AS VARCHAR) AS time_zone,
        CAST(s.analysis_date AS DATE) AS analysis_date,
        CAST(s.reporting_date AS DATE) AS reporting_date,
        CAST(s.last_updated_timestamp AS TIMESTAMP(6)) AS last_updated_timestamp,
        CAST(s.analysis_date AS VARCHAR) AS source_analysis_value,
        CAST(s.reporting_date AS VARCHAR) AS source_reporting_value,
        CAST(NULL AS VARCHAR) AS source_pilot_name,
        CAST(s.period AS VARCHAR) AS source_period,
        CAST(s.rank AS BIGINT) AS source_rank,
        CAST(NULL AS VARCHAR) AS ingestion_type,
        CAST(NULL AS VARCHAR) AS meter_type,
        CAST(s.fuel_type AS VARCHAR) AS fuel_type,
        CAST(NULL AS VARCHAR) AS module_name,
        CAST(NULL AS VARCHAR) AS email_type,
        CAST(NULL AS VARCHAR) AS bc_end_week_number,
        CAST(s.cluster_id AS VARCHAR) AS cluster_id,
        CAST(s.schedule_start AS DATE) AS schedule_start,
        CAST(s.schedule_end AS DATE) AS schedule_end,
        CAST(NULL AS VARCHAR) AS appliance_name,
        CAST(NULL AS VARCHAR) AS metric_name,
        CAST(NULL AS VARCHAR) AS application_error_code,
        CAST(s.failure_reason AS VARCHAR) AS failure_reason,
        CAST(NULL AS VARCHAR) AS reporting_frequency,
        CAST(NULL AS VARCHAR) AS trigger_flag,
        CAST(NULL AS VARCHAR) AS delivery_mode,
        CAST(NULL AS VARCHAR) AS event_type,
        CAST(NULL AS INTEGER) AS delay_in_days,
        CAST(NULL AS BOOLEAN) AS istou,
        CAST(s.failure_count AS BIGINT) AS failure_count,
        CAST(s.total_failure_count AS BIGINT) AS total_failure_count,
        CAST(s.failure_percentage AS DOUBLE) AS failure_percentage
      FROM (
      WITH cte AS (
        SELECT
          sre_her_schedule_errors.analysis_date AS analysis_date,
          sre_her_schedule_errors.reporting_date AS reporting_date,
          sre_her_schedule_errors.pilot_id AS pilot_id,
          sre_her_schedule_errors.cluster_id AS cluster_id,
          sre_her_schedule_errors.schedule_start AS schedule_start,
          sre_her_schedule_errors.schedule_end AS schedule_end,
          sre_her_schedule_errors.failure_reason AS failure_reason,
          sre_her_schedule_errors.measurement_type AS measurement_type,
          'Daily' AS "period",
          sre_her_schedule_errors.failure_count AS failure_count,
          sre_her_schedule_errors.last_updated_timestamp AS last_updated_timestamp
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_her_schedule_errors AS sre_her_schedule_errors
        UNION ALL
        SELECT
          CAST(DATE_TRUNC('WEEK', sre_her_schedule_errors.analysis_date) AS DATE) AS analysis_date,
          CAST(DATE_TRUNC('WEEK', sre_her_schedule_errors.reporting_date) AS DATE) AS reporting_date,
          sre_her_schedule_errors.pilot_id AS pilot_id,
          sre_her_schedule_errors.cluster_id AS cluster_id,
          sre_her_schedule_errors.schedule_start AS schedule_start,
          sre_her_schedule_errors.schedule_end AS schedule_end,
          sre_her_schedule_errors.failure_reason AS failure_reason,
          sre_her_schedule_errors.measurement_type AS measurement_type,
          'Weekly' AS "period",
          SUM(sre_her_schedule_errors.failure_count) AS failure_count,
          MAX(sre_her_schedule_errors.last_updated_timestamp) AS last_updated_timestamp
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_her_schedule_errors AS sre_her_schedule_errors
        GROUP BY
          CAST(DATE_TRUNC('WEEK', sre_her_schedule_errors.analysis_date) AS DATE),
          CAST(DATE_TRUNC('WEEK', sre_her_schedule_errors.reporting_date) AS DATE),
          sre_her_schedule_errors.pilot_id,
          sre_her_schedule_errors.cluster_id,
          sre_her_schedule_errors.schedule_start,
          sre_her_schedule_errors.schedule_end,
          sre_her_schedule_errors.failure_reason,
          sre_her_schedule_errors.measurement_type
        UNION ALL
        SELECT
          CAST(DATE_TRUNC('MONTH', sre_her_schedule_errors.analysis_date) AS DATE) AS analysis_date,
          CAST(DATE_TRUNC('MONTH', sre_her_schedule_errors.reporting_date) AS DATE) AS reporting_date,
          sre_her_schedule_errors.pilot_id AS pilot_id,
          sre_her_schedule_errors.cluster_id AS cluster_id,
          sre_her_schedule_errors.schedule_start AS schedule_start,
          sre_her_schedule_errors.schedule_end AS schedule_end,
          sre_her_schedule_errors.failure_reason AS failure_reason,
          sre_her_schedule_errors.measurement_type AS measurement_type,
          'Monthly' AS "period",
          SUM(sre_her_schedule_errors.failure_count) AS failure_count,
          MAX(sre_her_schedule_errors.last_updated_timestamp) AS last_updated_timestamp
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_her_schedule_errors AS sre_her_schedule_errors
        GROUP BY
          CAST(DATE_TRUNC('MONTH', sre_her_schedule_errors.analysis_date) AS DATE),
          CAST(DATE_TRUNC('MONTH', sre_her_schedule_errors.reporting_date) AS DATE),
          sre_her_schedule_errors.pilot_id,
          sre_her_schedule_errors.cluster_id,
          sre_her_schedule_errors.schedule_start,
          sre_her_schedule_errors.schedule_end,
          sre_her_schedule_errors.failure_reason,
          sre_her_schedule_errors.measurement_type
      ), her_errors AS (
        SELECT
          a.pilot_id AS pilot_id,
          a.cluster_id AS cluster_id,
          a.schedule_start AS schedule_start,
          a.schedule_end AS schedule_end,
          a.measurement_type AS fuel_type,
          a.failure_reason AS failure_reason,
          a.failure_count AS failure_count,
          b.total_failure_count AS total_failure_count,
          a.period AS period,
          a.analysis_date AS analysis_date,
          a.reporting_date AS reporting_date,
          ROUND((
            100.00 * a.failure_count
          ) / NULLIF(b.total_failure_count, 0), 2) AS failure_percentage,
          a.last_updated_timestamp AS last_updated_timestamp,
          ROW_NUMBER() OVER (
            PARTITION BY a.pilot_id, a.cluster_id, a.schedule_start, a.schedule_end, a.measurement_type, a."period", a.analysis_date
            ORDER BY a.failure_count DESC NULLS FIRST
          ) AS rank
        FROM cte AS a
        JOIN (
          SELECT
            cte.pilot_id AS pilot_id,
            cte.cluster_id AS cluster_id,
            cte.schedule_start AS schedule_start,
            cte.schedule_end AS schedule_end,
            cte.measurement_type AS measurement_type,
            cte."period" AS "period",
            cte.analysis_date AS analysis_date,
            cte.reporting_date AS reporting_date,
            SUM(cte.failure_count) AS total_failure_count
          FROM cte AS cte
          GROUP BY
            cte.pilot_id,
            cte.cluster_id,
            cte.schedule_start,
            cte.schedule_end,
            cte.measurement_type,
            cte."period",
            cte.analysis_date,
            cte.reporting_date
        ) AS b
          ON a.pilot_id = b.pilot_id
          AND a.cluster_id = b.cluster_id
          AND a.schedule_start = b.schedule_start
          AND a.schedule_end = b.schedule_end
          AND a.measurement_type = b.measurement_type
          AND a."period" = b."period"
          AND a.analysis_date = b.analysis_date
          AND a.reporting_date = b.reporting_date
      )
      SELECT
        s.pilot_id AS pilot_id,
        s.cluster_id AS cluster_id,
        s.schedule_start AS schedule_start,
        s.schedule_end AS schedule_end,
        s.fuel_type AS fuel_type,
        s.failure_reason AS failure_reason,
        s.failure_count AS failure_count,
        s.total_failure_count AS total_failure_count,
        s.period AS period,
        s.analysis_date AS analysis_date,
        s.reporting_date AS reporting_date,
        s.failure_percentage AS failure_percentage,
        s.last_updated_timestamp AS last_updated_timestamp,
        s.rank AS rank
      FROM her_errors AS s
      ) s
      INNER JOIN ${bre_pilots.SQL_TABLE_NAME} p
        ON CAST(s.pilot_id AS VARCHAR) = p.pilot_id
    ;;
  }
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local source row identifier. Preserves duplicate source rows; not a durable business key or a deduplication rule."
    sql: ${TABLE}.row_id ;;
  }
}
