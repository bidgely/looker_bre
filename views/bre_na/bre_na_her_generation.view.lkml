include: "/views/bre_na/bre_na_her_fields.view.lkml"

# SRC-34. Retain FULL JOINs and separate source-period aggregations.
view: bre_na_her_generation {
  extends: [bre_na_her_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        SELECT
            m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
            s.*
        FROM
        (
        SELECT
               CASE
                   WHEN position('(' IN pilot_name) > 0
                   THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
                   ELSE pilot_name -- Keep the original name if '(' doesn't exist
               END AS pilot_name,
               pilot_id
           FROM delta_prodna.reporting.pilot_consolidated_product_type_events

        ) AS m
        JOIN

        (
        select pilot_id,cluster_id,analysis_date,schedule_start,schedule_end,fuel_type,'Daily' as "Period",
        expected_eligible_users as expected_eligible_users,
        actual_eligible_users as actual_eligible_users,
        actual_generation_count as actual_generation_count,
        expected_eligible_users-actual_generation_count as weekly_actual_failure_count,last_updated_timestamp
        from
        (
        SELECT
        coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
        coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
        coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
        coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
        coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
        coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
        coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
        a.eligible_users AS expected_eligible_users,
        b.total_cluster_users AS actual_eligible_users,
        b.total_missing_notification AS actual_failure_count,
        b.total_generated_notification AS actual_generation_count,
        a.last_updated_timestamp
        FROM delta_prodna.reporting.sre_cluster_eligible_users a
        FULL JOIN delta_prodna.reporting.sre_her_schedule_tracker b
        ON a.pilot_id = b.pilot_id
        AND a.cluster_id = b.cluster_id
        AND a.analysis_date = b.analysis_date
        AND a.schedule_start = b.schedule_start
        AND a.schedule_end = b.schedule_end
        and a.measurement_type=b.measurement_type
        )
        union all
        select pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,'Weekly' as "Period",
        max(expected_eligible_users) as weekly_expected_eligible_users,
        max(actual_eligible_users) as weekly_actual_eligible_users,
        sum(actual_generation_count) as weekly_actual_generation_count,
        max(expected_eligible_users)-sum(actual_generation_count) as weekly_actual_failure_count,
        max(last_updated_timestamp) as last_updated_timestamp
        from
        (
        SELECT
        coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
        coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
        coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
        coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
        CAST(date_trunc('week', coalesce(a.analysis_date, b.analysis_date)) AS date) AS analysis_week,
        coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
        coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
        coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
        a.eligible_users AS expected_eligible_users,
        b.total_cluster_users AS actual_eligible_users,
        b.total_missing_notification AS actual_failure_count,
        b.total_generated_notification AS actual_generation_count,
        a.last_updated_timestamp
        FROM delta_prodna.reporting.sre_cluster_eligible_users a
        FULL JOIN delta_prodna.reporting.sre_her_schedule_tracker b
        ON a.pilot_id = b.pilot_id
        AND a.cluster_id = b.cluster_id
        AND a.analysis_date = b.analysis_date
        AND a.schedule_start = b.schedule_start
        AND a.schedule_end = b.schedule_end
        AND a.measurement_type = b.measurement_type
        )
        group by 1,2,3,4,5,6
        union all
        select pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,'Monthly' as "Period",
        max(expected_eligible_users) as monthly_expected_eligible_users,
        max(actual_eligible_users) as monthly_actual_eligible_users,
        sum(actual_generation_count) as monthly_actual_generation_count,
        max(expected_eligible_users)-sum(actual_generation_count) as monthly_actual_failure_count,
        max(last_updated_timestamp) as last_updated_timestamp
        from
        (
        SELECT
        coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
        coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
        coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
        coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
        CAST(date_trunc('month', coalesce(a.analysis_date, b.analysis_date)) AS date) AS analysis_month,
        coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
        coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
        coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
        a.eligible_users AS expected_eligible_users,
        b.total_cluster_users AS actual_eligible_users,
        b.total_missing_notification AS actual_failure_count,
        b.total_generated_notification AS actual_generation_count,
        a.last_updated_timestamp
        FROM delta_prodna.reporting.sre_cluster_eligible_users a
        FULL JOIN delta_prodna.reporting.sre_her_schedule_tracker b
        ON a.pilot_id = b.pilot_id
        AND a.cluster_id = b.cluster_id
        AND a.analysis_date = b.analysis_date
        AND a.schedule_start = b.schedule_start
        AND a.schedule_end = b.schedule_end
        AND a.measurement_type = b.measurement_type
        )
        group by 1,2,3,4,5,6
        )AS s ON m.pilot_id = s.pilot_id
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition fuel_type %} q.fuel_type {% endcondition %}
        AND {% condition cluster_id %} q.cluster_id {% endcondition %}
        AND q."period" = {% parameter period %}
        AND {% condition date_range %} q.analysis_date {% endcondition %}
    ;;
  }
  dimension: fuel_type {
    type: string
    description: "Source fuel_type; Cluster IDs selects cluster_id values."
    sql: ${TABLE}.fuel_type ;;
  }
  dimension: cluster_id {
    type: string
    description: "Source cluster_id; Cluster IDs selects cluster_id values."
    sql: ${TABLE}.cluster_id ;;
  }
  dimension: expected_eligible_users {
    type: number
    hidden: yes
    description: "Source expected_eligible_users; NULLs and source-period aggregation retained."
    sql: ${TABLE}.expected_eligible_users ;;
  }
  measure: expected_eligible_users_sum {
    type: sum
    description: "Sum of source expected_eligible_users at the selected source period."
    value_format: "#,##0"
    sql: ${expected_eligible_users} ;;
  }
  dimension: actual_eligible_users {
    type: number
    hidden: yes
    description: "Source actual_eligible_users; NULLs and source-period aggregation retained."
    sql: ${TABLE}.actual_eligible_users ;;
  }
  measure: actual_eligible_users_sum {
    type: sum
    description: "Sum of source actual_eligible_users at the selected source period."
    value_format: "#,##0"
    sql: ${actual_eligible_users} ;;
  }
  dimension: actual_generation_count {
    type: number
    hidden: yes
    description: "Source actual_generation_count; NULLs and source-period aggregation retained."
    sql: ${TABLE}.actual_generation_count ;;
  }
  measure: actual_generation_count_sum {
    type: sum
    description: "Sum of source actual_generation_count at the selected source period."
    value_format: "#,##0"
    sql: ${actual_generation_count} ;;
  }
  measure: success_pct {
    type: number
    description: "User-confirmed 100 * SUM(actual_generation_count) / SUM(actual_eligible_users). Zero denominator returns NULL; no outer average and no weekly/monthly adjustment from SRC-03."
    value_format: "0.00\"%\""
    sql: 100.0 * CAST(${actual_generation_count_sum} AS DOUBLE) / NULLIF(${actual_eligible_users_sum}, 0) ;;
  }
}
