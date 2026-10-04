view: bre_na_tou_fields {
  extension: required
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local row identifier; preserves every source join result, including duplicates."
    sql: ${TABLE}.row_id ;;
  }
  filter: date_range {
    type: date
    description: "Analysis-date range for the TOU source tiles."
  }
  filter: comparison_date_range {
    type: date
    description: "Selected analysis dates; retains the preceding equal-length range for average and median comparisons."
  }
  parameter: period {
    type: string
    default_value: "Daily"
    description: "Group analysis dates by day, Sunday-start week, or month."
    allowed_value: { label: "Daily" value: "Daily" }
    allowed_value: { label: "Weekly" value: "Weekly" }
    allowed_value: { label: "Monthly" value: "Monthly" }
  }
  dimension: pilot_id {
    type: string
    description: "Source pilot identifier."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_id
    sql: CAST(${TABLE}.pilot_id AS VARCHAR) ;;
  }
  dimension: pilot_name {
    type: string
    description: "Pilot name formatted by the SRC-35 parenthesis rule."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
    sql: ${TABLE}.pilot_name ;;
  }
  dimension: tou_mode {
    type: string
    description: "Source TOU mode; dashboard default is COMPLETE_BILLING_CYCLE."
    sql: ${TABLE}.tou_mode ;;
  }
  dimension: delay_in_days {
    type: number
    description: "Source delay in days; dashboard default is 1."
    sql: ${TABLE}.delay_in_days ;;
  }
  dimension: analysis_date {
    type: date
    description: "Source analysis_date without timezone conversion."
    convert_tz: no
    sql: ${TABLE}.analysis_date ;;
  }
  dimension: reporting_date {
    type: date
    description: "Source reporting_date without timezone conversion."
    convert_tz: no
    sql: ${TABLE}.reporting_date ;;
  }
  dimension: period_date {
    type: date
    description: "Analysis-date bucket; Sunday-start weeks match the documented Looker Studio WEEK calculation."
    convert_tz: no
    sql: {% if period._parameter_value == "'Weekly'" %}
      date_add('day', -1, date_trunc('week', date_add('day', 1, ${analysis_date::date})))
      {% elsif period._parameter_value == "'Monthly'" %} date_trunc('month', ${analysis_date::date})
      {% else %} ${analysis_date::date} {% endif %} ;;
  }
  dimension: total_tou_eligible_invoices {
    type: number
    description: "Raw SRC-35 total_tou_eligible_invoices; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_tou_eligible_invoices ;;
  }
  measure: total_tou_eligible_invoices_sum {
    type: sum
    description: "Sum of source total_tou_eligible_invoices."
    value_format: "#,##0"
    sql: ${total_tou_eligible_invoices} ;;
  }
  dimension: total_disagg_tou_invoices {
    type: number
    description: "Raw SRC-35 total_disagg_tou_invoices; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_disagg_tou_invoices ;;
  }
  measure: total_disagg_tou_invoices_sum {
    type: sum
    description: "Sum of source total_disagg_tou_invoices."
    value_format: "#,##0"
    sql: ${total_disagg_tou_invoices} ;;
  }
  dimension: actual_total_tou_invoices {
    type: number
    description: "Raw SRC-35 actual_total_tou_invoices; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.actual_total_tou_invoices ;;
  }
  measure: actual_total_tou_invoices_sum {
    type: sum
    description: "Sum of source actual_total_tou_invoices."
    value_format: "#,##0"
    sql: ${actual_total_tou_invoices} ;;
  }
  dimension: successful_tou_eligible_invoices {
    type: number
    description: "Raw SRC-35 successful_tou_eligible_invoices; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.successful_tou_eligible_invoices ;;
  }
  measure: successful_tou_eligible_invoices_sum {
    type: sum
    description: "Sum of source successful_tou_eligible_invoices."
    value_format: "#,##0"
    sql: ${successful_tou_eligible_invoices} ;;
  }
  dimension: tou_success_pct {
    type: number
    description: "User-confirmed tou_success_pct = successful_tou_eligible_invoices / total_tou_eligible_invoices, as a fraction. A zero denominator returns NULL."
    hidden: yes
    sql: CAST(${successful_tou_eligible_invoices} AS DOUBLE) / NULLIF(${total_tou_eligible_invoices}, 0) ;;
  }
  measure: tou_success_pct_average {
    type: average
    description: "Unweighted average of report-calculated tou_success_pct fractions, multiplied by 100 for percentage-point display; NULLs omitted."
    value_format: "0.00\"%\""
    sql: 100.0 * ${tou_success_pct} ;;
  }
  dimension: tou_failure_pct {
    type: number
    description: "User-confirmed tou_failure_pct = 1 - tou_success_pct; NULL success remains NULL."
    hidden: yes
    sql: 1.0 - ${tou_success_pct} ;;
  }
  measure: tou_failure_pct_average {
    type: average
    description: "Unweighted average of report-calculated tou_failure_pct fractions, multiplied by 100 for percentage-point display; NULLs omitted."
    value_format: "0.00\"%\""
    sql: 100.0 * ${tou_failure_pct} ;;
  }
  dimension: gauge_label {
    type: string
    description: "Constant category for the live single-value TOU percentage gauges."
    hidden: yes
    sql: 'Distribution %' ;;
  }
  dimension: comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "TOU Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start comparison_date_range %} AS DATE) ;;
  }
  dimension: comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "TOU Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "TOU Dashboard"
    hidden: yes
    sql: {% condition comparison_date_range %} ${analysis_date::date} {% endcondition %} ;;
  }
  dimension: is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "TOU Dashboard"
    hidden: yes
    sql: COALESCE(
      ${comparison_end::date} > ${comparison_start::date}
      AND ${analysis_date::date} >= date_add('day', -date_diff('day', ${comparison_start::date}, ${comparison_end::date}), ${comparison_start::date})
      AND ${analysis_date::date} < ${comparison_start::date}, FALSE) ;;
  }
  dimension: in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two successful TOU invoice statistics."
    group_label: "TOU Dashboard"
    hidden: yes
    sql: ${is_selected_period} OR ${is_previous_period} ;;
  }
  dimension: successful_invoices_selected {
    type: number
    description: "Successful TOU invoice count for the selected comparison period; other rows are NULL."
    group_label: "TOU Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_selected_period} THEN ${successful_tou_eligible_invoices} END ;;
  }
  measure: successful_invoices_selected_average {
    type: number
    label: "Successful TOU Aggregation — Selected Average"
    group_label: "TOU Dashboard"
    description: "Unweighted average of source successful_tou_eligible_invoices within this comparison range."
    sql:
      AVG(${successful_invoices_selected}) ;;
    value_format: "#,##0.00"
  }
  measure: successful_invoices_selected_median {
    type: number
    label: "Successful TOU Aggregation — Selected Median"
    group_label: "TOU Dashboard"
    description: "Exact median of source successful TOU invoice counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${successful_invoices_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${successful_invoices_selected} AS DOUBLE)) FILTER (WHERE ${successful_invoices_selected} IS NOT NULL)), CAST(floor((COUNT(${successful_invoices_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${successful_invoices_selected} AS DOUBLE)) FILTER (WHERE ${successful_invoices_selected} IS NOT NULL)), CAST(floor((COUNT(${successful_invoices_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  dimension: successful_invoices_previous {
    type: number
    description: "Successful TOU invoice count for the previous comparison period; other rows are NULL."
    group_label: "TOU Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_previous_period} THEN ${successful_tou_eligible_invoices} END ;;
  }
  measure: successful_invoices_previous_average {
    type: number
    label: "Successful TOU Aggregation — Previous Average"
    group_label: "TOU Dashboard"
    description: "Unweighted average of source successful_tou_eligible_invoices within this comparison range."
    sql:
      AVG(${successful_invoices_previous}) ;;
    value_format: "#,##0.00"
  }
  measure: successful_invoices_previous_median {
    type: number
    label: "Successful TOU Aggregation — Previous Median"
    group_label: "TOU Dashboard"
    description: "Exact median of source successful TOU invoice counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${successful_invoices_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${successful_invoices_previous} AS DOUBLE)) FILTER (WHERE ${successful_invoices_previous} IS NOT NULL)), CAST(floor((COUNT(${successful_invoices_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${successful_invoices_previous} AS DOUBLE)) FILTER (WHERE ${successful_invoices_previous} IS NOT NULL)), CAST(floor((COUNT(${successful_invoices_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  measure: successful_invoices_average_change {
    type: number
    label: "Successful TOU Aggregation Average Change"
    group_label: "TOU Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${successful_invoices_selected_average} - ${successful_invoices_previous_average}) / NULLIF(${successful_invoices_previous_average}, 0) ;;
    value_format: "0.0%"
  }
  measure: successful_invoices_median_change {
    type: number
    label: "Successful TOU Aggregation Median Change"
    group_label: "TOU Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${successful_invoices_selected_median} - ${successful_invoices_previous_median}) / NULLIF(${successful_invoices_previous_median}, 0) ;;
    value_format: "0.0%"
  }
}
