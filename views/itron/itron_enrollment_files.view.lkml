view: itron_enrollment_files {
  derived_table: {
    sql: with meter_events as (
          select event_id, uuid, gateway_ordinal, meter_ordinal, start_timestamp, end_timestamp, event_timestamp, token,
          SUBSTRING(token FROM 7 FOR GREATEST(POSITION('_AMI' IN token) - 7, 0)) AS meter_id,
          row_number() over (partition by uuid, SUBSTRING(token FROM 7 FOR GREATEST(POSITION('_AMI' IN token) - 7, 0)) order by event_timestamp) as rid_start,
          row_number() over (partition by uuid, SUBSTRING(token FROM 7 FOR GREATEST(POSITION('_AMI' IN token) - 7, 0)) order by event_timestamp desc) as rid_end,
          case when end_timestamp > 0 then true else false end as closed_meter_event_available
          from public.enrollment_events
          where event_type like 'METER%' and meter_ordinal > 0
          and uuid in (select uuid from user_meta_data where pilot_id in (
            10112, 10014, 10117, 10118, 10126, 10223,
            {% if _model._name == 'bre_itron_uat' %} 10015 {% else %} 10224 {% endif %}
          ))
          --and uuid = 'e0341b49-653c-4d44-b5e3-c19f4a816658'
          ),

        meter_start_events as (
          select *
          from meter_events
          where rid_start = 1),

        meter_end_events as (
          select *
          from meter_events
          where rid_end = 1 and closed_meter_event_available = true),

        meter_status as (
          select a.uuid, c.pilot_id, a.meter_id, a.start_timestamp, b.end_timestamp,
          case when b.end_timestamp is null and a.start_timestamp <= to_unixtime(current_timestamp) then true
               when b.end_timestamp > to_unixtime(current_timestamp) then true else false end as is_active_meter
          from meter_start_events a
          left join meter_end_events b
          on a.meter_id = b.meter_id
          left join public.user_meta_data c on a.uuid = c.uuid
        )

        select * from meter_status
        where {%condition active_meter%} is_active_meter {%endcondition%}
          and {%condition itron_enrollment_files.pilot_id%} pilot_id {%endcondition%}
          and start_timestamp <= to_unixtime(COALESCE(CAST({% date_end date_series.continous_date %} AS timestamp), current_timestamp))
          and (end_timestamp is null or end_timestamp >= to_unixtime(COALESCE(CAST({% date_start date_series.continous_date %} AS timestamp), TIMESTAMP '1970-01-01')))
      ;;
  }

  filter: active_meter {
    type: yesno
  }

  dimension: uuid {
    type: string
    sql: ${TABLE}.uuid ;;
  }

  dimension: pilot_id {
    type: number
    sql: ${TABLE}.pilot_id ;;
  }

  dimension: pilot_name {
    type: string
    sql: case when ${pilot_id} =  10112 then 'TECO'
              when ${pilot_id} =  10014 then 'SMUD'
              when ${pilot_id} = {% if _model._name == 'bre_itron_uat' %} 10015 {% else %} 10224 {% endif %} then 'CNP'
              when ${pilot_id} =  10117 then 'SCE'
              when ${pilot_id} =  10118 then 'Pecan ST'
              when ${pilot_id} =  10126 then 'Hydro One'
              when ${pilot_id} =  10223 then 'LUMA'
              else 'Others' end
        ;;
  }

  dimension: start_time_epoch {
    description: "epoch of the start time of meter"
    type: number
    sql: ${TABLE}.start_timestamp ;;
  }

  dimension: end_time_epoch {
    description: "epoch of the end timen of meter"
    type: number
    sql: ${TABLE}.end_timestamp ;;
  }

  #will update timezone values once itron gets updated in pilot table

  dimension_group: start_time {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: from_unixtime(${start_time_epoch}, 'US/Eastern') ;;
    #sql: from_unixtime(${start_time_epoch}, ${pilot_consolidated_product_types.time_zone}) ;;
  }

  dimension_group: end_time {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: from_unixtime(${end_time_epoch}, 'US/Eastern') ;;
    #sql: from_unixtime(${end_time_epoch}, ${pilot_consolidated_product_types.time_zone}) ;;
  }

  dimension: meter_id {
    description: "meter id for the user"
    type: string
    primary_key: yes
    sql: ${TABLE}.meter_id ;;
  }

  dimension: is_active_meter {
    description: "current status for the meter"
    type: yesno
    sql: ${TABLE}.is_active_meter ;;
  }

  measure: count_users {
    type: count_distinct
    sql:  ${uuid};;
    drill_fields: [uuid]
  }

  measure: count_active_users {
    type: count_distinct
    sql:  ${uuid};;
    drill_fields: [uuid]
    filters: {
      field: is_active_meter
      value: "Yes"
    }
  }

  measure: count_meters {
    type: count_distinct
    sql:  ${meter_id};;
    drill_fields: [meter_id]
  }

  measure: count_active_meters {
    type: count_distinct
    sql:  ${meter_id};;
    drill_fields: [meter_id]
    filters: {
      field: is_active_meter
      value: "Yes"
    }
  }

  measure: count_enrolled_meters {
    type: count_distinct
    sql: CASE
          WHEN ${start_time_date} = ${date_series.continous_date}
          THEN ${TABLE}.meter_id
       END ;;
  }

  measure: count_unenrolled_meters {
    type: count_distinct
    sql: CASE
          WHEN ${end_time_date} = ${date_series.continous_date}
          THEN ${TABLE}.meter_id
       END ;;
  }

}
