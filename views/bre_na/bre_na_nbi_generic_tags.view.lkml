include: "/views/bre_na/bre_na_nbi_fields.view.lkml"

# SRC-20. Source row grain and joins retained.
view: bre_na_nbi_generic_tags {
  extends: [bre_na_nbi_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
SELECT
    m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users, s.total_nbi_users_with_generic_tag, s.pct_users_with_generic_tag, s.last_updated_timestamp
 FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM delta_prodna.reporting.pilot_consolidated_product_type_events) as m
JOIN
    delta_prodna.reporting.sre_nbi_generic_tag_users s
ON
    m.pilot_id = s.pilot_id
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition date_range %} q.analysis_date {% endcondition %}
    ;;
  }
  dimension: total_nbi_users_with_generic_tag {
    type: number
    description: "Source total_nbi_users_with_generic_tag."
    hidden: yes
    sql: ${TABLE}.total_nbi_users_with_generic_tag ;;
  }
  measure: total_nbi_users_with_generic_tag_sum {
    type: sum
    description: "total nbi users with generic tag sum."
    value_format: "#,##0"
    sql: ${total_nbi_users_with_generic_tag} ;;
  }
  dimension: reporting_date {
    type: date
    description: "Source reporting_date without timezone conversion."
    convert_tz: no
    sql: ${TABLE}.reporting_date ;;
  }
}
