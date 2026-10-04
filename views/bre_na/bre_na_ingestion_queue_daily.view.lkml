include: "/views/bre_na/bre_na_ingestion_queue_fields.view.lkml"

# SRC-24; query-time only. Preserve the supplied source aggregation formulas.
view: bre_na_ingestion_queue_daily {
  extends: [bre_na_ingestion_queue_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, source.*
      FROM (
        SELECT
            CAST(date_trunc('day', analysis_date AT TIME ZONE 'UTC') AS TIMESTAMP) AS bucket_start,
            module_name,
            environment,
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
            ROUND(
              SUM(CASE WHEN metric_name = 'NumberOfEmptyReceives' THEN metric_value ELSE 0 END) /
              NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) +
                     SUM(CASE WHEN metric_name = 'NumberOfEmptyReceives' THEN metric_value ELSE 0 END), 0) * 100, 2) AS empty_receives_ratio
        FROM delta_prodna.reporting.sre_queue_metrics_fact
        WHERE module_name = 'Ingestion'
          AND {% condition bre_na_ingestion_queue_daily.date_range %} CAST(analysis_date AT TIME ZONE 'UTC' AS DATE) {% endcondition %}
          AND {% condition bre_na_ingestion_queue_daily.event_timestamp_str %} date_format(event_timestamp AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') {% endcondition %}
          AND {% condition bre_na_ingestion_queue_daily.queue_name %} queue_name {% endcondition %}
          AND {% condition bre_na_ingestion_queue_daily.queue_type %} queue_type {% endcondition %}
          AND {% condition bre_na_ingestion_queue_daily.module_name %} module_name {% endcondition %}
        GROUP BY date_trunc('day', analysis_date AT TIME ZONE 'UTC'), module_name, environment, queue_type, queue_name
      ) source
    ;;
  }
  dimension: total_messages_received {
    type: number
    hidden: yes
    description: "Source SRC-24 total_messages_received."
    sql: ${TABLE}.total_messages_received ;;
  }
  measure: total_messages_received_average {
    type: average
    label: "Processing Efficiency"
    description: "Documented AVG of daily messages received; this metric is a count, not a percentage."
    sql: ${total_messages_received} ;;
    value_format: "#,##0.00"
  }
}
