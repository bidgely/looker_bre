view: itron_consumption_data_uat{
  derived_table: {
    sql: WITH base AS (
          SELECT
              uuid,
              pilot_id,
              data_date,
              COUNT(uuid) AS raw_count,
              CASE
                  WHEN pilot_id = '10014' THEN COUNT(uuid)/3
                  ELSE COUNT(uuid)
              END AS adjusted_count
          FROM public.raw_consumption_data
          WHERE pilot_id IN ('10112', '10014', '10117','10118','10126', '10223', '10224')
          GROUP BY uuid, pilot_id, data_date
      )
      SELECT
          uuid,
          pilot_id,
          data_date,
          raw_count AS total_15_min_entries,
          CASE
              WHEN adjusted_count < 96 THEN 'incomplete_data'
              WHEN adjusted_count = 96 THEN 'complete_data'
              WHEN adjusted_count > 96 THEN 'more_than_96_entries'
          END AS data_category_15_min
      FROM base
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}.uuid ;;
  }

  dimension: data_date {
    type: date
    sql: ${TABLE}.data_date ;;
  }

  dimension: total_15_min_entries {
    type: number
    sql: ${TABLE}.total_15_min_entries ;;
  }

  dimension: data_category_15_min {
    type: string
    sql: ${TABLE}.data_category_15_min ;;
  }

  set: detail {
    fields: [
      uuid,
      data_date,
      total_15_min_entries,
      data_category_15_min
    ]
  }

}
