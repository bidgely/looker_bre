include: "/views/bre/bre_dashboard_fields.view.lkml"

# One row per email type/date after filtering and aggregating each source.
# Inherit the common Period calendar; the Explore exposes only blend-supported fields.
view: bre_email_delivery {
  extends: [bre_dashboard_fields]
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local identifier for each full-joined email type/date row, including unmatched NULL keys."
    sql: ${TABLE}.row_id ;;
  }
  filter: blend_date_range {
    type: date
    label: "Analysis Date Range"
    description: "Filters analysis_date in both sources before aggregation and the full outer join."
  }
  filter: blend_pilot_id {
    type: string
    label: "Pilot ID"
    description: "Filters pilot_id independently in both sources before aggregation."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_id
  }
  filter: blend_pilot_name {
    type: string
    label: "Pilot Name"
    description: "Filters pilot_name independently in both sources before aggregation."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
  }
  filter: blend_bc_end_week_number {
    type: string
    label: "BC End Week#"
    description: "Filters billing-cycle end week in Email Statistics before aggregation. The three Daily Tracker series have no billing-week field and are unaffected."
    suggest_explore: bre_email_week_filters
    suggest_dimension: bre_email_statistics.bc_end_week_number
  }
  derived_table: {
    sql:
      WITH statistics_by_key AS (
        SELECT s.email_type, s.analysis_date,
          SUM(s.cnt_expected_invoices) AS weekly_expected_total,
          COUNT(s.cnt_expected_invoices) AS weekly_expected_count,
          SUM(s.cnt_bills_item_available) AS weekly_eligible_total,
          COUNT(s.cnt_bills_item_available) AS weekly_eligible_count,
          SUM(s.cnt_bills_emails_sent) AS weekly_sent_total,
          COUNT(s.cnt_bills_emails_sent) AS weekly_sent_count,
          SUM(s.email_sent_pct) AS weekly_sent_vs_eligible_total,
          COUNT(s.email_sent_pct) AS weekly_sent_vs_eligible_count,
          SUM(CAST(s.cnt_bills_emails_sent AS DOUBLE) / NULLIF(s.cnt_expected_invoices, 0) * 100.0) AS weekly_sent_vs_expected_total,
          COUNT(CAST(s.cnt_bills_emails_sent AS DOUBLE) / NULLIF(s.cnt_expected_invoices, 0) * 100.0) AS weekly_sent_vs_expected_count
        FROM ${bre_email_statistics.SQL_TABLE_NAME} s
        WHERE {% condition bre_email_delivery.blend_date_range %} s.analysis_date {% endcondition %}
          AND {% condition bre_email_delivery.blend_pilot_id %} s.pilot_id {% endcondition %}
          AND {% condition bre_email_delivery.blend_pilot_name %} s.pilot_name {% endcondition %}
          AND {% condition bre_email_delivery.blend_bc_end_week_number %} s.bc_end_week_number {% endcondition %}
        GROUP BY s.email_type, s.analysis_date
      ), tracker_by_key AS (
        SELECT t.email_type, t.analysis_date,
          SUM(t.invoice_ingested) AS daily_eligible_total,
          SUM(t.generated_notification_id) AS daily_generated_total,
          SUM(t.delivered_notification_id) AS daily_sent_total
        FROM ${bre_email_tracker.SQL_TABLE_NAME} t
        WHERE {% condition bre_email_delivery.blend_date_range %} t.analysis_date {% endcondition %}
          AND {% condition bre_email_delivery.blend_pilot_id %} t.pilot_id {% endcondition %}
          AND {% condition bre_email_delivery.blend_pilot_name %} t.pilot_name {% endcondition %}
        GROUP BY t.email_type, t.analysis_date
      )
      SELECT ROW_NUMBER() OVER () AS row_id,
        COALESCE(s.email_type, t.email_type) AS email_type,
        COALESCE(s.analysis_date, t.analysis_date) AS analysis_date,
        t.daily_eligible_total,
        t.daily_generated_total,
        t.daily_sent_total,
        s.weekly_expected_total,
        s.weekly_expected_count,
        s.weekly_eligible_total,
        s.weekly_eligible_count,
        s.weekly_sent_total,
        s.weekly_sent_count,
        s.weekly_sent_vs_eligible_total,
        s.weekly_sent_vs_eligible_count,
        s.weekly_sent_vs_expected_total,
        s.weekly_sent_vs_expected_count
      FROM statistics_by_key s
      FULL OUTER JOIN tracker_by_key t
        ON s.email_type = t.email_type AND s.analysis_date = t.analysis_date
    ;;
  }
  dimension: daily_eligible_total {
    type: number
    hidden: yes
    description: "Daily Eligible Invoices #: per-key sum retained for Period aggregation."
    sql: ${TABLE}.daily_eligible_total ;;
  }
  measure: daily_eligible {
    type: number
    label: "Daily Eligible Invoices #"
    description: "Sum of source counts across the selected Period. Unmatched source values remain NULL."
    sql: SUM(${daily_eligible_total}) ;;
    value_format: "#,##0.00"
  }
  dimension: daily_generated_total {
    type: number
    hidden: yes
    description: "Daily Email Generation #: per-key sum retained for Period aggregation."
    sql: ${TABLE}.daily_generated_total ;;
  }
  measure: daily_generated {
    type: number
    label: "Daily Email Generation #"
    description: "Sum of source counts across the selected Period. Unmatched source values remain NULL."
    sql: SUM(${daily_generated_total}) ;;
    value_format: "#,##0.00"
  }
  dimension: daily_sent_total {
    type: number
    hidden: yes
    description: "Daily Email Sent #: per-key sum retained for Period aggregation."
    sql: ${TABLE}.daily_sent_total ;;
  }
  measure: daily_sent {
    type: number
    label: "Daily Email Sent #"
    description: "Sum of source counts across the selected Period. Unmatched source values remain NULL."
    sql: SUM(${daily_sent_total}) ;;
    value_format: "#,##0.00"
  }
  dimension: weekly_expected_total {
    type: number
    hidden: yes
    description: "Weekly Expected Email #: per-key sum retained for Period aggregation."
    sql: ${TABLE}.weekly_expected_total ;;
  }
  dimension: weekly_expected_count {
    type: number
    hidden: yes
    description: "Weekly Expected Email #: per-key non-NULL source-row count retained for Period aggregation."
    sql: ${TABLE}.weekly_expected_count ;;
  }
  measure: weekly_expected {
    type: number
    label: "Weekly Expected Email #"
    description: "Source-row arithmetic average reconstructed from sums and non-NULL counts across the selected Period. Unmatched source values remain NULL."
    sql: CAST(SUM(${weekly_expected_total}) AS DOUBLE) / NULLIF(SUM(${weekly_expected_count}), 0) ;;
    value_format: "#,##0.00"
  }
  dimension: weekly_eligible_total {
    type: number
    hidden: yes
    description: "Weekly Eligible User #: per-key sum retained for Period aggregation."
    sql: ${TABLE}.weekly_eligible_total ;;
  }
  dimension: weekly_eligible_count {
    type: number
    hidden: yes
    description: "Weekly Eligible User #: per-key non-NULL source-row count retained for Period aggregation."
    sql: ${TABLE}.weekly_eligible_count ;;
  }
  measure: weekly_eligible {
    type: number
    label: "Weekly Eligible User #"
    description: "Source-row arithmetic average reconstructed from sums and non-NULL counts across the selected Period. Unmatched source values remain NULL."
    sql: CAST(SUM(${weekly_eligible_total}) AS DOUBLE) / NULLIF(SUM(${weekly_eligible_count}), 0) ;;
    value_format: "#,##0.00"
  }
  dimension: weekly_sent_total {
    type: number
    hidden: yes
    description: "Weekly Email Sent #: per-key sum retained for Period aggregation."
    sql: ${TABLE}.weekly_sent_total ;;
  }
  dimension: weekly_sent_count {
    type: number
    hidden: yes
    description: "Weekly Email Sent #: per-key non-NULL source-row count retained for Period aggregation."
    sql: ${TABLE}.weekly_sent_count ;;
  }
  measure: weekly_sent {
    type: number
    label: "Weekly Email Sent #"
    description: "Source-row arithmetic average reconstructed from sums and non-NULL counts across the selected Period. Unmatched source values remain NULL."
    sql: CAST(SUM(${weekly_sent_total}) AS DOUBLE) / NULLIF(SUM(${weekly_sent_count}), 0) ;;
    value_format: "#,##0.00"
  }
  dimension: weekly_sent_vs_eligible_total {
    type: number
    hidden: yes
    description: "Weekly Tracker Email Sent vs Eligible %: per-key sum retained for Period aggregation."
    sql: ${TABLE}.weekly_sent_vs_eligible_total ;;
  }
  dimension: weekly_sent_vs_eligible_count {
    type: number
    hidden: yes
    description: "Weekly Tracker Email Sent vs Eligible %: per-key non-NULL source-row count retained for Period aggregation."
    sql: ${TABLE}.weekly_sent_vs_eligible_count ;;
  }
  measure: weekly_sent_vs_eligible {
    type: number
    label: "Weekly Tracker Email Sent vs Eligible %"
    description: "Source-row arithmetic average reconstructed from sums and non-NULL counts across the selected Period. Unmatched source values remain NULL."
    sql: CAST(SUM(${weekly_sent_vs_eligible_total}) AS DOUBLE) / NULLIF(SUM(${weekly_sent_vs_eligible_count}), 0) ;;
    value_format: "0.00\"%\""
  }
  dimension: weekly_sent_vs_expected_total {
    type: number
    hidden: yes
    description: "Weekly Tracker Email Sent vs Expected %: per-key sum retained for Period aggregation."
    sql: ${TABLE}.weekly_sent_vs_expected_total ;;
  }
  dimension: weekly_sent_vs_expected_count {
    type: number
    hidden: yes
    description: "Weekly Tracker Email Sent vs Expected %: per-key non-NULL source-row count retained for Period aggregation."
    sql: ${TABLE}.weekly_sent_vs_expected_count ;;
  }
  measure: weekly_sent_vs_expected {
    type: number
    label: "Weekly Tracker Email Sent vs Expected %"
    description: "Source-row arithmetic average reconstructed from sums and non-NULL counts across the selected Period. Unmatched source values remain NULL."
    sql: CAST(SUM(${weekly_sent_vs_expected_total}) AS DOUBLE) / NULLIF(SUM(${weekly_sent_vs_expected_count}), 0) ;;
    value_format: "0.00\"%\""
  }
}
