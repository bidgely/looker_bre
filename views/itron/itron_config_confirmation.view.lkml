view: itron_config_confirmation {
  derived_table: {
    sql: select *, date(from_unixtime(lastdatatimestamp / 1000)) as update_date
      from (
      select meterid, lastdatatimestamp
      from public.itron_config_messages
      --where meterid = '2.16.840.1.114416.15.80.1000169669'
      group by 1,2) ;;
  }

  measure: count_meter_config_confirmation {
    type: count_distinct
    sql: CASE WHEN ${update_time_date} = ${date_series.continous_date} THEN ${meter_timestamp_key} END ;;
  }

  measure: count_meters_per_day {
    type: count_distinct
    sql: CASE WHEN ${update_time_date} = ${date_series.continous_date} THEN ${meter_id} END ;;
  }

  dimension: meter_id {
    type: string
    sql: ${TABLE}.meterid ;;
  }

  dimension: lastdatatimestamp {
    type: number
    sql: ${TABLE}.lastdatatimestamp ;;
  }

  dimension: meter_timestamp_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${meter_id} || '-' || ${lastdatatimestamp} ;;
  }

  dimension_group: update_time {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: from_unixtime(${lastdatatimestamp} / 1000, 'US/Eastern') ;;
  }

}
