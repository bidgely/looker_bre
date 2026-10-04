include: "/views/bre_na/bre_na_disaggregation_fields.view.lkml"
view: bre_na_disaggregation_invoice_fields {
  extension: required
  extends: [bre_na_disaggregation_fields]
  dimension: failed_itemisation_pct {
    type: number
    hidden: yes
    description: "Source failed itemisation percentage."
    sql: ${TABLE}.failed_itemisation_pct ;;
  }
  dimension: failed_itemisation_fraction {
    type: number
    description: "User-supplied failed_itemisation_%: NULL becomes zero, otherwise source percentage divided by 100."
    sql: COALESCE(CAST(${failed_itemisation_pct} AS DOUBLE), 0) / 100.0 ;;
    value_format_name: percent_2
  }
  measure: daily_total_invoices {
    type: number
    description: "User-supplied daily_total_invoice#: AVG(total_invoices) for exactly one distinct analysis date, otherwise SUM(total_invoices). Not substituted for the chart's documented MAX."
    sql: CASE WHEN COUNT(DISTINCT ${analysis_date::date}) = 1 THEN AVG(${total_invoices}) ELSE SUM(${total_invoices}) END ;;
    value_format: "#,##0.00"
  }
  measure: record_count {
    type: number
    description: "User-supplied Record Count: COUNT(pilot_id), excluding NULL pilot IDs."
    sql: COUNT(${pilot_id}) ;;
    value_format: "#,##0"
  }
  dimension: module_name {
    type: string
    description: "Source module name."
    sql: ${TABLE}.module_name ;;
  }
  dimension: total_invoices {
    type: number
    description: "Source total_invoices without reweighting."
    hidden: yes
    sql: ${TABLE}.total_invoices ;;
  }
  dimension: delay_in_days {
    type: number
    description: "Source delay_in_days without reweighting."
    hidden: yes
    sql: ${TABLE}.delay_in_days ;;
  }
  dimension: successful_itemisation_pct {
    type: number
    description: "Source successful_itemisation_pct without reweighting."
    hidden: yes
    sql: ${TABLE}.successful_itemisation_pct ;;
  }
  dimension: trigger_flag {
    type: string
    description: "Source SCHEDULED or ADHOC trigger flag."
    hidden: yes
    sql: ${TABLE}.trigger_flag ;;
  }
  dimension: gauge_label {
    type: string
    description: "Constant category for a single-row success gauge."
    hidden: yes
    sql: 'Success %' ;;
  }
  dimension: success_t2 {
    type: number
    description: "Documented successful itemisation calculated field; nonmatching rows remain NULL."
    hidden: yes
    sql: CASE WHEN ${delay_in_days} = 2 AND ${trigger_flag} = 'SCHEDULED' THEN ${successful_itemisation_pct} END ;;
  }
  measure: success_t2_sum {
    type: sum
    description: "Sum of the conditional successful-itemisation source percentages; no ratio recomputation."
    value_format: "0.00\"%\""
    sql: ${success_t2} ;;
  }
  measure: success_t2_average {
    type: average
    description: "Average of the conditional successful-itemisation source percentages; no ratio recomputation."
    value_format: "0.00\"%\""
    sql: ${success_t2} ;;
  }
  dimension: success_t7 {
    type: number
    description: "Documented successful itemisation calculated field; nonmatching rows remain NULL."
    hidden: yes
    sql: CASE WHEN ${delay_in_days} = 7 AND ${trigger_flag} = 'SCHEDULED' THEN ${successful_itemisation_pct} END ;;
  }
  measure: success_t7_sum {
    type: sum
    description: "Sum of the conditional successful-itemisation source percentages; no ratio recomputation."
    value_format: "0.00\"%\""
    sql: ${success_t7} ;;
  }
  measure: success_t7_average {
    type: average
    description: "Average of the conditional successful-itemisation source percentages; no ratio recomputation."
    value_format: "0.00\"%\""
    sql: ${success_t7} ;;
  }
  dimension: success_correction {
    type: number
    description: "Documented successful itemisation calculated field; nonmatching rows remain NULL."
    hidden: yes
    sql: CASE WHEN ${trigger_flag} = 'ADHOC' THEN ${successful_itemisation_pct} END ;;
  }
  measure: success_correction_max {
    type: max
    description: "Max of the conditional successful-itemisation source percentages; no ratio recomputation."
    value_format: "0.00\"%\""
    sql: ${success_correction} ;;
  }
  measure: total_invoices_max {
    type: max
    description: "Maximum source total_invoices, as specified for the hybrid-processing chart."
    value_format: "#,##0"
    sql: ${total_invoices} ;;
  }
  dimension: period_date {
    type: date
    description: "Analysis-date trend bucket; Sunday-start weeks."
    convert_tz: no
    sql: {% if period._parameter_value == "'Weekly'" %}
      date_add('day', -1, date_trunc('week', date_add('day', 1, ${analysis_date::date})))
      {% elsif period._parameter_value == "'Monthly'" %} date_trunc('month', ${analysis_date::date})
      {% else %} ${analysis_date::date} {% endif %} ;;
  }
  filter: comparison_date_range {
    type: date
    description: "Selected analysis dates and immediately preceding equal-length range for invoice average and median comparisons."
  }
  dimension: comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "Disaggregation Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start comparison_date_range %} AS DATE) ;;
  }
  dimension: comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "Disaggregation Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "Disaggregation Dashboard"
    hidden: yes
    sql: {% condition comparison_date_range %} ${analysis_date::date} {% endcondition %} ;;
  }
  dimension: is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "Disaggregation Dashboard"
    hidden: yes
    sql: COALESCE(
      ${comparison_end::date} > ${comparison_start::date}
      AND ${analysis_date::date} >= date_add('day', -date_diff('day', ${comparison_start::date}, ${comparison_end::date}), ${comparison_start::date})
      AND ${analysis_date::date} < ${comparison_start::date}, FALSE) ;;
  }
  dimension: in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two invoice statistics."
    group_label: "Disaggregation Dashboard"
    hidden: yes
    sql: ${is_selected_period} OR ${is_previous_period} ;;
  }
  dimension: invoices_selected {
    type: number
    description: "Invoice count for the selected comparison period; other rows are NULL."
    group_label: "Disaggregation Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_selected_period} THEN ${total_invoices} END ;;
  }
  measure: invoices_selected_average {
    type: number
    label: "Invoices — Selected Average"
    group_label: "Disaggregation Dashboard"
    description: "Unweighted average of source total_invoices within this comparison range."
    sql:
      AVG(${invoices_selected}) ;;
    value_format: "#,##0.00"
  }
  measure: invoices_selected_median {
    type: number
    label: "Invoices — Selected Median"
    group_label: "Disaggregation Dashboard"
    description: "Exact median of source invoice counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${invoices_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${invoices_selected} AS DOUBLE)) FILTER (WHERE ${invoices_selected} IS NOT NULL)), CAST(floor((COUNT(${invoices_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${invoices_selected} AS DOUBLE)) FILTER (WHERE ${invoices_selected} IS NOT NULL)), CAST(floor((COUNT(${invoices_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  dimension: invoices_previous {
    type: number
    description: "Invoice count for the previous comparison period; other rows are NULL."
    group_label: "Disaggregation Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_previous_period} THEN ${total_invoices} END ;;
  }
  measure: invoices_previous_average {
    type: number
    label: "Invoices — Previous Average"
    group_label: "Disaggregation Dashboard"
    description: "Unweighted average of source total_invoices within this comparison range."
    sql:
      AVG(${invoices_previous}) ;;
    value_format: "#,##0.00"
  }
  measure: invoices_previous_median {
    type: number
    label: "Invoices — Previous Median"
    group_label: "Disaggregation Dashboard"
    description: "Exact median of source invoice counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${invoices_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${invoices_previous} AS DOUBLE)) FILTER (WHERE ${invoices_previous} IS NOT NULL)), CAST(floor((COUNT(${invoices_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${invoices_previous} AS DOUBLE)) FILTER (WHERE ${invoices_previous} IS NOT NULL)), CAST(floor((COUNT(${invoices_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  measure: invoices_average_change {
    type: number
    label: "Invoices Average Change"
    group_label: "Disaggregation Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${invoices_selected_average} - ${invoices_previous_average}) / NULLIF(${invoices_previous_average}, 0) ;;
    value_format: "0.0%"
  }
  measure: invoices_median_change {
    type: number
    label: "Invoices Median Change"
    group_label: "Disaggregation Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${invoices_selected_median} - ${invoices_previous_median}) / NULLIF(${invoices_previous_median}, 0) ;;
    value_format: "0.0%"
  }
}
