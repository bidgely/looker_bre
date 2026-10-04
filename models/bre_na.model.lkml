connection: "starburst_prod_na"
label: "BRE NA"
week_start_day: sunday

include: "/views/bre/bre_pilots.view.lkml"
include: "/views/bre/bre_dashboard_fields.view.lkml"
include: "/views/bre/bre_active_users.view.lkml"
include: "/views/bre/bre_ingestion_audit.view.lkml"
include: "/views/bre/bre_ingestion_failures.view.lkml"
include: "/views/bre/bre_post_ingestion.view.lkml"
include: "/views/bre/bre_ingestion_filter_values.view.lkml"
include: "/views/bre_na/bre_dashboard_na.view.lkml"
include: "/views/bre_na/bre_na_ingestion_queue_fields.view.lkml"
include: "/views/bre_na/bre_na_ingestion_queue_hourly.view.lkml"
include: "/views/bre_na/bre_na_ingestion_queue_daily.view.lkml"
include: "/views/bre_na/bre_na_ingestion_queue_health.view.lkml"
include: "/views/bre_na/bre_na_rate_plan_tracker.view.lkml"
include: "/views/bre_na/bre_na_ingestion_rate_comparison.view.lkml"
include: "/dashboards/bre_na_ingestion_governance.dashboard.lookml"
include: "/dashboards/bre_na_ingestion_queue_metrics.dashboard.lookml"

include: "/views/bre_na/bre_na_aggregation.view.lkml"
include: "/dashboards/bre_na_aggregation.dashboard.lookml"

explore: bre_na_aggregation {
  label: "BRE NA Aggregation"
  description: "SRC-29 raw data statistics and quality; reporting-date filters and analysis-date grouping."
}

include: "/views/bre_na/bre_na_disaggregation_invoices.view.lkml"
include: "/views/bre_na/bre_na_disaggregation_quality.view.lkml"
include: "/views/bre_na/bre_na_disaggregation_failures.view.lkml"
include: "/views/bre_na/bre_na_disaggregation_queue_hourly.view.lkml"
include: "/views/bre_na/bre_na_disaggregation_queue_daily.view.lkml"
include: "/views/bre_na/bre_na_disaggregation_queue_health.view.lkml"
include: "/dashboards/bre_na_disaggregation_queue_metrics.dashboard.lookml"

include: "/views/bre_na/bre_na_disaggregation_invoices_new.view.lkml"
include: "/dashboards/bre_na_disaggregation_governance.dashboard.lookml"

explore: bre_na_disaggregation_invoices_new {
  label: "BRE NA Disaggregation — Invoice Period Statistics"
  fields: [bre_na_disaggregation_invoices_new.row_id, bre_na_disaggregation_invoices_new.pilot_id, bre_na_disaggregation_invoices_new.pilot_name, bre_na_disaggregation_invoices_new.meter_type, bre_na_disaggregation_invoices_new.fuel_type, bre_na_disaggregation_invoices_new.module_name, bre_na_disaggregation_invoices_new.date_range, bre_na_disaggregation_invoices_new.period, bre_na_disaggregation_invoices_new.period_date, bre_na_disaggregation_invoices_new.analysis_date, bre_na_disaggregation_invoices_new.reporting_date, bre_na_disaggregation_invoices_new.total_invoices_max, bre_na_disaggregation_invoices_new.success_t2_average, bre_na_disaggregation_invoices_new.success_t7_average, bre_na_disaggregation_invoices_new.success_correction_max, bre_na_disaggregation_invoices_new.daily_total_invoices, bre_na_disaggregation_invoices_new.record_count, bre_na_disaggregation_invoices_new.failed_itemisation_fraction]
}

explore: bre_na_disaggregation_invoices {
  label: "BRE NA Disaggregation — Invoices"
}

explore: bre_na_disaggregation_quality {
  label: "BRE NA Disaggregation — Quality"
}

explore: bre_na_disaggregation_failures {
  label: "BRE NA Disaggregation — Failures"
}

