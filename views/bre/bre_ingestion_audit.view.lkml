# Ingestion Audit. Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_ingestion_audit {
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
        CAST(s.pilot_name AS VARCHAR) AS source_pilot_name,
        CAST(NULL AS VARCHAR) AS source_period,
        CAST(NULL AS BIGINT) AS source_rank,
        CAST(s.ingestion_type AS VARCHAR) AS ingestion_type,
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
        CAST(s.total_files_processed AS BIGINT) AS total_files_processed,
        CAST(s.total_chunks_processed AS BIGINT) AS total_chunks_processed,
        CAST(s.total_records_count AS BIGINT) AS total_records_count,
        CAST(s.total_success_record_count AS BIGINT) AS total_success_record_count,
        CAST(s.total_failure_record_count AS BIGINT) AS total_failure_record_count,
        CAST(s.success_percentage AS DECIMAL(26, 2)) AS success_percentage,
        CAST(s.failure_percentage AS DECIMAL(26, 2)) AS failure_percentage
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.pilot_name AS pilot_name,
        s.ingestion_type AS ingestion_type,
        s.analysis_date AS analysis_date,
        s.reporting_date AS reporting_date,
        s.total_files_processed AS total_files_processed,
        s.total_chunks_processed AS total_chunks_processed,
        s.total_records_count AS total_records_count,
        s.total_success_record_count AS total_success_record_count,
        s.total_failure_record_count AS total_failure_record_count,
        s.success_percentage AS success_percentage,
        s.failure_percentage AS failure_percentage,
        s.last_updated_timestamp AS last_updated_timestamp
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_ingestion_audit AS s
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
