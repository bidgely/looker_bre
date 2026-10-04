include: "/views/bre_na/bre_na_nbi_fields.view.lkml"

# SRC-41. Source row grain and joins retained.
view: bre_na_nbi_generation {
  extends: [bre_na_nbi_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
SELECT
    m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users as total_users_successful, s.total_users_with_200_errorcode, s.total_users_with_300_errorcode, s.nbi_error_pct, s.last_updated_timestamp
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM delta_prodna.reporting.pilot_consolidated_product_type_events) as m
JOIN
    delta_prodna.reporting.sre_nbi_generated_errors s
ON
    m.pilot_id = s.pilot_id
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% if comparison_date_range._is_filtered %}
          ({% condition comparison_date_range %} q.analysis_date {% endcondition %}
           OR COALESCE(q.analysis_date >= date_add('day',
             -date_diff('day', CAST({% date_start comparison_date_range %} AS DATE), CAST({% date_end comparison_date_range %} AS DATE)),
             CAST({% date_start comparison_date_range %} AS DATE))
             AND q.analysis_date < CAST({% date_start comparison_date_range %} AS DATE), FALSE))
        {% else %}
          {% condition date_range %} q.analysis_date {% endcondition %}
        {% endif %}
    ;;
  }
  dimension: total_users_successful {
    type: number
    description: "Source total_users_successful."
    hidden: yes
    sql: ${TABLE}.total_users_successful ;;
  }
  measure: total_users_successful_average {
    type: average
    description: "total users successful average."
    value_format: "#,##0"
    sql: ${total_users_successful} ;;
  }
  dimension: total_users_with_200_errorcode {
    type: number
    description: "Source total_users_with_200_errorcode."
    hidden: yes
    sql: ${TABLE}.total_users_with_200_errorcode ;;
  }
  measure: total_users_with_200_errorcode_average {
    type: average
    description: "total users with 200 errorcode average."
    value_format: "#,##0"
    sql: ${total_users_with_200_errorcode} ;;
  }
  dimension: total_users_with_300_errorcode {
    type: number
    description: "Source total_users_with_300_errorcode."
    hidden: yes
    sql: ${TABLE}.total_users_with_300_errorcode ;;
  }
  measure: total_users_with_300_errorcode_average {
    type: average
    description: "total users with 300 errorcode average."
    value_format: "#,##0"
    sql: ${total_users_with_300_errorcode} ;;
  }
  dimension: nbi_error_pct {
    type: number
    description: "Source nbi_error_pct."
    hidden: yes
    sql: ${TABLE}.nbi_error_pct ;;
  }
  measure: nbi_error_pct_average {
    type: average
    description: "nbi error pct average."
    value_format: "#,##0"
    sql: ${nbi_error_pct} ;;
  }
  dimension: failure_count {
    type: number
    description: "Sum of the two error counts; source NULLs retained."
    hidden: yes
    sql: ${total_users_with_200_errorcode} + ${total_users_with_300_errorcode} ;;
  }
  measure: failure_count_average {
    type: average
    description: "failure count average."
    value_format: "#,##0.00"
    sql: ${failure_count} ;;
  }
  dimension: total_users_nbi_generated {
    type: number
    description: "Successful users plus both error counts."
    hidden: yes
    sql: ${total_users_successful} + ${failure_count} ;;
  }
  measure: total_users_nbi_generated_average {
    type: average
    description: "total users nbi generated average."
    value_format: "#,##0.00"
    sql: ${total_users_nbi_generated} ;;
  }
  dimension: nbi_success_pct {
    type: number
    description: "Success percentage points from the documented complement."
    hidden: yes
    sql: 100.0 - ${nbi_error_pct} ;;
  }
  measure: nbi_success_pct_average {
    type: average
    description: "nbi success pct average."
    value_format: "0.00\"%\""
    sql: ${nbi_success_pct} ;;
  }
  measure: failure_count_sum {
    type: sum
    description: "failure count sum."
    value_format: "#,##0"
    sql: ${failure_count} ;;
  }
  dimension: nbi_200_error_pct {
    type: number
    description: "Share of all failures, as a fraction; zero failures returns NULL."
    hidden: yes
    sql: CAST(${total_users_with_200_errorcode} AS DOUBLE) / NULLIF(${failure_count}, 0) ;;
  }
  measure: nbi_200_error_pct_average {
    type: average
    description: "Unweighted mean error share, displayed in percentage points."
    value_format: "0.00\"%\""
    sql: 100.0 * ${nbi_200_error_pct} ;;
  }
  dimension: nbi_300_error_pct {
    type: number
    description: "Share of all failures, as a fraction; zero failures returns NULL."
    hidden: yes
    sql: CAST(${total_users_with_300_errorcode} AS DOUBLE) / NULLIF(${failure_count}, 0) ;;
  }
  measure: nbi_300_error_pct_average {
    type: average
    description: "Unweighted mean error share, displayed in percentage points."
    value_format: "0.00\"%\""
    sql: 100.0 * ${nbi_300_error_pct} ;;
  }
  dimension: gauge_label {
    type: string
    description: "Constant category for percentage gauges."
    sql: 'Failure distribution %' ;;
  }
  dimension: comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "NBI Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start comparison_date_range %} AS DATE) ;;
  }
  dimension: comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "NBI Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "NBI Dashboard"
    hidden: yes
    sql: {% condition comparison_date_range %} ${analysis_date::date} {% endcondition %} ;;
  }
  dimension: is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "NBI Dashboard"
    hidden: yes
    sql: COALESCE(
      ${comparison_end::date} > ${comparison_start::date}
      AND ${analysis_date::date} >= date_add('day', -date_diff('day', ${comparison_start::date}, ${comparison_end::date}), ${comparison_start::date})
      AND ${analysis_date::date} < ${comparison_start::date}, FALSE) ;;
  }
  dimension: in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two successful NBI user statistics."
    group_label: "NBI Dashboard"
    hidden: yes
    sql: ${is_selected_period} OR ${is_previous_period} ;;
  }
  dimension: successful_users_selected {
    type: number
    description: "Successful NBI user count for the selected comparison period; other rows are NULL."
    group_label: "NBI Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_selected_period} THEN ${total_users_successful} END ;;
  }
  measure: successful_users_selected_average {
    type: number
    label: "NBI Insight Generation — Selected Average"
    group_label: "NBI Dashboard"
    description: "Unweighted average of source total_users_successful within this comparison range."
    sql:
      AVG(${successful_users_selected}) ;;
    value_format: "#,##0.00"
  }
  measure: successful_users_selected_median {
    type: number
    label: "NBI Insight Generation — Selected Median"
    group_label: "NBI Dashboard"
    description: "Exact median of source successful NBI user counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${successful_users_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${successful_users_selected} AS DOUBLE)) FILTER (WHERE ${successful_users_selected} IS NOT NULL)), CAST(floor((COUNT(${successful_users_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${successful_users_selected} AS DOUBLE)) FILTER (WHERE ${successful_users_selected} IS NOT NULL)), CAST(floor((COUNT(${successful_users_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  dimension: successful_users_previous {
    type: number
    description: "Successful NBI user count for the previous comparison period; other rows are NULL."
    group_label: "NBI Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_previous_period} THEN ${total_users_successful} END ;;
  }
  measure: successful_users_previous_average {
    type: number
    label: "NBI Insight Generation — Previous Average"
    group_label: "NBI Dashboard"
    description: "Unweighted average of source total_users_successful within this comparison range."
    sql:
      AVG(${successful_users_previous}) ;;
    value_format: "#,##0.00"
  }
  measure: successful_users_previous_median {
    type: number
    label: "NBI Insight Generation — Previous Median"
    group_label: "NBI Dashboard"
    description: "Exact median of source successful NBI user counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${successful_users_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${successful_users_previous} AS DOUBLE)) FILTER (WHERE ${successful_users_previous} IS NOT NULL)), CAST(floor((COUNT(${successful_users_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${successful_users_previous} AS DOUBLE)) FILTER (WHERE ${successful_users_previous} IS NOT NULL)), CAST(floor((COUNT(${successful_users_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  measure: successful_users_average_change {
    type: number
    label: "NBI Insight Generation Average Change"
    group_label: "NBI Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${successful_users_selected_average} - ${successful_users_previous_average}) / NULLIF(${successful_users_previous_average}, 0) ;;
    value_format: "0.0%"
  }
  measure: successful_users_median_change {
    type: number
    label: "NBI Insight Generation Median Change"
    group_label: "NBI Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${successful_users_selected_median} - ${successful_users_previous_median}) / NULLIF(${successful_users_previous_median}, 0) ;;
    value_format: "0.0%"
  }
  dimension: reporting_date {
    type: date
    description: "Source reporting_date without timezone conversion."
    convert_tz: no
    sql: ${TABLE}.reporting_date ;;
  }
}
