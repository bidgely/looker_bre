include: "/views/bre_na/bre_na_nbi_emr_blend_source.view.lkml"

view: bre_na_nbi_emr_scatter {
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.analysis_date,
        SUM(q.is_failed) AS failed_jobs, SUM(q.stages_present) AS total_runs,
        AVG(q.nbi_error_pct) AS nbi_error_pct
      FROM ${bre_na_nbi_emr_blend_source.SQL_TABLE_NAME} q
      WHERE {% condition bre_na_nbi_emr_scatter.date_range %} q.analysis_date {% endcondition %}
        AND {% condition bre_na_nbi_emr_scatter.pilot_id %} q.pilot_id {% endcondition %}
        AND {% condition bre_na_nbi_emr_scatter.pilot_name %} q.pilot_name {% endcondition %}
      GROUP BY q.analysis_date
    ;;
  }
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local identifier for each selected analysis-date point."
    sql: ${TABLE}.row_id ;;
  }
  filter: date_range { type: date description: "Analysis-date range applied before computing daily scatter coordinates." }
  filter: pilot_id {
    type: string
    description: "Pilot IDs included before grouping daily scatter points."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_id
  }
  filter: pilot_name {
    type: string
    description: "Pilot names included before grouping daily scatter points."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
  }
  dimension: analysis_date {
    type: date
    convert_tz: no
    description: "One point per analysis date, even when two days have identical coordinates."
    sql: ${TABLE}.analysis_date ;;
  }
  dimension: failed_jobs {
    type: number
    label: "Failed Jobs #"
    description: "X coordinate: SUM(is_failed) across the joined rows for this analysis date."
    sql: ${TABLE}.failed_jobs ;;
  }
  dimension: total_runs {
    type: number
    hidden: yes
    description: "Daily SUM(stages_present) after the blend."
    sql: ${TABLE}.total_runs ;;
  }
  dimension: nbi_error_pct {
    type: number
    hidden: yes
    description: "Daily AVG(nbi_error_pct) after the blend, in percentage points."
    sql: ${TABLE}.nbi_error_pct ;;
  }
  measure: total_runs_value {
    type: max
    label: "Total Jobs Run #"
    description: "Y coordinate for a single date point; MAX retains its already calculated sum."
    sql: ${total_runs} ;;
    value_format: "#,##0"
  }
  measure: nbi_error_pct_value {
    type: max
    label: "NBI Interaction Gen Error %"
    description: "Bubble size for a single date point; MAX retains its already calculated average."
    sql: ${nbi_error_pct} ;;
    value_format: "0.00\"%\""
  }
}
