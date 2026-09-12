# One row per pilot_id is an upstream contract confirmed for this migration.
view: bre_pilots {
  derived_table: {
    sql:
      SELECT
        CAST(pilot_id AS VARCHAR) AS pilot_id,
        CASE WHEN strpos(pilot_name, '(') > 0
             THEN substr(pilot_name, strpos(pilot_name, '('))
             ELSE pilot_name END AS pilot_name,
        time_zone
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.pilot_consolidated_product_type_events
    ;;
  }
  dimension: pilot_id {
    primary_key: yes
    hidden: yes
    type: string
    description: "Pilot identifier; upstream guarantees one row per pilot within each region."
    sql: ${TABLE}.pilot_id ;;
  }
  dimension: pilot_name {
    type: string
    description: "Pilot name using the original Data Studio parenthesis-formatting rule."
    sql: ${TABLE}.pilot_name ;;
  }
  dimension: time_zone {
    type: string
    description: "Pilot time zone from the replacement pilot table; source DATE values are not shifted."
    sql: ${TABLE}.time_zone ;;
  }
}
