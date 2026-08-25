view: itron_solar_uat_data {
  derived_table: {
    sql:
      WITH latest_rows AS (
        SELECT
          uuid,
          "date",
          pilot_name,
          pilot_id,
          "hour",
          status,
          loaded_at,
          date_add('hour', "hour", CAST("date" AS timestamp)) AS date_hour,
          ROW_NUMBER() OVER (
            PARTITION BY pilot_id, uuid, "date", "hour"
            ORDER BY loaded_at DESC
          ) AS rn
        FROM reporting.itron_uat_solar_data
      )
      SELECT
        uuid,
        "date",
        pilot_name,
        pilot_id,
        "hour",
        status,
        loaded_at,
        date_hour
      FROM latest_rows
      WHERE rn = 1 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: distinct_uuid_count {
    type: count_distinct
    sql: ${uuid} ;;
    drill_fields: [detail*]
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}.uuid ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.date ;;
  }

  dimension: pilot_name {
    type: string
    sql: ${TABLE}.pilot_name ;;
  }

  dimension: pilot_id {
    type: number
    sql: ${TABLE}.pilot_id ;;
  }

  dimension: hour {
    type: number
    sql: ${TABLE}.hour ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: loaded_at {
    type: time
    sql: ${TABLE}.loaded_at ;;
  }

  dimension_group: date_hour {
    type: time
    sql: ${TABLE}.date_hour ;;
  }

  set: detail {
    fields: [
      uuid,
      date,
      pilot_name,
      pilot_id,
      hour,
      status,
      loaded_at_time,
      date_hour_time
    ]
  }
}
