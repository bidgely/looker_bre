include: "/views/bre_na/bre_na_ingestion_queue_fields.view.lkml"

# SRC-52; query-time only. Preserve the supplied source aggregation formulas.
view: bre_na_ingestion_queue_health {
  extends: [bre_na_ingestion_queue_fields]
  derived_table: {
    sql:
      SELECT ROW_NUMBER() OVER () AS row_id, source.*
      FROM (
        SELECT
            module_name,
            environment,
            queue_type,
            queue_name,
            CAST(date_trunc('day', analysis_date AT TIME ZONE 'UTC') AS TIMESTAMP) AS bucket_start,
            ROUND(
                (
                    (SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) /
                     NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0) * 50)  -- Success rate (50%)
                    + (100 - LEAST(AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) / 1000, 1) * 100) * 0.3  -- Backlog (30%, capped at 1000)
                    + (100 - LEAST(MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) / 3600, 1) * 100) * 0.2  -- Latency (20%, capped at 1 hour)
                ), 0
            ) AS health_score
        FROM delta_prodna.reporting.sre_queue_metrics_fact
        WHERE module_name = 'Ingestion'
          AND {% condition bre_na_ingestion_queue_health.date_range %} CAST(analysis_date AT TIME ZONE 'UTC' AS DATE) {% endcondition %}
          AND {% condition bre_na_ingestion_queue_health.event_timestamp_str %} date_format(event_timestamp AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') {% endcondition %}
          AND {% condition bre_na_ingestion_queue_health.queue_name %} queue_name {% endcondition %}
          AND {% condition bre_na_ingestion_queue_health.queue_type %} queue_type {% endcondition %}
          AND {% condition bre_na_ingestion_queue_health.module_name %} module_name {% endcondition %}
        GROUP BY module_name, environment, queue_type, queue_name, date_trunc('day', analysis_date AT TIME ZONE 'UTC')
      ) source
    ;;
  }
  dimension: health_score {
    type: number
    hidden: yes
    description: "Source SRC-52 health_score."
    sql: ${TABLE}.health_score ;;
  }
  measure: health_score_average {
    type: average
    label: "Health Score"
    description: "Average of source queue/day scores; original 50/30/20 weighting and rounding preserved."
    sql: ${health_score} ;;
    value_format: "0"
  }
}
