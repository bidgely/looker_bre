view: itron_feature_message {
  derived_table: {
    sql:  select pilot_id, meter_id, starttime, lastdatatimestamp, start_date, last_data_update_date
          from (
            select utilityid as pilot_id, meterid as meter_id, starttime, lastdatatimestamp,
            date(from_unixtime(CAST(starttime AS bigint), 'US/Eastern')) as start_date,
            date(from_unixtime(CAST(lastdatatimestamp AS bigint) / 1000, 'US/Eastern')) as last_data_update_date,
            timevaluelist, ROW_NUMBER() OVER (PARTITION BY meterid, starttime ORDER BY lastdatatimestamp DESC) as rid
            from public.itron_feature_messages
            where {%condition itron_di_monitoring.pilot_id%} pilot_id {%endcondition%}
                            and {%condition date_series.continous_date%} start_date {%endcondition%}
            )
          where rid = 1 ;;
  }

  dimension: pilot_id {
    type: string
    sql: ${TABLE}.pilot_id ;;
  }

  dimension: meter_id {
    type: string
    sql: ${TABLE}.meter_id ;;
  }

  dimension_group: event {
    type: time
    timeframes: [raw, date, week, month, quarter]
    sql: ${TABLE}.start_date ;;
  }

  dimension_group: data_update {
    type: time
    timeframes: [raw, date, week, month, quarter]
    sql: ${TABLE}.last_data_update_date ;;
  }

}
