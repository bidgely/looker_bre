# Ingestion Failures. Original error-code rows; rank within analysis date, pilot and ingestion type.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_ingestion_failures {
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
        CAST(s.application_error_code AS VARCHAR) AS application_error_code,
        CAST(NULL AS VARCHAR) AS failure_reason,
        CAST(NULL AS VARCHAR) AS reporting_frequency,
        CAST(NULL AS VARCHAR) AS trigger_flag,
        CAST(NULL AS VARCHAR) AS delivery_mode,
        CAST(NULL AS VARCHAR) AS event_type,
        CAST(NULL AS INTEGER) AS delay_in_days,
        CAST(NULL AS BOOLEAN) AS istou,
        CAST(s.failed_record_count AS BIGINT) AS failed_record_count,
        CAST(s.total_failed_record_count AS BIGINT) AS total_failed_record_count,
        CAST(s.failure_percentage AS DECIMAL(26, 2)) AS failure_percentage
      FROM (
      SELECT
        _0.pilot_id AS pilot_id,
        _0.ingestion_type AS ingestion_type,
        _0.analysis_date AS analysis_date,
        _0.reporting_date AS reporting_date,
        _0.application_error_code AS application_error_code,
        _0.failed_record_count AS failed_record_count,
        _0.total_failed_record_count AS total_failed_record_count,
        _0.failure_percentage AS failure_percentage,
        _0.last_updated_timestamp AS last_updated_timestamp,
        _0.rank AS rank
      FROM (
        SELECT
          sfs.pilot_id AS pilot_id,
          sfs.ingestion_type AS ingestion_type,
          sfs.analysis_date AS analysis_date,
          sfs.reporting_date AS reporting_date,
          sfs.application_error_code AS application_error_code,
          sfs.failed_record_count AS failed_record_count,
          sfs.total_failed_record_count AS total_failed_record_count,
          sfs.failure_percentage AS failure_percentage,
          sfs.last_updated_timestamp AS last_updated_timestamp,
          ROW_NUMBER() OVER (
            PARTITION BY sfs.analysis_date, sfs.pilot_id, sfs.ingestion_type
            ORDER BY sfs.failure_percentage DESC NULLS FIRST
          ) AS rank
        FROM (
          SELECT
            s.pilot_id AS pilot_id,
            s.ingestion_type AS ingestion_type,
            s.analysis_date AS analysis_date,
            s.reporting_date AS reporting_date,
            s.application_error_code AS application_error_code,
            s.failed_record_count AS failed_record_count,
            s.total_failed_record_count AS total_failed_record_count,
            s.failure_percentage AS failure_percentage,
            s.last_updated_timestamp AS last_updated_timestamp
          FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% elsif _model._name == 'bre_na' %}delta_prodna{% else %}bre_invalid_model{% endif %}.reporting.sre_ingestion_errors_statistic AS s
        ) AS sfs
      ) AS _0
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
