# Disagg Quality. Original quality rows by pilot, dates, meter, fuel and TOU status.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_disagg_quality {
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
        CAST(s.meter_type AS VARCHAR) AS meter_type,
        CAST(s.fuel_type AS VARCHAR) AS fuel_type,
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
        CAST(s.istou AS BOOLEAN) AS istou,
        CAST(s.appliances_kwh_variance_pct_1 AS DECIMAL(10, 2)) AS appliances_kwh_variance_pct_1,
        CAST(s.appliances_kwh_variance_pct_2 AS DECIMAL(10, 2)) AS appliances_kwh_variance_pct_2,
        CAST(s.total_cost_deviation_pct_1 AS DECIMAL(10, 2)) AS total_cost_deviation_pct_1,
        CAST(s.total_cost_deviation_pct_2 AS DECIMAL(10, 2)) AS total_cost_deviation_pct_2,
        CAST(s.cost_per_kwh_deviation_pct AS DECIMAL(10, 2)) AS cost_per_kwh_deviation_pct,
        CAST(s.seasonal_appliance_usage_deviation_pct AS DECIMAL(10, 2)) AS seasonal_appliance_usage_deviation_pct,
        CAST(s.single_appliance_domination_deviation_pct AS DECIMAL(10, 2)) AS single_appliance_domination_deviation_pct,
        CAST(s.missing_dwelliing_pct AS DECIMAL(10, 2)) AS missing_dwelliing_pct,
        CAST(s.ao_pct_non_tou AS DECIMAL(10, 2)) AS ao_pct_non_tou,
        CAST(s.ac_pct_non_tou AS DECIMAL(10, 2)) AS ac_pct_non_tou,
        CAST(s.sh_pct_non_tou AS DECIMAL(10, 2)) AS sh_pct_non_tou,
        CAST(s.other_pct_non_tou AS DECIMAL(10, 2)) AS other_pct_non_tou,
        CAST(s.solar_pct_non_tou AS DECIMAL(10, 2)) AS solar_pct_non_tou,
        CAST(s.missing_solar_pct_non_tou AS DECIMAL(10, 2)) AS missing_solar_pct_non_tou
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.reporting_date AS reporting_date,
        s.analysis_date AS analysis_date,
        s.meter_type AS meter_type,
        s.fuel_type AS fuel_type,
        s.istou AS istou,
        s.appliances_kwh_variance_pct_1 AS appliances_kwh_variance_pct_1,
        s.appliances_kwh_variance_pct_2 AS appliances_kwh_variance_pct_2,
        s.total_cost_deviation_pct_1 AS total_cost_deviation_pct_1,
        s.total_cost_deviation_pct_2 AS total_cost_deviation_pct_2,
        s.cost_per_kwh_deviation_pct AS cost_per_kwh_deviation_pct,
        s.seasonal_appliance_usage_deviation_pct AS seasonal_appliance_usage_deviation_pct,
        s.single_appliance_domination_deviation_pct AS single_appliance_domination_deviation_pct,
        s.missing_dwelliing_pct AS missing_dwelliing_pct,
        s.ao_pct_non_tou AS ao_pct_non_tou,
        s.ac_pct_non_tou AS ac_pct_non_tou,
        s.sh_pct_non_tou AS sh_pct_non_tou,
        s.other_pct_non_tou AS other_pct_non_tou,
        s.solar_pct_non_tou AS solar_pct_non_tou,
        s.missing_solar_pct_non_tou AS missing_solar_pct_non_tou,
        s.last_updated_timestamp AS last_updated_timestamp
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_quality_disagg AS s
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
