include: "/views/bre_na/bre_na_ingestion_queue_fields.view.lkml"

# SRC-01; query-time only. Preserve the supplied source aggregation formulas.
view: bre_na_ingestion_queue_hourly {
  extends: [bre_na_ingestion_queue_fields]
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
        WHERE module_name = 'Ingestion'
          AND {% condition bre_na_ingestion_queue_hourly.date_range %} CAST(analysis_date AT TIME ZONE 'UTC' AS DATE) {% endcondition %}
          AND {% condition bre_na_ingestion_queue_hourly.event_timestamp_str %} date_format(event_timestamp AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') {% endcondition %}
          AND {% condition bre_na_ingestion_queue_hourly.queue_name %} queue_name {% endcondition %}
          AND {% condition bre_na_ingestion_queue_hourly.queue_type %} queue_type {% endcondition %}
          AND {% condition bre_na_ingestion_queue_hourly.module_name %} module_name {% endcondition %}
          AND analysis_date >= current_timestamp - INTERVAL '7' DAY  -- Reduce the date range (11.8M+ unfiltered rows otherwise -> connector timeout)
        GROUP BY date_trunc('hour', analysis_date), environment, module_name, queue_type, queue_name
      ) source
    ;;
  }
  dimension: total_messages_received {
    type: number
    hidden: yes
    description: "Source SRC-01 total_messages_received."
    sql: ${TABLE}.total_messages_received ;;
  }
  measure: total_messages_received_sum {
    type: sum
    label: "Messages Received"
    description: "Sum of queue bucket messages received."
    sql: ${total_messages_received} ;;
    value_format: "#,##0"
  }
  dimension: total_messages_sent {
    type: number
    hidden: yes
    description: "Source SRC-01 total_messages_sent."
    sql: ${TABLE}.total_messages_sent ;;
  }
  measure: total_messages_sent_sum {
    type: sum
    label: "Messages Sent"
    description: "Sum of messages sent, matching the documented Processed Messages chart."
    sql: ${total_messages_sent} ;;
    value_format: "#,##0"
  }
  dimension: avg_queue_backlog {
    type: number
    hidden: yes
    description: "Source SRC-01 avg_queue_backlog."
    sql: ${TABLE}.avg_queue_backlog ;;
  }
  measure: avg_queue_backlog_average {
    type: average
    label: "Average Queue Backlog"
    description: "Unweighted average of source bucket averages, including ELSE 0 values in the source formula."
    sql: ${avg_queue_backlog} ;;
    value_format: "#,##0.00"
  }
  dimension: success_rate {
    type: number
    hidden: yes
    description: "Source SRC-01 success_rate."
    sql: ${TABLE}.success_rate ;;
  }
  measure: success_rate_average {
    type: average
    label: "Success Rate"
    description: "Unweighted average of rounded source queue/hour percentages; provisional chart aggregation pending confirmation."
    sql: ${success_rate} ;;
    value_format: "0.00\"%\""
  }
  dimension: max_latency_days {
    type: number
    hidden: yes
    description: "SRC-01 max_latency_in_days = max_latency / 86400, retaining the original seconds-to-days conversion."
    sql: ${TABLE}.max_latency / 86400.0 ;;
  }
  measure: max_latency_days_max {
    type: max
    label: "Oldest Message Age (Days)"
    description: "Maximum message age in days over selected source buckets."
    sql: ${max_latency_days} ;;
    value_format: "0.00"
  }
}
