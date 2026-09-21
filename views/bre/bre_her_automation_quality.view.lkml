# HER Automation Quality. Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_her_automation_quality {
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
        CAST(s.period AS VARCHAR) AS source_period,
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
        CAST(s.low_bc_duration_cnt AS BIGINT) AS low_bc_duration_cnt,
        CAST(s.high_bc_duration_cnt AS BIGINT) AS high_bc_duration_cnt,
        CAST(s.staleness_cnt AS BIGINT) AS staleness_cnt,
        CAST(s.solar_template_cnt AS BIGINT) AS solar_template_cnt,
        CAST(s.solar_consistency_cnt AS BIGINT) AS solar_consistency_cnt,
        CAST(s.solar_generation_cnt AS BIGINT) AS solar_generation_cnt,
        CAST(s.report_consistency_cnt AS BIGINT) AS report_consistency_cnt,
        CAST(s.itemization_cnt AS BIGINT) AS itemization_cnt,
        CAST(s.bill_change_consistency_cnt AS BIGINT) AS bill_change_consistency_cnt,
        CAST(s.ev_itemization_cnt AS BIGINT) AS ev_itemization_cnt,
        CAST(s.tou_template_cnt AS BIGINT) AS tou_template_cnt,
        CAST(s.nbi_occurence_cnt AS BIGINT) AS nbi_occurence_cnt,
        CAST(s.nbi_value_cnt AS BIGINT) AS nbi_value_cnt,
        CAST(s.nbi_appliance_itemization_cnt AS BIGINT) AS nbi_appliance_itemization_cnt,
        CAST(s.nbi_non_null_insight_cnt AS BIGINT) AS nbi_non_null_insight_cnt,
        CAST(s.nbi_unicode_cnt AS BIGINT) AS nbi_unicode_cnt,
        CAST(s.nbi_extreme_insight_cnt AS BIGINT) AS nbi_extreme_insight_cnt,
        CAST(s.nbi_seasonal_appliance_cnt AS BIGINT) AS nbi_seasonal_appliance_cnt,
        CAST(s.overall_report_count AS BIGINT) AS overall_report_count
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.reporting_date AS reporting_date,
        s.analysis_date AS analysis_date,
        s.low_bc_duration_cnt AS low_bc_duration_cnt,
        s.high_bc_duration_cnt AS high_bc_duration_cnt,
        s.staleness_cnt AS staleness_cnt,
        s.solar_template_cnt AS solar_template_cnt,
        s.solar_consistency_cnt AS solar_consistency_cnt,
        s.solar_generation_cnt AS solar_generation_cnt,
        s.report_consistency_cnt AS report_consistency_cnt,
        s.itemization_cnt AS itemization_cnt,
        s.bill_change_consistency_cnt AS bill_change_consistency_cnt,
        s.ev_itemization_cnt AS ev_itemization_cnt,
        s.tou_template_cnt AS tou_template_cnt,
        s.nbi_occurence_cnt AS nbi_occurence_cnt,
        s.nbi_value_cnt AS nbi_value_cnt,
        s.nbi_appliance_itemization_cnt AS nbi_appliance_itemization_cnt,
        s.nbi_non_null_insight_cnt AS nbi_non_null_insight_cnt,
        s.nbi_unicode_cnt AS nbi_unicode_cnt,
        s.nbi_extreme_insight_cnt AS nbi_extreme_insight_cnt,
        s.nbi_seasonal_appliance_cnt AS nbi_seasonal_appliance_cnt,
        s.overall_report_count AS overall_report_count,
        s.period AS period
      FROM (
        SELECT
          her_automation_query_results.pilot_id AS pilot_id,
          CAST(DATE_ADD(
            'DAY',
            her_automation_query_results.epoch_day + 1,
            CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
          ) AS DATE) AS reporting_date,
          CAST(DATE_ADD(
            'DAY',
            her_automation_query_results.epoch_day,
            CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
          ) AS DATE) AS analysis_date,
          SUM(
            CASE
              WHEN her_automation_query_results.low_bc_duration_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS low_bc_duration_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.high_bc_duration_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS high_bc_duration_cnt,
          SUM(CASE WHEN her_automation_query_results.staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_template_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_template_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_consistency_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_generation_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_generation_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.report_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS report_consistency_cnt,
          SUM(
            CASE WHEN her_automation_query_results.itemization_check = 'bad' THEN 1 ELSE 0 END
          ) AS itemization_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.bill_change_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS bill_change_consistency_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.ev_itemization_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS ev_itemization_cnt,
          SUM(
            CASE WHEN her_automation_query_results.tou_template_check = 'bad' THEN 1 ELSE 0 END
          ) AS tou_template_cnt,
          SUM(
            CASE WHEN her_automation_query_results.nbi_occurence_check = 'bad' THEN 1 ELSE 0 END
          ) AS nbi_occurence_cnt,
          SUM(CASE WHEN her_automation_query_results.nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_appliance_in_itemization_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_appliance_itemization_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_non_null_insight_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_non_null_insight_cnt,
          SUM(
            CASE WHEN her_automation_query_results.nbi_unicode_check = 'bad' THEN 1 ELSE 0 END
          ) AS nbi_unicode_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_extreme_insight_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_extreme_insight_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_seasonal_appliance_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_seasonal_appliance_cnt,
          SUM(CASE WHEN her_automation_query_results.report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
          'Daily' AS period
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.public.her_automation_query_results AS her_automation_query_results
        GROUP BY
          her_automation_query_results.pilot_id,
          CAST(DATE_ADD(
            'DAY',
            her_automation_query_results.epoch_day + 1,
            CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
          ) AS DATE),
          CAST(DATE_ADD(
            'DAY',
            her_automation_query_results.epoch_day,
            CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
          ) AS DATE)
        UNION ALL
        SELECT
          her_automation_query_results.pilot_id AS pilot_id,
          CAST(DATE_TRUNC(
            'WEEK',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day + 1,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE) AS reporting_date,
          CAST(DATE_TRUNC(
            'WEEK',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE) AS analysis_date,
          SUM(
            CASE
              WHEN her_automation_query_results.low_bc_duration_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS low_bc_duration_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.high_bc_duration_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS high_bc_duration_cnt,
          SUM(CASE WHEN her_automation_query_results.staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_template_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_template_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_consistency_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_generation_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_generation_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.report_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS report_consistency_cnt,
          SUM(
            CASE WHEN her_automation_query_results.itemization_check = 'bad' THEN 1 ELSE 0 END
          ) AS itemization_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.bill_change_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS bill_change_consistency_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.ev_itemization_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS ev_itemization_cnt,
          SUM(
            CASE WHEN her_automation_query_results.tou_template_check = 'bad' THEN 1 ELSE 0 END
          ) AS tou_template_cnt,
          SUM(
            CASE WHEN her_automation_query_results.nbi_occurence_check = 'bad' THEN 1 ELSE 0 END
          ) AS nbi_occurence_cnt,
          SUM(CASE WHEN her_automation_query_results.nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_appliance_in_itemization_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_appliance_itemization_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_non_null_insight_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_non_null_insight_cnt,
          SUM(
            CASE WHEN her_automation_query_results.nbi_unicode_check = 'bad' THEN 1 ELSE 0 END
          ) AS nbi_unicode_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_extreme_insight_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_extreme_insight_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_seasonal_appliance_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_seasonal_appliance_cnt,
          SUM(CASE WHEN her_automation_query_results.report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
          'Weekly' AS period
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.public.her_automation_query_results AS her_automation_query_results
        GROUP BY
          her_automation_query_results.pilot_id,
          CAST(DATE_TRUNC(
            'WEEK',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day + 1,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE),
          CAST(DATE_TRUNC(
            'WEEK',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE)
        UNION ALL
        SELECT
          her_automation_query_results.pilot_id AS pilot_id,
          CAST(DATE_TRUNC(
            'MONTH',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day + 1,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE) AS reporting_date,
          CAST(DATE_TRUNC(
            'MONTH',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE) AS analysis_date,
          SUM(
            CASE
              WHEN her_automation_query_results.low_bc_duration_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS low_bc_duration_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.high_bc_duration_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS high_bc_duration_cnt,
          SUM(CASE WHEN her_automation_query_results.staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_template_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_template_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_consistency_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.solar_generation_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS solar_generation_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.report_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS report_consistency_cnt,
          SUM(
            CASE WHEN her_automation_query_results.itemization_check = 'bad' THEN 1 ELSE 0 END
          ) AS itemization_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.bill_change_consistency_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS bill_change_consistency_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.ev_itemization_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS ev_itemization_cnt,
          SUM(
            CASE WHEN her_automation_query_results.tou_template_check = 'bad' THEN 1 ELSE 0 END
          ) AS tou_template_cnt,
          SUM(
            CASE WHEN her_automation_query_results.nbi_occurence_check = 'bad' THEN 1 ELSE 0 END
          ) AS nbi_occurence_cnt,
          SUM(CASE WHEN her_automation_query_results.nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_appliance_in_itemization_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_appliance_itemization_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_non_null_insight_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_non_null_insight_cnt,
          SUM(
            CASE WHEN her_automation_query_results.nbi_unicode_check = 'bad' THEN 1 ELSE 0 END
          ) AS nbi_unicode_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_extreme_insight_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_extreme_insight_cnt,
          SUM(
            CASE
              WHEN her_automation_query_results.nbi_seasonal_appliance_check = 'bad'
              THEN 1
              ELSE 0
            END
          ) AS nbi_seasonal_appliance_cnt,
          SUM(CASE WHEN her_automation_query_results.report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
          'Monthly' AS period
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.public.her_automation_query_results AS her_automation_query_results
        GROUP BY
          her_automation_query_results.pilot_id,
          CAST(DATE_TRUNC(
            'MONTH',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day + 1,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE),
          CAST(DATE_TRUNC(
            'MONTH',
            CAST(DATE_ADD(
              'DAY',
              her_automation_query_results.epoch_day,
              CAST(CAST('1970-01-01' AS DATE) AS TIMESTAMP)
            ) AS DATE)
          ) AS DATE)
      ) AS s
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
