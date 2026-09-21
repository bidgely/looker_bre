# Pilot Reporting Dates. One row per pilot; independent maximum analysis and reporting timestamps across the original six tables.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_pilot_reporting {
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
        CAST(NULL AS TIMESTAMP(6)) AS last_updated_timestamp,
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
        CAST(NULL AS BOOLEAN) AS istou
      FROM (
      WITH all_data AS (
        SELECT
          CAST(sre_ingestion_audit.pilot_id AS VARCHAR) AS pilot_id,
          CAST(sre_ingestion_audit.analysis_date AS TIMESTAMP) AS analysis_date,
          CAST(sre_ingestion_audit.reporting_date AS TIMESTAMP) AS reporting_date
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_ingestion_audit AS sre_ingestion_audit
        UNION ALL
        SELECT
          CAST(sre_invoice_statistics.pilot_id AS VARCHAR) AS pilot_id,
          CAST(sre_invoice_statistics.analysis_date AS TIMESTAMP) AS analysis_date,
          CAST(sre_invoice_statistics.reporting_date AS TIMESTAMP) AS reporting_date
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_invoice_statistics AS sre_invoice_statistics
        UNION ALL
        SELECT
          CAST(sre_quality_email_stats.pilot_id AS VARCHAR) AS pilot_id,
          CAST(sre_quality_email_stats.analysis_date AS TIMESTAMP) AS analysis_date,
          CAST(sre_quality_email_stats.reporting_date AS TIMESTAMP) AS reporting_date
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_quality_email_stats AS sre_quality_email_stats
        UNION ALL
        SELECT
          CAST(sre_nbi_generated_errors.pilot_id AS VARCHAR) AS pilot_id,
          CAST(sre_nbi_generated_errors.analysis_date AS TIMESTAMP) AS analysis_date,
          CAST(sre_nbi_generated_errors.reporting_date AS TIMESTAMP) AS reporting_date
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_nbi_generated_errors AS sre_nbi_generated_errors
        UNION ALL
        SELECT
          CAST(sre_cluster_eligible_users.pilot_id AS VARCHAR) AS pilot_id,
          CAST(sre_cluster_eligible_users.analysis_date AS TIMESTAMP) AS analysis_date,
          CAST(sre_cluster_eligible_users.reporting_date AS TIMESTAMP) AS reporting_date
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_cluster_eligible_users AS sre_cluster_eligible_users
        UNION ALL
        SELECT
          CAST(sre_email_daily_tracker.pilot_id AS VARCHAR) AS pilot_id,
          CAST(sre_email_daily_tracker.analysis_date AS TIMESTAMP) AS analysis_date,
          CAST(sre_email_daily_tracker.reporting_date AS TIMESTAMP) AS reporting_date
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_email_daily_tracker AS sre_email_daily_tracker
      ), latest_data AS (
        SELECT
          all_data.pilot_id AS pilot_id,
          MAX(all_data.analysis_date) AS analysis_date,
          MAX(all_data.reporting_date) AS reporting_date
        FROM all_data AS all_data
        GROUP BY
          all_data.pilot_id
      )
      SELECT
        l.pilot_id AS pilot_id,
        l.analysis_date AS analysis_date,
        l.reporting_date AS reporting_date
      FROM latest_data AS l
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
