# Email Failures. Original failure-reason rows; rank by count within original analysis date, pilot and email type.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_email_failures {
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
        CAST(NULL AS VARCHAR) AS source_period,
        CAST(s.rank AS BIGINT) AS source_rank,
        CAST(NULL AS VARCHAR) AS ingestion_type,
        CAST(NULL AS VARCHAR) AS meter_type,
        CAST(NULL AS VARCHAR) AS fuel_type,
        CAST(NULL AS VARCHAR) AS module_name,
        CAST(s.email_type AS VARCHAR) AS email_type,
        CAST(s.bc_end_week_number AS VARCHAR) AS bc_end_week_number,
        CAST(NULL AS VARCHAR) AS cluster_id,
        CAST(NULL AS DATE) AS schedule_start,
        CAST(NULL AS DATE) AS schedule_end,
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
        CAST(s.failure_pct AS DOUBLE) AS failure_pct
      FROM (
      SELECT
        sfs.pilot_id AS pilot_id,
        sfs.reporting_date AS reporting_date,
        sfs.analysis_date AS analysis_date,
        sfs.email_type AS email_type,
        sfs.bc_end_week_number AS bc_end_week_number,
        sfs.failure_reason AS failure_reason,
        sfs.failure_count AS failure_count,
        sfs.total_failure_count AS total_failure_count,
        sfs.failure_pct AS failure_pct,
        sfs.last_updated_timestamp AS last_updated_timestamp,
        ROW_NUMBER() OVER (
          PARTITION BY sfs.analysis_date, sfs.pilot_id, sfs.email_type
          ORDER BY sfs.failure_count DESC NULLS FIRST
        ) AS rank
      FROM (
        SELECT
          s.pilot_id AS pilot_id,
          s.reporting_date AS reporting_date,
          s.analysis_date AS analysis_date,
          s.email_type AS email_type,
          s.bc_end_week_number AS bc_end_week_number,
          s.failure_reason AS failure_reason,
          s.failure_count AS failure_count,
          s.total_failure_count AS total_failure_count,
          s.failure_pct AS failure_pct,
          s.last_updated_timestamp AS last_updated_timestamp
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_email_failure_reasons AS s
      ) AS sfs
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
