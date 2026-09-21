-- BRE dashboard migration: missing-table DDL handoff
-- Inventory checked: 2026-09-12
-- Sources: bre_dashboard_sources_ca.sql and bre_dashboard_sources_eu.sql
--
-- All content is commented; this placeholder contains no executable statements.
-- Paste the original Redshift DDL beneath the corresponding table heading.
-- Keep pasted DDL commented until it has been converted and reviewed.
-- Starburst syntax conversion and SELECT grants will be prepared afterward.
-- The user will run the completed script with a service account.
-- Target role(s) and any required storage locations must be supplied before
-- preparing the executable creation/grant script; no defaults are assumed here.
--
-- Usage counts sum source-level chart references, not distinct dashboard tiles.
-- A chart can depend on multiple tables; do not sum counts across tables.
-- All source variable counts are zero. Documented extract dependencies count
-- as indirect usage. Zero-usage sources remain inventory-only for LookML unless
-- an agreed dashboard tile requires them.
--
-- Pilot-table replacement (already present in both Delta catalogs):
-- data_sanity.master_pilot_list -> reporting.pilot_consolidated_product_type_events
-- No DDL is requested for the original data_sanity table.

-- CA: prod-ca-cluster / delta_prodca
-- 22 required table names absent from both delta_prodca and bdw_prodca listings.
-- Existing required targets, excluded from this missing-table list:
--   delta_prodca.reporting.pilot_consolidated_product_type_events
--   delta_prodca.reporting.sre_quality_her_statistics
--   delta_prodca.public.her_automation_query_results
-- Presence is a metadata result, not a data-readiness or SELECT-grant guarantee.

-- CA 01/22
-- Target: delta_prodca.reporting.sre_nbi_generated_errors
-- Usage: 9 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_nbi_generated_errors definition

-- Drop table

-- DROP TABLE reporting.sre_nbi_generated_errors;

