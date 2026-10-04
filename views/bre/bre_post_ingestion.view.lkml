# Post-Ingestion Quality. Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_post_ingestion {
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
        CAST(s.ingestion_type AS VARCHAR) AS ingestion_type,
        CAST(s.meter_type AS VARCHAR) AS meter_type,
        CAST(s.fuel_type AS VARCHAR) AS fuel_type,
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
        CAST(s.user_raw_with_delay_0_3 AS BIGINT) AS user_raw_with_delay_0_3,
        CAST(s.user_raw_with_delay_4_7 AS BIGINT) AS user_raw_with_delay_4_7,
        CAST(s.user_raw_with_delay_8_15 AS BIGINT) AS user_raw_with_delay_8_15,
        CAST(s.user_raw_with_delay_gt_15 AS BIGINT) AS user_raw_with_delay_gt_15,
        CAST(s.user_invoice_with_delay_0_7 AS BIGINT) AS user_invoice_with_delay_0_7,
        CAST(s.user_invoice_with_delay_7_15 AS BIGINT) AS user_invoice_with_delay_7_15,
        CAST(s.user_invoice_with_delay_15_30 AS BIGINT) AS user_invoice_with_delay_15_30,
        CAST(s.user_invoice_with_delay_gt_30 AS BIGINT) AS user_invoice_with_delay_gt_30,
        CAST(s.overlapping_bc_count AS BIGINT) AS overlapping_bc_count
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.meter_type AS meter_type,
        s.fuel_type AS fuel_type,
        s.ingestion_type AS ingestion_type,
        s.user_raw_with_delay_0_3 AS user_raw_with_delay_0_3,
        s.user_raw_with_delay_4_7 AS user_raw_with_delay_4_7,
        s.user_raw_with_delay_8_15 AS user_raw_with_delay_8_15,
        s.user_raw_with_delay_gt_15 AS user_raw_with_delay_gt_15,
        s.user_invoice_with_delay_0_7 AS user_invoice_with_delay_0_7,
        s.user_invoice_with_delay_7_15 AS user_invoice_with_delay_7_15,
        s.user_invoice_with_delay_15_30 AS user_invoice_with_delay_15_30,
        s.user_invoice_with_delay_gt_30 AS user_invoice_with_delay_gt_30,
        s.analysis_date AS analysis_date,
        s.reporting_date AS reporting_date,
        s.last_updated_timestamp AS last_updated_timestamp,
        e.overlapping_bc_count AS overlapping_bc_count
      FROM (
        SELECT
          COALESCE(a.pilot_id, b.pilot_id) AS pilot_id,
          COALESCE(a.meter_type, b.meter_type) AS meter_type,
          COALESCE(a.fuel_type, b.fuel_type) AS fuel_type,
          COALESCE(a.ingestion_type, b.ingestion_type) AS ingestion_type,
          a.user_with_delay_0_3 AS user_raw_with_delay_0_3,
          a.user_with_delay_4_7 AS user_raw_with_delay_4_7,
          a.user_with_delay_8_15 AS user_raw_with_delay_8_15,
          a.user_with_delay_gt_15 AS user_raw_with_delay_gt_15,
          b.invoice_with_delay_0_7 AS user_invoice_with_delay_0_7,
          b.invoice_with_delay_7_15 AS user_invoice_with_delay_7_15,
          b.invoice_with_delay_15_30 AS user_invoice_with_delay_15_30,
          b.invoice_with_delay_gt_30 AS user_invoice_with_delay_gt_30,
          COALESCE(a.analysis_date, b.analysis_date) AS analysis_date,
          COALESCE(a.reporting_date, b.reporting_date) AS reporting_date,
          COALESCE(a.last_updated_timestamp, b.last_updated_timestamp) AS last_updated_timestamp
        FROM (
          SELECT
            sre_raw_consumption_delay.pilot_id AS pilot_id,
            sre_raw_consumption_delay.meter_type AS meter_type,
            sre_raw_consumption_delay.fuel_type AS fuel_type,
            sre_raw_consumption_delay.user_with_delay_0_3 AS user_with_delay_0_3,
            sre_raw_consumption_delay.user_with_delay_4_7 AS user_with_delay_4_7,
            sre_raw_consumption_delay.user_with_delay_8_15 AS user_with_delay_8_15,
            sre_raw_consumption_delay.user_with_delay_gt_15 AS user_with_delay_gt_15,
            sre_raw_consumption_delay.analysis_date AS analysis_date,
            sre_raw_consumption_delay.reporting_date AS reporting_date,
            sre_raw_consumption_delay.last_updated_timestamp AS last_updated_timestamp,
            'CONSUMPTION' AS ingestion_type
          FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% elsif _model._name == 'bre_na' %}delta_prodna{% else %}bre_invalid_model{% endif %}.reporting.sre_raw_consumption_delay AS sre_raw_consumption_delay
        ) AS a
        FULL JOIN (
          SELECT
            sre_invoice_delay_tracker.pilot_id AS pilot_id,
            sre_invoice_delay_tracker.meter_type AS meter_type,
            sre_invoice_delay_tracker.fuel_type AS fuel_type,
            sre_invoice_delay_tracker.invoice_with_delay_0_7 AS invoice_with_delay_0_7,
            sre_invoice_delay_tracker.invoice_with_delay_7_15 AS invoice_with_delay_7_15,
            sre_invoice_delay_tracker.invoice_with_delay_15_30 AS invoice_with_delay_15_30,
            sre_invoice_delay_tracker.invoice_with_delay_gt_30 AS invoice_with_delay_gt_30,
            sre_invoice_delay_tracker.analysis_date AS analysis_date,
            sre_invoice_delay_tracker.reporting_date AS reporting_date,
            sre_invoice_delay_tracker.last_updated_timestamp AS last_updated_timestamp,
            CASE
              WHEN sre_invoice_delay_tracker.pilot_id IN (
                10021,
                10024,
                10043,
                10046,
                10047,
                10048,
                10049,
                10050,
                10051,
                10055,
                10064,
                10068,
                10070,
                10082,
                10110
              )
              THEN 'OPOWER'
              ELSE 'BILLING'
            END AS ingestion_type
          FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% elsif _model._name == 'bre_na' %}delta_prodna{% else %}bre_invalid_model{% endif %}.reporting.sre_invoice_delay_tracker AS sre_invoice_delay_tracker
        ) AS b
          ON a.pilot_id = b.pilot_id
          AND a.meter_type = b.meter_type
          AND a.fuel_type = b.fuel_type
          AND a.ingestion_type = b.ingestion_type
      ) AS s
      LEFT JOIN (
        SELECT
          sre_ingestion_errors_statistic.pilot_id AS pilot_id,
          sre_ingestion_errors_statistic.failed_record_count AS overlapping_bc_count,
          sre_ingestion_errors_statistic.analysis_date AS analysis_date,
          sre_ingestion_errors_statistic.reporting_date AS reporting_date,
          sre_ingestion_errors_statistic.last_updated_timestamp AS last_updated_timestamp,
          CASE
            WHEN sre_ingestion_errors_statistic.pilot_id IN (
              10021,
              10024,
              10043,
              10046,
              10047,
              10048,
              10049,
              10050,
              10051,
              10055,
              10064,
              10068,
              10070,
              10082,
              10110
            )
            THEN 'OPOWER'
            ELSE 'BILLING'
          END AS ingestion_type
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% elsif _model._name == 'bre_na' %}delta_prodna{% else %}bre_invalid_model{% endif %}.reporting.sre_ingestion_errors_statistic AS sre_ingestion_errors_statistic
        WHERE
          sre_ingestion_errors_statistic.application_error_code = 'ERROR_CONFLICTING_INVOICE_DATA'
      ) AS e
        ON s.pilot_id = e.pilot_id
        AND s.analysis_date = e.analysis_date
        AND s.ingestion_type = e.ingestion_type
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
