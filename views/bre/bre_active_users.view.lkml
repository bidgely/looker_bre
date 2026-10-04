# Active Users. Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_active_users {
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
        CAST(s.pilot_name AS VARCHAR) AS source_pilot_name,
        CAST(NULL AS VARCHAR) AS source_period,
        CAST(s.rn AS BIGINT) AS source_rank,
        CAST(NULL AS VARCHAR) AS ingestion_type,
        CAST(NULL AS VARCHAR) AS meter_type,
        CAST(NULL AS VARCHAR) AS fuel_type,
        CAST(NULL AS VARCHAR) AS module_name,
        CAST(NULL AS VARCHAR) AS email_type,
        CAST(NULL AS VARCHAR) AS bc_end_week_number,
        CAST(NULL AS VARCHAR) AS cluster_id,
        CAST(NULL AS DATE) AS schedule_start,
        CAST(NULL AS DATE) AS schedule_end,
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
        CAST(s.total_uuid AS INTEGER) AS total_uuid,
        CAST(s.enabled_uuid AS INTEGER) AS enabled_uuid,
        CAST(s.disabled_uuid AS INTEGER) AS disabled_uuid,
        CAST(s.active_uuid AS INTEGER) AS active_uuid,
        CAST(s.total_active_electric_uuid AS INTEGER) AS total_active_electric_uuid,
        CAST(s.total_active_gas_uuid AS INTEGER) AS total_active_gas_uuid,
        CAST(s.total_active_uuid AS INTEGER) AS total_active_uuid,
        CAST(s.total_active_user_meters AS INTEGER) AS total_active_user_meters,
        CAST(s.total_active_electric_meters AS INTEGER) AS total_active_electric_meters,
        CAST(s.total_active_gas_meters AS INTEGER) AS total_active_gas_meters
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.pilot_name AS pilot_name,
        s.total_uuid AS total_uuid,
        s.enabled_uuid AS enabled_uuid,
        s.disabled_uuid AS disabled_uuid,
        s.active_uuid AS active_uuid,
        s.reporting_date AS reporting_date,
        s.last_updated_timestamp AS last_updated_timestamp,
        s.analysis_date AS analysis_date,
        s.total_active_electric_uuid AS total_active_electric_uuid,
        s.total_active_gas_uuid AS total_active_gas_uuid,
        s.total_active_uuid AS total_active_uuid,
        s.total_active_user_meters AS total_active_user_meters,
        s.total_active_electric_meters AS total_active_electric_meters,
        s.total_active_gas_meters AS total_active_gas_meters,
        s.rn AS rn
      FROM (
        SELECT
          t.pilot_id AS pilot_id,
          t.pilot_name AS pilot_name,
          t.total_uuid AS total_uuid,
          t.enabled_uuid AS enabled_uuid,
          t.disabled_uuid AS disabled_uuid,
          t.active_uuid AS active_uuid,
          t.reporting_date AS reporting_date,
          t.last_updated_timestamp AS last_updated_timestamp,
          t.analysis_date AS analysis_date,
          t.total_active_electric_uuid AS total_active_electric_uuid,
          t.total_active_gas_uuid AS total_active_gas_uuid,
          t.total_active_uuid AS total_active_uuid,
          t.total_active_user_meters AS total_active_user_meters,
          t.total_active_electric_meters AS total_active_electric_meters,
          t.total_active_gas_meters AS total_active_gas_meters,
          t.rn AS rn
        FROM (
          SELECT
            sre_total_active_users.pilot_id AS pilot_id,
            sre_total_active_users.pilot_name AS pilot_name,
            sre_total_active_users.total_uuid AS total_uuid,
            sre_total_active_users.enabled_uuid AS enabled_uuid,
            sre_total_active_users.disabled_uuid AS disabled_uuid,
            sre_total_active_users.active_uuid AS active_uuid,
            sre_total_active_users.reporting_date AS reporting_date,
            sre_total_active_users.last_updated_timestamp AS last_updated_timestamp,
            sre_total_active_users.analysis_date AS analysis_date,
            sre_total_active_users.total_active_electric_uuid AS total_active_electric_uuid,
            sre_total_active_users.total_active_gas_uuid AS total_active_gas_uuid,
            sre_total_active_users.total_active_uuid AS total_active_uuid,
            sre_total_active_users.total_active_user_meters AS total_active_user_meters,
            sre_total_active_users.total_active_electric_meters AS total_active_electric_meters,
            sre_total_active_users.total_active_gas_meters AS total_active_gas_meters,
            ROW_NUMBER() OVER (
              PARTITION BY sre_total_active_users.pilot_id
              ORDER BY sre_total_active_users.reporting_date DESC NULLS FIRST
            ) AS rn
          FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% elsif _model._name == 'bre_na' %}delta_prodna{% else %}bre_invalid_model{% endif %}.reporting.sre_total_active_users AS sre_total_active_users
        ) AS t
        WHERE
          t.rn = 1
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
