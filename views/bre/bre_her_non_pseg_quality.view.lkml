# HER Non-PSEG Quality. Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_her_non_pseg_quality {
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
        CAST(s.low_bc_duration_count AS BIGINT) AS low_bc_duration_count,
        CAST(s.high_bc_duration_count AS BIGINT) AS high_bc_duration_count,
        CAST(s.staleness_count AS BIGINT) AS staleness_count,
        CAST(s.solar_template_count AS BIGINT) AS solar_template_count,
        CAST(s.solar_consistency_count AS BIGINT) AS solar_consistency_count,
        CAST(s.solar_generation_count AS BIGINT) AS solar_generation_count,
        CAST(s.report_consistency_count AS BIGINT) AS report_consistency_count,
        CAST(s.itemization_count AS BIGINT) AS itemization_count,
        CAST(s.bill_change_consistency_count AS BIGINT) AS bill_change_consistency_count,
        CAST(s.ev_itemization_count AS BIGINT) AS ev_itemization_count,
        CAST(s.tou_template_count AS BIGINT) AS tou_template_count,
        CAST(s.nbi_occurance_count AS BIGINT) AS nbi_occurance_count,
        CAST(s.nbi_value_count AS BIGINT) AS nbi_value_count,
        CAST(s.nbi_appliance_itemisation_count AS BIGINT) AS nbi_appliance_itemisation_count,
        CAST(s.nbi_non_null_insight_count AS BIGINT) AS nbi_non_null_insight_count,
        CAST(s.nbi_unicode_count AS BIGINT) AS nbi_unicode_count,
        CAST(s.nbi_extreme_insight_count AS BIGINT) AS nbi_extreme_insight_count
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        CAST(s.analysis_date AS DATE) AS analysis_date,
        CAST(s.reporting_date AS DATE) AS reporting_date,
        s.low_bc_duration_count AS low_bc_duration_count,
        s.high_bc_duration_count AS high_bc_duration_count,
        s.staleness_count AS staleness_count,
        s.solar_template_count AS solar_template_count,
        s.solar_consistency_count AS solar_consistency_count,
        s.solar_generation_count AS solar_generation_count,
        s.report_consistency_count AS report_consistency_count,
        s.itemization_count AS itemization_count,
        s.bill_change_consistency_count AS bill_change_consistency_count,
        s.ev_itemization_count AS ev_itemization_count,
        s.tou_template_count AS tou_template_count,
        s.last_updated_timestamp AS last_updated_timestamp,
        s.nbi_occurance_count AS nbi_occurance_count,
        s.nbi_value_count AS nbi_value_count,
        s.nbi_appliance_itemisation_count AS nbi_appliance_itemisation_count,
        s.nbi_non_null_insight_count AS nbi_non_null_insight_count,
        s.nbi_unicode_count AS nbi_unicode_count,
        s.nbi_extreme_insight_count AS nbi_extreme_insight_count
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_her_qc_data AS s
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
