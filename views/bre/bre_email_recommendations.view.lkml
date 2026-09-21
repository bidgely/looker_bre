# Email Recommendation Quality. Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_email_recommendations {
  derived_table: {
    sql:
      SELECT
        ROW_NUMBER() OVER () AS row_id,
        CAST(s.pilot_id AS VARCHAR) AS pilot_id,
        CAST(p.pilot_name AS VARCHAR) AS pilot_name,
        CAST(CAST(s.pilot_id AS VARCHAR) || ' : ' || COALESCE(p.pilot_name, '') AS VARCHAR) AS pilot_id_name,
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
        CAST(s.fuel_type AS VARCHAR) AS fuel_type,
        CAST(NULL AS VARCHAR) AS module_name,
        CAST(s.email_type AS VARCHAR) AS email_type,
        CAST(s.bc_end_week_number AS VARCHAR) AS bc_end_week_number,
        CAST(NULL AS VARCHAR) AS cluster_id,
        CAST(NULL AS DATE) AS schedule_start,
        CAST(NULL AS DATE) AS schedule_end,
        CAST(s.appliance_name AS VARCHAR) AS appliance_name,
        CAST(s.metric_name AS VARCHAR) AS metric_name,
        CAST(NULL AS VARCHAR) AS application_error_code,
        CAST(NULL AS VARCHAR) AS failure_reason,
        CAST(NULL AS VARCHAR) AS reporting_frequency,
        CAST(NULL AS VARCHAR) AS trigger_flag,
        CAST(NULL AS VARCHAR) AS delivery_mode,
        CAST(NULL AS VARCHAR) AS event_type,
        CAST(NULL AS INTEGER) AS delay_in_days,
        CAST(NULL AS BOOLEAN) AS istou,
        CAST(s.metric_notification_count AS BIGINT) AS metric_notification_count,
        CAST(s.total_notification_count AS BIGINT) AS total_notification_count,
        CAST(s.notification_pct AS DOUBLE) AS notification_pct,
        CAST(s.user_count AS BIGINT) AS user_count,
        CAST(s.total_user_count AS BIGINT) AS total_user_count,
        CAST(s.user_pct AS DOUBLE) AS user_pct
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.reporting_date AS reporting_date,
        s.analysis_date AS analysis_date,
        s.bc_end_week_number AS bc_end_week_number,
        s.appliance_name AS appliance_name,
        s.fuel_type AS fuel_type,
        s.email_type AS email_type,
        s.metric_name AS metric_name,
        s.metric_notification_count AS metric_notification_count,
        s.total_notification_count AS total_notification_count,
        s.notification_pct AS notification_pct,
        s.user_count AS user_count,
        s.total_user_count AS total_user_count,
        s.user_pct AS user_pct,
        s.last_updated_timestamp AS last_updated_timestamp
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_quality_reco_stats AS s
      ) s
      LEFT JOIN ${bre_pilots.SQL_TABLE_NAME} p
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
