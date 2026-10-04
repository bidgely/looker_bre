view: bre_na_her_fields {
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
    description: "Analysis-date range for the HER tiles: analysis dates except quality, which uses reporting dates."
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
  parameter: period {
    type: string
    default_value: "Daily"
    description: "Select the source's Daily, Weekly, or Monthly rows. Weekly source SQL uses Monday starts; do not rebucket its preaggregated rows."
    allowed_value: { value: "Daily" }
    allowed_value: { value: "Weekly" }
    allowed_value: { value: "Monthly" }
  }
}