--DROP TABLE reporting.sre_nbi_generated_errors;
CREATE TABLE IF NOT EXISTS reporting.sre_nbi_generated_errors
(
	pilot_id INTEGER   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,total_nbi_users BIGINT   ENCODE RAW
	,total_users_with_200_errorcode BIGINT   ENCODE RAW
	,total_users_with_300_errorcode BIGINT   ENCODE RAW
	,nbi_error_pct NUMERIC(26,2)   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_nbi_generated_errors owner to ajaypawar;

-- CA 02/22
-- Target: delta_prodca.reporting.sre_ingestion_errors_statistic
-- Usage: 5 charts, 0 variables (includes 1 indirect extract chart)
-- Paste Redshift DDL here (commented):
-- reporting.sre_ingestion_errors_statistic definition

-- Drop table

-- DROP TABLE reporting.sre_ingestion_errors_statistic;

--DROP TABLE reporting.sre_ingestion_errors_statistic;
CREATE TABLE IF NOT EXISTS reporting.sre_ingestion_errors_statistic
(
	pilot_id INTEGER   ENCODE RAW
	,ingestion_type VARCHAR(128)   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,application_error_code VARCHAR(512)   ENCODE RAW
	,failed_record_count BIGINT   ENCODE RAW
	,total_failed_record_count BIGINT   ENCODE RAW
	,failure_percentage NUMERIC(26,2)   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_ingestion_errors_statistic owner to ajaypawar;


-- CA 03/22
-- Target: delta_prodca.reporting.sre_invoice_delay_tracker
-- Usage: 3 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_invoice_delay_tracker definition

-- Drop table

-- DROP TABLE reporting.sre_invoice_delay_tracker;

--DROP TABLE reporting.sre_invoice_delay_tracker;
CREATE TABLE IF NOT EXISTS reporting.sre_invoice_delay_tracker
(
	pilot_id INTEGER   ENCODE RAW
	,meter_type VARCHAR(3)   ENCODE RAW
	,fuel_type VARCHAR(8)   ENCODE RAW
	,total_invoice BIGINT   ENCODE RAW
	,invoice_with_delay_0_7 BIGINT   ENCODE RAW
	,invoice_with_delay_7_15 BIGINT   ENCODE RAW
	,invoice_with_delay_15_30 BIGINT   ENCODE RAW
	,invoice_with_delay_gt_30 BIGINT   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,delay_0_7_pct DOUBLE PRECISION   ENCODE RAW
	,delay_7_15_pct DOUBLE PRECISION   ENCODE RAW
	,delay_15_30_pct DOUBLE PRECISION   ENCODE RAW
	,delay_gt_30_pct DOUBLE PRECISION   ENCODE RAW
	,user_with_delay_0_7 BIGINT   ENCODE az64
	,user_with_delay_7_15 BIGINT   ENCODE az64
	,user_with_delay_15_30 BIGINT   ENCODE az64
	,user_with_delay_gt_30 BIGINT   ENCODE az64
	,user_delay_0_7_pct BIGINT   ENCODE az64
	,user_delay_7_15_pct BIGINT   ENCODE az64
	,user_delay_15_30_pct BIGINT   ENCODE az64
	,user_delay_gt_30_pct BIGINT   ENCODE az64
	,total_users BIGINT   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	analysis_date
	, reporting_date
	)
;
ALTER TABLE reporting.sre_invoice_delay_tracker owner to ajaypawar;


-- CA 04/22
-- Target: delta_prodca.reporting.sre_raw_consumption_delay
-- Usage: 3 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_raw_consumption_delay definition

-- Drop table

-- DROP TABLE reporting.sre_raw_consumption_delay;

--DROP TABLE reporting.sre_raw_consumption_delay;
CREATE TABLE IF NOT EXISTS reporting.sre_raw_consumption_delay
(
	pilot_id INTEGER   ENCODE RAW
	,gid INTEGER   ENCODE RAW
	,meter_type VARCHAR(3)   ENCODE RAW
	,fuel_type VARCHAR(8)   ENCODE RAW
	,user_with_delay_0_3 BIGINT   ENCODE RAW
	,user_with_delay_4_7 BIGINT   ENCODE RAW
	,user_with_delay_8_15 BIGINT   ENCODE RAW
	,user_with_delay_gt_15 BIGINT   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,user_with_delay_0_3_pct DOUBLE PRECISION   ENCODE RAW
	,user_with_delay_4_7_pct DOUBLE PRECISION   ENCODE RAW
	,user_with_delay_8_15_pct DOUBLE PRECISION   ENCODE RAW
	,user_with_delay_gt_15_pct DOUBLE PRECISION   ENCODE RAW
	,total_active_users BIGINT   ENCODE az64
	,meter_with_delay_0_3 BIGINT   ENCODE az64
	,meter_with_delay_4_7 BIGINT   ENCODE az64
	,meter_with_delay_8_15 BIGINT   ENCODE az64
	,meter_with_delay_gt_15 BIGINT   ENCODE az64
	,meter_with_delay_0_3_pct BIGINT   ENCODE az64
	,meter_with_delay_4_7_pct BIGINT   ENCODE az64
	,meter_with_delay_8_15_pct BIGINT   ENCODE az64
	,meter_with_delay_gt_15_pct BIGINT   ENCODE az64
	,total_active_meters BIGINT   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	analysis_date
	, reporting_date
	)
;
ALTER TABLE reporting.sre_raw_consumption_delay owner to ajaypawar;


-- CA 05/22
-- Target: delta_prodca.reporting.sre_her_qc_data
-- Usage: 1 chart, 0 variables
-- REVIEW: delta_prodca.reporting.sre_quality_her_qc_data already exists, but
-- uses qc_group_name/data_key/data_value rather than the source query's wide
-- metric columns. Confirm whether it replaces this table before creating it.
-- The replacement mapping has not been approved.
-- Paste Redshift DDL here (commented):
-- reporting.sre_her_qc_data definition

-- Drop table

-- DROP TABLE reporting.sre_her_qc_data;

--DROP TABLE reporting.sre_her_qc_data;
CREATE TABLE IF NOT EXISTS reporting.sre_her_qc_data
(
	pilot_id VARCHAR(256)   ENCODE lzo
	,reporting_date VARCHAR(256)   ENCODE RAW
	,analysis_date VARCHAR(256)   ENCODE RAW
	,low_bc_duration_count BIGINT   ENCODE az64
	,high_bc_duration_count BIGINT   ENCODE az64
	,staleness_count BIGINT   ENCODE az64
	,solar_template_count BIGINT   ENCODE az64
	,solar_consistency_count BIGINT   ENCODE az64
	,solar_generation_count BIGINT   ENCODE az64
	,report_consistency_count BIGINT   ENCODE az64
	,itemization_count BIGINT   ENCODE az64
	,bill_change_consistency_count BIGINT   ENCODE az64
	,ev_itemization_count BIGINT   ENCODE az64
	,tou_template_count BIGINT   ENCODE az64
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,nbi_occurance_count BIGINT   ENCODE az64
	,nbi_value_count BIGINT   ENCODE az64
	,nbi_appliance_itemisation_count BIGINT   ENCODE az64
	,nbi_non_null_insight_count BIGINT   ENCODE az64
	,nbi_unicode_count BIGINT   ENCODE az64
	,nbi_extreme_insight_count BIGINT   ENCODE az64
	,nbi_seasonal_appliance_count BIGINT   ENCODE az64
	,overall_report_count BIGINT   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_her_qc_data owner to ajaypawar;



-- CA 06/22
-- Target: delta_prodca.reporting.sre_queue_metrics_fact
-- Usage: 0 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_queue_metrics_fact definition

-- Drop table

-- DROP TABLE reporting.sre_queue_metrics_fact;

--DROP TABLE reporting.sre_queue_metrics_fact;
CREATE TABLE IF NOT EXISTS reporting.sre_queue_metrics_fact
(
	analysis_date TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
	,reporting_date TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
	,event_timestamp TIMESTAMP WITHOUT TIME ZONE   ENCODE RAW
	,module_name VARCHAR(50)   ENCODE lzo
	,queue_name VARCHAR(100)   ENCODE lzo
	,queue_type VARCHAR(50)   ENCODE lzo
	,metric_name VARCHAR(100)   ENCODE lzo
	,metric_value DOUBLE PRECISION   ENCODE RAW
	,environment VARCHAR(20)   ENCODE lzo
)
DISTSTYLE KEY
 DISTKEY (analysis_date)
 SORTKEY (
	event_timestamp
	)
;
ALTER TABLE reporting.sre_queue_metrics_fact owner to ajaypawar;



-- CA 07/22
-- Target: delta_prodca.reporting.sre_total_active_users
-- Usage: 1 chart, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_total_active_users definition

-- Drop table

-- DROP TABLE reporting.sre_total_active_users;

--DROP TABLE reporting.sre_total_active_users;
CREATE TABLE IF NOT EXISTS reporting.sre_total_active_users
(
	pilot_id INTEGER   ENCODE az64
	,pilot_name VARCHAR(255)   ENCODE RAW
	,total_uuid INTEGER   ENCODE az64
	,enabled_uuid INTEGER   ENCODE az64
	,disabled_uuid INTEGER   ENCODE az64
	,active_uuid INTEGER   ENCODE az64
	,reporting_date DATE   ENCODE az64
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,analysis_date DATE   ENCODE az64
	,total_active_electric_uuid INTEGER   ENCODE az64
	,total_active_gas_uuid INTEGER   ENCODE az64
	,total_active_uuid INTEGER   ENCODE az64
	,total_active_user_meters INTEGER   ENCODE az64
	,total_active_electric_meters INTEGER   ENCODE az64
	,total_active_gas_meters INTEGER   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	)
;
ALTER TABLE reporting.sre_total_active_users owner to ajaypawar;


-- CA 08/22
-- Target: delta_prodca.reporting.sre_cluster_eligible_users
-- Usage: 6 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_cluster_eligible_users definition

-- Drop table

-- DROP TABLE reporting.sre_cluster_eligible_users;

--DROP TABLE reporting.sre_cluster_eligible_users;
CREATE TABLE IF NOT EXISTS reporting.sre_cluster_eligible_users
(
	analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,pilot_id INTEGER   ENCODE RAW
	,cluster_id VARCHAR(36)   ENCODE RAW
	,schedule_start DATE   ENCODE RAW
	,schedule_end DATE   ENCODE RAW
	,eligible_users BIGINT   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,measurement_type VARCHAR(20)   ENCODE lzo
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	analysis_date
	, reporting_date
	)
;
ALTER TABLE reporting.sre_cluster_eligible_users owner to ajaypawar;



-- CA 09/22
-- Target: delta_prodca.reporting.sre_email_daily_tracker
-- Usage: 4 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_email_daily_tracker definition

-- Drop table

-- DROP TABLE reporting.sre_email_daily_tracker;

--DROP TABLE reporting.sre_email_daily_tracker;
CREATE TABLE IF NOT EXISTS reporting.sre_email_daily_tracker
(
	pilot_id VARCHAR(100)   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,email_type VARCHAR(24)   ENCODE RAW
	,delivery_mode VARCHAR(5)   ENCODE RAW
	,delivered_notification_id BIGINT   ENCODE RAW
	,generated_notification_id BIGINT   ENCODE RAW
	,last_updated_timestap TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,invoice_ingested BIGINT   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	analysis_date
	, reporting_date
	)
;
ALTER TABLE reporting.sre_email_daily_tracker owner to ajaypawar;




-- CA 10/22
-- Target: delta_prodca.reporting.sre_ingestion_audit
-- Usage: 9 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_ingestion_audit definition

-- Drop table

-- DROP TABLE reporting.sre_ingestion_audit;

--DROP TABLE reporting.sre_ingestion_audit;
CREATE TABLE IF NOT EXISTS reporting.sre_ingestion_audit
(
	pilot_id INTEGER   ENCODE RAW
	,pilot_name VARCHAR(100)   ENCODE RAW
	,ingestion_type VARCHAR(128)   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,total_files_processed BIGINT   ENCODE RAW
	,total_chunks_processed BIGINT   ENCODE RAW
	,total_records_count BIGINT   ENCODE RAW
	,total_success_record_count BIGINT   ENCODE RAW
	,total_failure_record_count BIGINT   ENCODE RAW
	,success_percentage NUMERIC(26,2)   ENCODE RAW
	,failure_percentage NUMERIC(26,2)   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_ingestion_audit owner to ajaypawar;



-- CA 11/22
-- Target: delta_prodca.reporting.sre_invoice_statistics
-- Usage: 10 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_invoice_statistics definition

-- Drop table

-- DROP TABLE reporting.sre_invoice_statistics;

--DROP TABLE reporting.sre_invoice_statistics;
CREATE TABLE IF NOT EXISTS reporting.sre_invoice_statistics
(
	pilot_id VARCHAR(50)   ENCODE lzo
	,meter_type VARCHAR(50)   ENCODE lzo
	,fuel_type VARCHAR(50)   ENCODE lzo
	,reporting_date DATE   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_frequency VARCHAR(50)   ENCODE lzo
	,module_name VARCHAR(50)   ENCODE lzo
	,total_invoices INTEGER   ENCODE az64
	,failed_itemisation_pct NUMERIC(5,2)   ENCODE az64
	,successful_itemisation_pct NUMERIC(5,2)   ENCODE az64
	,delay_in_days INTEGER   ENCODE az64
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,trigger_flag VARCHAR(50)  DEFAULT 'SCHEDULED'::character varying ENCODE lzo
	,failed_itemisation_cnt INTEGER   ENCODE az64
	,successful_itemisation_cnt INTEGER   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_invoice_statistics owner to ajaypawar;


-- CA 12/22
-- Target: delta_prodca.reporting.sre_quality_email_stats
-- Usage: 8 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_quality_email_stats definition

-- Drop table

-- DROP TABLE reporting.sre_quality_email_stats;

--DROP TABLE reporting.sre_quality_email_stats;
CREATE TABLE IF NOT EXISTS reporting.sre_quality_email_stats
(
	pilot_id VARCHAR(256)   ENCODE lzo
	,reporting_date VARCHAR(256)   ENCODE RAW
	,analysis_date VARCHAR(256)   ENCODE RAW
	,bc_end_week_number VARCHAR(10)   ENCODE lzo
	,email_type VARCHAR(50)   ENCODE lzo
	,cnt_bills_ingested VARCHAR(256)   ENCODE lzo
	,cnt_bills_emails_sent VARCHAR(256)   ENCODE lzo
	,cnt_bills_emails_delivered VARCHAR(256)   ENCODE lzo
	,email_sent_pct DOUBLE PRECISION   ENCODE RAW
	,email_not_sent_pct DOUBLE PRECISION   ENCODE RAW
	,cnt_expected_invoices BIGINT   ENCODE az64
	,cnt_bills_item_available BIGINT   ENCODE az64
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_quality_email_stats owner to ajaypawar;



-- CA 13/22
-- Target: delta_prodca.reporting.sre_failure_statistics
-- Usage: 4 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_failure_statistics definition

-- Drop table

-- DROP TABLE reporting.sre_failure_statistics;

--DROP TABLE reporting.sre_failure_statistics;
CREATE TABLE IF NOT EXISTS reporting.sre_failure_statistics
(
	pilot_id VARCHAR(50)   ENCODE lzo
	,meter_type VARCHAR(50)   ENCODE lzo
	,fuel_type VARCHAR(50)   ENCODE lzo
	,reporting_date DATE   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_frequency VARCHAR(50)   ENCODE lzo
	,module_name VARCHAR(50)   ENCODE lzo
	,event_type VARCHAR(50)   ENCODE lzo
	,failure_reason VARCHAR(255)   ENCODE lzo
	,failure_percentage NUMERIC(5,2)   ENCODE az64
	,delay_in_days INTEGER  DEFAULT 2 ENCODE az64
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,trigger_flag VARCHAR(50)  DEFAULT 'SCHEDULED'::character varying ENCODE lzo
	,failure_count INTEGER   ENCODE az64
	,total_failure_count INTEGER   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_failure_statistics owner to ajaypawar;



-- CA 14/22
-- Target: delta_prodca.reporting.sre_her_schedule_tracker
-- Usage: 5 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_her_schedule_tracker definition

-- Drop table

-- DROP TABLE reporting.sre_her_schedule_tracker;

--DROP TABLE reporting.sre_her_schedule_tracker;
CREATE TABLE IF NOT EXISTS reporting.sre_her_schedule_tracker
(
	analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,pilot_id INTEGER   ENCODE RAW
	,cluster_id VARCHAR(36)   ENCODE RAW
	,schedule_start DATE   ENCODE RAW
	,schedule_end DATE   ENCODE RAW
	,total_cluster_users BIGINT   ENCODE RAW
	,total_missing_notification BIGINT   ENCODE RAW
	,total_generated_notification BIGINT   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,measurement_type VARCHAR(20)   ENCODE lzo
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	analysis_date
	, reporting_date
	)
;
ALTER TABLE reporting.sre_her_schedule_tracker owner to ajaypawar;



-- CA 15/22
-- Target: delta_prodca.reporting.sre_quality_disagg
-- Usage: 3 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_quality_disagg definition

-- Drop table

-- DROP TABLE reporting.sre_quality_disagg;

--DROP TABLE reporting.sre_quality_disagg;
CREATE TABLE IF NOT EXISTS reporting.sre_quality_disagg
(
	pilot_id VARCHAR(255)   ENCODE RAW
	,reporting_date VARCHAR(255)   ENCODE RAW
	,analysis_date VARCHAR(255)   ENCODE lzo
	,meter_type VARCHAR(255)   ENCODE RAW
	,fuel_type VARCHAR(255)   ENCODE RAW
	,istou BOOLEAN  DEFAULT false ENCODE RAW
	,appliances_kwh_variance_pct_1 NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,appliances_kwh_variance_pct_2 NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,total_cost_deviation_pct_1 NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,total_cost_deviation_pct_2 NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,cost_per_kwh_deviation_pct NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,seasonal_appliance_usage_deviation_pct NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,single_appliance_domination_deviation_pct NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,missing_dwelliing_pct NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,ao_pct_non_tou NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,ac_pct_non_tou NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,sh_pct_non_tou NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,other_pct_non_tou NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,solar_pct_non_tou NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,missing_solar_pct_non_tou NUMERIC(10,2)  DEFAULT 0 ENCODE az64
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	pilot_id
	, reporting_date
	, meter_type
	, fuel_type
	)
;
ALTER TABLE reporting.sre_quality_disagg owner to ajaypawar;




-- CA 16/22
-- Target: delta_prodca.reporting.sre_daily_her_tracker
-- Usage: 3 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_daily_her_tracker definition

-- Drop table

-- DROP TABLE reporting.sre_daily_her_tracker;

--DROP TABLE reporting.sre_daily_her_tracker;
CREATE TABLE IF NOT EXISTS reporting.sre_daily_her_tracker
(
	pilot_id VARCHAR(180)   ENCODE RAW
	,cluster_id VARCHAR(36)   ENCODE RAW
	,measurement_type VARCHAR(23)   ENCODE RAW
	,schedule_start DATE   ENCODE RAW
	,schedule_end DATE   ENCODE RAW
	,total_eligible_users BIGINT   ENCODE RAW
	,total_generated_notification_id BIGINT   ENCODE RAW
	,total_scheduled_notification_id BIGINT   ENCODE RAW
	,total_queued_notification_id BIGINT   ENCODE RAW
	,total_printed_notification_id BIGINT   ENCODE RAW
	,total_mailed_notification_id BIGINT   ENCODE RAW
	,total_failed_notification_id BIGINT   ENCODE RAW
	,reporting_date DATE   ENCODE az64
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,analysis_date DATE   ENCODE az64
	,total_swept_notification_id BIGINT   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, cluster_id
	)
;
ALTER TABLE reporting.sre_daily_her_tracker owner to ajaypawar;




-- CA 17/22
-- Target: delta_prodca.reporting.sre_nbi_generic_tag_users
-- Usage: 2 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_nbi_generic_tag_users definition

-- Drop table

-- DROP TABLE reporting.sre_nbi_generic_tag_users;

--DROP TABLE reporting.sre_nbi_generic_tag_users;
CREATE TABLE IF NOT EXISTS reporting.sre_nbi_generic_tag_users
(
	pilot_id INTEGER   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,total_nbi_users BIGINT   ENCODE RAW
	,total_nbi_users_with_generic_tag BIGINT   ENCODE RAW
	,pct_users_with_generic_tag NUMERIC(26,2)   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_nbi_generic_tag_users owner to ajaypawar;




-- CA 18/22
-- Target: delta_prodca.reporting.sre_emr_metrics_fact
-- Usage: 0 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_emr_metrics_fact definition

-- Drop table

-- DROP TABLE reporting.sre_emr_metrics_fact;

--DROP TABLE reporting.sre_emr_metrics_fact;
CREATE TABLE IF NOT EXISTS reporting.sre_emr_metrics_fact
(
	analysis_date TIMESTAMP WITH TIME ZONE   ENCODE az64
	,reporting_date TIMESTAMP WITH TIME ZONE   ENCODE az64
	,pilot_id VARCHAR(50)   ENCODE lzo
	,event_timestamp TIMESTAMP WITH TIME ZONE   ENCODE az64
	,module_name VARCHAR(256)   ENCODE lzo
	,cluster_id VARCHAR(256)   ENCODE lzo
	,cluster_type VARCHAR(256)   ENCODE lzo
	,metric_name VARCHAR(256)   ENCODE lzo
	,metric_value VARCHAR(256)   ENCODE lzo
	,reason_code VARCHAR(256)   ENCODE lzo
	,environment VARCHAR(256)   ENCODE lzo
	,creation_time TIMESTAMP WITH TIME ZONE   ENCODE az64
	,end_time TIMESTAMP WITH TIME ZONE   ENCODE az64
	,steps_status VARCHAR(256)   ENCODE lzo
)
DISTSTYLE AUTO
;
ALTER TABLE reporting.sre_emr_metrics_fact owner to ajaypawar;



-- CA 19/22
-- Target: delta_prodca.reporting.sre_quality_reco_stats
-- Usage: 2 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_quality_reco_stats definition

-- Drop table

-- DROP TABLE reporting.sre_quality_reco_stats;

--DROP TABLE reporting.sre_quality_reco_stats;
CREATE TABLE IF NOT EXISTS reporting.sre_quality_reco_stats
(
	pilot_id VARCHAR(50)   ENCODE lzo
	,reporting_date DATE   ENCODE az64
	,analysis_date DATE   ENCODE RAW
	,bc_end_week_number VARCHAR(256)   ENCODE lzo
	,appliance_name VARCHAR(256)   ENCODE lzo
	,fuel_type VARCHAR(256)   ENCODE lzo
	,email_type VARCHAR(256)   ENCODE lzo
	,metric_name VARCHAR(256)   ENCODE lzo
	,metric_notification_count BIGINT   ENCODE az64
	,total_notification_count BIGINT   ENCODE az64
	,notification_pct DOUBLE PRECISION   ENCODE RAW
	,user_count BIGINT   ENCODE az64
	,total_user_count BIGINT   ENCODE az64
	,user_pct DOUBLE PRECISION   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	analysis_date
	, reporting_date
	)
;
ALTER TABLE reporting.sre_quality_reco_stats owner to ajaypawar;



-- CA 20/22
-- Target: delta_prodca.reporting.utility_billing_length_tracker
-- Usage: 0 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.utility_billing_length_tracker definition

-- Drop table

-- DROP TABLE reporting.utility_billing_length_tracker;

--DROP TABLE reporting.utility_billing_length_tracker;
CREATE TABLE IF NOT EXISTS reporting.utility_billing_length_tracker
(
	pilot_id INTEGER   ENCODE RAW
	,bc_1_15_count BIGINT   ENCODE RAW
	,bc_15_30_count BIGINT   ENCODE RAW
	,bc_31_45_count BIGINT   ENCODE RAW
	,bc_45_60_count BIGINT   ENCODE RAW
	,bc_61_75_count BIGINT   ENCODE RAW
	,bc_76_90_count BIGINT   ENCODE RAW
	,bc_gt_90_count BIGINT   ENCODE RAW
	,analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.utility_billing_length_tracker owner to ajaypawar;



-- CA 21/22
-- Target: delta_prodca.reporting.sre_her_schedule_errors
-- Usage: 2 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_her_schedule_errors definition

-- Drop table

-- DROP TABLE reporting.sre_her_schedule_errors;

--DROP TABLE reporting.sre_her_schedule_errors;
CREATE TABLE IF NOT EXISTS reporting.sre_her_schedule_errors
(
	analysis_date DATE   ENCODE RAW
	,reporting_date DATE   ENCODE RAW
	,pilot_id INTEGER   ENCODE RAW
	,cluster_id VARCHAR(36)   ENCODE RAW
	,schedule_start DATE   ENCODE RAW
	,schedule_end DATE   ENCODE RAW
	,failure_reason VARCHAR(256)   ENCODE RAW
	,failure_count BIGINT   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
	,measurement_type VARCHAR(20)   ENCODE lzo
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	analysis_date
	, reporting_date
	)
;
ALTER TABLE reporting.sre_her_schedule_errors owner to ajaypawar;



-- CA 22/22
-- Target: delta_prodca.reporting.sre_email_failure_reasons
-- Usage: 2 charts, 0 variables
-- Paste Redshift DDL here (commented):
-- reporting.sre_email_failure_reasons definition

-- Drop table

-- DROP TABLE reporting.sre_email_failure_reasons;

--DROP TABLE reporting.sre_email_failure_reasons;
CREATE TABLE IF NOT EXISTS reporting.sre_email_failure_reasons
(
	pilot_id VARCHAR(256)   ENCODE lzo
	,reporting_date VARCHAR(256)   ENCODE RAW
	,analysis_date VARCHAR(256)   ENCODE RAW
	,email_type VARCHAR(256)   ENCODE lzo
	,bc_end_week_number VARCHAR(10)   ENCODE lzo
	,failure_reason VARCHAR(1000)   ENCODE lzo
	,failure_count BIGINT   ENCODE az64
	,total_failure_count BIGINT   ENCODE az64
	,failure_pct DOUBLE PRECISION   ENCODE RAW
	,last_updated_timestamp TIMESTAMP WITHOUT TIME ZONE  DEFAULT ('now'::character varying)::timestamp with time zone ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (pilot_id)
 SORTKEY (
	reporting_date
	, analysis_date
	)
;
ALTER TABLE reporting.sre_email_failure_reasons owner to ajaypawar;




-- EU: prod-eu-cluster / delta_prodeu
-- No missing tables: all 16 required targets are present in delta_prodeu,
-- including reporting.pilot_consolidated_product_type_events as the pilot
-- replacement. Both delta_prodeu and bdw_prodeu were checked.
-- No CREATE TABLE placeholders are needed for EU from this inventory.
-- SELECT grants for EU will be prepared with the CA grants once target roles
-- are supplied. Existing tables do not need to be recreated for grants.
