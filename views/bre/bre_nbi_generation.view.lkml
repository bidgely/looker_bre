# NBI Generation. Original pilot and analysis/reporting date rows with generation and error counts.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_nbi_generation {
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
        CAST(NULL AS BIGINT) AS source_rank,
        CAST(NULL AS VARCHAR) AS ingestion_type,
        CAST(NULL AS VARCHAR) AS meter_type,
        CAST(NULL AS VARCHAR) AS fuel_type,
        CAST(NULL AS VARCHAR) AS module_name,
        CAST(NULL AS VARCHAR) AS email_type,
        CAST(NULL AS VARCHAR) AS bc_end_week_number,
        CAST(NULL AS VARCHAR) AS cluster_id,
        CAST(NULL AS DATE) AS schedule_start,
        CAST(NULL AS DATE) AS schedule_end,
        CAST(NULL AS VARCHAR) AS appliance_name,
        CAST(NULL AS VARCHAR) AS metric_name,
        CAST(NULL AS VARCHAR) AS application_error_code,
        CAST(NULL AS VARCHAR) AS failure_reason,
        CAST(NULL AS VARCHAR) AS reporting_frequency,
        CAST(NULL AS VARCHAR) AS trigger_flag,
        CAST(NULL AS VARCHAR) AS delivery_mode,
        CAST(NULL AS VARCHAR) AS event_type,
        CAST(NULL AS INTEGER) AS delay_in_days,
        CAST(NULL AS BOOLEAN) AS istou,
        CAST(s.total_users_successful AS BIGINT) AS total_users_successful,
        CAST(s.total_users_with_200_errorcode AS BIGINT) AS total_users_with_200_errorcode,
        CAST(s.total_users_with_300_errorcode AS BIGINT) AS total_users_with_300_errorcode,
        CAST(s.nbi_error_pct AS DECIMAL(26, 2)) AS nbi_error_pct
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.analysis_date AS analysis_date,
        s.reporting_date AS reporting_date,
        s.total_nbi_users AS total_users_successful,
        s.total_users_with_200_errorcode AS total_users_with_200_errorcode,
        s.total_users_with_300_errorcode AS total_users_with_300_errorcode,
        s.nbi_error_pct AS nbi_error_pct,
        s.last_updated_timestamp AS last_updated_timestamp
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_nbi_generated_errors AS s
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
