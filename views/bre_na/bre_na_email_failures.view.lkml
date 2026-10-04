include: "/views/bre_na/bre_na_email_fields.view.lkml"

# SRC-33; source joins and ranking retained before dashboard filters.
view: bre_na_email_failures {
  extends: [bre_na_email_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, q.*
      FROM (
        SELECT
            sfs.*,
            ROW_NUMBER() OVER (
                PARTITION BY analysis_date, pilot_id, email_type
                ORDER BY failure_count DESC
            ) AS rank
        FROM
            (SELECT
            m.pilot_name, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
            s.*
        FROM
            (SELECT
            CASE
                WHEN position('(' IN pilot_name) > 0
                THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
                ELSE pilot_name -- Keep the original name if '(' doesn't exist
            END AS pilot_name,
            pilot_id
        FROM delta_prodna.reporting.pilot_consolidated_product_type_events) as m
        JOIN
            delta_prodna.reporting.sre_email_failure_reasons s
        ON
            CAST(m.pilot_id AS VARCHAR) = s.pilot_id) as sfs
        ORDER BY
            analysis_date DESC,
            pilot_id,
            email_type,
            failure_count DESC
      ) q
      WHERE {% condition pilot_id %} CAST(q.pilot_id AS VARCHAR) {% endcondition %}
        AND {% condition pilot_name %} q.pilot_name {% endcondition %}
        AND {% condition email_type %} q.email_type {% endcondition %}
        AND {% condition date_range %} CAST(q.analysis_date AS DATE) {% endcondition %}
    ;;
  }
  dimension: analysis_date {
    sql: CAST(${TABLE}.analysis_date AS DATE) ;;
    description: "Source analysis_date text cast to DATE for Looker filters and grouping; source ranking still uses the original value."
  }
  dimension: reporting_date {
    sql: CAST(${TABLE}.reporting_date AS DATE) ;;
    description: "Source reporting_date text cast to DATE for Looker filters and grouping; source ranking still uses the original value."
  }
  dimension: failure_reason {
    type: string
    description: "Source failure_reason, without rescaling or regrouping."
    sql: ${TABLE}.failure_reason ;;
  }
  dimension: failure_count {
    type: number
    description: "Source failure_count, without rescaling or regrouping."
    sql: ${TABLE}.failure_count ;;
  }
  dimension: failure_pct {
    type: number
    description: "Source failure_pct, without rescaling or regrouping."
    sql: ${TABLE}.failure_pct ;;
  }
  dimension: rank {
    type: number
    description: "Source rank, without rescaling or regrouping."
    sql: ${TABLE}.rank ;;
  }
  # Use underscore-free selector values; Looker parameter defaults do not safely handle underscores.
  parameter: metric {
    type: string
    default_value: "percentage"
    description: "Choose AVG(failure_pct) or SUM(failure_count). Percentage is the initial display choice; original report default is unconfirmed."
    allowed_value: { label: "% Failure" value: "percentage" }
    allowed_value: { label: "Failure Count" value: "count" }
  }
  measure: metric_toggle {
    type: number
    label_from_parameter: metric
    description: "User-confirmed Metric Toggle: AVG(failure_pct) or SUM(failure_count). No additional outer average or percentage rescaling."
    value_format: "#,##0.00"
    sql: {% if metric._parameter_value == "'count'" %}
      SUM(${failure_count})
      {% else %} AVG(${failure_pct}) {% endif %} ;;
  }
}
