-- BRE dashboard tables: EU / delta_prodeu
-- Run on prod-eu-cluster with the service account. Prepared 2026-09-12.
-- Source: bre_missing_tables_ddl.sql (DBeaver-exported Redshift DDL).
-- Verified: all 22 expected definitions are present exactly once; 302 columns.
--
-- Includes all 22 supplied definitions, including inventory-only tables.
-- CREATE TABLE IF NOT EXISTS skips existing tables; it does not reconcile their
-- columns, defaults, or data. No table is dropped or replaced.
-- These statements create EMPTY Delta tables; data loading is a separate step.
-- Both reporting schema locations were verified with SHOW CREATE SCHEMA.
-- Uses the existing schema storage root; no per-table S3 path is hardcoded.
-- Expected root: s3://bidgely-delta-lakehouse-prod-eu/delta-cataloge/reporting
--
-- Conversion details:
-- * Preserves column names/order, nullability, numeric precision and scale.
-- * Removes Redshift ENCODE, DISTSTYLE, DISTKEY, SORTKEY and owner statements.
-- * VARCHAR(n) becomes VARCHAR (Delta STRING); length limits are not enforced.
-- * NUMERIC becomes DECIMAL; DOUBLE PRECISION becomes DOUBLE.
-- * TIMESTAMP WITHOUT TIME ZONE becomes TIMESTAMP(6).
-- * TIMESTAMP WITH TIME ZONE becomes TIMESTAMP(3) WITH TIME ZONE for Delta;
--   EMR timestamp sub-millisecond precision cannot be retained by this mapping.
-- * Literal defaults are retained. Dynamic DEFAULT now() expressions are omitted:
--   supply those timestamp values in the ingestion writer. Omitted values become
--   NULL; creation alone does not reproduce Redshift timestamp default behavior.
-- * Original spellings, including last_updated_timestap, remain unchanged.
-- * sre_her_qc_data is separate from sre_quality_her_qc_data, as confirmed by user.
--
-- Validation: all 22 CREATE statements passed EXPLAIN (TYPE VALIDATE) on EU.
-- All 302 column types checked; 18 literal defaults retained, 20 dynamic defaults
-- documented and omitted. The complete script also parsed as Trino SQL locally.
-- Dry-run validation does not establish successful writes or grant authority.
-- No CREATE or GRANT statement has been executed against Starburst.
-- Grant statements are placed last and require SELECT WITH GRANT OPTION or
-- equivalent ownership authority in the service account's active role.
-- ROLE PUBLIC means all Galaxy users. Grants are table-specific, not schema-wide.
-- If a grant on an existing table fails, review that statement with the service
-- account; successful preceding CREATE statements are not rolled back.
--
-- Syntax references:
-- https://docs.starburst.io/starburst-galaxy/reference/sql/ref/sql/create-table.html
-- https://docs.starburst.io/starburst-galaxy/data-engineering/working-with-data-lakes/table-formats/gl-deltalake.html
-- https://docs.starburst.io/latest/connector/delta-lake.html#type-mapping
-- https://docs.starburst.io/starburst-galaxy/reference/sql/ref/sql/grant.html

-- EU: the earlier dashboard inventory found all 16 dependencies present.
-- The CREATE section also includes the CA-only definitions supplied by user,
-- for regional parity; IF NOT EXISTS leaves existing EU definitions intact.

-- 1. Table creation

