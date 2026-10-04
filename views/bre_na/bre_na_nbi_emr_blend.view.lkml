include: "/views/bre_na/bre_na_nbi_fields.view.lkml"
include: "/views/bre_na/bre_na_nbi_emr_blend_source.view.lkml"

# Screenshot-confirmed SRE_NBI_EMR_FAILURE_CORR_BLEND. Group each input before joining.
# Period is determined by analysis_date, which is already an input grouping key.
# Apply period bucketing in the outer LookML dimension, keeping this reusable SQL
# independent of a parameter that is unavailable in the scatter Explore.
# Preserve repeated daily metrics across EMR groups; no extra deduplication after the join.
view: bre_na_nbi_emr_blend {
  extends: [bre_na_nbi_fields]
  derived_table: {
    sql:
      SELECT q.*
      FROM ${bre_na_nbi_emr_blend_source.SQL_TABLE_NAME} q
      WHERE {% condition bre_na_nbi_emr_blend.date_range %} q.analysis_date {% endcondition %}
        AND {% condition bre_na_nbi_emr_blend.pilot_id %} q.pilot_id {% endcondition %}
        AND {% condition bre_na_nbi_emr_blend.pilot_name %} q.pilot_name {% endcondition %}
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