explore: bre_na_disaggregation_queue_hourly {
  label: "BRE NA Disaggregation — Queue Hourly"
}

explore: bre_na_disaggregation_queue_daily {
  label: "BRE NA Disaggregation — Queue Daily"
}

explore: bre_na_disaggregation_queue_health {
  label: "BRE NA Disaggregation — Queue Health"
}

include: "/views/bre_na/bre_na_tou.view.lkml"
include: "/dashboards/bre_na_tou.dashboard.lookml"

explore: bre_na_tou {
  label: "BRE NA TOU"
  description: "SRC-35 TOU counts and source percentages; analysis-date comparisons and grouping."
}

explore: bre_dashboard {
  from: bre_dashboard_na
  label: "BRE NA Ingestion Sources"
  description: "Select one source family per query. NA ingestion fields preserve the captured NA chart aggregations."
  fields: [bre_dashboard.common*, bre_dashboard.active_users*,
    bre_dashboard.ingestion_audit*, bre_dashboard.ingestion_failures*,
    bre_dashboard.post_ingestion*, bre_dashboard.na_ingestion*]
}

explore: bre_pilot_filters {
  view_name: bre_pilots
  hidden: yes
  description: "NA pilot directory suggestions."
}

explore: bre_ingestion_filter_values {
  hidden: yes
  description: "NA raw ingestion_type suggestions across ingestion sources."
}

explore: bre_na_ingestion_queue_hourly {
  label: "BRE NA Ingestion Queue Metrics by Hour"
  description: "SRC-01 hourly queue aggregates for Ingestion, retaining the source rolling seven-day history limit."
}

explore: bre_na_ingestion_queue_daily {
  label: "BRE NA Ingestion Queue Metrics by Day"
  description: "SRC-24 daily received-message averages for Ingestion."
}

explore: bre_na_ingestion_queue_health {
  label: "BRE NA Ingestion Queue Health"
  description: "SRC-52 queue/day health scores for Ingestion."
}

explore: bre_na_rate_plan_tracker {
  hidden: yes
  description: "NA Rate Plan ID suggestions from SRC-17."
}

explore: bre_na_ingestion_rate_comparison {
  label: "BRE NA Ingestion and Rate Comparison"
  description: "Audit LEFT JOIN Rate Comparison on pilot ID and exact last updated timestamp. Original-report aggregate parity remains subject to blend input-grain verification."
  fields: [bre_na_ingestion_rate_comparison.row_id, bre_na_ingestion_rate_comparison.pilot_id, bre_na_ingestion_rate_comparison.pilot_name,
    bre_na_ingestion_rate_comparison.analysis_date, bre_na_ingestion_rate_comparison.ingestion_period_date, bre_na_ingestion_rate_comparison.period,
    bre_na_ingestion_rate_comparison.date_range, bre_na_ingestion_rate_comparison.selected_pilot_id, bre_na_ingestion_rate_comparison.selected_pilot_name,
    bre_na_ingestion_rate_comparison.file_type, bre_na_ingestion_rate_comparison.current_plan_number,
    bre_na_ingestion_rate_comparison.files, bre_na_ingestion_rate_comparison.chunks, bre_na_ingestion_rate_comparison.records, bre_na_ingestion_rate_comparison.success_percentage_average, bre_na_ingestion_rate_comparison.expected_rc, bre_na_ingestion_rate_comparison.successful_rc, bre_na_ingestion_rate_comparison.missing_rc_percentage_average]
}

include: "/views/bre_na/bre_na_rate_comparison.view.lkml"
include: "/views/bre_na/bre_na_rate_comparison_triggers.view.lkml"
include: "/dashboards/bre_na_rate_comparison.dashboard.lookml"

explore: bre_na_rate_comparison {
  label: "BRE NA Rate Comparison — Email Anomalies"
  description: "SRC-28 email promotion and rate-comparison anomaly statistics, analysis-date filtering and comparisons."
}

explore: bre_na_rate_comparison_triggers {
  label: "BRE NA Rate Comparison — Invoice Triggers"
  description: "SRC-21 invoice/TOU/RC trigger statistics, filtered by reporting date."
}

