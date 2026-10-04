# Shared, filter-free SQL for the screenshot-confirmed NBI blend.
# Consumer views apply their own fully scoped pilot/date filters before chart aggregation.
view: bre_na_nbi_emr_blend_source {
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
        q.pilot_id_name, CAST(q.pilot_id AS VARCHAR) AS pilot_id, q.pilot_name
      FROM generation_source q
),
emr_input AS (
SELECT q.analysis_date, q.cluster_id, q.module_name, q.cluster_type,
        q.metric_name, q.metric_value, q.pilot_id_name, CAST(q.pilot_id AS VARCHAR) AS pilot_id, q.pilot_name,
        AVG(q.duration_seconds) AS duration_seconds,
        1 - COUNT(DISTINCT q.cluster_type) AS failed_job_cnt,
        CAST(100 AS DOUBLE) * COUNT(CASE WHEN q.metric_value IN
          ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED') THEN 1 END)
          / NULLIF(COUNT(q.metric_value), 0) AS failure_rate_perc
      FROM emr_source q
      GROUP BY 1,2,3,4,5,6,7,8,9
),
failed_jobs_input AS (
SELECT q.analysis_date, CAST(q.pilot_id AS VARCHAR) AS pilot_id,
        q.has_failed_stage, q.stages_present, q.pilot_id_name, q.pilot_name, SUM(q.is_failed) AS is_failed
      FROM failed_jobs_source q
      GROUP BY 1,2,3,4,5,6
)
SELECT ROW_NUMBER() OVER () AS row_id,
  g.analysis_date, g.pilot_id, g.pilot_name, g.pilot_id_name,
  g.nbi_error_pct, g.failure_count,
  e.cluster_id, e.module_name, e.cluster_type, e.metric_name, e.metric_value,
  e.duration_seconds, e.failed_job_cnt, e.failure_rate_perc,
  f.has_failed_stage, f.stages_present, f.is_failed
FROM generation_input g
INNER JOIN emr_input e ON g.pilot_id = e.pilot_id
  AND g.pilot_id_name = e.pilot_id_name AND g.analysis_date = e.analysis_date
INNER JOIN failed_jobs_input f ON g.pilot_id = f.pilot_id
  AND g.pilot_id_name = f.pilot_id_name AND g.analysis_date = f.analysis_date ;;
  }
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local identifier for each joined source row, preserving blend multiplicity."
    sql: ${TABLE}.row_id ;;
  }
}
