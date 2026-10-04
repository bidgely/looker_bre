# Shared fields for NA Disaggregation governance source wrappers.
view: bre_na_disaggregation_fields {
  extension: required
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local identifier, preserving the source output grain."
    sql: ${TABLE}.row_id ;;
  }
  filter: date_range {
    type: date
    description: "Date control applied after the original source transformations; see each tile for analysis vs reporting date."
  }
  parameter: period {
    type: string
    default_value: "Daily"
    description: "Select original Daily, Weekly, or Monthly source rows for quality and failure charts."
    allowed_value: { label: "Daily" value: "Daily" }
    allowed_value: { label: "Weekly" value: "Weekly" }
    allowed_value: { label: "Monthly" value: "Monthly" }
  }
  dimension: pilot_id {
    type: string
    description: "Source pilot_id; preserves original formatting."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_id
    sql: CAST(${TABLE}.pilot_id AS VARCHAR) ;;
  }
  dimension: pilot_name {
    type: string
    description: "Source pilot_name; preserves original formatting."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
    sql: CAST(${TABLE}.pilot_name AS VARCHAR) ;;
  }
  dimension: meter_type {
    type: string
    description: "Source meter_type; preserves original formatting."
    sql: CAST(${TABLE}.meter_type AS VARCHAR) ;;
  }
  dimension: fuel_type {
    type: string
    description: "Source fuel_type; preserves original formatting."
    sql: CAST(${TABLE}.fuel_type AS VARCHAR) ;;
  }
  dimension: analysis_date {
    type: date
    description: "Source analysis_date after any source-level period aggregation."
    convert_tz: no
    sql: CAST(${TABLE}.analysis_date AS DATE) ;;
  }
  dimension: reporting_date {
    type: date
    description: "Source reporting_date after any source-level period aggregation."
    convert_tz: no
    sql: CAST(${TABLE}.reporting_date AS DATE) ;;
  }
}
