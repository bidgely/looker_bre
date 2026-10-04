include: "/views/bre_na/bre_na_her_fields.view.lkml"

# SRC-48; preserve source joins, windows, and source period grains.
view: bre_na_her_quality {
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
                    WHEN POSITION('(' IN pilot_name) > 0
                    THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                    ELSE pilot_name
                END AS pilot_name,
                pilot_id
            FROM delta_prodna.reporting.pilot_consolidated_product_type_events
        ) AS m
        JOIN
        (
            SELECT
                pilot_id,
                date_add('day', 1, CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE)) AS reporting_date,
                CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE) AS analysis_date,
                SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
                SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
                SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
                SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
                SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
                SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
                SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
                SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
                SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
                SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
                SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
                SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
                SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
                SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
                SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
                SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
                SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
                SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
                SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
                'Daily' AS period
            FROM delta_prodna.public.her_automation_query_results
            GROUP BY 1,2,3

            UNION ALL

            SELECT
                pilot_id,
                CAST(date_trunc('week', date_add('day', 1, CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE))) AS DATE) AS reporting_date,
                CAST(date_trunc('week', CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE)) AS DATE) AS analysis_date,
                SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
                SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
                SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
                SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
                SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
                SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
                SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
                SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
                SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
                SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
                SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
                SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
                SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
                SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
                SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
                SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
                SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
                SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
                SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
                'Weekly' AS period
            FROM delta_prodna.public.her_automation_query_results
            GROUP BY 1,2,3

            UNION ALL

            SELECT
                pilot_id,
                CAST(date_trunc('month', date_add('day', 1, CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE))) AS DATE) AS reporting_date,
                CAST(date_trunc('month', CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE)) AS DATE) AS analysis_date,
                SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
                SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
                SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
                SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
                SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
                SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
                SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
                SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
                SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
                SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
                SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
                SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
                SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
                SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
                SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
                SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
                SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
                SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
                SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
                'Monthly' AS period
            FROM delta_prodna.public.her_automation_query_results
            GROUP BY 1,2,3
        ) AS s
        ON m.pilot_id = s.pilot_id
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND q."period" = {% parameter period %}
        AND {% condition date_range %} q.reporting_date {% endcondition %}
    ;;
  }
  dimension: low_bc_duration_cnt {
    type: number
    hidden: yes
    description: "Source low_bc_duration_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.low_bc_duration_cnt ;;
  }
  measure: low_bc_duration_cnt_sum {
    type: sum
    description: "Sum of source low_bc_duration_cnt."
    value_format: "#,##0"
    sql: ${low_bc_duration_cnt} ;;
  }
  dimension: high_bc_duration_cnt {
    type: number
    hidden: yes
    description: "Source high_bc_duration_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.high_bc_duration_cnt ;;
  }
  measure: high_bc_duration_cnt_sum {
    type: sum
    description: "Sum of source high_bc_duration_cnt."
    value_format: "#,##0"
    sql: ${high_bc_duration_cnt} ;;
  }
  dimension: staleness_cnt {
    type: number
    hidden: yes
    description: "Source staleness_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.staleness_cnt ;;
  }
  measure: staleness_cnt_sum {
    type: sum
    description: "Sum of source staleness_cnt."
    value_format: "#,##0"
    sql: ${staleness_cnt} ;;
  }
  dimension: solar_template_cnt {
    type: number
    hidden: yes
    description: "Source solar_template_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.solar_template_cnt ;;
  }
  measure: solar_template_cnt_sum {
    type: sum
    description: "Sum of source solar_template_cnt."
    value_format: "#,##0"
    sql: ${solar_template_cnt} ;;
  }
  dimension: solar_consistency_cnt {
    type: number
    hidden: yes
    description: "Source solar_consistency_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.solar_consistency_cnt ;;
  }
  measure: solar_consistency_cnt_sum {
    type: sum
    description: "Sum of source solar_consistency_cnt."
    value_format: "#,##0"
    sql: ${solar_consistency_cnt} ;;
  }
  dimension: solar_generation_cnt {
    type: number
    hidden: yes
    description: "Source solar_generation_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.solar_generation_cnt ;;
  }
  measure: solar_generation_cnt_sum {
    type: sum
    description: "Sum of source solar_generation_cnt."
    value_format: "#,##0"
    sql: ${solar_generation_cnt} ;;
  }
  dimension: report_consistency_cnt {
    type: number
    hidden: yes
    description: "Source report_consistency_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.report_consistency_cnt ;;
  }
  measure: report_consistency_cnt_sum {
    type: sum
    description: "Sum of source report_consistency_cnt."
    value_format: "#,##0"
    sql: ${report_consistency_cnt} ;;
  }
  dimension: itemization_cnt {
    type: number
    hidden: yes
    description: "Source itemization_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.itemization_cnt ;;
  }
  measure: itemization_cnt_sum {
    type: sum
    description: "Sum of source itemization_cnt."
    value_format: "#,##0"
    sql: ${itemization_cnt} ;;
  }
  dimension: bill_change_consistency_cnt {
    type: number
    hidden: yes
    description: "Source bill_change_consistency_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.bill_change_consistency_cnt ;;
  }
  measure: bill_change_consistency_cnt_sum {
    type: sum
    description: "Sum of source bill_change_consistency_cnt."
    value_format: "#,##0"
    sql: ${bill_change_consistency_cnt} ;;
  }
  dimension: ev_itemization_cnt {
    type: number
    hidden: yes
    description: "Source ev_itemization_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.ev_itemization_cnt ;;
  }
  measure: ev_itemization_cnt_sum {
    type: sum
    description: "Sum of source ev_itemization_cnt."
    value_format: "#,##0"
    sql: ${ev_itemization_cnt} ;;
  }
  dimension: tou_template_cnt {
    type: number
    hidden: yes
    description: "Source tou_template_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.tou_template_cnt ;;
  }
  measure: tou_template_cnt_sum {
    type: sum
    description: "Sum of source tou_template_cnt."
    value_format: "#,##0"
    sql: ${tou_template_cnt} ;;
  }
  dimension: nbi_occurence_cnt {
    type: number
    hidden: yes
    description: "Source nbi_occurence_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.nbi_occurence_cnt ;;
  }
  measure: nbi_occurence_cnt_sum {
    type: sum
    description: "Sum of source nbi_occurence_cnt."
    value_format: "#,##0"
    sql: ${nbi_occurence_cnt} ;;
  }
  dimension: nbi_value_cnt {
    type: number
    hidden: yes
    description: "Source nbi_value_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.nbi_value_cnt ;;
  }
  measure: nbi_value_cnt_sum {
    type: sum
    description: "Sum of source nbi_value_cnt."
    value_format: "#,##0"
    sql: ${nbi_value_cnt} ;;
  }
  dimension: nbi_appliance_itemization_cnt {
    type: number
    hidden: yes
    description: "Source nbi_appliance_itemization_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.nbi_appliance_itemization_cnt ;;
  }
  measure: nbi_appliance_itemization_cnt_sum {
    type: sum
    description: "Sum of source nbi_appliance_itemization_cnt."
    value_format: "#,##0"
    sql: ${nbi_appliance_itemization_cnt} ;;
  }
  dimension: nbi_non_null_insight_cnt {
    type: number
    hidden: yes
    description: "Source nbi_non_null_insight_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.nbi_non_null_insight_cnt ;;
  }
  measure: nbi_non_null_insight_cnt_sum {
    type: sum
    description: "Sum of source nbi_non_null_insight_cnt."
    value_format: "#,##0"
    sql: ${nbi_non_null_insight_cnt} ;;
  }
  dimension: nbi_unicode_cnt {
    type: number
    hidden: yes
    description: "Source nbi_unicode_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.nbi_unicode_cnt ;;
  }
  measure: nbi_unicode_cnt_sum {
    type: sum
    description: "Sum of source nbi_unicode_cnt."
    value_format: "#,##0"
    sql: ${nbi_unicode_cnt} ;;
  }
  dimension: nbi_extreme_insight_cnt {
    type: number
    hidden: yes
    description: "Source nbi_extreme_insight_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.nbi_extreme_insight_cnt ;;
  }
  measure: nbi_extreme_insight_cnt_sum {
    type: sum
    description: "Sum of source nbi_extreme_insight_cnt."
    value_format: "#,##0"
    sql: ${nbi_extreme_insight_cnt} ;;
  }
  dimension: nbi_seasonal_appliance_cnt {
    type: number
    hidden: yes
    description: "Source nbi_seasonal_appliance_cnt; source grain and NULL handling retained."
    sql: ${TABLE}.nbi_seasonal_appliance_cnt ;;
  }
  measure: nbi_seasonal_appliance_cnt_sum {
    type: sum
    description: "Sum of source nbi_seasonal_appliance_cnt."
    value_format: "#,##0"
    sql: ${nbi_seasonal_appliance_cnt} ;;
  }
  dimension: overall_report_count {
    type: number
    hidden: yes
    description: "Source overall_report_count; source grain and NULL handling retained."
    sql: ${TABLE}.overall_report_count ;;
  }
  measure: overall_report_count_sum {
    type: sum
    description: "Sum of source overall_report_count."
    value_format: "#,##0"
    sql: ${overall_report_count} ;;
  }
}
