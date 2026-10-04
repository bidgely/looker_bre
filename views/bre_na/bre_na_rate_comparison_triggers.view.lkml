include: "/views/bre_na/bre_na_rate_comparison_fields.view.lkml"

# SRC-21; preserve source aggregation and join multiplicity. No PDT.
view: bre_na_rate_comparison_triggers {
  extends: [bre_na_rate_comparison_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        SELECT
            rd.pilot_id, m.pilot_name, CAST(rd.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
            rd.notification_type AS email_type,
            rd.reporting_date,
            rd.analysis_date,
            COUNT(user_id || CAST(billing_start_time AS VARCHAR) || CAST(billing_end_time AS VARCHAR)) AS total_records,
            COALESCE(
                AVG(
                    CASE
                        WHEN nl.tou_run_timestamp IS NOT NULL
                             AND nl.invoice_ingested_timestamp IS NOT NULL
                        THEN (nl.tou_run_timestamp - nl.invoice_ingested_timestamp) / (1000.0 * 3600)
                    END
                ), 0
            ) AS avg_invoice_to_tou_latency_hrs,
            COALESCE(
                AVG(
                    CASE
                        WHEN nl.rc_run_timestamp IS NOT NULL
                             AND nl.tou_run_timestamp IS NOT NULL
                        THEN (nl.rc_run_timestamp - nl.tou_run_timestamp) / (1000.0 * 3600)
                    END
                ), 0
            ) AS avg_tou_to_rc_latency_hrs,
            COUNT(CASE WHEN nl.tou_run_timestamp IS NULL THEN user_id || CAST(billing_start_time AS VARCHAR) || CAST(billing_end_time AS VARCHAR) END) AS missing_tou_count,
            COUNT(CASE WHEN nl.rc_run_timestamp IS NULL THEN user_id || CAST(billing_start_time AS VARCHAR) || CAST(billing_end_time AS VARCHAR) END) AS missing_rc_count,
            CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END AS missing_promotion_flag
        FROM delta_prodna.reporting.reporting_dates_map rd
        LEFT JOIN delta_prodna.reporting.sre_notification_report nl
          ON rd.pilot_id = nl.pilot_id
         AND rd.notification_type = nl.notification_type
         AND rd.analysis_date = nl.analysis_date
        JOIN (
            SELECT
                CASE
                    WHEN POSITION('(' IN pilot_name) > 0
                    THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                    ELSE pilot_name
                END AS pilot_name,
                pilot_id
            FROM delta_prodna.reporting.pilot_consolidated_product_type_events
        ) m ON rd.pilot_id = m.pilot_id
        GROUP BY rd.pilot_id, m.pilot_name, rd.notification_type,
                 rd.reporting_date, rd.analysis_date,
                 CAST(rd.pilot_id AS VARCHAR) || ' : ' || m.pilot_name,
                 CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% if excluded_email_types._is_filtered %}
          NOT COALESCE(({% condition excluded_email_types %} q.email_type {% endcondition %}), FALSE)
        {% else %} TRUE {% endif %}
        AND {% if excluded_promotions._is_filtered %}
          NOT COALESCE(({% condition excluded_promotions %} q.missing_promotion_flag {% endcondition %}), FALSE)
        {% else %} TRUE {% endif %}
        AND {% condition date_range %} q.reporting_date {% endcondition %}
    ;;
  }
  dimension: total_records {
    type: number
    hidden: yes
    description: "Source total_records; source row grain and NULLs retained."
    sql: ${TABLE}.total_records ;;
  }
  measure: total_records_sum {
    type: sum
    description: "Sum of source total_records."
    value_format: "#,##0"
    sql: ${total_records} ;;
  }
  dimension: missing_tou_count {
    type: number
    hidden: yes
    description: "Source missing_tou_count; source row grain and NULLs retained."
    sql: ${TABLE}.missing_tou_count ;;
  }
  measure: missing_tou_count_sum {
    type: sum
    description: "Sum of source missing_tou_count."
    value_format: "#,##0"
    sql: ${missing_tou_count} ;;
  }
  dimension: missing_rc_count {
    type: number
    hidden: yes
    description: "Source missing_rc_count; source row grain and NULLs retained."
    sql: ${TABLE}.missing_rc_count ;;
  }
  measure: missing_rc_count_sum {
    type: sum
    description: "Sum of source missing_rc_count."
    value_format: "#,##0"
    sql: ${missing_rc_count} ;;
  }
  dimension: avg_invoice_to_tou_latency_hrs {
    type: number
    hidden: yes
    description: "Source avg_invoice_to_tou_latency_hrs; source row grain and NULLs retained."
    sql: ${TABLE}.avg_invoice_to_tou_latency_hrs ;;
  }
  measure: avg_invoice_to_tou_latency_hrs_average {
    type: average
    description: "Average of source avg_invoice_to_tou_latency_hrs."
    value_format: "#,##0.00"
    sql: ${avg_invoice_to_tou_latency_hrs} ;;
  }
  dimension: avg_tou_to_rc_latency_hrs {
    type: number
    hidden: yes
    description: "Source avg_tou_to_rc_latency_hrs; source row grain and NULLs retained."
    sql: ${TABLE}.avg_tou_to_rc_latency_hrs ;;
  }
  measure: avg_tou_to_rc_latency_hrs_average {
    type: average
    description: "Average of source avg_tou_to_rc_latency_hrs."
    value_format: "#,##0.00"
    sql: ${avg_tou_to_rc_latency_hrs} ;;
  }
}
