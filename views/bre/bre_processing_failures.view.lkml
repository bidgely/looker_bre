# Processing Failures. Original failure-detail rows; rank by percentage within analysis date, pilot and module, before optional top-three filtering.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_processing_failures {
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
        CAST(s.meter_type AS VARCHAR) AS meter_type,
        CAST(s.fuel_type AS VARCHAR) AS fuel_type,
        CAST(s.module_name AS VARCHAR) AS module_name,
        CAST(NULL AS VARCHAR) AS email_type,
        CAST(NULL AS VARCHAR) AS bc_end_week_number,
        CAST(NULL AS VARCHAR) AS cluster_id,
        CAST(NULL AS DATE) AS schedule_start,
        CAST(NULL AS DATE) AS schedule_end,
        CAST(NULL AS VARCHAR) AS appliance_name,
        CAST(NULL AS VARCHAR) AS metric_name,
        CAST(NULL AS VARCHAR) AS application_error_code,
        CAST(s.failure_reason AS VARCHAR) AS failure_reason,
        CAST(s.reporting_frequency AS VARCHAR) AS reporting_frequency,
        CAST(s.trigger_flag AS VARCHAR) AS trigger_flag,
        CAST(NULL AS VARCHAR) AS delivery_mode,
        CAST(s.event_type AS VARCHAR) AS event_type,
        CAST(s.delay_in_days AS INTEGER) AS delay_in_days,
        CAST(NULL AS BOOLEAN) AS istou,
        CAST(s.failure_percentage AS DECIMAL(5, 2)) AS failure_percentage,
        CAST(s.failure_count AS INTEGER) AS failure_count,
        CAST(s.total_failure_count AS INTEGER) AS total_failure_count
      FROM (
      SELECT
        _0.pilot_id AS pilot_id,
        _0.meter_type AS meter_type,
        _0.fuel_type AS fuel_type,
        _0.reporting_date AS reporting_date,
        _0.analysis_date AS analysis_date,
        _0.reporting_frequency AS reporting_frequency,
        _0.module_name AS module_name,
        _0.event_type AS event_type,
        _0.failure_reason AS failure_reason,
        _0.failure_percentage AS failure_percentage,
        _0.delay_in_days AS delay_in_days,
        _0.last_updated_timestamp AS last_updated_timestamp,
        _0.trigger_flag AS trigger_flag,
        _0.failure_count AS failure_count,
        _0.total_failure_count AS total_failure_count,
        _0.rank AS rank
      FROM (
        SELECT
          sfs.pilot_id AS pilot_id,
          sfs.meter_type AS meter_type,
          sfs.fuel_type AS fuel_type,
          sfs.reporting_date AS reporting_date,
          sfs.analysis_date AS analysis_date,
          sfs.reporting_frequency AS reporting_frequency,
          sfs.module_name AS module_name,
          sfs.event_type AS event_type,
          sfs.failure_reason AS failure_reason,
          sfs.failure_percentage AS failure_percentage,
          sfs.delay_in_days AS delay_in_days,
          sfs.last_updated_timestamp AS last_updated_timestamp,
          sfs.trigger_flag AS trigger_flag,
          sfs.failure_count AS failure_count,
          sfs.total_failure_count AS total_failure_count,
          ROW_NUMBER() OVER (
            PARTITION BY sfs.analysis_date, sfs.pilot_id, sfs.module_name
            ORDER BY sfs.failure_percentage DESC NULLS FIRST
          ) AS rank
        FROM (
          SELECT
            s.pilot_id AS pilot_id,
            s.meter_type AS meter_type,
            s.fuel_type AS fuel_type,
            s.reporting_date AS reporting_date,
            s.analysis_date AS analysis_date,
            s.reporting_frequency AS reporting_frequency,
            s.module_name AS module_name,
            s.event_type AS event_type,
            s.failure_reason AS failure_reason,
            s.failure_percentage AS failure_percentage,
            s.delay_in_days AS delay_in_days,
            s.last_updated_timestamp AS last_updated_timestamp,
            s.trigger_flag AS trigger_flag,
            s.failure_count AS failure_count,
            s.total_failure_count AS total_failure_count
          FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_failure_statistics AS s
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
