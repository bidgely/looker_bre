include: "/views/bre_na/bre_na_email_fields.view.lkml"

# SRC-05; preserve Daily/Weekly UNION ALL and source pilot join.
view: bre_na_email_delivery {
  extends: [bre_na_email_fields]
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
            FROM delta_prodna.reporting.pilot_consolidated_product_type_events) m
        JOIN
            (SELECT
                pilot_id,
                analysis_date,
                reporting_date,
                email_type,
                delivery_mode,
                delivery_cnt,
                generation_cnt,
                invoice_ingested,
                generation_rate,
                delivery_rate,
                last_updated_timestamp
            FROM (
                SELECT
                    pilot_id,
                    analysis_date,
                    reporting_date,
                    email_type,
                    'Daily' AS delivery_mode,
                    delivered_notification_id AS delivery_cnt,
                    generated_notification_id AS generation_cnt,
                    invoice_ingested,
                    CASE
                        WHEN invoice_ingested > 0
                        THEN (CAST(generated_notification_id AS DOUBLE) / CAST(invoice_ingested AS DOUBLE))
                        ELSE CAST(0 AS DOUBLE)
                    END AS generation_rate,
                    CASE
                        WHEN generated_notification_id > 0
                        THEN (CAST(delivered_notification_id AS DOUBLE) / CAST(generated_notification_id AS DOUBLE))
                        ELSE CAST(0 AS DOUBLE)
                    END AS delivery_rate,
                    last_updated_timestap AS last_updated_timestamp
                FROM delta_prodna.reporting.sre_email_daily_tracker
                WHERE analysis_date IS NOT NULL

                UNION ALL

                SELECT
                    pilot_id,
                    CAST(analysis_date AS DATE) AS analysis_date,
                    CAST(reporting_date AS DATE) AS reporting_date,
                    email_type,
                    'Weekly' AS delivery_mode,
                    CAST(cnt_bills_emails_delivered AS BIGINT) AS delivery_cnt,
                    CAST(cnt_bills_emails_sent AS BIGINT) AS generation_cnt,
                    CAST(cnt_bills_ingested AS BIGINT) AS invoice_ingested,
                    CASE
                        WHEN CAST(cnt_bills_ingested AS BIGINT) > 0
                        THEN (CAST(cnt_bills_emails_sent AS DOUBLE) / CAST(CAST(cnt_bills_ingested AS BIGINT) AS DOUBLE))
                        ELSE CAST(0 AS DOUBLE)
                    END AS generation_rate,
                    CASE
                        WHEN CAST(cnt_bills_emails_sent AS BIGINT) > 0
                        THEN (CAST(cnt_bills_emails_delivered AS DOUBLE) / CAST(CAST(cnt_bills_emails_sent AS BIGINT) AS DOUBLE))
                        ELSE CAST(0 AS DOUBLE)
                    END AS delivery_rate,
                    last_updated_timestamp
                FROM delta_prodna.reporting.sre_quality_email_stats
                WHERE analysis_date IS NOT NULL
            ) union_stats) s
        ON CAST(m.pilot_id AS VARCHAR) = s.pilot_id
        ORDER BY pilot_id_name, analysis_date, delivery_mode
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition delivery_mode %} q.delivery_mode {% endcondition %}
        AND {% condition email_type %} q.email_type {% endcondition %}
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
  dimension: delivery_mode {
    type: string
    description: "Daily or Weekly source branch. Independent of Period chart grouping. SRC-05 supplies no Monthly delivery-mode rows."
    sql: ${TABLE}.delivery_mode ;;
  }
  dimension: delivery_cnt {
    type: number
    hidden: yes
    description: "Source delivery_cnt, retaining each UNION ALL row and NULL value."
    sql: ${TABLE}.delivery_cnt ;;
  }
  measure: delivery_cnt_sum {
    type: sum
    description: "Sum of source delivery_cnt."
    value_format: "#,##0"
    sql: ${delivery_cnt} ;;
  }
  dimension: generation_cnt {
    type: number
    hidden: yes
    description: "Source generation_cnt, retaining each UNION ALL row and NULL value."
    sql: ${TABLE}.generation_cnt ;;
  }
  measure: generation_cnt_sum {
    type: sum
    description: "Sum of source generation_cnt."
    value_format: "#,##0"
    sql: ${generation_cnt} ;;
  }
  dimension: invoice_ingested {
    type: number
    hidden: yes
    description: "Source invoice_ingested, retaining each UNION ALL row and NULL value."
    sql: ${TABLE}.invoice_ingested ;;
  }
  measure: invoice_ingested_sum {
    type: sum
    description: "Sum of source invoice_ingested."
    value_format: "#,##0"
    sql: ${invoice_ingested} ;;
  }
  measure: calc_generation_perc {
    type: number
    description: "Documented SUM(generation_cnt) / SUM(invoice_ingested), multiplied by 100 for percentage display. Zero denominator returns NULL; this is not an average of row-level source rates."
    value_format: "0.00\"%\""
    sql: 100.0 * CAST(${generation_cnt_sum} AS DOUBLE) / NULLIF(${invoice_ingested_sum}, 0) ;;
  }
  measure: calc_delivery_perc {
    type: number
    description: "Documented SUM(delivery_cnt) / SUM(generation_cnt), multiplied by 100 for percentage display. Zero denominator returns NULL; this is not an average of row-level source rates."
    value_format: "0.00\"%\""
    sql: 100.0 * CAST(${delivery_cnt_sum} AS DOUBLE) / NULLIF(${generation_cnt_sum}, 0) ;;
  }
  measure: record_count {
    type: number
    description: "Documented COUNT(pilot_id) over source output rows."
    sql: COUNT(${pilot_id}) ;;
  }
  filter: comparison_date_range {
    type: date
    description: "Selected analysis dates; retains the preceding equal-length range for average and median comparisons."
  }
  dimension: gauge_label {
    type: string
    description: "Constant category for the live single-value Email percentage gauges."
    hidden: yes
    sql: 'Distribution %' ;;
  }
  dimension: comparison_start {
    type: date
    description: "Inclusive selected range start; NULL for an unbounded start."
    group_label: "Email Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_start comparison_date_range %} AS DATE) ;;
  }
  dimension: comparison_end {
    type: date
    description: "Exclusive selected range end; NULL for an unbounded end."
    group_label: "Email Dashboard"
    hidden: yes
    convert_tz: no
    sql: CAST({% date_end comparison_date_range %} AS DATE) ;;
  }
  # A templated date condition must compare DATE/TIMESTAMP values, not display strings.
  dimension: is_selected_period {
    type: yesno
    description: "Matches the selected date filter, without removing prior rows from comparison queries."
    group_label: "Email Dashboard"
    hidden: yes
    sql: {% condition comparison_date_range %} ${analysis_date::date} {% endcondition %} ;;
  }
  dimension: is_previous_period {
    type: yesno
    description: "Immediately preceding equal-length calendar range; false if either boundary is absent."
    group_label: "Email Dashboard"
    hidden: yes
    sql: COALESCE(
      ${comparison_end::date} > ${comparison_start::date}
      AND ${analysis_date::date} >= date_add('day', -date_diff('day', ${comparison_start::date}, ${comparison_end::date}), ${comparison_start::date})
      AND ${analysis_date::date} < ${comparison_start::date}, FALSE) ;;
  }
  dimension: in_comparison_window {
    type: yesno
    description: "Keep current and previous rows before calculating the two delivered email statistics."
    group_label: "Email Dashboard"
    hidden: yes
    sql: ${is_selected_period} OR ${is_previous_period} ;;
  }
  dimension: emails_delivered_selected {
    type: number
    description: "Delivered email count for the selected comparison period; other rows are NULL."
    group_label: "Email Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_selected_period} THEN ${delivery_cnt} END ;;
  }
  measure: emails_delivered_selected_average {
    type: number
    label: "Email Delivered — Selected Average"
    group_label: "Email Dashboard"
    description: "Unweighted average of source delivery_cnt within this comparison range."
    sql:
      AVG(${emails_delivered_selected}) ;;
    value_format: "#,##0.00"
  }
  measure: emails_delivered_selected_median {
    type: number
    label: "Email Delivered — Selected Median"
    group_label: "Email Dashboard"
    description: "Exact median of source delivered email counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${emails_delivered_selected}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${emails_delivered_selected} AS DOUBLE)) FILTER (WHERE ${emails_delivered_selected} IS NOT NULL)), CAST(floor((COUNT(${emails_delivered_selected}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${emails_delivered_selected} AS DOUBLE)) FILTER (WHERE ${emails_delivered_selected} IS NOT NULL)), CAST(floor((COUNT(${emails_delivered_selected}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  dimension: emails_delivered_previous {
    type: number
    description: "Delivered email count for the previous comparison period; other rows are NULL."
    group_label: "Email Dashboard"
    hidden: yes
    sql: CASE WHEN ${is_previous_period} THEN ${delivery_cnt} END ;;
  }
  measure: emails_delivered_previous_average {
    type: number
    label: "Email Delivered — Previous Average"
    group_label: "Email Dashboard"
    description: "Unweighted average of source delivery_cnt within this comparison range."
    sql:
      AVG(${emails_delivered_previous}) ;;
    value_format: "#,##0.00"
  }
  measure: emails_delivered_previous_median {
    type: number
    label: "Email Delivered — Previous Median"
    group_label: "Email Dashboard"
    description: "Exact median of source delivered email counts. NULLs omitted; even row counts average the central pair. Uses a query-time sorted array."
    sql:
      CASE WHEN COUNT(${emails_delivered_previous}) > 0 THEN (
          element_at(array_sort(array_agg(CAST(${emails_delivered_previous} AS DOUBLE)) FILTER (WHERE ${emails_delivered_previous} IS NOT NULL)), CAST(floor((COUNT(${emails_delivered_previous}) + 1) / 2.0) AS BIGINT))
          + element_at(array_sort(array_agg(CAST(${emails_delivered_previous} AS DOUBLE)) FILTER (WHERE ${emails_delivered_previous} IS NOT NULL)), CAST(floor((COUNT(${emails_delivered_previous}) + 2) / 2.0) AS BIGINT))
        ) / 2.0 END ;;
    value_format: "#,##0.00"
  }
  measure: emails_delivered_average_change {
    type: number
    label: "Email Delivered Average Change"
    group_label: "Email Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${emails_delivered_selected_average} - ${emails_delivered_previous_average}) / NULLIF(${emails_delivered_previous_average}, 0) ;;
    value_format: "0.0%"
  }
  measure: emails_delivered_median_change {
    type: number
    label: "Email Delivered Median Change"
    group_label: "Email Dashboard"
    description: "Relative change versus the preceding equal-length range. NULL if prior value is zero or absent."
    sql:
      (${emails_delivered_selected_median} - ${emails_delivered_previous_median}) / NULLIF(${emails_delivered_previous_median}, 0) ;;
    value_format: "0.0%"
  }
}
