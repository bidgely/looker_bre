view: itron_appliance_data {
  derived_table: {
    sql: with appliance_events as (
            select utilityid, meterid, applianceid, eventtype, eventtime, date(from_unixtime(CAST(eventtime AS bigint), 'US/Eastern')) as event_date,
            eventcapturetime, amplitude_value, current, power_factor, power_value, voltage
            from (
                    SELECT *,
                    metadata.amplitude AS amplitude_value,
                    metadata."current" AS current,
                    metadata.power_factor AS power_factor,
                    CAST(NULL AS varchar) AS power_value,
                    metadata.voltage AS voltage,
                    row_number() over (partition by utilityid, meterid, applianceid, eventtype, eventtime, eventcapturetime order by lastdatatimestamp desc) as rid
                    FROM public.itron_appliance_data
                    --where meterid = '2.16.840.1.114416.15.80.1000332688'
                    )
            where rid = 1 ),

      lagged_events as (
        select *, LAG(eventtype, 1) OVER (PARTITION BY utilityid, meterid, applianceid ORDER BY eventtime) as lag_event_type
        from appliance_events
      )

      select *,
      case when lag_event_type is not null and lag_event_type = eventtype then TRUE else FALSE end as corresponding_event_flag
      from lagged_events ;;
  }

  measure: count {
    type: count
    #drill_fields: [detail*]
  }

  dimension: pilot_id {
    type: string
    sql: ${TABLE}.utilityid ;;
  }

  dimension: meter_id {
    type: string
    sql: ${TABLE}.meterid ;;
  }

  dimension: appliance_id {
    type: number
    sql: ${TABLE}.applianceid ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.eventtype ;;
  }

  dimension: event_time {
    type: number
    sql: ${TABLE}.eventtime ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: eventcapturetime {
    type: number
    sql: ${TABLE}.eventcapturetime ;;
  }

  dimension: amplitude_value {
    type: string
    sql: ${TABLE}.amplitude_value ;;
  }

  dimension: current {
    type: string
    sql: ${TABLE}.current ;;
  }

  dimension: power_factor {
    type: string
    sql: ${TABLE}.power_factor ;;
  }

  dimension: power_value {
    type: string
    sql: ${TABLE}.power_value ;;
  }

  dimension: voltage {
    type: string
    sql: ${TABLE}.voltage ;;
  }

  dimension: lag_event_type {
    type: string
    sql: ${TABLE}.lag_event_type ;;
  }

  dimension: corresponding_event_flag {
    type: string
    sql: ${TABLE}.corresponding_event_flag ;;
    hidden: yes
  }

  dimension: meter_event_key {
    type: string
    sql: ${meter_id}||CAST(${eventcapturetime} AS varchar);;
    #primary_key: yes
    hidden: yes  # Optional: hide it from Explore UI
  }

  filter: corresponding_event_flag_filter {
    type: string
  }

  measure: count_unique_meter {
    type: count_distinct
    sql: ${meter_id} ;;
    drill_fields: [meter_id]
  }

  measure: count_events {
    type: count_distinct
    sql: ${meter_event_key} ;;
    drill_fields: [meter_id]
  }

  dimension: merge_key {
    type: string
    sql: 'dummy' ;;
    hidden: no
  }

  set: detail {
    fields: [
      pilot_id,
      meter_id,
      appliance_id,
      event_type,
      event_time,
      event_date,
      eventcapturetime,
      amplitude_value,
      current,
      power_factor,
      power_value,
      voltage,
      lag_event_type,
      corresponding_event_flag,
      meter_event_key
    ]
  }
}
