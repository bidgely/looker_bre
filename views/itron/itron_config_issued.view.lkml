view: itron_config_issued {
  derived_table: {
    sql:  with typed_requests as (
            -- UAT can expose numeric values as varchar; cast before aggregation.
            select
              uuid,
              CAST(start_date_for_config_generation AS bigint) as start_date_for_config_generation,
              CAST(end_date_for_config_generation AS bigint) as end_date_for_config_generation,
              status,
              CAST(last_updated_timestamp AS bigint) as last_updated_timestamp,
              CAST(retry_count AS bigint) as retry_count
            from meter_config_update_request
          ),
          base as (
            select
              uuid,
              start_date_for_config_generation,
              end_date_for_config_generation,
              status,
              min(last_updated_timestamp) as first_update_timestamp,
              max(last_updated_timestamp) as latest_update_timestamp,
              count(distinct last_updated_timestamp) as total_entries,
              count(distinct case when retry_count > 0 then last_updated_timestamp end) as total_entries_with_retries,
              sum(retry_count) as sum_of_retry_counts
            from typed_requests
            --where uuid in ('01146133-d43b-4e7c-a949-5048a27ed363', 'bfad5e02-1e11-4be1-9d75-f273304300b9')
            group by 1, 2, 3, 4
          )
          select
            base.*,

            -- column_a: REQUEST_SENT timestamp per config
            min(case when status = 'REQUEST_SENT'
                then first_update_timestamp end)
                over(partition by uuid, start_date_for_config_generation, end_date_for_config_generation) as request_sent_ts,

            -- column_b: COMPLETED/COMPLETED_WITH_ERRORS timestamp per config
            min(case when status in ('COMPLETED', 'COMPLETED_WITH_ERRORS')
                then first_update_timestamp end)
                over(partition by uuid, start_date_for_config_generation, end_date_for_config_generation) as final_ts

          from base
          order by uuid, start_date_for_config_generation, status
          ;;
}

  dimension: uuid {
    type: string
    sql: ${TABLE}.uuid ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: start_date_for_config_generation {
    type: number
    sql: ${TABLE}.start_date_for_config_generation ;;
  }

  dimension: end_date_for_config_generation {
    type: number
    sql: ${TABLE}.end_date_for_config_generation ;;
  }

  dimension: config_status_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${uuid} || '-' || CAST(${start_date_for_config_generation} AS varchar) || '-' || CAST(${end_date_for_config_generation} AS varchar) || '-' || ${status} ;;
  }

  dimension: config_key {
    hidden: yes
    type: string
    sql: to_hex(md5(to_utf8(${uuid} || '-' || CAST(${start_date_for_config_generation} AS varchar) || '-' || CAST(${end_date_for_config_generation} AS varchar)))) ;;
  }

# Convert epoch (10-digit seconds) to readable date
  dimension_group: start_date {
    type: time
    timeframes: [raw, date, week, month, year]
    datatype: epoch
    sql: ${TABLE}.start_date_for_config_generation ;;
  }

  dimension_group: end_date {
    type: time
    timeframes: [raw, date, week, month, year]
    datatype: epoch
    sql: ${TABLE}.end_date_for_config_generation ;;
  }


  dimension: first_update_timestamp {
    type: number
    sql: ${TABLE}.first_update_timestamp ;;
  }

  dimension: latest_update_timestamp {
    type: number
    sql: ${TABLE}.latest_update_timestamp ;;
  }

# Convert epoch (13-digit seconds) to readable date
  dimension_group: first_update {
    type: time
    timeframes: [raw, date, week, month, year]
    datatype: epoch
    sql: ${TABLE}.first_update_timestamp / 1000 ;;
  }

  dimension_group: latest_update {
    type: time
    timeframes: [raw, date, week, month, year]
    datatype: epoch
    sql: ${TABLE}.latest_update_timestamp  / 1000 ;;
  }

  dimension: total_entries {
    type: number
    sql: ${TABLE}.total_entries ;;
  }

  dimension: total_entries_with_retries {
    type: number
    sql: ${TABLE}.total_entries_with_retries ;;
  }

  dimension: sum_of_retry_counts {
    type: number
    sql: ${TABLE}.sum_of_retry_counts ;;
  }

  dimension: uuid_timestamp_key {
    #primary_key: yes
    hidden: yes
    type: string
    sql: ${uuid} || '-' || CAST(${latest_update_timestamp} AS varchar) ;;
  }


  dimension: request_sent_ts {
    type: number
    sql: ${TABLE}.request_sent_ts ;;
  }

  dimension: final_ts {
    type: number
    sql: ${TABLE}.final_ts ;;
  }

  dimension: time_required_seconds {
    type: number
    sql: CASE
         WHEN ${status} = 'REQUEST_SENT'
           AND ${request_sent_ts} IS NOT NULL
           AND ${final_ts} IS NOT NULL
         THEN (${final_ts} - ${request_sent_ts}) / 1000
       END ;;
  }

  measure: average_time_required_seconds {
    type: number
    sql: AVG(CASE WHEN ${status} = 'REQUEST_SENT'
            AND ${request_sent_ts} IS NOT NULL
            AND ${final_ts} IS NOT NULL
       THEN (${final_ts} - ${request_sent_ts}) / 1000 END) ;;
    value_format_name: decimal_2
    label: "Avg Time Required (seconds)"
  }

  measure: average_time_required_min {
    type: number
    sql: ${average_time_required_seconds} / 60.0 ;;
    value_format_name: decimal_2
    label: "Avg Time Required (minutes)"
  }

  measure: average_time_required_hh_mm_ss {
    type: string
    sql:
    date_format(
      date_add(
        'second',
        CAST(${average_time_required_seconds} AS bigint),
        TIMESTAMP '1970-01-01 00:00:00'
      ),
      '%H:%i:%s'
    ) ;;
    label: "Avg Time Required (HH:MM:SS)"
  }

  measure: total_entries_sum {
    type: sum
    sql:  ${total_entries} ;;
  }

  measure: total_entries_with_retries_sum {
    type: sum
    sql:  ${total_entries_with_retries} ;;
  }

  measure: sum_retry_counts {
    type: sum
    sql:  ${sum_of_retry_counts} ;;
  }

  measure: count_users_config_issued {
    type: count_distinct
    sql: CASE WHEN ${first_update_date} = ${date_series.continous_date} THEN ${uuid_timestamp_key} END ;;
  }

  measure: count_users_per_day {
    type: count_distinct
    sql: CASE WHEN ${first_update_date} = ${date_series.continous_date} THEN ${uuid} END ;;
  }

}
