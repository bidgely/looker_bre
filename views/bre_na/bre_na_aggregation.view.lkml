include: "/views/bre/bre_pilots.view.lkml"

# SRC-29: preserve the supplied inner join and source rows, without deduplication.
view: bre_na_aggregation {
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id,
        p.pilot_name, CAST(s.pilot_id AS VARCHAR) || ' : ' || p.pilot_name AS pilot_id_name,
        s.*
      FROM delta_prodna.reporting.sre_raw_data_analysis s
      INNER JOIN ${bre_pilots.SQL_TABLE_NAME} p ON p.pilot_id = CAST(s.pilot_id AS VARCHAR)
      WHERE {% condition pilot_id %} CAST(s.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} p.pilot_name {% endcondition %}
        AND {% condition duration %} s.duration {% endcondition %}
        AND {% if comparison_date_range._is_filtered %}
          ({% condition comparison_date_range %} s.reporting_date {% endcondition %}
           OR COALESCE(s.reporting_date >= date_add('day',
             -date_diff('day', CAST({% date_start comparison_date_range %} AS DATE), CAST({% date_end comparison_date_range %} AS DATE)),
             CAST({% date_start comparison_date_range %} AS DATE))
             AND s.reporting_date < CAST({% date_start comparison_date_range %} AS DATE), FALSE))
        {% else %}
          {% condition date_range %} s.reporting_date {% endcondition %}
        {% endif %}
    ;;
  }
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local row identifier; preserves every source join result, including duplicates."
    sql: ${TABLE}.row_id ;;
  }
  filter: date_range {
    type: date
    description: "Reporting-date range for Aggregation tiles; analysis_date remains the trend grouping date."
  }
  filter: comparison_date_range {
    type: date
    description: "Selected reporting dates; retains the preceding equal-length range for average and median comparisons."
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
    description: "Pilot name formatted by the SRC-29 parenthesis rule."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
    sql: ${TABLE}.pilot_name ;;
  }
  dimension: duration {
    type: number
    description: "Source duration used by File Granularity; raw units retained."
    sql: ${TABLE}.duration ;;
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
  dimension: total_meters {
    type: number
    description: "Raw SRC-29 total_meters; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_meters ;;
  }
  dimension: total_datapoints {
    type: number
    description: "Raw SRC-29 total_datapoints; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_datapoints ;;
  }
  dimension: total_expected_datapoints {
    type: number
    description: "Raw SRC-29 total_expected_datapoints; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_expected_datapoints ;;
  }
  dimension: total_negative_consumption_datapoints {
    type: number
    description: "Raw SRC-29 total_negative_consumption_datapoints; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_negative_consumption_datapoints ;;
  }
  dimension: negative_consumption_users {
    type: number
    description: "Raw SRC-29 negative_consumption_users; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.negative_consumption_users ;;
  }
  dimension: total_negative_consumption_users {
    type: number
    description: "Raw SRC-29 total_negative_consumption_users; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_negative_consumption_users ;;
  }
  dimension: zero_consumption_users {
    type: number
    description: "Raw SRC-29 zero_consumption_users; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.zero_consumption_users ;;
  }
  dimension: total_zero_consumption_users {
    type: number
    description: "Raw SRC-29 total_zero_consumption_users; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_zero_consumption_users ;;
  }
  dimension: missing_datapoint_users {
    type: number
    description: "Raw SRC-29 missing_datapoint_users; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.missing_datapoint_users ;;
  }
  dimension: negative_consumption_meters {
    type: number
    description: "Raw SRC-29 negative_consumption_meters; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.negative_consumption_meters ;;
  }
  dimension: total_negative_consumption_meters {
    type: number
    description: "Raw SRC-29 total_negative_consumption_meters; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_negative_consumption_meters ;;
  }
  dimension: zero_consumption_meters {
    type: number
    description: "Raw SRC-29 zero_consumption_meters; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.zero_consumption_meters ;;
  }
  dimension: total_zero_consumption_meters {
    type: number
    description: "Raw SRC-29 total_zero_consumption_meters; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.total_zero_consumption_meters ;;
  }
  dimension: missing_datapoint_meters {
    type: number
    description: "Raw SRC-29 missing_datapoint_meters; source NULLs retained."
    hidden: yes
    sql: ${TABLE}.missing_datapoint_meters ;;
  }
  dimension: success_perc {
    type: number
    description: "User-confirmed Looker Studio sucess_perc = 100 * (total_datapoints / total_expected_datapoints). Zero denominator returns NULL."
    hidden: yes
    sql: 100.0 * CAST(${total_datapoints} AS DOUBLE) / NULLIF(${total_expected_datapoints}, 0) ;;
  }
  measure: total_meters_sum {
    type: sum
    description: "Sum of source total_meters."
    value_format: "#,##0"
    sql: ${total_meters} ;;
  }
  measure: total_datapoints_sum {
    type: sum
    description: "Sum of source total_datapoints."
    value_format: "#,##0"
    sql: ${total_datapoints} ;;
  }
  measure: total_expected_datapoints_sum {
    type: sum
    description: "Sum of source total_expected_datapoints."
    value_format: "#,##0"
    sql: ${total_expected_datapoints} ;;
  }
  measure: total_negative_consumption_datapoints_sum {
    type: sum
    description: "Sum of source total_negative_consumption_datapoints."
    value_format: "#,##0"
    sql: ${total_negative_consumption_datapoints} ;;
  }
  measure: negative_consumption_users_sum {
    type: sum
    description: "Sum of source negative_consumption_users."
    value_format: "#,##0"
    sql: ${negative_consumption_users} ;;
  }
  measure: total_negative_consumption_users_sum {
    type: sum
    description: "Sum of source total_negative_consumption_users."
    value_format: "#,##0"
    sql: ${total_negative_consumption_users} ;;
  }
  measure: zero_consumption_users_sum {
    type: sum
    description: "Sum of source zero_consumption_users."
    value_format: "#,##0"
    sql: ${zero_consumption_users} ;;
  }
  measure: total_zero_consumption_users_sum {
    type: sum
    description: "Sum of source total_zero_consumption_users."
    value_format: "#,##0"
    sql: ${total_zero_consumption_users} ;;
  }
  measure: missing_datapoint_users_sum {
    type: sum
    description: "Sum of source missing_datapoint_users."
    value_format: "#,##0"
    sql: ${missing_datapoint_users} ;;
  }
  measure: negative_consumption_meters_sum {
    type: sum
    description: "Sum of source negative_consumption_meters."
    value_format: "#,##0"
    sql: ${negative_consumption_meters} ;;
  }
  measure: total_negative_consumption_meters_sum {
    type: sum
    description: "Sum of source total_negative_consumption_meters."
    value_format: "#,##0"
    sql: ${total_negative_consumption_meters} ;;
  }
  measure: zero_consumption_meters_sum {
    type: sum
    description: "Sum of source zero_consumption_meters."
    value_format: "#,##0"
    sql: ${zero_consumption_meters} ;;
  }
  measure: total_zero_consumption_meters_sum {
    type: sum
    description: "Sum of source total_zero_consumption_meters."
    value_format: "#,##0"
    sql: ${total_zero_consumption_meters} ;;
  }
  measure: missing_datapoint_meters_sum {
    type: sum
    description: "Sum of source missing_datapoint_meters."
    value_format: "#,##0"
    sql: ${missing_datapoint_meters} ;;
  }
  measure: total_meters_average {
    type: average
    description: "Unweighted source-row average of total_meters; NULLs omitted."
    value_format: "#,##0.00"
    sql: ${total_meters} ;;
  }
  measure: success_perc_average {
    type: average
    description: "Unweighted source-row average of success_perc; NULLs omitted."
    value_format: "0.00\"%\""
    sql: ${success_perc} ;;
  }
  dimension: gauge_label {
    type: string
    description: "Constant category for live single-value gauges."
    hidden: yes
    sql: 'Average' ;;
  }
  dimension: comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "Aggregation Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start comparison_date_range %} AS DATE) ;;
  }
  dimension: comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "Aggregation Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "Aggregation Dashboard"
    hidden: yes
    sql: {% condition comparison_date_range %} ${reporting_date::date} {% endcondition %} ;;
  }
  dimension: is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "Aggregation Dashboard"
    hidden: yes
    sql: COALESCE(
      ${comparison_end::date} > ${comparison_start::date}
      AND ${reporting_date::date} >= date_add('day', -date_diff('day', ${comparison_start::date}, ${comparison_end::date}), ${comparison_start::date})
      AND ${reporting_date::date} < ${comparison_start::date}, FALSE) ;;
  }
  dimension: in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two raw datapoint statistics."
    group_label: "Aggregation Dashboard"
    hidden: yes
    sql: ${is_selected_period} OR ${is_previous_period} ;;
  }
  dimension: datapoints_selected {
    type: number
    description: "Raw datapoint count for the selected comparison period; other rows are NULL."
    group_label: "Aggregation Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_selected_period} THEN ${total_datapoints} END ;;
  }
  measure: datapoints_selected_average {
    type: number
    label: "Raw Datapoints — Selected Average"
    group_label: "Aggregation Dashboard"
    description: "Unweighted average of source total_datapoints within this comparison range."
    sql:
      AVG(${datapoints_selected}) ;;
    value_format: "#,##0.00"
  }
  measure: datapoints_selected_median {
    type: number
    label: "Raw Datapoints — Selected Median"
    group_label: "Aggregation Dashboard"
    description: "Exact median of source raw datapoint counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${datapoints_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${datapoints_selected} AS DOUBLE)) FILTER (WHERE ${datapoints_selected} IS NOT NULL)), CAST(floor((COUNT(${datapoints_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${datapoints_selected} AS DOUBLE)) FILTER (WHERE ${datapoints_selected} IS NOT NULL)), CAST(floor((COUNT(${datapoints_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  dimension: datapoints_previous {
    type: number
    description: "Raw datapoint count for the previous comparison period; other rows are NULL."
    group_label: "Aggregation Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_previous_period} THEN ${total_datapoints} END ;;
  }
  measure: datapoints_previous_average {
    type: number
    label: "Raw Datapoints — Previous Average"
    group_label: "Aggregation Dashboard"
    description: "Unweighted average of source total_datapoints within this comparison range."
    sql:
      AVG(${datapoints_previous}) ;;
    value_format: "#,##0.00"
  }
  measure: datapoints_previous_median {
    type: number
    label: "Raw Datapoints — Previous Median"
    group_label: "Aggregation Dashboard"
    description: "Exact median of source raw datapoint counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${datapoints_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${datapoints_previous} AS DOUBLE)) FILTER (WHERE ${datapoints_previous} IS NOT NULL)), CAST(floor((COUNT(${datapoints_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${datapoints_previous} AS DOUBLE)) FILTER (WHERE ${datapoints_previous} IS NOT NULL)), CAST(floor((COUNT(${datapoints_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  measure: datapoints_average_change {
    type: number
    label: "Raw Datapoints Average Change"
    group_label: "Aggregation Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${datapoints_selected_average} - ${datapoints_previous_average}) / NULLIF(${datapoints_previous_average}, 0) ;;
    value_format: "0.0%"
  }
  measure: datapoints_median_change {
    type: number
    label: "Raw Datapoints Median Change"
    group_label: "Aggregation Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${datapoints_selected_median} - ${datapoints_previous_median}) / NULLIF(${datapoints_previous_median}, 0) ;;
    value_format: "0.0%"
  }
}
