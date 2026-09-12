connection: "starburst_prod_eu"
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
