# Fields shared by the three Ingestion queue aggregation grains.
view: bre_na_ingestion_queue_fields {
  extension: required
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local identifier assigned after source aggregation; not a stable business key."
    sql: ${TABLE}.row_id ;;
  }
  filter: date_range {
    type: date
    label: "Queue Time Period"
    description: "UTC analysis-date filter applied to queue facts before aggregation."
  }
  filter: event_timestamp_str {
    type: string
    label: "Event Timestamp (UTC)"
    description: "Exact source event timestamp formatted as YYYY-MM-DDTHH:MM:SS in UTC; applied before aggregation."
  }
  dimension_group: bucket {
    type: time
    timeframes: [raw, date, hour]
    convert_tz: no
    datatype: datetime
    description: "UTC source aggregation bucket: hourly for SRC-01, daily for SRC-24 and SRC-52."
    sql: ${TABLE}.bucket_start ;;
  }
  dimension: module_name {
    type: string
    description: "Source module_name; this Explore is restricted to the Ingestion module."
    sql: ${TABLE}.module_name ;;
  }
  dimension: environment {
    type: string
    description: "Source environment; this Explore is restricted to the Ingestion module."
    sql: ${TABLE}.environment ;;
  }
  dimension: queue_name {
    type: string
    description: "Source queue_name; this Explore is restricted to the Ingestion module."
    sql: ${TABLE}.queue_name ;;
  }
  dimension: queue_type {
    type: string
    description: "Source queue_type; this Explore is restricted to the Ingestion module."
    sql: ${TABLE}.queue_type ;;
  }
}
