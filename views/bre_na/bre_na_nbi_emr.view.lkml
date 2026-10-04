include: "/views/bre_na/bre_na_nbi_fields.view.lkml"

# SRC-32. Source row grain and joins retained.
view: bre_na_nbi_emr {
  extends: [bre_na_nbi_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
SELECT source_rows.*, CAST(substr(analysis_date_str, 1, 10) AS DATE) AS analysis_date
FROM (
SELECT
    m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    date_format(s.analysis_date AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS analysis_date_str,
    s.pilot_id,s.module_name,s.cluster_id,s.cluster_type,s.metric_name,s.metric_value,s.reason_code,s.steps_status,

    date_diff('second', s.creation_time, s.end_time) AS duration_seconds,

    date_format(s.creation_time AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS creation_time,
    date_format(s.end_time AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS end_time,
    date_format(s.event_timestamp AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS event_timestamp

FROM
    (
        SELECT
            CASE
                WHEN POSITION('(' IN pilot_name) > 0
                THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                ELSE pilot_name
            END AS pilot_name,
            pilot_id
        FROM delta_prodna.reporting.pilot_consolidated_product_type_events
    ) AS m
JOIN
    delta_prodna.reporting.sre_emr_metrics_fact s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
) source_rows
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition date_range %} q.analysis_date {% endcondition %}
    ;;
  }
  dimension: module_name {
    type: string
    description: "Source module_name."
    sql: ${TABLE}.module_name ;;
  }
  dimension: cluster_id {
    type: string
    description: "Source cluster_id."
    sql: ${TABLE}.cluster_id ;;
  }
  dimension: cluster_type {
    type: string
    description: "Source cluster_type."
    sql: ${TABLE}.cluster_type ;;
  }
  dimension: metric_name {
    type: string
    description: "Source metric_name."
    sql: ${TABLE}.metric_name ;;
  }
  dimension: metric_value {
    type: string
    description: "Source metric_value."
    sql: ${TABLE}.metric_value ;;
  }
  dimension: reason_code {
    type: string
    description: "Source reason_code."
    sql: ${TABLE}.reason_code ;;
  }
  dimension: steps_status {
    type: string
    description: "Source steps_status."
    sql: ${TABLE}.steps_status ;;
  }
  dimension: creation_time {
    type: string
    description: "Source creation_time."
    sql: ${TABLE}.creation_time ;;
  }
  dimension: end_time {
    type: string
    description: "Source end_time."
    sql: ${TABLE}.end_time ;;
  }
  dimension: event_timestamp {
    type: string
    description: "Source event_timestamp."
    sql: ${TABLE}.event_timestamp ;;
  }
  dimension: duration_seconds {
    type: number
    description: "Source duration_seconds."
    hidden: yes
    sql: ${TABLE}.duration_seconds ;;
  }
  measure: duration_seconds_sum {
    type: sum
    description: "duration seconds sum."
    value_format: "#,##0"
    sql: ${duration_seconds} ;;
  }
  measure: duration_seconds_average {
    type: average
    description: "duration seconds average."
    value_format: "#,##0.00"
    sql: ${duration_seconds} ;;
  }
  measure: record_count {
    type: number
    description: "Count of source rows, not distinct cluster IDs."
    value_format: "#,##0"
    sql: COUNT(${pilot_id}) ;;
  }
  measure: failure_rate_perc {
    type: number
    description: "Documented source failure rate; denominator counts non-NULL statuses."
    value_format: "0.00\"%\""
    sql: CAST(100 AS DOUBLE) * COUNT(CASE WHEN ${metric_value} IN ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED') THEN 1 END) / NULLIF(COUNT(${metric_value}), 0) ;;
  }
  measure: success_rate_perc {
    type: number
    description: "Documented source success rate; denominator counts non-NULL statuses."
    value_format: "0.00\"%\""
    sql: CAST(100 AS DOUBLE) * COUNT(CASE WHEN (${metric_value} = 'TERMINATED' AND ${reason_code} = 'ALL_STEPS_COMPLETED') OR ${metric_value} = 'RUNNING' THEN 1 END) / NULLIF(COUNT(${metric_value}), 0) ;;
  }

  measure: cluster_id_count {
    type: number
    description: "COUNT(cluster_id), as confirmed for NA-8B-T01; duplicate IDs count again and NULL IDs do not count."
    value_format: "#,##0"
    sql: COUNT(${cluster_id}) ;;
  }
  measure: duration_seconds_rounded {
    type: number
    hidden: yes
    description: "Average source duration rounded to the nearest whole second for display; NULL remains NULL."
    sql: ROUND(${duration_seconds_average}) ;;
  }
  measure: duration_hh_mm_ss {
    type: string
    description: "Average source duration displayed as hh:mm:ss, with hours allowed above 24 and a sign for negative source durations."
    sql: CASE WHEN ${duration_seconds_rounded} IS NOT NULL THEN
      CONCAT(
        CASE WHEN ${duration_seconds_rounded} < 0 THEN '-' ELSE '' END,
        CASE WHEN ABS(${duration_seconds_rounded}) < 36000 THEN '0' ELSE '' END,
        CAST(CAST(FLOOR(ABS(${duration_seconds_rounded}) / 3600.0) AS BIGINT) AS VARCHAR), ':',
        LPAD(CAST(CAST(FLOOR(MOD(ABS(${duration_seconds_rounded}), 3600) / 60.0) AS BIGINT) AS VARCHAR), 2, '0'), ':',
        LPAD(CAST(CAST(MOD(ABS(${duration_seconds_rounded}), 60) AS BIGINT) AS VARCHAR), 2, '0')) END ;;
  }
}
