include: "/views/bre_na/bre_na_nbi_fields.view.lkml"

# SRC-18. Source row grain and joins retained.
view: bre_na_nbi_failed_jobs {
  extends: [bre_na_nbi_fields]
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
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition date_range %} q.analysis_date {% endcondition %}
    ;;
  }
  dimension: stages_present {
    type: number
    description: "Source stages_present."
    hidden: yes
    sql: ${TABLE}.stages_present ;;
  }
  measure: stages_present_sum {
    type: sum
    description: "stages present sum."
    value_format: "#,##0"
    sql: ${stages_present} ;;
  }
  dimension: has_failed_stage {
    type: number
    description: "Source has_failed_stage."
    hidden: yes
    sql: ${TABLE}.has_failed_stage ;;
  }
  measure: has_failed_stage_sum {
    type: sum
    description: "has failed stage sum."
    value_format: "#,##0"
    sql: ${has_failed_stage} ;;
  }
  dimension: is_failed {
    type: number
    description: "Source is_failed."
    hidden: yes
    sql: ${TABLE}.is_failed ;;
  }
  measure: is_failed_sum {
    type: sum
    description: "is failed sum."
    value_format: "#,##0"
    sql: ${is_failed} ;;
  }
}
