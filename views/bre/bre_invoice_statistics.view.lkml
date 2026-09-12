# Invoice Statistics. Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_invoice_statistics {
  derived_table: {
    sql:
      SELECT
        ROW_NUMBER() OVER () AS row_id,
        CAST(s.pilot_id AS VARCHAR) AS pilot_id,
        CAST(p.pilot_name AS VARCHAR) AS pilot_name,
        CAST(CAST(s.pilot_id AS VARCHAR) || ' : ' || COALESCE(p.pilot_name, '') AS VARCHAR) AS pilot_id_name,
        CAST(p.time_zone AS VARCHAR) AS time_zone,
        CAST(s.analysis_date AS DATE) AS analysis_date,
        CAST(s.reporting_date AS DATE) AS reporting_date,
        CAST(s.last_updated_timestamp AS TIMESTAMP(6)) AS last_updated_timestamp,
        CAST(s.analysis_date AS VARCHAR) AS source_analysis_value,
        CAST(s.reporting_date AS VARCHAR) AS source_reporting_value,
        CAST(NULL AS VARCHAR) AS source_pilot_name,
        CAST(NULL AS VARCHAR) AS source_period,
        CAST(s.rnk AS BIGINT) AS source_rank,
        CAST(NULL AS VARCHAR) AS ingestion_type,
        CAST(s.meter_type AS VARCHAR) AS meter_type,
        CAST(s.fuel_type AS VARCHAR) AS fuel_type,
        CAST(s.module_name AS VARCHAR) AS module_name,
        CAST(NULL AS VARCHAR) AS email_type,
        CAST(NULL AS VARCHAR) AS bc_end_week_number,
        CAST(NULL AS VARCHAR) AS cluster_id,
        CAST(NULL AS DATE) AS schedule_start,
        CAST(NULL AS DATE) AS schedule_end,
        CAST(NULL AS VARCHAR) AS appliance_name,
        CAST(NULL AS VARCHAR) AS metric_name,
        CAST(NULL AS VARCHAR) AS application_error_code,
        CAST(NULL AS VARCHAR) AS failure_reason,
        CAST(s.reporting_frequency AS VARCHAR) AS reporting_frequency,
        CAST(s.trigger_flag AS VARCHAR) AS trigger_flag,
        CAST(NULL AS VARCHAR) AS delivery_mode,
        CAST(NULL AS VARCHAR) AS event_type,
        CAST(s.delay_in_days AS INTEGER) AS delay_in_days,
        CAST(NULL AS BOOLEAN) AS istou,
        CAST(s.total_invoices AS INTEGER) AS total_invoices,
        CAST(s.failed_itemisation_pct AS DECIMAL(5, 2)) AS failed_itemisation_pct,
        CAST(s.successful_itemisation_pct AS DECIMAL(5, 2)) AS successful_itemisation_pct
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.meter_type AS meter_type,
        s.fuel_type AS fuel_type,
        s.reporting_date AS reporting_date,
        s.analysis_date AS analysis_date,
        s.reporting_frequency AS reporting_frequency,
        s.module_name AS module_name,
        s.total_invoices AS total_invoices,
        COALESCE(s.failed_itemisation_pct, 0) AS failed_itemisation_pct,
        COALESCE(s.successful_itemisation_pct, 0) AS successful_itemisation_pct,
        s.delay_in_days AS delay_in_days,
        s.trigger_flag AS trigger_flag,
        s.last_updated_timestamp AS last_updated_timestamp,
        s.rnk AS rnk
      FROM (
        SELECT
          sre_invoice_statistics.pilot_id AS pilot_id,
          sre_invoice_statistics.meter_type AS meter_type,
          sre_invoice_statistics.fuel_type AS fuel_type,
          sre_invoice_statistics.reporting_date AS reporting_date,
          sre_invoice_statistics.analysis_date AS analysis_date,
          sre_invoice_statistics.reporting_frequency AS reporting_frequency,
          sre_invoice_statistics.module_name AS module_name,
          sre_invoice_statistics.total_invoices AS total_invoices,
          sre_invoice_statistics.failed_itemisation_pct AS failed_itemisation_pct,
          sre_invoice_statistics.successful_itemisation_pct AS successful_itemisation_pct,
          sre_invoice_statistics.delay_in_days AS delay_in_days,
          sre_invoice_statistics.last_updated_timestamp AS last_updated_timestamp,
          sre_invoice_statistics.trigger_flag AS trigger_flag,
          sre_invoice_statistics.failed_itemisation_cnt AS failed_itemisation_cnt,
          sre_invoice_statistics.successful_itemisation_cnt AS successful_itemisation_cnt,
          ROW_NUMBER() OVER (
            PARTITION BY sre_invoice_statistics.pilot_id, sre_invoice_statistics.meter_type, sre_invoice_statistics.fuel_type, sre_invoice_statistics.module_name, sre_invoice_statistics.analysis_date, sre_invoice_statistics.trigger_flag, CASE
              WHEN sre_invoice_statistics.trigger_flag = 'SCHEDULED'
              THEN sre_invoice_statistics.delay_in_days
            END
            ORDER BY sre_invoice_statistics.last_updated_timestamp DESC NULLS FIRST
          ) AS rnk
        FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_invoice_statistics AS sre_invoice_statistics
        WHERE
          sre_invoice_statistics.trigger_flag IN ('SCHEDULED', 'ADHOC')
      ) AS s
      WHERE
        s.rnk = 1
      ) s
      LEFT JOIN ${bre_pilots.SQL_TABLE_NAME} p
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
