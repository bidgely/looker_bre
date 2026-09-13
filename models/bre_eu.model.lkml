connection: "starburst_prod_eu"
persist_for: "12 hours"
label: "BRE EU"
week_start_day: monday

include: "/views/bre/bre_pilots.view.lkml"
include: "/views/bre/bre_dashboard_fields.view.lkml"
include: "/views/bre/bre_active_users.view.lkml"
include: "/views/bre/bre_pilot_reporting.view.lkml"
include: "/views/bre/bre_ingestion_audit.view.lkml"
include: "/views/bre/bre_ingestion_failures.view.lkml"
include: "/views/bre/bre_post_ingestion.view.lkml"
include: "/views/bre/bre_invoice_statistics.view.lkml"
include: "/views/bre/bre_disagg_quality.view.lkml"
include: "/views/bre/bre_processing_failures.view.lkml"
include: "/views/bre/bre_email_statistics.view.lkml"
include: "/views/bre/bre_email_tracker.view.lkml"
include: "/views/bre/bre_email_recommendations.view.lkml"
include: "/views/bre/bre_email_failures.view.lkml"
include: "/views/bre/bre_billing_length.view.lkml"
include: "/views/bre/bre_dashboard_eu.view.lkml"

explore: bre_dashboard {
  from: bre_dashboard_eu
  label: "BRE EU Dashboard Sources"
  description: "Select one Source Family per query. Shared Trino source definitions preserve the Data Studio grains; fields from other families return NULL."
  fields: [
    bre_dashboard.common*,
    bre_dashboard.active_users*,
    bre_dashboard.pilot_reporting*,
    bre_dashboard.ingestion_audit*,
    bre_dashboard.ingestion_failures*,
    bre_dashboard.post_ingestion*,
    bre_dashboard.invoice_statistics*,
    bre_dashboard.disagg_quality*,
    bre_dashboard.processing_failures*,
    bre_dashboard.email_statistics*,
    bre_dashboard.email_tracker*,
    bre_dashboard.email_recommendations*,
    bre_dashboard.email_failures*,
    bre_dashboard.billing_length*
  ]
}

# Hidden helpers supply dropdown values for the dashboard Explores.
explore: bre_email_type_filters {
  view_name: bre_email_tracker
  hidden: yes
  description: "Email Type dropdown values from SRE Email Daily Tracker."
  fields: [bre_email_tracker.email_type]
}
explore: bre_email_week_filters {
  view_name: bre_email_statistics
  hidden: yes
  description: "BC End Week# dropdown values from SRE Email Statistics."
  fields: [bre_email_statistics.bc_end_week_number]
}
explore: bre_invoice_filters {
  view_name: bre_invoice_statistics
  hidden: yes
  description: "Disagg filter suggestions from Invoice Statistics, preserving its source selection."
  fields: [bre_invoice_statistics.meter_type, bre_invoice_statistics.fuel_type, bre_invoice_statistics.module_name]
}
include: "/views/bre/bre_ingestion_filter_values.view.lkml"
explore: bre_ingestion_filter_values {
  hidden: yes
  description: "Dynamic Ingestion File Type filter suggestions across source families."
}
explore: bre_pilot_filters {
  view_name: bre_pilots
  hidden: yes
  description: "Consistent pilot filter suggestions from the shared pilot directory."
}

include: "/dashboards/bre_eu_ingestion.dashboard.lookml"
include: "/dashboards/bre_eu_disagg.dashboard.lookml"
include: "/dashboards/bre_eu_email.dashboard.lookml"

include: "/views/bre/bre_email_delivery.view.lkml"
explore: bre_email_delivery {
  label: "BRE EU Email Delivery Blend"
  description: "Full outer blend of Email Statistics and Daily Tracker on email type and analysis date; sources aggregate independently before joining."
  fields: [
    bre_email_delivery.row_id,
    bre_email_delivery.analysis_date,
    bre_email_delivery.email_type,
    bre_email_delivery.period,
    bre_email_delivery.email_period_date,
    bre_email_delivery.blend_date_range,
    bre_email_delivery.blend_pilot_id,
    bre_email_delivery.blend_pilot_name,
    bre_email_delivery.blend_bc_end_week_number,
    bre_email_delivery.daily_eligible,
    bre_email_delivery.daily_generated,
    bre_email_delivery.daily_sent,
    bre_email_delivery.weekly_expected,
    bre_email_delivery.weekly_eligible,
    bre_email_delivery.weekly_sent,
    bre_email_delivery.weekly_sent_vs_eligible,
    bre_email_delivery.weekly_sent_vs_expected
  ]
}
