include: "/views/bre/bre_dashboard_fields.view.lkml"
include: "/views/bre/bre_ingestion_audit.view.lkml"
include: "/views/bre_na/bre_na_rate_plan_tracker.view.lkml"

# NA-1A-T06. User-confirmed LEFT JOIN: Pilot and last updated timestamp (Date & Time).
# Preserve full timestamp equality and source multiplicity; no inferred date/type join keys.
view: bre_na_ingestion_rate_comparison {
  extends: [bre_dashboard_fields]
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local identifier of each joined source-row pair, including unmatched audit rows."
    sql: ${TABLE}.row_id ;;
  }
  filter: date_range {
    type: date
    label: "Time Period"
    description: "Filters the audit-side analysis_date before the left join; does not add a date equality join key."
  }
  filter: selected_pilot_id {
    type: string
    label: "Pilot ID"
    description: "Filters the audit-side pilot ID before the join."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_id
  }
  filter: selected_pilot_name {
    type: string
    label: "Pilot Name"
    description: "Filters the audit-side pilot name before the join."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
  }
  filter: file_type {
    type: string
    label: "File Type"
    description: "Filters audit ingestion_type before joining. The confirmed join has no ingestion_type equality condition."
    suggest_explore: bre_ingestion_filter_values
    suggest_dimension: bre_ingestion_filter_values.ingestion_type
  }
  dimension: current_plan_number {
    type: string
    label: "Rate Plan ID"
    description: "Tracker plan number on the joined result. Selecting a plan excludes audit rows with no matching tracker plan."
    sql: ${TABLE}.current_plan_number ;;
    suggest_explore: bre_na_rate_plan_tracker
    suggest_dimension: bre_na_rate_plan_tracker.current_plan_number
  }
  derived_table: {
    sql:
      WITH audit_rows AS (
        SELECT a.*
        FROM ${bre_ingestion_audit.SQL_TABLE_NAME} a
        WHERE {% condition bre_na_ingestion_rate_comparison.date_range %} a.analysis_date {% endcondition %}
          AND {% condition bre_na_ingestion_rate_comparison.selected_pilot_id %} a.pilot_id {% endcondition %}
          AND {% condition bre_na_ingestion_rate_comparison.selected_pilot_name %} a.pilot_name {% endcondition %}
          AND {% condition bre_na_ingestion_rate_comparison.file_type %} a.ingestion_type {% endcondition %}
      )
      SELECT ROW_NUMBER() OVER () AS row_id,
        a.pilot_id, a.pilot_name, a.analysis_date,
        a.ingestion_type, a.last_updated_timestamp,
        r.current_plan_number,
        a.total_files_processed, a.total_chunks_processed, a.total_records_count,
        a.success_percentage,
        r.expected_total_rate_plan_count,
        r.successful_total_rate_plan_count,
        r.missing_total_rate_plan_pct
      FROM audit_rows a
      LEFT JOIN ${bre_na_rate_plan_tracker.SQL_TABLE_NAME} r
        ON a.pilot_id = r.pilot_id
        AND a.last_updated_timestamp = CAST(r.last_updated_timestamp AS TIMESTAMP(6))
    ;;
  }
  dimension: total_files_processed_value {
    type: number
    hidden: yes
    description: "Source total_files_processed on each joined row. Unmatched tracker values remain NULL."
    sql: ${TABLE}.total_files_processed ;;
  }
  measure: files {
    type: sum
    label: "Files #"
    description: "Sum of total_files_processed over the joined rows. Repeated join matches retain source multiplicity."
    sql: ${total_files_processed_value} ;;
    value_format: "#,##0"
  }
  dimension: total_chunks_processed_value {
    type: number
    hidden: yes
    description: "Source total_chunks_processed on each joined row. Unmatched tracker values remain NULL."
    sql: ${TABLE}.total_chunks_processed ;;
  }
  measure: chunks {
    type: sum
    label: "Chunks #"
    description: "Sum of total_chunks_processed over the joined rows. Repeated join matches retain source multiplicity."
    sql: ${total_chunks_processed_value} ;;
    value_format: "#,##0"
  }
  dimension: total_records_count_value {
    type: number
    hidden: yes
    description: "Source total_records_count on each joined row. Unmatched tracker values remain NULL."
    sql: ${TABLE}.total_records_count ;;
  }
  measure: records {
    type: sum
    label: "Records #"
    description: "Sum of total_records_count over the joined rows. Repeated join matches retain source multiplicity."
    sql: ${total_records_count_value} ;;
    value_format: "#,##0"
  }
  dimension: success_percentage_value {
    type: number
    hidden: yes
    description: "Source success_percentage on each joined row. Unmatched tracker values remain NULL."
    sql: ${TABLE}.success_percentage ;;
  }
  measure: success_percentage_average {
    type: average
    label: "Success %"
    description: "Unweighted average of success_percentage over the joined rows. Repeated join matches retain source multiplicity."
    sql: ${success_percentage_value} ;;
    value_format: "0.00\"%\""
  }
  dimension: expected_total_rate_plan_count_value {
    type: number
    hidden: yes
    description: "Source expected_total_rate_plan_count on each joined row. Unmatched tracker values remain NULL."
    sql: ${TABLE}.expected_total_rate_plan_count ;;
  }
  measure: expected_rc {
    type: sum
    label: "Expected RC #"
    description: "Sum of expected_total_rate_plan_count over the joined rows. Repeated join matches retain source multiplicity."
    sql: ${expected_total_rate_plan_count_value} ;;
    value_format: "#,##0"
  }
  dimension: successful_total_rate_plan_count_value {
    type: number
    hidden: yes
    description: "Source successful_total_rate_plan_count on each joined row. Unmatched tracker values remain NULL."
    sql: ${TABLE}.successful_total_rate_plan_count ;;
  }
  measure: successful_rc {
    type: sum
    label: "Successful RC #"
    description: "Sum of successful_total_rate_plan_count over the joined rows. Repeated join matches retain source multiplicity."
    sql: ${successful_total_rate_plan_count_value} ;;
    value_format: "#,##0"
  }
  dimension: missing_total_rate_plan_pct_value {
    type: number
    hidden: yes
    description: "Source missing_total_rate_plan_pct on each joined row. Unmatched tracker values remain NULL."
    sql: ${TABLE}.missing_total_rate_plan_pct ;;
  }
  measure: missing_rc_percentage_average {
    type: average
    label: "Missing RC %"
    description: "Unweighted average of missing_total_rate_plan_pct over the joined rows. Repeated join matches retain source multiplicity."
    sql: ${missing_total_rate_plan_pct_value} ;;
    value_format: "0.00\"%\""
  }
}
