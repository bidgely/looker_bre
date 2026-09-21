view: itron_config_messages {
  derived_table: {
    sql: with meter_pilot_map as (
          select meter_id, pilot_id
          from (
            select
              SUBSTRING(token FROM 7 FOR GREATEST(POSITION('_AMI' IN token) - 7, 0)) AS meter_id,
              um.pilot_id,
              ROW_NUMBER() OVER (
                PARTITION BY SUBSTRING(token FROM 7 FOR GREATEST(POSITION('_AMI' IN token) - 7, 0))
                ORDER BY event_timestamp DESC
              ) AS rn
            from public.enrollment_events e
            left join public.user_meta_data um on e.uuid = um.uuid
            where e.event_type like 'METER%' and e.meter_ordinal > 0
          )
          where rn = 1
        )
        select meterid as meter_id, bidgelymeterid as bidgely_meter_id, evmin, evmax, duration, checkforev, interference, evlicence, lastdatatimestamp, from_unixtime(lastdatatimestamp/1000) AS update_date
      from (
        select icm.*, row_number() over (partition by icm.meterid order by icm.lastdatatimestamp desc) as rid
        from public.itron_config_messages icm
        left join meter_pilot_map mp on icm.meterid = mp.meter_id
        where {%condition itron_enrollment_files.pilot_id%} mp.pilot_id {%endcondition%}
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
