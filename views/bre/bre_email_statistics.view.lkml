# Email Statistics. Original email-quality rows by pilot, dates, email type and billing-cycle end week.
# No persistence: preserve source rows and keep all filters outside source windows.
view: bre_email_statistics {
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
        CAST(NULL AS VARCHAR) AS fuel_type,
        CAST(NULL AS VARCHAR) AS module_name,
        CAST(s.email_type AS VARCHAR) AS email_type,
        CAST(s.bc_end_week_number AS VARCHAR) AS bc_end_week_number,
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
        CAST(s.cnt_bills_ingested AS BIGINT) AS cnt_bills_ingested,
        CAST(s.cnt_bills_emails_sent AS BIGINT) AS cnt_bills_emails_sent,
        CAST(s.cnt_bills_emails_delivered AS BIGINT) AS cnt_bills_emails_delivered,
        CAST(s.email_sent_pct AS DOUBLE) AS email_sent_pct,
        CAST(s.email_not_sent_pct AS DOUBLE) AS email_not_sent_pct,
        CAST(s.cnt_expected_invoices AS BIGINT) AS cnt_expected_invoices,
        CAST(s.cnt_bills_item_available AS BIGINT) AS cnt_bills_item_available,
        s.cnt_bills_ingested AS cnt_bills_ingested_source_text,
        s.cnt_bills_emails_sent AS cnt_bills_emails_sent_source_text,
        s.cnt_bills_emails_delivered AS cnt_bills_emails_delivered_source_text
      FROM (
      SELECT
        s.pilot_id AS pilot_id,
        s.reporting_date AS reporting_date,
        s.analysis_date AS analysis_date,
        s.bc_end_week_number AS bc_end_week_number,
        s.email_type AS email_type,
        s.cnt_bills_ingested AS cnt_bills_ingested,
        s.cnt_bills_emails_sent AS cnt_bills_emails_sent,
        s.cnt_bills_emails_delivered AS cnt_bills_emails_delivered,
        s.email_sent_pct AS email_sent_pct,
        s.email_not_sent_pct AS email_not_sent_pct,
        s.cnt_expected_invoices AS cnt_expected_invoices,
        s.cnt_bills_item_available AS cnt_bills_item_available,
        s.last_updated_timestamp AS last_updated_timestamp
      FROM {% if _model._name == 'bre_ca' %}delta_prodca{% elsif _model._name == 'bre_eu' %}delta_prodeu{% else %}bre_invalid_model{% endif %}.reporting.sre_quality_email_stats AS s
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
  dimension: bc_end_week_number {
    type: string
    description: "BC End Week# dropdown values from the SRE Email Statistics source."
    sql: ${TABLE}.bc_end_week_number ;;
  }
}
