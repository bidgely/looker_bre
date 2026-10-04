include: "/views/bre_na/bre_na_rate_comparison_fields.view.lkml"

# SRC-28; preserve source aggregation and join multiplicity. No PDT.
view: bre_na_rate_comparison {
  extends: [bre_na_rate_comparison_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        SELECT
            m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
            s.*
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
            (
            WITH base AS (
                SELECT
                    pilot_id, analysis_date, reporting_date, notification_type, notification_id, loadshiftamount,
                    rc_run_timestamp, tou_run_timestamp, email_generation_timestamp,
                    CAST(date_add('second', CAST(invoice_ingested_timestamp / 1000 AS BIGINT), TIMESTAMP '1970-01-01 00:00:00') AS TIMESTAMP(3)) AS invoice_ingested_ts,
                    CAST(date_add('second', CAST(rc_run_timestamp / 1000 AS BIGINT), TIMESTAMP '1970-01-01 00:00:00') AS TIMESTAMP(3)) AS rc_run_ts
                FROM delta_prodna.reporting.sre_notification_report
            ),
            agg AS (
                SELECT
                    pilot_id, analysis_date, reporting_date, notification_type AS email_type,
                    count(notification_id) AS total_invoices,
                    count(CASE WHEN (rc_run_timestamp NOT BETWEEN tou_run_timestamp AND email_generation_timestamp)
                                 OR (loadshiftamount = '' AND date_diff('day', date(invoice_ingested_ts), date(rc_run_ts)) < 3)
                          THEN notification_id ELSE NULL END) AS anomaly_count,
                    count(CASE WHEN date_diff('hour', date_trunc('hour', invoice_ingested_ts), date_trunc('hour', rc_run_ts)) < 1
                                 AND rc_run_timestamp > tou_run_timestamp
                          THEN notification_id ELSE NULL END) AS rc_early_trigger_anomally,
                    count(CASE WHEN loadshiftamount = '' AND date_diff('day', date(invoice_ingested_ts), date(rc_run_ts)) < 3
                          THEN notification_id ELSE NULL END) AS rc_missing_anomaly,
                    count(CASE WHEN (rc_run_timestamp NOT BETWEEN tou_run_timestamp AND email_generation_timestamp)
                          THEN notification_id ELSE NULL END) AS rc_ooo_trigger_anomaly,
                    count(CASE WHEN loadshiftamount != '' AND try_cast(loadshiftamount AS DOUBLE) < 20
                          THEN notification_id ELSE NULL END) AS ls_low_value_anomally,
                    CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END AS missing_promotion_flag
                FROM base
                GROUP BY pilot_id, analysis_date, reporting_date, notification_type, CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END
            ),
            with_deviation AS (
                SELECT *,
                    total_invoices - anomaly_count AS favourable_count,
                    round(1.00 * anomaly_count / NULLIF(total_invoices, 0), 3) AS deviation_perc
                FROM agg
            )
            SELECT *, 1 - deviation_perc AS accuracy_perc
            FROM with_deviation
            ) s
        ON
            m.pilot_id = s.pilot_id order by s.reporting_date desc
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% if excluded_email_types._is_filtered %}
          NOT COALESCE(({% condition excluded_email_types %} q.email_type {% endcondition %}), FALSE)
        {% else %} TRUE {% endif %}
        AND {% if excluded_promotions._is_filtered %}
          NOT COALESCE(({% condition excluded_promotions %} q.missing_promotion_flag {% endcondition %}), FALSE)
        {% else %} TRUE {% endif %}
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
  dimension: period_date {
    type: date
    description: "Analysis-date bucket; Sunday-start weeks match the documented Looker Studio WEEK calculation."
    convert_tz: no
    sql: {% if period._parameter_value == "'Weekly'" %}
      date_add('day', -1, date_trunc('week', date_add('day', 1, ${analysis_date::date})))
      {% elsif period._parameter_value == "'Monthly'" %} date_trunc('month', ${analysis_date::date})
      {% else %} ${analysis_date::date} {% endif %} ;;
  }
  dimension: gauge_label {
    type: string
    description: "Constant category for the live single-value Rate Comparison percentage gauges."
    hidden: yes
    sql: 'Distribution %' ;;
  }
  dimension: total_invoices {
    type: number
    hidden: yes
    description: "Source total_invoices; source row grain and NULLs retained."
    sql: ${TABLE}.total_invoices ;;
  }
  measure: total_invoices_sum {
    type: sum
    description: "Sum of source total_invoices."
    value_format: "#,##0"
    sql: ${total_invoices} ;;
  }
  dimension: favourable_count {
    type: number
    hidden: yes
    description: "Source favourable_count; source row grain and NULLs retained."
    sql: ${TABLE}.favourable_count ;;
  }
  measure: favourable_count_sum {
    type: sum
    description: "Sum of source favourable_count."
    value_format: "#,##0"
    sql: ${favourable_count} ;;
  }
  dimension: anomaly_count {
    type: number
    hidden: yes
    description: "Source anomaly_count; source row grain and NULLs retained."
    sql: ${TABLE}.anomaly_count ;;
  }
  measure: anomaly_count_sum {
    type: sum
    description: "Sum of source anomaly_count."
    value_format: "#,##0"
    sql: ${anomaly_count} ;;
  }
  dimension: rc_ooo_trigger_anomaly {
    type: number
    hidden: yes
    description: "Source rc_ooo_trigger_anomaly; source row grain and NULLs retained."
    sql: ${TABLE}.rc_ooo_trigger_anomaly ;;
  }
  measure: rc_ooo_trigger_anomaly_sum {
    type: sum
    description: "Sum of source rc_ooo_trigger_anomaly."
    value_format: "#,##0"
    sql: ${rc_ooo_trigger_anomaly} ;;
  }
  dimension: rc_early_trigger_anomally {
    type: number
    hidden: yes
    description: "Source rc_early_trigger_anomally; source row grain and NULLs retained."
    sql: ${TABLE}.rc_early_trigger_anomally ;;
  }
  measure: rc_early_trigger_anomally_sum {
    type: sum
    description: "Sum of source rc_early_trigger_anomally."
    value_format: "#,##0"
    sql: ${rc_early_trigger_anomally} ;;
  }
  dimension: rc_missing_anomaly {
    type: number
    hidden: yes
    description: "Source rc_missing_anomaly; source row grain and NULLs retained."
    sql: ${TABLE}.rc_missing_anomaly ;;
  }
  measure: rc_missing_anomaly_sum {
    type: sum
    description: "Sum of source rc_missing_anomaly."
    value_format: "#,##0"
    sql: ${rc_missing_anomaly} ;;
  }
  dimension: ls_low_value_anomally {
    type: number
    hidden: yes
    description: "Source ls_low_value_anomally; source row grain and NULLs retained."
    sql: ${TABLE}.ls_low_value_anomally ;;
  }
  measure: ls_low_value_anomally_sum {
    type: sum
    description: "Sum of source ls_low_value_anomally."
    value_format: "#,##0"
    sql: ${ls_low_value_anomally} ;;
  }
  dimension: accuracy_perc {
    type: number
    hidden: yes
    description: "Source accuracy_perc; source row grain and NULLs retained."
    sql: ${TABLE}.accuracy_perc ;;
  }
  measure: accuracy_perc_average {
    type: average
    description: "Unweighted average of source fractions, multiplied by 100 for percentage display"
    value_format: "0.00\"%\""
    sql: 100.0 * ${accuracy_perc} ;;
  }
  dimension: deviation_perc {
    type: number
    hidden: yes
    description: "Source deviation_perc; source row grain and NULLs retained."
    sql: ${TABLE}.deviation_perc ;;
  }
  measure: deviation_perc_average {
    type: average
    description: "Unweighted average of source fractions, multiplied by 100 for percentage display"
    value_format: "0.00\"%\""
    sql: 100.0 * ${deviation_perc} ;;
  }
  dimension: comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "Rate Comparison Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start comparison_date_range %} AS DATE) ;;
  }
  dimension: comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "Rate Comparison Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "Rate Comparison Dashboard"
    hidden: yes
    sql: {% condition comparison_date_range %} ${analysis_date::date} {% endcondition %} ;;
  }
  dimension: is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "Rate Comparison Dashboard"
    hidden: yes
    sql: COALESCE(
      ${comparison_end::date} > ${comparison_start::date}
      AND ${analysis_date::date} >= date_add('day', -date_diff('day', ${comparison_start::date}, ${comparison_end::date}), ${comparison_start::date})
      AND ${analysis_date::date} < ${comparison_start::date}, FALSE) ;;
  }
  dimension: in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two missing load shift statistics."
    group_label: "Rate Comparison Dashboard"
    hidden: yes
    sql: ${is_selected_period} OR ${is_previous_period} ;;
  }
  dimension: missing_load_shift_selected {
    type: number
    description: "Missing load shift count for the selected comparison period; other rows are NULL."
    group_label: "Rate Comparison Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_selected_period} THEN ${rc_missing_anomaly} END ;;
  }
  measure: missing_load_shift_selected_average {
    type: number
    label: "Missing Load Shift — Selected Average"
    group_label: "Rate Comparison Dashboard"
    description: "Unweighted average of source rc_missing_anomaly within this comparison range."
    sql:
      AVG(${missing_load_shift_selected}) ;;
    value_format: "#,##0.00"
  }
  measure: missing_load_shift_selected_median {
    type: number
    label: "Missing Load Shift — Selected Median"
    group_label: "Rate Comparison Dashboard"
    description: "Exact median of source missing load shift counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${missing_load_shift_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${missing_load_shift_selected} AS DOUBLE)) FILTER (WHERE ${missing_load_shift_selected} IS NOT NULL)), CAST(floor((COUNT(${missing_load_shift_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${missing_load_shift_selected} AS DOUBLE)) FILTER (WHERE ${missing_load_shift_selected} IS NOT NULL)), CAST(floor((COUNT(${missing_load_shift_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  dimension: missing_load_shift_previous {
    type: number
    description: "Missing load shift count for the previous comparison period; other rows are NULL."
    group_label: "Rate Comparison Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_previous_period} THEN ${rc_missing_anomaly} END ;;
  }
  measure: missing_load_shift_previous_average {
    type: number
    label: "Missing Load Shift — Previous Average"
    group_label: "Rate Comparison Dashboard"
    description: "Unweighted average of source rc_missing_anomaly within this comparison range."
    sql:
      AVG(${missing_load_shift_previous}) ;;
    value_format: "#,##0.00"
  }
  measure: missing_load_shift_previous_median {
    type: number
    label: "Missing Load Shift — Previous Median"
    group_label: "Rate Comparison Dashboard"
    description: "Exact median of source missing load shift counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${missing_load_shift_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${missing_load_shift_previous} AS DOUBLE)) FILTER (WHERE ${missing_load_shift_previous} IS NOT NULL)), CAST(floor((COUNT(${missing_load_shift_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${missing_load_shift_previous} AS DOUBLE)) FILTER (WHERE ${missing_load_shift_previous} IS NOT NULL)), CAST(floor((COUNT(${missing_load_shift_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  measure: missing_load_shift_average_change {
    type: number
    label: "Missing Load Shift Average Change"
    group_label: "Rate Comparison Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${missing_load_shift_selected_average} - ${missing_load_shift_previous_average}) / NULLIF(${missing_load_shift_previous_average}, 0) ;;
    value_format: "0.0%"
  }
  measure: missing_load_shift_median_change {
    type: number
    label: "Missing Load Shift Median Change"
    group_label: "Rate Comparison Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${missing_load_shift_selected_median} - ${missing_load_shift_previous_median}) / NULLIF(${missing_load_shift_previous_median}, 0) ;;
    value_format: "0.0%"
  }
}
