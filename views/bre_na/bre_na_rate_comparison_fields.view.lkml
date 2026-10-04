view: bre_na_rate_comparison_fields {
  extension: required
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local row identifier; preserves every source join result, including duplicates."
    sql: ${TABLE}.row_id ;;
  }
  filter: date_range {
    type: date
    description: "Analysis-date range for the Rate Comparison tiles; analysis_date for KPI 1 and reporting_date for KPI 2."
  }
  dimension: pilot_id {
    type: string
    description: "Source pilot identifier."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_id
    sql: CAST(${TABLE}.pilot_id AS VARCHAR) ;;
  }
  dimension: pilot_name {
    type: string
    description: "Pilot name formatted by the source parenthesis rule."
    suggest_explore: bre_pilot_filters
    suggest_dimension: bre_pilots.pilot_name
    sql: ${TABLE}.pilot_name ;;
  }
  dimension: analysis_date {
    type: date
    description: "Source analysis_date without timezone conversion."
    convert_tz: no
    sql: ${TABLE}.analysis_date ;;
  }
  dimension: reporting_date {
    type: date
    description: "Source reporting_date without timezone conversion."
    convert_tz: no
    sql: ${TABLE}.reporting_date ;;
  }
  dimension: pilot_id_name {
    type: string
    description: "Pilot ID and formatted pilot name from the source directory join."
    sql: ${TABLE}.pilot_id_name ;;
  }
  dimension: email_type {
    type: string
    description: "Source notification type, retained as email_type."
    sql: ${TABLE}.email_type ;;
  }
  dimension: missing_promotion_flag {
    type: string
    description: "Absent for an empty loadshiftamount string; Present otherwise, including NULL, matching the source CASE."
    sql: ${TABLE}.missing_promotion_flag ;;
  }
  filter: excluded_email_types {
    type: string
    description: "Select email types to exclude. Blank excludes nothing. Matching rows are removed from both current and previous periods."
    suggest_explore: bre_na_rate_comparison
    suggest_dimension: bre_na_rate_comparison.email_type
  }
  filter: excluded_promotions {
    type: string
    description: "Select promotion flags to exclude. Blank excludes nothing."
    suggestions: ["Absent", "Present"]
  }
}
