view: itron_config_messages {
  derived_table: {
    sql: select meterid as meter_id, bidgelymeterid as bidgely_meter_id, evmin, evmax, duration, checkforev, interference, evlicence, lastdatatimestamp, from_unixtime(lastdatatimestamp/1000) AS update_date
      from (
        select *, row_number() over (partition by meterid order by lastdatatimestamp desc) as rid
        from public.itron_config_messages
        --where meterid = '2.16.840.1.114416.15.80.1000416353'
        )
      where rid = 1;;
  }

  dimension: meter_id {
    type: string
    sql: ${TABLE}.meter_id ;;
  }

  dimension: bidgely_meter_id {
    type: string
    sql: ${TABLE}.bidgely_meter_id ;;
  }

  dimension: evmin {
    type: number
    sql: ${TABLE}.evmin ;;
  }

  dimension: evmax {
    type: number
    sql: ${TABLE}.evmax ;;
  }

  dimension: duration {
    type: number
    sql: ${TABLE}.duration ;;
  }

  dimension: checkforev {
    type: number
    sql: ${TABLE}.checkforev ;;
  }

  dimension: interference {
    type: number
    sql: ${TABLE}.interference ;;
  }

  dimension: evlicence {
    type: number
    sql: ${TABLE}.evlicence ;;
  }

  dimension: lastdatatimestamp {
    type: number
    sql: ${TABLE}.lastdatatimestamp ;;
  }

  dimension_group: update_time {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: from_unixtime(${lastdatatimestamp} / 1000, 'US/Eastern') ;;
  }

  measure: count_meter_config_recieved {
    type: count_distinct
    sql: CASE
          WHEN ${update_time_date} = ${date_series.continous_date}
          THEN ${TABLE}.meter_id
       END ;;
  }

}
