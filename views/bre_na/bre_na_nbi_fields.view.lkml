view: bre_na_nbi_fields {
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
    description: "Analysis-date range for the NBI source tiles."
  }
  filter: comparison_date_range {
    type: date
    description: "Selected analysis dates; retains the preceding equal-length range for average and median comparisons."
  }
  parameter: period {
    type: string
    default_value: "Daily"
    description: "Group analysis dates by day, Sunday-start week, or month."
    allowed_value: { label: "Daily" value: "Daily" }
    allowed_value: { label: "Weekly" value: "Weekly" }
    allowed_value: { label: "Monthly" value: "Monthly" }
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
    description: "Pilot name formatted by the NBI sources parenthesis rule."
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
  dimension: period_date {
    type: date
    description: "Analysis-date bucket; Sunday-start weeks match the documented Looker Studio WEEK calculation."
    convert_tz: no
    sql: {% if period._parameter_value == "'Weekly'" %}
      date_add('day', -1, date_trunc('week', date_add('day', 1, ${analysis_date::date})))
      {% elsif period._parameter_value == "'Monthly'" %} date_trunc('month', ${analysis_date::date})
      {% else %} ${analysis_date::date} {% endif %} ;;
  }
}
