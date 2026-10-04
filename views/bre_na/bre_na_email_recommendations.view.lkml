include: "/views/bre_na/bre_na_email_fields.view.lkml"

# SRC-26; source joins and ranking retained before dashboard filters.
view: bre_na_email_recommendations {
  extends: [bre_na_email_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        SELECT
            m.pilot_name, s.pilot_id || ' : ' || coalesce(m.pilot_name, '') AS pilot_id_name,
            s.*
        FROM delta_prodna.reporting.sre_quality_reco_stats s
        LEFT JOIN
            (SELECT
                CASE
                    WHEN position('(' IN pilot_name) > 0
                    THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
                    ELSE pilot_name -- Keep the original name if '(' doesn't exist
                END AS pilot_name,
                CAST(pilot_id AS VARCHAR) AS pilot_id
            FROM delta_prodna.reporting.pilot_consolidated_product_type_events) AS m
        ON
            m.pilot_id = s.pilot_id
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition email_type %} q.email_type {% endcondition %}
        AND {% condition date_range %} CAST(q.analysis_date AS DATE) {% endcondition %}
    ;;
  }
  dimension: metric_name {
    type: string
    description: "Source metric_name, without rescaling or regrouping."
    sql: ${TABLE}.metric_name ;;
  }
  dimension: notification_pct {
    type: number
    description: "Source notification_pct, without rescaling or regrouping."
    sql: ${TABLE}.notification_pct ;;
  }
  measure: notification_pct_average {
    type: average
    description: "Unweighted average of source notification_pct by analysis date and metric_name."
    value_format: "0.00\"%\""
    sql: ${notification_pct} ;;
  }
}
