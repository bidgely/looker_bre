# Billing-Cycle Length. Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_billing_length {
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
        CAST(NULL AS TIMESTAMP(6)) AS last_updated_timestamp,
        CAST(s.analysis_date AS VARCHAR) AS source_analysis_value,
        CAST(s.reporting_date AS VARCHAR) AS source_reporting_value,
        CAST(NULL AS VARCHAR) AS source_pilot_name,
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
        CAST(s.bc_1_15_count AS BIGINT) AS bc_1_15_count,
        CAST(s.bc_15_30_count AS BIGINT) AS bc_15_30_count,
        CAST(s.bc_31_45_count AS BIGINT) AS bc_31_45_count,
        CAST(s.bc_45_60_count AS BIGINT) AS bc_45_60_count,
        CAST(s.bc_61_75_count AS BIGINT) AS bc_61_75_count,
        CAST(s.bc_76_90_count AS BIGINT) AS bc_76_90_count,
        CAST(s.bc_gt_90_count AS BIGINT) AS bc_gt_90_count
      FROM (
      SELECT
        ubt.pilot_id AS pilot_id,
        ubt.bc_1_15_count AS bc_1_15_count,
        ubt.bc_15_30_count AS bc_15_30_count,
        ubt.bc_31_45_count AS bc_31_45_count,
        ubt.bc_45_60_count AS bc_45_60_count,
        ubt.bc_61_75_count AS bc_61_75_count,
        ubt.bc_76_90_count AS bc_76_90_count,
        ubt.bc_gt_90_count AS bc_gt_90_count,
        ubt.analysis_date AS analysis_date,
        ubt.reporting_date AS reporting_date,
        CASE
          WHEN ubt.pilot_id IN (
            10021,
            10024,
            10043,
            10046,
            10047,
            10048,
            10049,
            10050,
            10051,
            10055,
            10064,
            10068,
            10070,
            10082,
            10110
          )
          THEN 'OPOWER'
          ELSE 'BILLING'
        END AS ingestion_type
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.utility_billing_length_tracker AS ubt
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
