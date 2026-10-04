include: "/views/bre_na/bre_na_her_fields.view.lkml"

# SRC-06; preserve source joins, windows, and source period grains.
view: bre_na_her_failures {
  extends: [bre_na_her_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        with cte as
        (
            select analysis_date,reporting_date,pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Daily' as "Period",
            failure_count,last_updated_timestamp
            from delta_prodna.reporting.sre_her_schedule_errors
            union all
            select CAST(date_trunc('week', analysis_date) AS DATE) as analysis_date, CAST(date_trunc('week', reporting_date) AS DATE) as reporting_date,
            pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Weekly' as "Period",
            sum(failure_count) as failure_count,max(last_updated_timestamp) as last_updated_timestamp
            from delta_prodna.reporting.sre_her_schedule_errors
            group by 1,2,3,4,5,6,7,8
            union all
            select CAST(date_trunc('month', analysis_date) AS DATE) as analysis_date, CAST(date_trunc('month', reporting_date) AS DATE) as reporting_date,
            pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Monthly' as "Period",
            sum(failure_count) as failure_count,max(last_updated_timestamp) as last_updated_timestamp
            from delta_prodna.reporting.sre_her_schedule_errors
            group by 1,2,3,4,5,6,7,8
        ),
        her_errors as
        (
        select pilot_id,cluster_id,schedule_start,schedule_end,measurement_type as fuel_type,failure_reason,failure_count,
            SUM(failure_count) OVER (
                PARTITION BY pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date,reporting_date
            ) as total_failure_count,
            "period", analysis_date, reporting_date,
            round(
                (100.00*failure_count) / SUM(failure_count) OVER (
                    PARTITION BY pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date,reporting_date
                ), 2
            ) as failure_percentage,
            last_updated_timestamp,
            ROW_NUMBER() OVER (PARTITION BY pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date ORDER BY failure_count DESC) AS rank
        from cte
        )
        select m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,s.*
        from her_errors s
        join
        (
            SELECT
                CASE
                    WHEN POSITION('(' IN pilot_name) > 0
                    THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                    ELSE pilot_name
                END AS pilot_name,
                pilot_id
            FROM delta_prodna.reporting.pilot_consolidated_product_type_events
        ) as m ON m.pilot_id = s.pilot_id
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
    description: "Source fuel_type; Cluster IDs control selects cluster_id values."
    sql: ${TABLE}.fuel_type ;;
  }
  dimension: cluster_id {
    type: string
    description: "Source cluster_id; Cluster IDs control selects cluster_id values."
    sql: ${TABLE}.cluster_id ;;
  }
  dimension: failure_count {
    type: number
    hidden: yes
    description: "Source failure_count; source grain and NULL handling retained."
    sql: ${TABLE}.failure_count ;;
  }
  measure: failure_count_sum {
    type: sum
    description: "Sum of source failure_count."
    value_format: "#,##0"
    sql: ${failure_count} ;;
  }
  dimension: total_failure_count {
    type: number
    hidden: yes
    description: "Source total_failure_count; source grain and NULL handling retained."
    sql: ${TABLE}.total_failure_count ;;
  }
  measure: total_failure_count_sum {
    type: sum
    description: "Sum of source total_failure_count."
    value_format: "#,##0"
    sql: ${total_failure_count} ;;
  }
  dimension: calc_failure_reason {
    type: string
    description: "Documented IFNULL(failure_reason, 'UNKNOWN')."
    sql: COALESCE(${TABLE}.failure_reason, 'UNKNOWN') ;;
  }
  dimension: rank {
    type: number
    description: "Source failure-count rank before dashboard filtering. No top-N cutoff was supplied."
    sql: ${TABLE}.rank ;;
  }
  # Use underscore-free selector values; Looker parameter defaults do not safely handle underscores.
  parameter: metric {
    type: string
    default_value: "percentage"
    description: "Select the documented percentage or count calculation. Percentage is the initial display choice."
    allowed_value: { value: "percentage" label: "% Failure" }
    allowed_value: { value: "count" label: "Failure Count" }
  }
  measure: calc_failure_perc {
    type: number
    description: "Documented 100 * SUM(failure_count) / SUM(total_failure_count). Repeated source denominators retained; zero denominator returns NULL."
    value_format: "0.00\"%\""
    sql: 100.0 * CAST(${failure_count_sum} AS DOUBLE) / NULLIF(${total_failure_count_sum}, 0) ;;
  }
  measure: metric_toggle {
    type: number
    label_from_parameter: metric
    description: "Documented Metric Toggle: calculated failure percentage or sum of failure_count."
    value_format: "#,##0.00"
    sql: {% if metric._parameter_value == "'count'" %}
      ${failure_count_sum} {% else %} ${calc_failure_perc} {% endif %} ;;
  }
}
