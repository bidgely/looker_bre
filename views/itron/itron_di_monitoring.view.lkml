view: itron_di_monitoring {
  derived_table: {
    sql: select pilot_id, meter_id, start_date as event_date, sum(daily_entries)*48 as total_daily_entries
        --,sum(total_consumption_value) as total_daily_consumption_value
            from (
                    select utilityid as pilot_id, meterid as meter_id, starttime, lastdatatimestamp,
                    date(from_unixtime(CAST(starttime AS bigint), 'US/Eastern')) as start_date,
                    date(from_unixtime(CAST(lastdatatimestamp AS bigint) / 1000, 'US/Eastern')) as end_date,
                    count(starttime) as daily_entries
                    from public.itron_feature_messages
                    where {%condition itron_di_monitoring.pilot_id%} pilot_id {%endcondition%}
                            and {%condition date_series.continous_date%} start_date {%endcondition%}
                    group by 1,2,3,4,5,6 )
            group by 1,2,3 ;;
  }

  dimension: pilot_id {
    type: string
    sql: ${TABLE}.pilot_id ;;
  }

  dimension: meter_id {
    type: string
    sql: ${TABLE}.meter_id ;;
  }

  dimension: total_daily_entries {
    type: number
    sql: ${TABLE}.total_daily_entries ;;
  }

# dimension: total_daily_consumption_value {
#    type: number
#    sql: ${TABLE}.total_daily_consumption_value ;;
#  }

  dimension: total_entries_percentile_category {
    type: string
    sql:
    CASE
      WHEN ${total_daily_entries} = 0 THEN '00: 0'
      WHEN ${total_daily_entries} <= 48 THEN '01: 1–48'
      WHEN ${total_daily_entries} <= 96 THEN '02: 49–96'
      WHEN ${total_daily_entries} <= 144 THEN '03: 97–144'
      WHEN ${total_daily_entries} <= 192 THEN '04: 145–192'
      WHEN ${total_daily_entries} <= 240 THEN '05: 193–240'
      WHEN ${total_daily_entries} <= 288 THEN '06: 241–288'
      WHEN ${total_daily_entries} <= 336 THEN '07: 289–336'
      WHEN ${total_daily_entries} <= 384 THEN '08: 337–384'
      WHEN ${total_daily_entries} <= 432 THEN '09: 385–432'
      WHEN ${total_daily_entries} <= 480 THEN '10: 433–480'
      WHEN ${total_daily_entries} >=480 THEN '11: Above 480'
      ELSE '00: 0'
    END ;;
  }

  dimension_group: event {
    type: time
    timeframes: [raw, date, week, month, quarter]
    sql: ${TABLE}.event_date ;;
  }

  measure: count_unique_meter {
    type: count_distinct
    sql: ${meter_id} ;;
    drill_fields: [meter_id]
  }

  measure: count_meter_with_data {
    type: count_distinct
    sql: ${meter_id} ;;
    drill_fields: [meter_id]
    filters: {
      field: total_daily_entries
      value: "> 0"
    }
  }

  # set: detail {
  #   fields: [
  #       pilot_id,
  #       year,
  #       month,
  #       date_value,
  #       meter_id,
  #       total_entries,
  #       total_consumption_value
  #         ]
  # }

}
