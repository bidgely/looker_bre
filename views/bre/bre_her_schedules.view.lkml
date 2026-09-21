# HER Schedule Status. Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_her_schedules {
  derived_table: {
    sql:
      SELECT
        ROW_NUMBER() OVER () AS row_id,
        CAST(s.pilot_id AS VARCHAR) AS pilot_id,
        CAST(p.pilot_name AS VARCHAR) AS pilot_name,
        CAST(CAST(s.pilot_id AS VARCHAR) || ' : ' || p.pilot_name AS VARCHAR) AS pilot_id_name,
        CAST(p.time_zone AS VARCHAR) AS time_zone,
        CAST(s.analysis_date AS DATE) AS analysis_date,
        CAST(s.reporting_date AS DATE) AS reporting_date,
        CAST(s.last_updated_timestamp AS TIMESTAMP(6)) AS last_updated_timestamp,
        CAST(s.analysis_date AS VARCHAR) AS source_analysis_value,
        CAST(s.reporting_date AS VARCHAR) AS source_reporting_value,
        CAST(NULL AS VARCHAR) AS source_pilot_name,
        CAST(NULL AS VARCHAR) AS source_period,
        CAST(NULL AS BIGINT) AS source_rank,
        CAST(NULL AS VARCHAR) AS ingestion_type,
        CAST(NULL AS VARCHAR) AS meter_type,
        CAST(s.fuel_type AS VARCHAR) AS fuel_type,
        CAST(NULL AS VARCHAR) AS module_name,
        CAST(NULL AS VARCHAR) AS email_type,
        CAST(NULL AS VARCHAR) AS bc_end_week_number,
        CAST(s.cluster_id AS VARCHAR) AS cluster_id,
        CAST(s.schedule_start AS DATE) AS schedule_start,
        CAST(s.schedule_end AS DATE) AS schedule_end,
        CAST(NULL AS VARCHAR) AS appliance_name,
        CAST(NULL AS VARCHAR) AS metric_name,
        CAST(NULL AS VARCHAR) AS application_error_code,
        CAST(NULL AS VARCHAR) AS failure_reason,
        CAST(NULL AS VARCHAR) AS reporting_frequency,
        CAST(NULL AS VARCHAR) AS trigger_flag,
        CAST(NULL AS VARCHAR) AS delivery_mode,
        CAST(NULL AS VARCHAR) AS event_type,
        CAST(NULL AS INTEGER) AS delay_in_days,
        CAST(NULL AS BOOLEAN) AS istou,
        CAST(s.total_eligible_users AS BIGINT) AS total_eligible_users,
        CAST(s.total_generated_notification_id AS BIGINT) AS total_generated_notification_id,
        CAST(s.total_scheduled_notification_id AS BIGINT) AS total_scheduled_notification_id,
        CAST(s.total_queued_notification_id AS BIGINT) AS total_queued_notification_id,
        CAST(s.total_printed_notification_id AS BIGINT) AS total_printed_notification_id,
        CAST(s.total_mailed_notification_id AS BIGINT) AS total_mailed_notification_id,
        CAST(s.total_failed_notification_id AS BIGINT) AS total_failed_notification_id,
        CAST(s.total_swept_notification_id AS BIGINT) AS total_swept_notification_id
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.cluster_id AS cluster_id,
        s.measurement_type AS fuel_type,
        s.schedule_start AS schedule_start,
        s.schedule_end AS schedule_end,
        s.total_eligible_users AS total_eligible_users,
        s.total_generated_notification_id AS total_generated_notification_id,
        s.total_scheduled_notification_id AS total_scheduled_notification_id,
        s.total_queued_notification_id AS total_queued_notification_id,
        s.total_printed_notification_id AS total_printed_notification_id,
        s.total_mailed_notification_id AS total_mailed_notification_id,
        s.total_failed_notification_id AS total_failed_notification_id,
        s.reporting_date AS reporting_date,
        s.last_updated_timestamp AS last_updated_timestamp,
        s.analysis_date AS analysis_date,
        s.total_swept_notification_id AS total_swept_notification_id
      FROM (
        SELECT
          _0.pilot_id AS pilot_id,
          _0.schedule_start AS schedule_start,
          _0.schedule_end AS schedule_end,
          _0.measurement_type AS measurement_type,
          _0.cluster_id AS cluster_id,
          SUM(_0.total_eligible_users) AS total_eligible_users,
          SUM(_0.total_generated_notification_id) AS total_generated_notification_id,
          SUM(_0.total_scheduled_notification_id) AS total_scheduled_notification_id,
          SUM(_0.total_swept_notification_id) AS total_swept_notification_id,
          SUM(_0.total_queued_notification_id) AS total_queued_notification_id,
          SUM(_0.total_printed_notification_id) AS total_printed_notification_id,
          SUM(_0.total_mailed_notification_id) AS total_mailed_notification_id,
          SUM(_0.total_failed_notification_id) AS total_failed_notification_id,
          MAX(_0.analysis_date) AS analysis_date,
          MAX(_0.reporting_date) AS reporting_date,
          MAX(_0.last_updated_timestamp) AS last_updated_timestamp
        FROM (
          SELECT
            x.pilot_id AS pilot_id,
            x.cluster_id AS cluster_id,
            x.measurement_type AS measurement_type,
            CASE
              WHEN x.schedule_quarter_start < x.schedule_start
              THEN x.schedule_start
              ELSE x.schedule_quarter_start
            END AS schedule_start,
            CAST(DATE_ADD(
              'DAY',
              -1,
              CAST(DATE_ADD('QUARTER', 1, CAST(x.schedule_quarter_start AS TIMESTAMP)) AS TIMESTAMP)
            ) AS DATE) AS schedule_end,
            x.total_eligible_users AS total_eligible_users,
            x.total_generated_notification_id AS total_generated_notification_id,
            x.total_scheduled_notification_id AS total_scheduled_notification_id,
            x.total_swept_notification_id AS total_swept_notification_id,
            x.total_queued_notification_id AS total_queued_notification_id,
            x.total_printed_notification_id AS total_printed_notification_id,
            x.total_mailed_notification_id AS total_mailed_notification_id,
            x.total_failed_notification_id AS total_failed_notification_id,
            x.reporting_date AS reporting_date,
            x.analysis_date AS analysis_date,
            x.last_updated_timestamp AS last_updated_timestamp
          FROM (
            SELECT
              sre_daily_her_tracker.pilot_id AS pilot_id,
              sre_daily_her_tracker.cluster_id AS cluster_id,
              sre_daily_her_tracker.measurement_type AS measurement_type,
              sre_daily_her_tracker.schedule_start AS schedule_start,
              sre_daily_her_tracker.schedule_end AS schedule_end,
              sre_daily_her_tracker.total_eligible_users AS total_eligible_users,
              sre_daily_her_tracker.total_generated_notification_id AS total_generated_notification_id,
              sre_daily_her_tracker.total_scheduled_notification_id AS total_scheduled_notification_id,
              sre_daily_her_tracker.total_queued_notification_id AS total_queued_notification_id,
              sre_daily_her_tracker.total_printed_notification_id AS total_printed_notification_id,
              sre_daily_her_tracker.total_mailed_notification_id AS total_mailed_notification_id,
              sre_daily_her_tracker.total_failed_notification_id AS total_failed_notification_id,
              sre_daily_her_tracker.reporting_date AS reporting_date,
              sre_daily_her_tracker.last_updated_timestamp AS last_updated_timestamp,
              sre_daily_her_tracker.analysis_date AS analysis_date,
              sre_daily_her_tracker.total_swept_notification_id AS total_swept_notification_id,
              DATE(DATE_TRUNC('QUARTER', sre_daily_her_tracker.analysis_date)) AS schedule_quarter_start,
              ROW_NUMBER() OVER (
                PARTITION BY sre_daily_her_tracker.pilot_id, sre_daily_her_tracker.cluster_id, sre_daily_her_tracker.measurement_type, sre_daily_her_tracker.schedule_start, sre_daily_her_tracker.schedule_end, DATE_TRUNC('QUARTER', sre_daily_her_tracker.analysis_date)
                ORDER BY sre_daily_her_tracker.reporting_date DESC NULLS FIRST
              ) AS rk
            FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_daily_her_tracker AS sre_daily_her_tracker
            WHERE
              sre_daily_her_tracker.pilot_id = '10037'
          ) AS x
          WHERE
            x.rk = 1
          UNION
          SELECT
            x.pilot_id AS pilot_id,
            x.cluster_id AS cluster_id,
            x.measurement_type AS measurement_type,
            x.schedule_start AS schedule_start,
            x.schedule_end AS schedule_end,
            x.total_eligible_users AS total_eligible_users,
            x.total_generated_notification_id AS total_generated_notification_id,
            x.total_scheduled_notification_id AS total_scheduled_notification_id,
            x.total_swept_notification_id AS total_swept_notification_id,
            x.total_queued_notification_id AS total_queued_notification_id,
            x.total_printed_notification_id AS total_printed_notification_id,
            x.total_mailed_notification_id AS total_mailed_notification_id,
            x.total_failed_notification_id AS total_failed_notification_id,
            x.reporting_date AS reporting_date,
            x.analysis_date AS analysis_date,
            x.last_updated_timestamp AS last_updated_timestamp
          FROM (
            SELECT
              sre_daily_her_tracker.pilot_id AS pilot_id,
              sre_daily_her_tracker.cluster_id AS cluster_id,
              sre_daily_her_tracker.measurement_type AS measurement_type,
              sre_daily_her_tracker.schedule_start AS schedule_start,
              sre_daily_her_tracker.schedule_end AS schedule_end,
              sre_daily_her_tracker.total_eligible_users AS total_eligible_users,
              sre_daily_her_tracker.total_generated_notification_id AS total_generated_notification_id,
              sre_daily_her_tracker.total_scheduled_notification_id AS total_scheduled_notification_id,
              sre_daily_her_tracker.total_queued_notification_id AS total_queued_notification_id,
              sre_daily_her_tracker.total_printed_notification_id AS total_printed_notification_id,
              sre_daily_her_tracker.total_mailed_notification_id AS total_mailed_notification_id,
              sre_daily_her_tracker.total_failed_notification_id AS total_failed_notification_id,
              sre_daily_her_tracker.reporting_date AS reporting_date,
              sre_daily_her_tracker.last_updated_timestamp AS last_updated_timestamp,
              sre_daily_her_tracker.analysis_date AS analysis_date,
              sre_daily_her_tracker.total_swept_notification_id AS total_swept_notification_id,
              ROW_NUMBER() OVER (
                PARTITION BY sre_daily_her_tracker.pilot_id, sre_daily_her_tracker.cluster_id, sre_daily_her_tracker.measurement_type, sre_daily_her_tracker.schedule_start, sre_daily_her_tracker.schedule_end
                ORDER BY sre_daily_her_tracker.reporting_date DESC NULLS FIRST
              ) AS rk
            FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_daily_her_tracker AS sre_daily_her_tracker
            WHERE
              sre_daily_her_tracker.pilot_id <> '10037'
          ) AS x
          WHERE
            x.rk = 1
        ) AS _0
        GROUP BY
          _0.pilot_id,
          _0.schedule_start,
          _0.schedule_end,
          _0.measurement_type,
          _0.cluster_id
      ) AS s
      ) s
      INNER JOIN ${bre_pilots.SQL_TABLE_NAME} p
        ON CAST(s.pilot_id AS VARCHAR) = p.pilot_id
    ;;
  }
  dimension: row_id {
    primary_key: yes
    hidden: yes
    type: number
    description: "Query-local source row identifier. Preserves duplicate source rows; not a durable business key or a deduplication rule."
    sql: ${TABLE}.row_id ;;
  }
}