-- 01/22: reporting.sre_nbi_generated_errors
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_nbi_generated_errors (
    pilot_id INTEGER,
    analysis_date DATE,
    reporting_date DATE,
    total_nbi_users BIGINT,
    total_users_with_200_errorcode BIGINT,
    total_users_with_300_errorcode BIGINT,
    nbi_error_pct DECIMAL(26,2),
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 02/22: reporting.sre_ingestion_errors_statistic
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_ingestion_errors_statistic (
    pilot_id INTEGER,
    ingestion_type VARCHAR,
    analysis_date DATE,
    reporting_date DATE,
    application_error_code VARCHAR,
    failed_record_count BIGINT,
    total_failed_record_count BIGINT,
    failure_percentage DECIMAL(26,2),
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 03/22: reporting.sre_invoice_delay_tracker
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_invoice_delay_tracker (
    pilot_id INTEGER,
    meter_type VARCHAR,
    fuel_type VARCHAR,
    total_invoice BIGINT,
    invoice_with_delay_0_7 BIGINT,
    invoice_with_delay_7_15 BIGINT,
    invoice_with_delay_15_30 BIGINT,
    invoice_with_delay_gt_30 BIGINT,
    analysis_date DATE,
    reporting_date DATE,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    delay_0_7_pct DOUBLE,
    delay_7_15_pct DOUBLE,
    delay_15_30_pct DOUBLE,
    delay_gt_30_pct DOUBLE,
    user_with_delay_0_7 BIGINT,
    user_with_delay_7_15 BIGINT,
    user_with_delay_15_30 BIGINT,
    user_with_delay_gt_30 BIGINT,
    user_delay_0_7_pct BIGINT,
    user_delay_7_15_pct BIGINT,
    user_delay_15_30_pct BIGINT,
    user_delay_gt_30_pct BIGINT,
    total_users BIGINT
)
WITH (type = 'DELTA');

-- 04/22: reporting.sre_raw_consumption_delay
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_raw_consumption_delay (
    pilot_id INTEGER,
    gid INTEGER,
    meter_type VARCHAR,
    fuel_type VARCHAR,
    user_with_delay_0_3 BIGINT,
    user_with_delay_4_7 BIGINT,
    user_with_delay_8_15 BIGINT,
    user_with_delay_gt_15 BIGINT,
    analysis_date DATE,
    reporting_date DATE,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    user_with_delay_0_3_pct DOUBLE,
    user_with_delay_4_7_pct DOUBLE,
    user_with_delay_8_15_pct DOUBLE,
    user_with_delay_gt_15_pct DOUBLE,
    total_active_users BIGINT,
    meter_with_delay_0_3 BIGINT,
    meter_with_delay_4_7 BIGINT,
    meter_with_delay_8_15 BIGINT,
    meter_with_delay_gt_15 BIGINT,
    meter_with_delay_0_3_pct BIGINT,
    meter_with_delay_4_7_pct BIGINT,
    meter_with_delay_8_15_pct BIGINT,
    meter_with_delay_gt_15_pct BIGINT,
    total_active_meters BIGINT
)
WITH (type = 'DELTA');

-- 05/22: reporting.sre_her_qc_data
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_her_qc_data (
    pilot_id VARCHAR,
    reporting_date VARCHAR,
    analysis_date VARCHAR,
    low_bc_duration_count BIGINT,
    high_bc_duration_count BIGINT,
    staleness_count BIGINT,
    solar_template_count BIGINT,
    solar_consistency_count BIGINT,
    solar_generation_count BIGINT,
    report_consistency_count BIGINT,
    itemization_count BIGINT,
    bill_change_consistency_count BIGINT,
    ev_itemization_count BIGINT,
    tou_template_count BIGINT,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    nbi_occurance_count BIGINT,
    nbi_value_count BIGINT,
    nbi_appliance_itemisation_count BIGINT,
    nbi_non_null_insight_count BIGINT,
    nbi_unicode_count BIGINT,
    nbi_extreme_insight_count BIGINT,
    nbi_seasonal_appliance_count BIGINT,
    overall_report_count BIGINT
)
WITH (type = 'DELTA');

-- 06/22: reporting.sre_queue_metrics_fact
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_queue_metrics_fact (
    analysis_date TIMESTAMP(6),
    reporting_date TIMESTAMP(6),
    event_timestamp TIMESTAMP(6),
    module_name VARCHAR,
    queue_name VARCHAR,
    queue_type VARCHAR,
    metric_name VARCHAR,
    metric_value DOUBLE,
    environment VARCHAR
)
WITH (type = 'DELTA');

-- 07/22: reporting.sre_total_active_users
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_total_active_users (
    pilot_id INTEGER,
    pilot_name VARCHAR,
    total_uuid INTEGER,
    enabled_uuid INTEGER,
    disabled_uuid INTEGER,
    active_uuid INTEGER,
    reporting_date DATE,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    analysis_date DATE,
    total_active_electric_uuid INTEGER,
    total_active_gas_uuid INTEGER,
    total_active_uuid INTEGER,
    total_active_user_meters INTEGER,
    total_active_electric_meters INTEGER,
    total_active_gas_meters INTEGER
)
WITH (type = 'DELTA');

-- 08/22: reporting.sre_cluster_eligible_users
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_cluster_eligible_users (
    analysis_date DATE,
    reporting_date DATE,
    pilot_id INTEGER,
    cluster_id VARCHAR,
    schedule_start DATE,
    schedule_end DATE,
    eligible_users BIGINT,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    measurement_type VARCHAR
)
WITH (type = 'DELTA');

-- 09/22: reporting.sre_email_daily_tracker
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_email_daily_tracker (
    pilot_id VARCHAR,
    analysis_date DATE,
    reporting_date DATE,
    email_type VARCHAR,
    delivery_mode VARCHAR,
    delivered_notification_id BIGINT,
    generated_notification_id BIGINT,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestap TIMESTAMP(6),
    invoice_ingested BIGINT
)
WITH (type = 'DELTA');

-- 10/22: reporting.sre_ingestion_audit
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_ingestion_audit (
    pilot_id INTEGER,
    pilot_name VARCHAR,
    ingestion_type VARCHAR,
    analysis_date DATE,
    reporting_date DATE,
    total_files_processed BIGINT,
    total_chunks_processed BIGINT,
    total_records_count BIGINT,
    total_success_record_count BIGINT,
    total_failure_record_count BIGINT,
    success_percentage DECIMAL(26,2),
    failure_percentage DECIMAL(26,2),
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 11/22: reporting.sre_invoice_statistics
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_invoice_statistics (
    pilot_id VARCHAR,
    meter_type VARCHAR,
    fuel_type VARCHAR,
    reporting_date DATE,
    analysis_date DATE,
    reporting_frequency VARCHAR,
    module_name VARCHAR,
    total_invoices INTEGER,
    failed_itemisation_pct DECIMAL(5,2),
    successful_itemisation_pct DECIMAL(5,2),
    delay_in_days INTEGER,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    trigger_flag VARCHAR DEFAULT 'SCHEDULED',
    failed_itemisation_cnt INTEGER,
    successful_itemisation_cnt INTEGER
)
WITH (type = 'DELTA');

-- 12/22: reporting.sre_quality_email_stats
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_quality_email_stats (
    pilot_id VARCHAR,
    reporting_date VARCHAR,
    analysis_date VARCHAR,
    bc_end_week_number VARCHAR,
    email_type VARCHAR,
    cnt_bills_ingested VARCHAR,
    cnt_bills_emails_sent VARCHAR,
    cnt_bills_emails_delivered VARCHAR,
    email_sent_pct DOUBLE,
    email_not_sent_pct DOUBLE,
    cnt_expected_invoices BIGINT,
    cnt_bills_item_available BIGINT,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 13/22: reporting.sre_failure_statistics
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_failure_statistics (
    pilot_id VARCHAR,
    meter_type VARCHAR,
    fuel_type VARCHAR,
    reporting_date DATE,
    analysis_date DATE,
    reporting_frequency VARCHAR,
    module_name VARCHAR,
    event_type VARCHAR,
    failure_reason VARCHAR,
    failure_percentage DECIMAL(5,2),
    delay_in_days INTEGER DEFAULT 2,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    trigger_flag VARCHAR DEFAULT 'SCHEDULED',
    failure_count INTEGER,
    total_failure_count INTEGER
)
WITH (type = 'DELTA');

-- 14/22: reporting.sre_her_schedule_tracker
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_her_schedule_tracker (
    analysis_date DATE,
    reporting_date DATE,
    pilot_id INTEGER,
    cluster_id VARCHAR,
    schedule_start DATE,
    schedule_end DATE,
    total_cluster_users BIGINT,
    total_missing_notification BIGINT,
    total_generated_notification BIGINT,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    measurement_type VARCHAR
)
WITH (type = 'DELTA');

-- 15/22: reporting.sre_quality_disagg
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_quality_disagg (
    pilot_id VARCHAR,
    reporting_date VARCHAR,
    analysis_date VARCHAR,
    meter_type VARCHAR,
    fuel_type VARCHAR,
    istou BOOLEAN DEFAULT false,
    appliances_kwh_variance_pct_1 DECIMAL(10,2) DEFAULT 0,
    appliances_kwh_variance_pct_2 DECIMAL(10,2) DEFAULT 0,
    total_cost_deviation_pct_1 DECIMAL(10,2) DEFAULT 0,
    total_cost_deviation_pct_2 DECIMAL(10,2) DEFAULT 0,
    cost_per_kwh_deviation_pct DECIMAL(10,2) DEFAULT 0,
    seasonal_appliance_usage_deviation_pct DECIMAL(10,2) DEFAULT 0,
    single_appliance_domination_deviation_pct DECIMAL(10,2) DEFAULT 0,
    missing_dwelliing_pct DECIMAL(10,2) DEFAULT 0,
    ao_pct_non_tou DECIMAL(10,2) DEFAULT 0,
    ac_pct_non_tou DECIMAL(10,2) DEFAULT 0,
    sh_pct_non_tou DECIMAL(10,2) DEFAULT 0,
    other_pct_non_tou DECIMAL(10,2) DEFAULT 0,
    solar_pct_non_tou DECIMAL(10,2) DEFAULT 0,
    missing_solar_pct_non_tou DECIMAL(10,2) DEFAULT 0,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 16/22: reporting.sre_daily_her_tracker
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_daily_her_tracker (
    pilot_id VARCHAR,
    cluster_id VARCHAR,
    measurement_type VARCHAR,
    schedule_start DATE,
    schedule_end DATE,
    total_eligible_users BIGINT,
    total_generated_notification_id BIGINT,
    total_scheduled_notification_id BIGINT,
    total_queued_notification_id BIGINT,
    total_printed_notification_id BIGINT,
    total_mailed_notification_id BIGINT,
    total_failed_notification_id BIGINT,
    reporting_date DATE,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    analysis_date DATE,
    total_swept_notification_id BIGINT
)
WITH (type = 'DELTA');

-- 17/22: reporting.sre_nbi_generic_tag_users
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_nbi_generic_tag_users (
    pilot_id INTEGER,
    analysis_date DATE,
    reporting_date DATE,
    total_nbi_users BIGINT,
    total_nbi_users_with_generic_tag BIGINT,
    pct_users_with_generic_tag DECIMAL(26,2),
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 18/22: reporting.sre_emr_metrics_fact
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_emr_metrics_fact (
    analysis_date TIMESTAMP(3) WITH TIME ZONE,
    reporting_date TIMESTAMP(3) WITH TIME ZONE,
    pilot_id VARCHAR,
    event_timestamp TIMESTAMP(3) WITH TIME ZONE,
    module_name VARCHAR,
    cluster_id VARCHAR,
    cluster_type VARCHAR,
    metric_name VARCHAR,
    metric_value VARCHAR,
    reason_code VARCHAR,
    environment VARCHAR,
    creation_time TIMESTAMP(3) WITH TIME ZONE,
    end_time TIMESTAMP(3) WITH TIME ZONE,
    steps_status VARCHAR
)
WITH (type = 'DELTA');

-- 19/22: reporting.sre_quality_reco_stats
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_quality_reco_stats (
    pilot_id VARCHAR,
    reporting_date DATE,
    analysis_date DATE,
    bc_end_week_number VARCHAR,
    appliance_name VARCHAR,
    fuel_type VARCHAR,
    email_type VARCHAR,
    metric_name VARCHAR,
    metric_notification_count BIGINT,
    total_notification_count BIGINT,
    notification_pct DOUBLE,
    user_count BIGINT,
    total_user_count BIGINT,
    user_pct DOUBLE,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 20/22: reporting.utility_billing_length_tracker
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.utility_billing_length_tracker (
    pilot_id INTEGER,
    bc_1_15_count BIGINT,
    bc_15_30_count BIGINT,
    bc_31_45_count BIGINT,
    bc_45_60_count BIGINT,
    bc_61_75_count BIGINT,
    bc_76_90_count BIGINT,
    bc_gt_90_count BIGINT,
    analysis_date DATE,
    reporting_date DATE,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 21/22: reporting.sre_her_schedule_errors
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_her_schedule_errors (
    analysis_date DATE,
    reporting_date DATE,
    pilot_id INTEGER,
    cluster_id VARCHAR,
    schedule_start DATE,
    schedule_end DATE,
    failure_reason VARCHAR,
    failure_count BIGINT,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6),
    measurement_type VARCHAR
)
WITH (type = 'DELTA');

-- 22/22: reporting.sre_email_failure_reasons
CREATE TABLE IF NOT EXISTS delta_prodeu.reporting.sre_email_failure_reasons (
    pilot_id VARCHAR,
    reporting_date VARCHAR,
    analysis_date VARCHAR,
    email_type VARCHAR,
    bc_end_week_number VARCHAR,
    failure_reason VARCHAR,
    failure_count BIGINT,
    total_failure_count BIGINT,
    failure_pct DOUBLE,
    -- Original DEFAULT now(): writer must supply this timestamp explicitly.
    last_updated_timestamp TIMESTAMP(6)
)
WITH (type = 'DELTA');

-- 2. SELECT grants for the 22 supplied tables

GRANT SELECT ON TABLE delta_prodeu.reporting.sre_nbi_generated_errors TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_ingestion_errors_statistic TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_invoice_delay_tracker TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_raw_consumption_delay TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_her_qc_data TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_queue_metrics_fact TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_total_active_users TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_cluster_eligible_users TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_email_daily_tracker TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_ingestion_audit TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_invoice_statistics TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_quality_email_stats TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_failure_statistics TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_her_schedule_tracker TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_quality_disagg TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_daily_her_tracker TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_nbi_generic_tag_users TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_emr_metrics_fact TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_quality_reco_stats TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.utility_billing_length_tracker TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_her_schedule_errors TO ROLE PUBLIC;
GRANT SELECT ON TABLE delta_prodeu.reporting.sre_email_failure_reasons TO ROLE PUBLIC;

-- 3. SELECT grants for other existing dashboard dependencies
-- These tables are intentionally not recreated by this script.

GRANT SELECT ON TABLE delta_prodeu.reporting.pilot_consolidated_product_type_events TO ROLE PUBLIC;