include: "/views/bre_na/bre_na_email_delivery.view.lkml"
include: "/dashboards/bre_na_email_governance.dashboard.lookml"

explore: bre_na_email_delivery {
  label: "BRE NA Email — Delivery"
  description: "SRC-05 Daily/Weekly delivery rows, analysis-date comparisons, and ratios of summed counts."
}

include: "/views/bre_na/bre_na_email_queue_hourly.view.lkml"

explore: bre_na_email_queue_hourly {
  label: "BRE NA Email — Queue Hourly"
}

include: "/views/bre_na/bre_na_email_queue_daily.view.lkml"

explore: bre_na_email_queue_daily {
  label: "BRE NA Email — Queue Daily"
}

include: "/views/bre_na/bre_na_email_queue_health.view.lkml"

explore: bre_na_email_queue_health {
  label: "BRE NA Email — Queue Health"
}

include: "/dashboards/bre_na_email_queue_metrics.dashboard.lookml"

include: "/views/bre_na/bre_na_email_recommendations.view.lkml"

explore: bre_na_email_recommendations {
  label: "BRE NA Email — Recommendation Quality"
}

include: "/views/bre_na/bre_na_email_failures.view.lkml"

explore: bre_na_email_failures {
  label: "BRE NA Email — Failure Reasons"
}

include: "/views/bre_na/bre_na_her_schedules.view.lkml"

explore: bre_na_her_schedules {
  label: "BRE NA HER — Schedules"
}

include: "/views/bre_na/bre_na_her_quality.view.lkml"

explore: bre_na_her_quality {
  label: "BRE NA HER — Quality"
}

include: "/views/bre_na/bre_na_her_failures.view.lkml"

explore: bre_na_her_failures {
  label: "BRE NA HER — Failure Reasons"
}

include: "/dashboards/bre_na_her_governance.dashboard.lookml"

include: "/views/bre_na/bre_na_her_generation.view.lkml"

explore: bre_na_her_generation {
  label: "BRE NA HER — Generation"
  description: "SRC-34 source-period eligibility and generation statistics with the confirmed success ratio of sums."
}

include: "/views/bre_na/bre_na_her_queue_hourly.view.lkml"

explore: bre_na_her_queue_hourly {
  label: "BRE NA HER — Queue Hourly"
}

include: "/views/bre_na/bre_na_her_queue_daily.view.lkml"

explore: bre_na_her_queue_daily {
  label: "BRE NA HER — Queue Daily"
}

include: "/views/bre_na/bre_na_her_queue_health.view.lkml"

explore: bre_na_her_queue_health {
  label: "BRE NA HER — Queue Health"
}

include: "/dashboards/bre_na_her_queue_metrics.dashboard.lookml"

include: "/views/bre_na/bre_na_nbi_generation.view.lkml"

explore: bre_na_nbi_generation {
  label: "BRE NA NBI — Generation"
}

include: "/views/bre_na/bre_na_nbi_generic_tags.view.lkml"

explore: bre_na_nbi_generic_tags {
  label: "BRE NA NBI — Generic Tags"
}

include: "/views/bre_na/bre_na_nbi_emr.view.lkml"

explore: bre_na_nbi_emr {
  label: "BRE NA NBI — Emr"
}

include: "/views/bre_na/bre_na_nbi_failed_jobs.view.lkml"

explore: bre_na_nbi_failed_jobs {
  label: "BRE NA NBI — Failed Jobs"
}

include: "/dashboards/bre_na_nbi_governance.dashboard.lookml"

include: "/dashboards/bre_na_nbi_emr_metrics.dashboard.lookml"

include: "/views/bre_na/bre_na_nbi_emr_blend.view.lkml"

explore: bre_na_nbi_emr_blend {
  label: "BRE NA NBI — EMR Failure Correlation Blend"
}

include: "/views/bre_na/bre_na_nbi_emr_scatter.view.lkml"

explore: bre_na_nbi_emr_scatter {
  label: "BRE NA NBI — EMR Daily Scatter Points"
}
