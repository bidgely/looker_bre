include: "/views/bre/bre_dashboard_fields.view.lkml"

# Regional routing only. Source SQL and fields are shared across the models.
view: bre_dashboard_na {
  extends: [bre_dashboard_fields]
  parameter: source_family {
    default_value: "ingestionaudit"
    allowed_value: { label: "Active Users" value: "activeusers" }
    allowed_value: { label: "Ingestion Audit" value: "ingestionaudit" }
    allowed_value: { label: "Ingestion Failures" value: "ingestionfailures" }
    allowed_value: { label: "Post-Ingestion Quality" value: "postingestion" }
  }
  parameter: failure_scope {
    default_value: "All"
  }
  # Liquid uses the bre_dashboard Explore alias defined by the NA model.
  # Keep this query-time only: these connections do not support PDTs.
  derived_table: {
    sql:
      WITH selected_family AS (
        {% if bre_dashboard.source_family._parameter_value == "'activeusers'" %}
          SELECT * FROM ${bre_active_users.SQL_TABLE_NAME}
          WHERE {% condition bre_dashboard.pilot_id %} pilot_id {% endcondition %}
            AND {% condition bre_dashboard.pilot_name %} pilot_name {% endcondition %}
        {% elsif bre_dashboard.source_family._parameter_value == "'ingestionaudit'" %}
          SELECT * FROM ${bre_ingestion_audit.SQL_TABLE_NAME}
          WHERE {% condition bre_dashboard.pilot_id %} pilot_id {% endcondition %}
            AND {% condition bre_dashboard.pilot_name %} pilot_name {% endcondition %}
        {% elsif bre_dashboard.source_family._parameter_value == "'ingestionfailures'" %}
          SELECT * FROM ${bre_ingestion_failures.SQL_TABLE_NAME}
          WHERE {% condition bre_dashboard.pilot_id %} pilot_id {% endcondition %}
            AND {% condition bre_dashboard.pilot_name %} pilot_name {% endcondition %}
        {% elsif bre_dashboard.source_family._parameter_value == "'postingestion'" %}
          SELECT * FROM ${bre_post_ingestion.SQL_TABLE_NAME}
          WHERE {% condition bre_dashboard.pilot_id %} pilot_id {% endcondition %}
            AND {% condition bre_dashboard.pilot_name %} pilot_name {% endcondition %}
        {% else %}
          SELECT CAST(NULL AS BIGINT) AS row_id,
            CAST(NULL AS VARCHAR) AS pilot_id,
            CAST(NULL AS VARCHAR) AS pilot_name,
            CAST(NULL AS VARCHAR) AS pilot_id_name,
            CAST(NULL AS VARCHAR) AS time_zone,
            CAST(NULL AS DATE) AS analysis_date,
            CAST(NULL AS DATE) AS reporting_date,
            CAST(NULL AS TIMESTAMP(6)) AS last_updated_timestamp,
            CAST(NULL AS VARCHAR) AS source_analysis_value,
            CAST(NULL AS VARCHAR) AS source_reporting_value,
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
          WHERE FALSE
        {% endif %}
      )
      SELECT f.row_id,
        f.pilot_id,
        f.pilot_name,
        f.pilot_id_name,
        f.time_zone,
        f.analysis_date,
        f.reporting_date,
        f.last_updated_timestamp,
        f.source_analysis_value,
        f.source_reporting_value,
        f.source_pilot_name,
        f.source_period,
        f.source_rank,
        f.ingestion_type,
        f.meter_type,
        f.fuel_type,
        f.module_name,
        f.email_type,
        f.bc_end_week_number,
        f.cluster_id,
        f.schedule_start,
        f.schedule_end,
        f.appliance_name,
        f.metric_name,
        f.application_error_code,
        f.failure_reason,
        f.reporting_frequency,
        f.trigger_flag,
        f.delivery_mode,
        f.event_type,
        f.delay_in_days,
        f.istou
        {% if bre_dashboard.source_family._parameter_value == "'activeusers'" %}
        , f.total_uuid AS active_users_total_uuid,
          f.enabled_uuid AS active_users_enabled_uuid,
          f.disabled_uuid AS active_users_disabled_uuid,
          f.active_uuid AS active_users_active_uuid,
          f.total_active_electric_uuid AS active_users_total_active_electric_uuid,
          f.total_active_gas_uuid AS active_users_total_active_gas_uuid,
          f.total_active_uuid AS active_users_total_active_uuid,
          f.total_active_user_meters AS active_users_total_active_user_meters,
          f.total_active_electric_meters AS active_users_total_active_electric_meters,
          f.total_active_gas_meters AS active_users_total_active_gas_meters
        {% else %}
        , CAST(NULL AS INTEGER) AS active_users_total_uuid,
          CAST(NULL AS INTEGER) AS active_users_enabled_uuid,
          CAST(NULL AS INTEGER) AS active_users_disabled_uuid,
          CAST(NULL AS INTEGER) AS active_users_active_uuid,
          CAST(NULL AS INTEGER) AS active_users_total_active_electric_uuid,
          CAST(NULL AS INTEGER) AS active_users_total_active_gas_uuid,
          CAST(NULL AS INTEGER) AS active_users_total_active_uuid,
          CAST(NULL AS INTEGER) AS active_users_total_active_user_meters,
          CAST(NULL AS INTEGER) AS active_users_total_active_electric_meters,
          CAST(NULL AS INTEGER) AS active_users_total_active_gas_meters
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'ingestionaudit'" %}
        , f.total_files_processed AS ingestion_audit_total_files_processed,
          f.total_chunks_processed AS ingestion_audit_total_chunks_processed,
          f.total_records_count AS ingestion_audit_total_records_count,
          f.total_success_record_count AS ingestion_audit_total_success_record_count,
          f.total_failure_record_count AS ingestion_audit_total_failure_record_count,
          f.success_percentage AS ingestion_audit_success_percentage,
          f.failure_percentage AS ingestion_audit_failure_percentage
        {% else %}
        , CAST(NULL AS BIGINT) AS ingestion_audit_total_files_processed,
          CAST(NULL AS BIGINT) AS ingestion_audit_total_chunks_processed,
          CAST(NULL AS BIGINT) AS ingestion_audit_total_records_count,
          CAST(NULL AS BIGINT) AS ingestion_audit_total_success_record_count,
          CAST(NULL AS BIGINT) AS ingestion_audit_total_failure_record_count,
          CAST(NULL AS DECIMAL(26, 2)) AS ingestion_audit_success_percentage,
          CAST(NULL AS DECIMAL(26, 2)) AS ingestion_audit_failure_percentage
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'ingestionfailures'" %}
        , f.failed_record_count AS ingestion_failures_failed_record_count,
          f.total_failed_record_count AS ingestion_failures_total_failed_record_count,
          f.failure_percentage AS ingestion_failures_failure_percentage
        {% else %}
        , CAST(NULL AS BIGINT) AS ingestion_failures_failed_record_count,
          CAST(NULL AS BIGINT) AS ingestion_failures_total_failed_record_count,
          CAST(NULL AS DECIMAL(26, 2)) AS ingestion_failures_failure_percentage
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'postingestion'" %}
        , f.user_raw_with_delay_0_3 AS post_ingestion_user_raw_with_delay_0_3,
          f.user_raw_with_delay_4_7 AS post_ingestion_user_raw_with_delay_4_7,
          f.user_raw_with_delay_8_15 AS post_ingestion_user_raw_with_delay_8_15,
          f.user_raw_with_delay_gt_15 AS post_ingestion_user_raw_with_delay_gt_15,
          f.user_invoice_with_delay_0_7 AS post_ingestion_user_invoice_with_delay_0_7,
          f.user_invoice_with_delay_7_15 AS post_ingestion_user_invoice_with_delay_7_15,
          f.user_invoice_with_delay_15_30 AS post_ingestion_user_invoice_with_delay_15_30,
          f.user_invoice_with_delay_gt_30 AS post_ingestion_user_invoice_with_delay_gt_30,
          f.overlapping_bc_count AS post_ingestion_overlapping_bc_count
        {% else %}
        , CAST(NULL AS BIGINT) AS post_ingestion_user_raw_with_delay_0_3,
          CAST(NULL AS BIGINT) AS post_ingestion_user_raw_with_delay_4_7,
          CAST(NULL AS BIGINT) AS post_ingestion_user_raw_with_delay_8_15,
          CAST(NULL AS BIGINT) AS post_ingestion_user_raw_with_delay_gt_15,
          CAST(NULL AS BIGINT) AS post_ingestion_user_invoice_with_delay_0_7,
          CAST(NULL AS BIGINT) AS post_ingestion_user_invoice_with_delay_7_15,
          CAST(NULL AS BIGINT) AS post_ingestion_user_invoice_with_delay_15_30,
          CAST(NULL AS BIGINT) AS post_ingestion_user_invoice_with_delay_gt_30,
          CAST(NULL AS BIGINT) AS post_ingestion_overlapping_bc_count
        {% endif %}

        , CAST(NULL AS INTEGER) AS invoice_statistics_total_invoices,
          CAST(NULL AS DECIMAL(5, 2)) AS invoice_statistics_failed_itemisation_pct,
          CAST(NULL AS DECIMAL(5, 2)) AS invoice_statistics_successful_itemisation_pct


        , CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_appliances_kwh_variance_pct_1,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_appliances_kwh_variance_pct_2,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_total_cost_deviation_pct_1,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_total_cost_deviation_pct_2,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_cost_per_kwh_deviation_pct,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_seasonal_appliance_usage_deviation_pct,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_single_appliance_domination_deviation_pct,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_missing_dwelliing_pct,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_ao_pct_non_tou,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_ac_pct_non_tou,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_sh_pct_non_tou,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_other_pct_non_tou,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_solar_pct_non_tou,
          CAST(NULL AS DECIMAL(10, 2)) AS disagg_quality_missing_solar_pct_non_tou


        , CAST(NULL AS DECIMAL(5, 2)) AS processing_failures_failure_percentage,
          CAST(NULL AS INTEGER) AS processing_failures_failure_count,
          CAST(NULL AS INTEGER) AS processing_failures_total_failure_count


        , CAST(NULL AS BIGINT) AS email_statistics_cnt_bills_ingested,
          CAST(NULL AS BIGINT) AS email_statistics_cnt_bills_emails_sent,
          CAST(NULL AS BIGINT) AS email_statistics_cnt_bills_emails_delivered,
          CAST(NULL AS DOUBLE) AS email_statistics_email_sent_pct,
          CAST(NULL AS DOUBLE) AS email_statistics_email_not_sent_pct,
          CAST(NULL AS BIGINT) AS email_statistics_cnt_expected_invoices,
          CAST(NULL AS BIGINT) AS email_statistics_cnt_bills_item_available,
          CAST(NULL AS VARCHAR) AS email_statistics_cnt_bills_ingested_source_text,
          CAST(NULL AS VARCHAR) AS email_statistics_cnt_bills_emails_sent_source_text,
          CAST(NULL AS VARCHAR) AS email_statistics_cnt_bills_emails_delivered_source_text


        , CAST(NULL AS BIGINT) AS email_tracker_delivered_notification_id,
          CAST(NULL AS BIGINT) AS email_tracker_generated_notification_id,
          CAST(NULL AS BIGINT) AS email_tracker_invoice_ingested


        , CAST(NULL AS BIGINT) AS email_recommendations_metric_notification_count,
          CAST(NULL AS BIGINT) AS email_recommendations_total_notification_count,
          CAST(NULL AS DOUBLE) AS email_recommendations_notification_pct,
          CAST(NULL AS BIGINT) AS email_recommendations_user_count,
          CAST(NULL AS BIGINT) AS email_recommendations_total_user_count,
          CAST(NULL AS DOUBLE) AS email_recommendations_user_pct


        , CAST(NULL AS BIGINT) AS email_failures_failure_count,
          CAST(NULL AS BIGINT) AS email_failures_total_failure_count,
          CAST(NULL AS DOUBLE) AS email_failures_failure_pct


        , CAST(NULL AS BIGINT) AS her_generation_expected_eligible_users,
          CAST(NULL AS BIGINT) AS her_generation_actual_eligible_users,
          CAST(NULL AS BIGINT) AS her_generation_actual_generation_count,
          CAST(NULL AS BIGINT) AS her_generation_weekly_actual_failure_count


        , CAST(NULL AS BIGINT) AS her_schedules_total_eligible_users,
          CAST(NULL AS BIGINT) AS her_schedules_total_generated_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_scheduled_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_queued_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_printed_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_mailed_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_failed_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_swept_notification_id


        , CAST(NULL AS BIGINT) AS her_failures_failure_count,
          CAST(NULL AS BIGINT) AS her_failures_total_failure_count,
          CAST(NULL AS DOUBLE) AS her_failures_failure_percentage


        , CAST(NULL AS BIGINT) AS her_non_pseg_quality_low_bc_duration_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_high_bc_duration_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_staleness_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_solar_template_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_solar_consistency_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_solar_generation_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_report_consistency_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_itemization_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_bill_change_consistency_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_ev_itemization_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_tou_template_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_nbi_occurance_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_nbi_value_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_nbi_appliance_itemisation_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_nbi_non_null_insight_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_nbi_unicode_count,
          CAST(NULL AS BIGINT) AS her_non_pseg_quality_nbi_extreme_insight_count


        , CAST(NULL AS BIGINT) AS her_automation_quality_low_bc_duration_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_high_bc_duration_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_staleness_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_solar_template_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_solar_consistency_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_solar_generation_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_report_consistency_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_itemization_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_bill_change_consistency_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_ev_itemization_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_tou_template_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_nbi_occurence_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_nbi_value_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_nbi_appliance_itemization_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_nbi_non_null_insight_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_nbi_unicode_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_nbi_extreme_insight_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_nbi_seasonal_appliance_cnt,
          CAST(NULL AS BIGINT) AS her_automation_quality_overall_report_count


        , CAST(NULL AS BIGINT) AS nbi_generation_total_users_successful,
          CAST(NULL AS BIGINT) AS nbi_generation_total_users_with_200_errorcode,
          CAST(NULL AS BIGINT) AS nbi_generation_total_users_with_300_errorcode,
          CAST(NULL AS DECIMAL(26, 2)) AS nbi_generation_nbi_error_pct


        , CAST(NULL AS BIGINT) AS nbi_generic_tags_total_nbi_users,
          CAST(NULL AS BIGINT) AS nbi_generic_tags_total_nbi_users_with_generic_tag,
          CAST(NULL AS DECIMAL(26, 2)) AS nbi_generic_tags_pct_users_with_generic_tag

        , CAST(NULL AS BIGINT) AS billing_length_bc_1_15_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_15_30_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_31_45_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_45_60_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_61_75_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_76_90_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_gt_90_count
      FROM selected_family f
      WHERE TRUE
        AND {% condition bre_dashboard.pilot_id %} f.pilot_id {% endcondition %}
        AND {% condition bre_dashboard.pilot_name %} f.pilot_name {% endcondition %}
    ;;
  }

  # NA uses raw ingestion_type values; CA/EU retain their existing Billing grouping.
  dimension: ingestion_file_type {
    description: "NA File Type uses the source ingestion_type without merging BILLING and OPOWER."
    sql: ${ingestion_type} ;;
    suggest_dimension: bre_ingestion_filter_values.ingestion_type
  }
  measure: active_users_uuid_summary {
    description: "Latest source snapshot active UUIDs out of total UUIDs, filtered by reporting date and pilot."
  }
  dimension: na_users_millions {
    type: number
    hidden: yes
    description: "SRC-14 total_users_across_age_buckets; OPOWER is not included in the documented CASE. Source NULLIF behavior is preserved."
    sql: CASE WHEN ${ingestion_type} = 'CONSUMPTION' THEN ${post_ingestion_users_receiving_raw} / 1000000.0 WHEN ${ingestion_type} = 'BILLING' THEN ${post_ingestion_users_receiving_invoice} / 1000000.0 END ;;
  }
  measure: na_users_millions_sum {
    type: sum
    label: "Users (M)"
    description: "Documented SUM of total_users_across_age_buckets; not divided by the number of days."
    sql: ${na_users_millions} ;;
    value_format: "#,##0.00"
  }
  measure: na_raw_users_millions_sum {
    type: number
    label: "Users Receiving Raw Data (M)"
    description: "SUM of the SRC-14 avg_users_receiving_raw_per_day formula; source NULLIF semantics preserved."
    sql: ${post_ingestion_users_receiving_raw_sum} / 1000000.0 ;;
    value_format: "#,##0.00"
  }
  parameter: na_failure_metric {
    type: string
    label: "Failure Metric"
    description: "SRC-27 Metric Toggle: average percentage or sum of failed records."
    default_value: "failure_percentage"
    allowed_value: { label: "% Failure" value: "failure_percentage" }
    allowed_value: { label: "Failure Count" value: "failed_record_count" }
  }
  measure: na_failure_metric_value {
    type: number
    label_from_parameter: na_failure_metric
    description: "Average failure percentage or sum of failed record counts after retaining source rank <= 3."
    sql: {% if na_failure_metric._parameter_value == "'failed_record_count'" %}
      ${ingestion_failures_failed_record_count_sum}
      {% else %} ${ingestion_failures_failure_percentage_average} {% endif %} ;;
    value_format: "#,##0.00"
  }
  measure: na_raw_delay_0_3_count {
    type: number
    label: "Raw Delay 0 3 (Count)"
    description: "Documented COUNT of non-null user_raw_with_delay_0_3 rows, including rows whose value is zero; not a sum of users."
    sql: COUNT(${post_ingestion_user_raw_with_delay_0_3}) ;;
  }
  measure: na_raw_delay_4_7_count {
    type: number
    label: "Raw Delay 4 7 (Count)"
    description: "Documented COUNT of non-null user_raw_with_delay_4_7 rows, including rows whose value is zero; not a sum of users."
    sql: COUNT(${post_ingestion_user_raw_with_delay_4_7}) ;;
  }
  measure: na_raw_delay_8_15_count {
    type: number
    label: "Raw Delay 8 15 (Count)"
    description: "Documented COUNT of non-null user_raw_with_delay_8_15 rows, including rows whose value is zero; not a sum of users."
    sql: COUNT(${post_ingestion_user_raw_with_delay_8_15}) ;;
  }
  measure: na_raw_delay_gt_15_count {
    type: number
    label: "Raw Delay gt 15 (Count)"
    description: "Documented COUNT of non-null user_raw_with_delay_gt_15 rows, including rows whose value is zero; not a sum of users."
    sql: COUNT(${post_ingestion_user_raw_with_delay_gt_15}) ;;
  }
  dimension: na_gauge_label {
    type: string
    label: "Gauge"
    description: "Constant category for the one-row NA Ingestion gauges; does not change the metric aggregation."
    sql: {% if source_family._parameter_value == "'postingestion'" %}
      'Users (M)'
      {% else %} 'Success %' {% endif %} ;;
  }
  set: na_ingestion {
    fields: [na_gauge_label, na_users_millions, na_users_millions_sum, na_raw_users_millions_sum,
      na_failure_metric, na_failure_metric_value, na_raw_delay_0_3_count,
      na_raw_delay_4_7_count, na_raw_delay_8_15_count, na_raw_delay_gt_15_count]
  }
}
