view: itron_config_confirmation {
  derived_table: {
    sql: with meter_pilot_map as (
          select meter_id, pilot_id
          from (
            select
              SUBSTRING(e.token FROM 7 FOR GREATEST(POSITION('_AMI' IN e.token) - 7, 0)) AS meter_id,
              um.pilot_id,
              ROW_NUMBER() OVER (
                PARTITION BY SUBSTRING(e.token FROM 7 FOR GREATEST(POSITION('_AMI' IN e.token) - 7, 0))
                ORDER BY e.event_timestamp DESC
              ) AS rn
            from public.enrollment_events e
            left join public.user_meta_data um on e.uuid = um.uuid
            where e.event_type like 'METER%' and e.meter_ordinal > 0
          )
          where rn = 1
        )
        select *, date(from_unixtime(lastdatatimestamp / 1000)) as update_date
      from (
      select icm.meterid, icm.lastdatatimestamp
      from public.itron_config_messages icm
      left join meter_pilot_map mp on icm.meterid = mp.meter_id
      where {%condition itron_enrollment_files.pilot_id%} mp.pilot_id {%endcondition%}
        and {%condition date_series.continous_date%} from_unixtime(icm.lastdatatimestamp / 1000, 'US/Eastern') {%endcondition%}
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
    sql: ${meter_id} || '-' || CAST(${lastdatatimestamp} AS varchar) ;;
  }

  dimension_group: update_time {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: from_unixtime(${lastdatatimestamp} / 1000, 'US/Eastern') ;;
  }

}
