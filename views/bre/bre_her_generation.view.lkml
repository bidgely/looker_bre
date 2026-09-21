# HER Generation. Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_her_generation {
  derived_table: {
    sql:
      SELECT
        ROW_NUMBER() OVER () AS row_id,
        CAST(s.pilot_id AS VARCHAR) AS pilot_id,
        CAST(p.pilot_name AS VARCHAR) AS pilot_name,
        CAST(CAST(s.pilot_id AS VARCHAR) || ' : ' || p.pilot_name AS VARCHAR) AS pilot_id_name,
        CAST(p.time_zone AS VARCHAR) AS time_zone,
        CAST(s.analysis_date AS DATE) AS analysis_date,
        CAST(NULL AS DATE) AS reporting_date,
        CAST(s.last_updated_timestamp AS TIMESTAMP(6)) AS last_updated_timestamp,
        CAST(s.analysis_date AS VARCHAR) AS source_analysis_value,
        CAST(NULL AS VARCHAR) AS source_reporting_value,
        CAST(NULL AS VARCHAR) AS source_pilot_name,
        CAST(s.period AS VARCHAR) AS source_period,
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
        CAST(s.expected_eligible_users AS BIGINT) AS expected_eligible_users,
        CAST(s.actual_eligible_users AS BIGINT) AS actual_eligible_users,
        CAST(s.actual_generation_count AS BIGINT) AS actual_generation_count,
        CAST(s.weekly_actual_failure_count AS BIGINT) AS weekly_actual_failure_count
      FROM (
      WITH generation_base AS (
        SELECT
          COALESCE(a.pilot_id, b.pilot_id) AS pilot_id,
          COALESCE(a.cluster_id, b.cluster_id) AS cluster_id,
          COALESCE(a.analysis_date, b.analysis_date) AS analysis_date,
          COALESCE(a.reporting_date, b.reporting_date) AS reporting_date,
          COALESCE(a.schedule_start, b.schedule_start) AS schedule_start,
          COALESCE(a.schedule_end, b.schedule_end) AS schedule_end,
          COALESCE(a.measurement_type, b.measurement_type) AS fuel_type,
          a.eligible_users AS expected_eligible_users,
          b.total_cluster_users AS actual_eligible_users,
          b.total_missing_notification AS actual_failure_count,
          b.total_generated_notification AS actual_generation_count,
          a.last_updated_timestamp AS last_updated_timestamp,
          CAST(DATE_TRUNC('WEEK', COALESCE(a.analysis_date, b.analysis_date)) AS DATE) AS analysis_week,
          CAST(DATE_TRUNC('MONTH', COALESCE(a.analysis_date, b.analysis_date)) AS DATE) AS analysis_month
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_cluster_eligible_users AS a
        FULL JOIN {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_her_schedule_tracker AS b
          ON a.pilot_id = b.pilot_id
          AND a.cluster_id = b.cluster_id
          AND a.analysis_date = b.analysis_date
          AND a.schedule_start = b.schedule_start
          AND a.schedule_end = b.schedule_end
          AND a.measurement_type = b.measurement_type
      )
      SELECT
        s.pilot_id AS pilot_id,
        s.cluster_id AS cluster_id,
        s.analysis_date AS analysis_date,
        s.schedule_start AS schedule_start,
        s.schedule_end AS schedule_end,
        s.fuel_type AS fuel_type,
        "s"."period" AS "period",
        s.expected_eligible_users AS expected_eligible_users,
        s.actual_eligible_users AS actual_eligible_users,
        s.actual_generation_count AS actual_generation_count,
        s.weekly_actual_failure_count AS weekly_actual_failure_count,
        s.last_updated_timestamp AS last_updated_timestamp
      FROM (
        SELECT
          generation_base.pilot_id AS pilot_id,
          generation_base.cluster_id AS cluster_id,
          generation_base.analysis_date AS analysis_date,
          generation_base.schedule_start AS schedule_start,
          generation_base.schedule_end AS schedule_end,
          generation_base.fuel_type AS fuel_type,
          'Daily' AS "period",
          generation_base.expected_eligible_users AS expected_eligible_users,
          generation_base.actual_eligible_users AS actual_eligible_users,
          generation_base.actual_generation_count AS actual_generation_count,
          generation_base.expected_eligible_users - generation_base.actual_generation_count AS weekly_actual_failure_count,
          generation_base.last_updated_timestamp AS last_updated_timestamp
        FROM generation_base AS generation_base
        UNION ALL
        SELECT
          generation_base.pilot_id AS pilot_id,
          generation_base.cluster_id AS cluster_id,
          generation_base.analysis_week AS analysis_week,
          generation_base.schedule_start AS schedule_start,
          generation_base.schedule_end AS schedule_end,
          generation_base.fuel_type AS fuel_type,
          'Weekly' AS "period",
          MAX(generation_base.expected_eligible_users) AS weekly_expected_eligible_users,
          MAX(generation_base.actual_eligible_users) AS weekly_actual_eligible_users,
          SUM(generation_base.actual_generation_count) AS weekly_actual_generation_count,
          MAX(generation_base.expected_eligible_users) - SUM(generation_base.actual_generation_count) AS weekly_actual_failure_count,
          MAX(generation_base.last_updated_timestamp) AS last_updated_timestamp
        FROM generation_base AS generation_base
        GROUP BY
          generation_base.pilot_id,
          generation_base.cluster_id,
          generation_base.analysis_week,
          generation_base.schedule_start,
          generation_base.schedule_end,
          generation_base.fuel_type
        UNION ALL
        SELECT
          generation_base.pilot_id AS pilot_id,
          generation_base.cluster_id AS cluster_id,
          generation_base.analysis_month AS analysis_month,
          generation_base.schedule_start AS schedule_start,
          generation_base.schedule_end AS schedule_end,
          generation_base.fuel_type AS fuel_type,
          'Monthly' AS "period",
          MAX(generation_base.expected_eligible_users) AS monthly_expected_eligible_users,
          MAX(generation_base.actual_eligible_users) AS monthly_actual_eligible_users,
          SUM(generation_base.actual_generation_count) AS monthly_actual_generation_count,
          MAX(generation_base.expected_eligible_users) - SUM(generation_base.actual_generation_count) AS monthly_actual_failure_count,
          MAX(generation_base.last_updated_timestamp) AS last_updated_timestamp
        FROM generation_base AS generation_base
        GROUP BY
          generation_base.pilot_id,
          generation_base.cluster_id,
          generation_base.analysis_month,
          generation_base.schedule_start,
          generation_base.schedule_end,
          generation_base.fuel_type
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
  dimension: fuel_type {
    type: string
    label: "Fuel Type"
    description: "Fuel Type dropdown values from SRE HER Cluster Specific Generation Stats."
    sql: ${TABLE}.fuel_type ;;
  }
  dimension: cluster_id {
    type: string
    label: "Cluster IDs"
    description: "Cluster ID dropdown values from SRE HER Cluster Specific Generation Stats."
    sql: ${TABLE}.cluster_id ;;
  }
}
