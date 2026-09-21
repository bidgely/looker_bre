include: "/views/bre/bre_dashboard_fields.view.lkml"

# Regional routing only. Source SQL and fields are shared across the models.
view: bre_dashboard_ca {
  extends: [bre_dashboard_fields]
  parameter: source_family {
    default_value: "ingestionaudit"
    allowed_value: { label: "Active Users" value: "activeusers" }
    allowed_value: { label: "Pilot Reporting Dates" value: "pilotreporting" }
    allowed_value: { label: "Ingestion Audit" value: "ingestionaudit" }
    allowed_value: { label: "Ingestion Failures" value: "ingestionfailures" }
    allowed_value: { label: "Post-Ingestion Quality" value: "postingestion" }
    allowed_value: { label: "Invoice Statistics" value: "invoicestatistics" }
    allowed_value: { label: "Disagg Quality" value: "disaggquality" }
    allowed_value: { label: "Processing Failures" value: "processingfailures" }
    allowed_value: { label: "Email Statistics" value: "emailstatistics" }
    allowed_value: { label: "Email Daily Tracker" value: "emailtracker" }
    allowed_value: { label: "Email Recommendation Quality" value: "emailrecommendations" }
    allowed_value: { label: "Email Failures" value: "emailfailures" }
    allowed_value: { label: "HER Generation" value: "hergeneration" }
    allowed_value: { label: "HER Schedule Status" value: "herschedules" }
    allowed_value: { label: "HER Generation Failures" value: "herfailures" }
    allowed_value: { label: "HER Non-PSEG Quality" value: "hernonpsegquality" }
    allowed_value: { label: "HER Automation Quality" value: "herautomationquality" }
    allowed_value: { label: "NBI Generation" value: "nbigeneration" }
    allowed_value: { label: "NBI Generic Tags" value: "nbigenerictags" }
  }
  parameter: failure_scope {
    default_value: "All"
  }
  # Liquid uses the bre_dashboard Explore alias defined by both models.
  # Keep this query-time only: these connections do not support PDTs.
  derived_table: {
    sql:
      WITH selected_family AS (
        {% if bre_dashboard.source_family._parameter_value == "'activeusers'" %}
          SELECT * FROM ${bre_active_users.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'pilotreporting'" %}
          SELECT * FROM ${bre_pilot_reporting.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'ingestionaudit'" %}
          SELECT * FROM ${bre_ingestion_audit.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'ingestionfailures'" %}
          SELECT * FROM ${bre_ingestion_failures.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'postingestion'" %}
          SELECT * FROM ${bre_post_ingestion.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'invoicestatistics'" %}
          SELECT * FROM ${bre_invoice_statistics.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'disaggquality'" %}
          SELECT * FROM ${bre_disagg_quality.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'processingfailures'" %}
          SELECT * FROM ${bre_processing_failures.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'emailstatistics'" %}
          SELECT * FROM ${bre_email_statistics.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'emailtracker'" %}
          SELECT * FROM ${bre_email_tracker.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'emailrecommendations'" %}
          SELECT * FROM ${bre_email_recommendations.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'emailfailures'" %}
          SELECT * FROM ${bre_email_failures.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'hergeneration'" %}
          SELECT * FROM ${bre_her_generation.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'herschedules'" %}
          SELECT * FROM ${bre_her_schedules.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'herfailures'" %}
          SELECT * FROM ${bre_her_failures.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'hernonpsegquality'" %}
          SELECT * FROM ${bre_her_non_pseg_quality.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'herautomationquality'" %}
          SELECT * FROM ${bre_her_automation_quality.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'nbigeneration'" %}
          SELECT * FROM ${bre_nbi_generation.SQL_TABLE_NAME}
        {% elsif bre_dashboard.source_family._parameter_value == "'nbigenerictags'" %}
          SELECT * FROM ${bre_nbi_generic_tags.SQL_TABLE_NAME}
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
        {% if bre_dashboard.source_family._parameter_value == "'invoicestatistics'" %}
        , f.total_invoices AS invoice_statistics_total_invoices,
          f.failed_itemisation_pct AS invoice_statistics_failed_itemisation_pct,
          f.successful_itemisation_pct AS invoice_statistics_successful_itemisation_pct
        {% else %}
        , CAST(NULL AS INTEGER) AS invoice_statistics_total_invoices,
          CAST(NULL AS DECIMAL(5, 2)) AS invoice_statistics_failed_itemisation_pct,
          CAST(NULL AS DECIMAL(5, 2)) AS invoice_statistics_successful_itemisation_pct
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'disaggquality'" %}
        , f.appliances_kwh_variance_pct_1 AS disagg_quality_appliances_kwh_variance_pct_1,
          f.appliances_kwh_variance_pct_2 AS disagg_quality_appliances_kwh_variance_pct_2,
          f.total_cost_deviation_pct_1 AS disagg_quality_total_cost_deviation_pct_1,
          f.total_cost_deviation_pct_2 AS disagg_quality_total_cost_deviation_pct_2,
          f.cost_per_kwh_deviation_pct AS disagg_quality_cost_per_kwh_deviation_pct,
          f.seasonal_appliance_usage_deviation_pct AS disagg_quality_seasonal_appliance_usage_deviation_pct,
          f.single_appliance_domination_deviation_pct AS disagg_quality_single_appliance_domination_deviation_pct,
          f.missing_dwelliing_pct AS disagg_quality_missing_dwelliing_pct,
          f.ao_pct_non_tou AS disagg_quality_ao_pct_non_tou,
          f.ac_pct_non_tou AS disagg_quality_ac_pct_non_tou,
          f.sh_pct_non_tou AS disagg_quality_sh_pct_non_tou,
          f.other_pct_non_tou AS disagg_quality_other_pct_non_tou,
          f.solar_pct_non_tou AS disagg_quality_solar_pct_non_tou,
          f.missing_solar_pct_non_tou AS disagg_quality_missing_solar_pct_non_tou
        {% else %}
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
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'processingfailures'" %}
        , f.failure_percentage AS processing_failures_failure_percentage,
          f.failure_count AS processing_failures_failure_count,
          f.total_failure_count AS processing_failures_total_failure_count
        {% else %}
        , CAST(NULL AS DECIMAL(5, 2)) AS processing_failures_failure_percentage,
          CAST(NULL AS INTEGER) AS processing_failures_failure_count,
          CAST(NULL AS INTEGER) AS processing_failures_total_failure_count
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'emailstatistics'" %}
        , f.cnt_bills_ingested AS email_statistics_cnt_bills_ingested,
          f.cnt_bills_emails_sent AS email_statistics_cnt_bills_emails_sent,
          f.cnt_bills_emails_delivered AS email_statistics_cnt_bills_emails_delivered,
          f.email_sent_pct AS email_statistics_email_sent_pct,
          f.email_not_sent_pct AS email_statistics_email_not_sent_pct,
          f.cnt_expected_invoices AS email_statistics_cnt_expected_invoices,
          f.cnt_bills_item_available AS email_statistics_cnt_bills_item_available,
          f.cnt_bills_ingested_source_text AS email_statistics_cnt_bills_ingested_source_text,
          f.cnt_bills_emails_sent_source_text AS email_statistics_cnt_bills_emails_sent_source_text,
          f.cnt_bills_emails_delivered_source_text AS email_statistics_cnt_bills_emails_delivered_source_text
        {% else %}
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
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'emailtracker'" %}
        , f.delivered_notification_id AS email_tracker_delivered_notification_id,
          f.generated_notification_id AS email_tracker_generated_notification_id,
          f.invoice_ingested AS email_tracker_invoice_ingested
        {% else %}
        , CAST(NULL AS BIGINT) AS email_tracker_delivered_notification_id,
          CAST(NULL AS BIGINT) AS email_tracker_generated_notification_id,
          CAST(NULL AS BIGINT) AS email_tracker_invoice_ingested
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'emailrecommendations'" %}
        , f.metric_notification_count AS email_recommendations_metric_notification_count,
          f.total_notification_count AS email_recommendations_total_notification_count,
          f.notification_pct AS email_recommendations_notification_pct,
          f.user_count AS email_recommendations_user_count,
          f.total_user_count AS email_recommendations_total_user_count,
          f.user_pct AS email_recommendations_user_pct
        {% else %}
        , CAST(NULL AS BIGINT) AS email_recommendations_metric_notification_count,
          CAST(NULL AS BIGINT) AS email_recommendations_total_notification_count,
          CAST(NULL AS DOUBLE) AS email_recommendations_notification_pct,
          CAST(NULL AS BIGINT) AS email_recommendations_user_count,
          CAST(NULL AS BIGINT) AS email_recommendations_total_user_count,
          CAST(NULL AS DOUBLE) AS email_recommendations_user_pct
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'emailfailures'" %}
        , f.failure_count AS email_failures_failure_count,
          f.total_failure_count AS email_failures_total_failure_count,
          f.failure_pct AS email_failures_failure_pct
        {% else %}
        , CAST(NULL AS BIGINT) AS email_failures_failure_count,
          CAST(NULL AS BIGINT) AS email_failures_total_failure_count,
          CAST(NULL AS DOUBLE) AS email_failures_failure_pct
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'hergeneration'" %}
        , f.expected_eligible_users AS her_generation_expected_eligible_users,
          f.actual_eligible_users AS her_generation_actual_eligible_users,
          f.actual_generation_count AS her_generation_actual_generation_count,
          f.weekly_actual_failure_count AS her_generation_weekly_actual_failure_count
        {% else %}
        , CAST(NULL AS BIGINT) AS her_generation_expected_eligible_users,
          CAST(NULL AS BIGINT) AS her_generation_actual_eligible_users,
          CAST(NULL AS BIGINT) AS her_generation_actual_generation_count,
          CAST(NULL AS BIGINT) AS her_generation_weekly_actual_failure_count
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'herschedules'" %}
        , f.total_eligible_users AS her_schedules_total_eligible_users,
          f.total_generated_notification_id AS her_schedules_total_generated_notification_id,
          f.total_scheduled_notification_id AS her_schedules_total_scheduled_notification_id,
          f.total_queued_notification_id AS her_schedules_total_queued_notification_id,
          f.total_printed_notification_id AS her_schedules_total_printed_notification_id,
          f.total_mailed_notification_id AS her_schedules_total_mailed_notification_id,
          f.total_failed_notification_id AS her_schedules_total_failed_notification_id,
          f.total_swept_notification_id AS her_schedules_total_swept_notification_id
        {% else %}
        , CAST(NULL AS BIGINT) AS her_schedules_total_eligible_users,
          CAST(NULL AS BIGINT) AS her_schedules_total_generated_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_scheduled_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_queued_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_printed_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_mailed_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_failed_notification_id,
          CAST(NULL AS BIGINT) AS her_schedules_total_swept_notification_id
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'herfailures'" %}
        , f.failure_count AS her_failures_failure_count,
          f.total_failure_count AS her_failures_total_failure_count,
          f.failure_percentage AS her_failures_failure_percentage
        {% else %}
        , CAST(NULL AS BIGINT) AS her_failures_failure_count,
          CAST(NULL AS BIGINT) AS her_failures_total_failure_count,
          CAST(NULL AS DOUBLE) AS her_failures_failure_percentage
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'hernonpsegquality'" %}
        , f.low_bc_duration_count AS her_non_pseg_quality_low_bc_duration_count,
          f.high_bc_duration_count AS her_non_pseg_quality_high_bc_duration_count,
          f.staleness_count AS her_non_pseg_quality_staleness_count,
          f.solar_template_count AS her_non_pseg_quality_solar_template_count,
          f.solar_consistency_count AS her_non_pseg_quality_solar_consistency_count,
          f.solar_generation_count AS her_non_pseg_quality_solar_generation_count,
          f.report_consistency_count AS her_non_pseg_quality_report_consistency_count,
          f.itemization_count AS her_non_pseg_quality_itemization_count,
          f.bill_change_consistency_count AS her_non_pseg_quality_bill_change_consistency_count,
          f.ev_itemization_count AS her_non_pseg_quality_ev_itemization_count,
          f.tou_template_count AS her_non_pseg_quality_tou_template_count,
          f.nbi_occurance_count AS her_non_pseg_quality_nbi_occurance_count,
          f.nbi_value_count AS her_non_pseg_quality_nbi_value_count,
          f.nbi_appliance_itemisation_count AS her_non_pseg_quality_nbi_appliance_itemisation_count,
          f.nbi_non_null_insight_count AS her_non_pseg_quality_nbi_non_null_insight_count,
          f.nbi_unicode_count AS her_non_pseg_quality_nbi_unicode_count,
          f.nbi_extreme_insight_count AS her_non_pseg_quality_nbi_extreme_insight_count
        {% else %}
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
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'herautomationquality'" %}
        , f.low_bc_duration_cnt AS her_automation_quality_low_bc_duration_cnt,
          f.high_bc_duration_cnt AS her_automation_quality_high_bc_duration_cnt,
          f.staleness_cnt AS her_automation_quality_staleness_cnt,
          f.solar_template_cnt AS her_automation_quality_solar_template_cnt,
          f.solar_consistency_cnt AS her_automation_quality_solar_consistency_cnt,
          f.solar_generation_cnt AS her_automation_quality_solar_generation_cnt,
          f.report_consistency_cnt AS her_automation_quality_report_consistency_cnt,
          f.itemization_cnt AS her_automation_quality_itemization_cnt,
          f.bill_change_consistency_cnt AS her_automation_quality_bill_change_consistency_cnt,
          f.ev_itemization_cnt AS her_automation_quality_ev_itemization_cnt,
          f.tou_template_cnt AS her_automation_quality_tou_template_cnt,
          f.nbi_occurence_cnt AS her_automation_quality_nbi_occurence_cnt,
          f.nbi_value_cnt AS her_automation_quality_nbi_value_cnt,
          f.nbi_appliance_itemization_cnt AS her_automation_quality_nbi_appliance_itemization_cnt,
          f.nbi_non_null_insight_cnt AS her_automation_quality_nbi_non_null_insight_cnt,
          f.nbi_unicode_cnt AS her_automation_quality_nbi_unicode_cnt,
          f.nbi_extreme_insight_cnt AS her_automation_quality_nbi_extreme_insight_cnt,
          f.nbi_seasonal_appliance_cnt AS her_automation_quality_nbi_seasonal_appliance_cnt,
          f.overall_report_count AS her_automation_quality_overall_report_count
        {% else %}
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
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'nbigeneration'" %}
        , f.total_users_successful AS nbi_generation_total_users_successful,
          f.total_users_with_200_errorcode AS nbi_generation_total_users_with_200_errorcode,
          f.total_users_with_300_errorcode AS nbi_generation_total_users_with_300_errorcode,
          f.nbi_error_pct AS nbi_generation_nbi_error_pct
        {% else %}
        , CAST(NULL AS BIGINT) AS nbi_generation_total_users_successful,
          CAST(NULL AS BIGINT) AS nbi_generation_total_users_with_200_errorcode,
          CAST(NULL AS BIGINT) AS nbi_generation_total_users_with_300_errorcode,
          CAST(NULL AS DECIMAL(26, 2)) AS nbi_generation_nbi_error_pct
        {% endif %}
        {% if bre_dashboard.source_family._parameter_value == "'nbigenerictags'" %}
        , f.total_nbi_users AS nbi_generic_tags_total_nbi_users,
          f.total_nbi_users_with_generic_tag AS nbi_generic_tags_total_nbi_users_with_generic_tag,
          f.pct_users_with_generic_tag AS nbi_generic_tags_pct_users_with_generic_tag
        {% else %}
        , CAST(NULL AS BIGINT) AS nbi_generic_tags_total_nbi_users,
          CAST(NULL AS BIGINT) AS nbi_generic_tags_total_nbi_users_with_generic_tag,
          CAST(NULL AS DECIMAL(26, 2)) AS nbi_generic_tags_pct_users_with_generic_tag
        {% endif %}
        , CAST(NULL AS BIGINT) AS billing_length_bc_1_15_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_15_30_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_31_45_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_45_60_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_61_75_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_76_90_count,
          CAST(NULL AS BIGINT) AS billing_length_bc_gt_90_count
      FROM selected_family f
      WHERE TRUE
      {% if bre_dashboard.source_family._parameter_value == "'herautomationquality'" %}
        AND f.source_period = {% parameter bre_dashboard.period %}
      {% endif %}
      {% if bre_dashboard.source_family._parameter_value == "'hergeneration'" %}
        AND f.source_period = {% parameter bre_dashboard.period %}
      {% endif %}
      {% if bre_dashboard.source_family._parameter_value == "'herfailures'" %}
        AND f.source_period = {% parameter bre_dashboard.period %}
      {% endif %}
      {% if bre_dashboard.source_family._parameter_value == "'processingfailures'" and bre_dashboard.failure_scope._parameter_value == "'Top Three'" %}
        AND f.source_rank <= 3
      {% endif %}
    ;;
  }
}
