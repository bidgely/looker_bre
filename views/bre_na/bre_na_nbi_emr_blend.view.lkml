include: "/views/bre_na/bre_na_nbi_fields.view.lkml"

# Screenshot-confirmed SRE_NBI_EMR_FAILURE_CORR_BLEND. Group each input before joining.
# Preserve repeated daily metrics across EMR groups; no extra deduplication after the join.
view: bre_na_nbi_emr_blend {
  extends: [bre_na_nbi_fields]
  derived_table: {
    sql:
WITH generation_source AS (
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
),
emr_source AS (
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
),
failed_jobs_source AS (
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
    (SELECT
    pilot_id,
    CAST(analysis_date AS DATE) AS analysis_date,

    COUNT(DISTINCT cluster_type) AS stages_present,

    MAX(
        CASE
            WHEN metric_value IN ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED')
            THEN 1
            ELSE 0
        END
    ) AS has_failed_stage,

    CASE
        WHEN COUNT(DISTINCT cluster_type) < 3
             OR MAX(CASE
                      WHEN metric_value IN ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED')
                      THEN 1
                      ELSE 0
                  END) = 1
        THEN 1
        ELSE 0
    END AS is_failed

FROM
    delta_prodna.reporting.sre_emr_metrics_fact
GROUP BY
    pilot_id, CAST(analysis_date AS DATE)) s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
),
generation_input AS (
SELECT DISTINCT q.analysis_date, q.nbi_error_pct,
        q.total_users_with_200_errorcode + q.total_users_with_300_errorcode AS failure_count,
        {% if period._parameter_value == "'Weekly'" %}
          date_add('day', -1, date_trunc('week', date_add('day', 1, q.analysis_date)))
        {% elsif period._parameter_value == "'Monthly'" %} date_trunc('month', q.analysis_date)
        {% else %} q.analysis_date {% endif %} AS period_date, q.pilot_id_name, CAST(q.pilot_id AS VARCHAR) AS pilot_id, q.pilot_name
      FROM generation_source q
      WHERE {% condition date_range %} q.analysis_date {% endcondition %}
          AND {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
          AND {% condition pilot_name %} q.pilot_name {% endcondition %}
),
emr_input AS (
SELECT q.analysis_date, q.cluster_id, q.module_name, q.cluster_type,
        q.metric_name, q.metric_value, {% if period._parameter_value == "'Weekly'" %}
          date_add('day', -1, date_trunc('week', date_add('day', 1, q.analysis_date)))
        {% elsif period._parameter_value == "'Monthly'" %} date_trunc('month', q.analysis_date)
        {% else %} q.analysis_date {% endif %} AS period_date,
        q.pilot_id_name, CAST(q.pilot_id AS VARCHAR) AS pilot_id, q.pilot_name,
        AVG(q.duration_seconds) AS duration_seconds,
        1 - COUNT(DISTINCT q.cluster_type) AS failed_job_cnt,
        CAST(100 AS DOUBLE) * COUNT(CASE WHEN q.metric_value IN
          ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED') THEN 1 END)
          / NULLIF(COUNT(q.metric_value), 0) AS failure_rate_perc
      FROM emr_source q
      WHERE {% condition date_range %} q.analysis_date {% endcondition %}
          AND {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
          AND {% condition pilot_name %} q.pilot_name {% endcondition %}
      GROUP BY 1,2,3,4,5,6,7,8,9,10
),
failed_jobs_input AS (
SELECT q.analysis_date, CAST(q.pilot_id AS VARCHAR) AS pilot_id,
        q.has_failed_stage, q.stages_present, {% if period._parameter_value == "'Weekly'" %}
          date_add('day', -1, date_trunc('week', date_add('day', 1, q.analysis_date)))
        {% elsif period._parameter_value == "'Monthly'" %} date_trunc('month', q.analysis_date)
        {% else %} q.analysis_date {% endif %} AS period_date,
        q.pilot_id_name, q.pilot_name, SUM(q.is_failed) AS is_failed
      FROM failed_jobs_source q
      WHERE {% condition date_range %} q.analysis_date {% endcondition %}
          AND {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
          AND {% condition pilot_name %} q.pilot_name {% endcondition %}
      GROUP BY 1,2,3,4,5,6,7
)
SELECT ROW_NUMBER() OVER () AS row_id,
  g.analysis_date, g.period_date, g.pilot_id, g.pilot_name, g.pilot_id_name,
  g.nbi_error_pct, g.failure_count,
  e.cluster_id, e.module_name, e.cluster_type, e.metric_name, e.metric_value,
  e.duration_seconds, e.failed_job_cnt, e.failure_rate_perc,
  f.has_failed_stage, f.stages_present, f.is_failed
FROM generation_input g
INNER JOIN emr_input e ON g.pilot_id = e.pilot_id
  AND g.pilot_id_name = e.pilot_id_name AND g.analysis_date = e.analysis_date
INNER JOIN failed_jobs_input f ON g.pilot_id = f.pilot_id
  AND g.pilot_id_name = f.pilot_id_name AND g.analysis_date = f.analysis_date
    ;;
  }
  dimension: pilot_id_name {
    type: string
    description: "Blend input dimension pilot_id_name."
    sql: ${TABLE}.pilot_id_name ;;
  }
  dimension: cluster_id {
    type: string
    description: "Blend input dimension cluster_id."
    sql: ${TABLE}.cluster_id ;;
  }
  dimension: module_name {
    type: string
    description: "Blend input dimension module_name."
    sql: ${TABLE}.module_name ;;
  }
  dimension: cluster_type {
    type: string
    description: "Blend input dimension cluster_type."
    sql: ${TABLE}.cluster_type ;;
  }
  dimension: metric_name {
    type: string
    description: "Blend input dimension metric_name."
    sql: ${TABLE}.metric_name ;;
  }
  dimension: metric_value {
    type: string
    description: "Blend input dimension metric_value."
    sql: ${TABLE}.metric_value ;;
  }
  dimension: nbi_error_pct {
    type: number
    hidden: yes
    description: "Preaggregated blend input nbi_error_pct; repeated matching rows retained."
    sql: ${TABLE}.nbi_error_pct ;;
  }
  measure: nbi_error_pct_average {
    type: average
    label: "Failed Generation %"
    description: "Average of nbi_error_pct after the screenshot-confirmed three-source inner blend."
    value_format: "0.00\"%\""
    sql: ${nbi_error_pct} ;;
  }
  dimension: failure_count {
    type: number
    hidden: yes
    description: "Preaggregated blend input failure_count; repeated matching rows retained."
    sql: ${TABLE}.failure_count ;;
  }
  measure: failure_count_sum {
    type: sum
    label: "Failed Generation #"
    description: "Sum of failure_count after the screenshot-confirmed three-source inner blend."
    value_format: "#,##0"
    sql: ${failure_count} ;;
  }
  dimension: duration_seconds {
    type: number
    hidden: yes
    description: "Preaggregated blend input duration_seconds; repeated matching rows retained."
    sql: ${TABLE}.duration_seconds ;;
  }
  measure: duration_seconds_average {
    type: average
    label: "Duration (seconds)"
    description: "Average of duration_seconds after the screenshot-confirmed three-source inner blend."
    value_format: "#,##0.00"
    sql: ${duration_seconds} ;;
  }
  dimension: failed_job_cnt {
    type: number
    hidden: yes
    description: "Preaggregated blend input failed_job_cnt; repeated matching rows retained."
    sql: ${TABLE}.failed_job_cnt ;;
  }
  measure: failed_job_cnt_sum {
    type: sum
    label: "Source Failed Job Count"
    description: "Sum of failed_job_cnt after the screenshot-confirmed three-source inner blend."
    value_format: "#,##0"
    sql: ${failed_job_cnt} ;;
  }
  dimension: failure_rate_perc {
    type: number
    hidden: yes
    description: "Preaggregated blend input failure_rate_perc; repeated matching rows retained."
    sql: ${TABLE}.failure_rate_perc ;;
  }
  measure: failure_rate_perc_average {
    type: average
    label: "EMR Job Failure %"
    description: "Average of failure_rate_perc after the screenshot-confirmed three-source inner blend."
    value_format: "0.00\"%\""
    sql: ${failure_rate_perc} ;;
  }
  dimension: has_failed_stage {
    type: number
    hidden: yes
    description: "Preaggregated blend input has_failed_stage; repeated matching rows retained."
    sql: ${TABLE}.has_failed_stage ;;
  }
  measure: has_failed_stage_sum {
    type: sum
    label: "Has Failed Stage"
    description: "Sum of has_failed_stage after the screenshot-confirmed three-source inner blend."
    value_format: "#,##0"
    sql: ${has_failed_stage} ;;
  }
  dimension: stages_present {
    type: number
    hidden: yes
    description: "Preaggregated blend input stages_present; repeated matching rows retained."
    sql: ${TABLE}.stages_present ;;
  }
  measure: stages_present_sum {
    type: sum
    label: "Total Jobs Run #"
    description: "Sum of stages_present after the screenshot-confirmed three-source inner blend."
    value_format: "#,##0"
    sql: ${stages_present} ;;
  }
  dimension: is_failed {
    type: number
    hidden: yes
    description: "Preaggregated blend input is_failed; repeated matching rows retained."
    sql: ${TABLE}.is_failed ;;
  }
  measure: is_failed_sum {
    type: sum
    label: "EMR Failed Jobs #"
    description: "Sum of is_failed after the screenshot-confirmed three-source inner blend."
    value_format: "#,##0"
    sql: ${is_failed} ;;
  }
}
