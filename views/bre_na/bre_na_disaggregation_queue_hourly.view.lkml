include: "/views/bre_na/bre_na_ingestion_queue_hourly.view.lkml"

# Same SRC queue formulas; user-confirmed Agg/Disagg module scope.
view: bre_na_disaggregation_queue_hourly {
  extends: [bre_na_ingestion_queue_hourly]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, source.*
            FROM (
              SELECT
                  CAST(date_trunc('hour', analysis_date) AT TIME ZONE 'UTC' AS TIMESTAMP) AS bucket_start,
                  environment,
                  module_name,
                  queue_type,
                  queue_name,
                  SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) AS total_messages_received,
                  SUM(CASE WHEN metric_name = 'NumberOfMessagesSent' THEN metric_value ELSE 0 END) AS total_messages_sent,
                  SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) AS total_messages_deleted,
                  AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) AS avg_queue_backlog,
                  MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) AS max_latency,
                  ROUND(
                      SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) * 100.0 /
                      NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0),
                  2) AS success_rate,  -- Rounded to 2 decimal places
                  SUM(CASE WHEN metric_name = 'ApproximateNumberOfMessagesDelayed' THEN metric_value ELSE 0 END) AS delayed_messages
              FROM delta_prodna.reporting.sre_queue_metrics_fact
              WHERE module_name IN ('Disaggregation', 'Aggregation', 'UploadEventSplitter')
                AND {% condition bre_na_disaggregation_queue_hourly.date_range %} CAST(analysis_date AT TIME ZONE 'UTC' AS DATE) {% endcondition %}
                AND {% condition bre_na_disaggregation_queue_hourly.event_timestamp_str %} date_format(event_timestamp AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') {% endcondition %}
                AND {% condition bre_na_disaggregation_queue_hourly.queue_name %} queue_name {% endcondition %}
                AND {% condition bre_na_disaggregation_queue_hourly.queue_type %} queue_type {% endcondition %}
                AND {% condition bre_na_disaggregation_queue_hourly.module_name %} module_name {% endcondition %}
                AND {% condition bre_na_disaggregation_queue_hourly.environment %} environment {% endcondition %}
                AND analysis_date >= current_timestamp - INTERVAL '7' DAY  -- Reduce the date range (11.8M+ unfiltered rows otherwise -> connector timeout)
              GROUP BY date_trunc('hour', analysis_date), environment, module_name, queue_type, queue_name
            ) source
    ;;
  }
  dimension: module_name {
    description: "Source module_name within the Disaggregation, Aggregation, and UploadEventSplitter module scope."
  }
  dimension: environment {
    description: "Source environment within the Disaggregation, Aggregation, and UploadEventSplitter module scope."
  }
  dimension: queue_name {
    description: "Source queue_name within the Disaggregation, Aggregation, and UploadEventSplitter module scope."
  }
  dimension: queue_type {
    description: "Source queue_type within the Disaggregation, Aggregation, and UploadEventSplitter module scope."
  }
  dimension: delayed_messages {
    type: number
    hidden: yes
    description: "Original source delayed_messages; NULLs and source rounding are retained."
    sql: ${TABLE}.delayed_messages ;;
  }
  measure: delayed_messages_sum {
    type: sum
    description: "Documented sum of delayed_messages across selected source buckets."
    sql: ${delayed_messages} ;;
    value_format: "#,##0"
  }
}
