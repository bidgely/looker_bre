include: "/views/bre/bre_pilots.view.lkml"

# SRC-17. Keep source rows; use the documented replacement pilot directory.
view: bre_na_rate_plan_tracker {
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local source row identifier; preserves repeated plan rows without deduplication."
    sql: ${TABLE}.row_id ;;
  }
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id,
        CAST(s.pilot_id AS VARCHAR) AS pilot_id,
        p.pilot_name,
        CAST(s.pilot_id AS VARCHAR) || ' : ' || p.pilot_name AS pilot_id_name,
        s.analysis_date, s.reporting_date, s.last_updated_timestamp,
        CAST(s.current_plan_number AS VARCHAR) AS current_plan_number,
        s.measurement_type,
        'BILLING' AS ingestion_type,
        s.expected_total_rate_plan_count,
        s.successful_total_rate_plan_count,
        s.missing_total_rate_plan_pct
      FROM delta_prodna.reporting.sre_rate_plan_tracker s
      INNER JOIN ${bre_pilots.SQL_TABLE_NAME} p
        ON CAST(s.pilot_id AS VARCHAR) = p.pilot_id
    ;;
  }
  dimension: pilot_id {
    type: string
    description: "Pilot ID from the NA rate plan tracker."
    sql: ${TABLE}.pilot_id ;;
  }
  dimension: pilot_name {
    type: string
    description: "Pilot name from the replacement consolidated pilot directory."
    sql: ${TABLE}.pilot_name ;;
  }
  dimension: current_plan_number {
    type: string
    label: "Rate Plan ID"
    description: "Source current_plan_number represented as text for the Rate Plan ID dropdown."
    sql: ${TABLE}.current_plan_number ;;
  }
  dimension: analysis_date {
    type: date
    convert_tz: no
    description: "Rate plan tracker analysis date, used for source date filtering."
    sql: ${TABLE}.analysis_date ;;
  }
  dimension_group: last_updated {
    type: time
    timeframes: [raw, date, time]
    convert_tz: no
    description: "Original tracker last_updated_timestamp, including its time component and fractional seconds."
    sql: ${TABLE}.last_updated_timestamp ;;
  }
}
