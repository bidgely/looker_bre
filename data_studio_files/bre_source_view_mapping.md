# BRE source-to-view mapping

The migration uses separate `bre_ca` and `bre_eu` models with one `bre_dashboard` explore in each. Both models reuse the source SQL and field definitions under `views/bre/`. This document covers source replacement; dashboard tile definitions are the next stage.

| Model | Connection | Catalog | Available families |
|---|---|---|---:|
| `bre_ca` | `starburst_prod_ca` | `delta_prodca` | 19 |
| `bre_eu` | `starburst_prod_eu` | `delta_prodeu` | 13 |

There are 20 source-family views, one shared pilot view, one shared field-definition base, and two regional routing views: 24 views and two models. The 12 families used in both environments have one implementation each. The seven CA-only families cover HER/NBI; billing-cycle length is exposed only in EU because its CA source has zero charts.

## Query controls

All field names below use the explore namespace `bre_dashboard.`. Choose `source_family` using the exact stored value in the family table. A tile must save its source selection; the explore default is `ingestionaudit`. Only that family's SQL is selected. Other families' fields and measures return NULL.

`period` accepts `Daily`, `Weekly`, or `Monthly`, defaulting to `Daily`. The three HER period families select the corresponding original preaggregated rows. For other families, select `period_date` to group analysis dates by the chosen period; the parameter alone does not aggregate a result. Weeks start on Monday. `analysis_date` and `reporting_date` remain separate.

`failure_scope` applies only to Processing Failures. It accepts `All` or `Top Three`, defaulting to All in CA and Top Three in EU. To replace a particular source, save the setting specified below rather than relying on the model default.

## Source families and preserved grain

| Family / source view | Selector value | Environments | Grain and behavior |
|---|---|---|---|
| [Active Users](../views/bre/bre_active_users.view.lkml) | `activeusers` | CA, EU | Latest reporting-date snapshot per pilot; counts are snapshots, not additive across dates. |
| [Pilot Reporting Dates](../views/bre/bre_pilot_reporting.view.lkml) | `pilotreporting` | CA, EU | One row per pilot; independent maximum analysis and reporting timestamps across the original six tables. |
| [Ingestion Audit](../views/bre/bre_ingestion_audit.view.lkml) | `ingestionaudit` | CA, EU | Original pilot, analysis/reporting date and ingestion-type rows; no additional deduplication. |
| [Ingestion Failures](../views/bre/bre_ingestion_failures.view.lkml) | `ingestionfailures` | CA, EU | Original error-code rows; rank within analysis date, pilot and ingestion type. |
| [Post-Ingestion Quality](../views/bre/bre_post_ingestion.view.lkml) | `postingestion` | CA, EU | Delay rows by pilot, dates, meter/fuel and ingestion type. Original overlap-error join multiplicity is preserved. |
| [Invoice Statistics](../views/bre/bre_invoice_statistics.view.lkml) | `invoicestatistics` | CA, EU | Latest update per pilot, meter, fuel, module, analysis date and trigger; SCHEDULED additionally partitions by delay. |
| [Disagg Quality](../views/bre/bre_disagg_quality.view.lkml) | `disaggquality` | CA, EU | Original quality rows by pilot, dates, meter, fuel and TOU status. |
| [Processing Failures](../views/bre/bre_processing_failures.view.lkml) | `processingfailures` | CA, EU | Original failure-detail rows; rank by percentage within analysis date, pilot and module, before optional top-three filtering. |
| [Email Statistics](../views/bre/bre_email_statistics.view.lkml) | `emailstatistics` | CA, EU | Original email-quality rows by pilot, dates, email type and billing-cycle end week. |
| [Email Daily Tracker](../views/bre/bre_email_tracker.view.lkml) | `emailtracker` | CA, EU | Original daily rows by pilot, email type and delivery mode. |
| [Email Recommendation Quality](../views/bre/bre_email_recommendations.view.lkml) | `emailrecommendations` | CA, EU | Original rows by pilot, dates, billing week, appliance, fuel, email type and metric; denominators repeat across detail rows. |
| [Email Failures](../views/bre/bre_email_failures.view.lkml) | `emailfailures` | CA, EU | Original failure-reason rows; rank by count within original analysis date, pilot and email type. |
| [HER Generation](../views/bre/bre_her_generation.view.lkml) | `hergeneration` | CA | Pilot, cluster, fuel, schedule and selected period; period eligibility uses MAX, generation uses SUM. |
| [HER Schedule Status](../views/bre/bre_her_schedules.view.lkml) | `herschedules` | CA | Latest schedule snapshot; pilot 10037 retains quarterly schedule segmentation before schedule aggregation. |
| [HER Generation Failures](../views/bre/bre_her_failures.view.lkml) | `herfailures` | CA | Pilot, cluster, schedule, fuel, reason and both analysis/reporting periods; ranking retains the original partition. |
| [HER Non-PSEG Quality](../views/bre/bre_her_non_pseg_quality.view.lkml) | `hernonpsegquality` | CA | Original supplied quality counts by pilot and analysis/reporting dates; separate from automation quality. |
| [HER Automation Quality](../views/bre/bre_her_automation_quality.view.lkml) | `herautomationquality` | CA | Bad-check counts grouped by pilot and both analysis/reporting periods; reporting day is epoch day plus one. |
| [NBI Generation](../views/bre/bre_nbi_generation.view.lkml) | `nbigeneration` | CA | Original pilot and analysis/reporting date rows with generation and error counts. |
| [NBI Generic Tags](../views/bre/bre_nbi_generic_tags.view.lkml) | `nbigenerictags` | CA | Original pilot and analysis/reporting date rows with generic-tag counts and supplied percentage. |
| [Billing-Cycle Length](../views/bre/bre_billing_length.view.lkml) | `billinglength` | EU | Original pilot and analysis/reporting date rows with billing-length bands and the original OPOWER pilot classification. |

## Original source coverage

Each original entry is listed separately, including duplicate connectors, extract references, and exclusions. Chart counts are the supplied source-usage counts; they are not distinct dashboard-tile counts and must not be added across joined sources. All supplied variable counts are zero.

### CA

41 source entries; 31 active non-Google-Analytics entries map to 19 families.

| Original source and line | Connector | Charts | Replacement family | Required setting / status |
|---|---|---:|---|---|
| [SRE NBI Engine Daily Run Statistics — line 1](bre_dashboard_sources_ca.sql#L1) | Amazon Redshift | 2 | `nbi_generation` | Default Daily; select Weekly/Monthly as required |
| [SRE Post Ingestion Data Quality — line 24](bre_dashboard_sources_ca.sql#L24) | Apps Script Addon | 1 | `post_ingestion` | Default Daily; select Weekly/Monthly as required |
| [SRE HER Quality Statistics (non-PSEG) — line 110](bre_dashboard_sources_ca.sql#L110) | Amazon Redshift | 1 | `her_non_pseg_quality` | Default Daily; select Weekly/Monthly as required |
| [SRE SQS Queue Health Metrics By Day — line 153](bre_dashboard_sources_ca.sql#L153) | Amazon Redshift | 0 | — | Inventory only: zero charts |
| [SRE All Active Users — line 172](bre_dashboard_sources_ca.sql#L172) | Apps Script Addon | 1 | `active_users` | Default Daily; select Weekly/Monthly as required |
| [User Analytics — line 203](bre_dashboard_sources_ca.sql#L203) | Google Analytics | 11 | — | Excluded: Google Analytics marked not required |
| [SRE Master Pilot List — line 207](bre_dashboard_sources_ca.sql#L207) | Apps Script Addon | 1 | `pilot_reporting` | Default Daily; select Weekly/Monthly as required |
| [SRE Ingestion Failure Statistics — line 286](bre_dashboard_sources_ca.sql#L286) | Apps Script Addon | 1 | `ingestion_failures` | Default Daily; select Weekly/Monthly as required |
| [SRE Failure Statistics — line 321](bre_dashboard_sources_ca.sql#L321) | Amazon Redshift | 1 | `processing_failures` | failure_scope = All |
| [SRE Post Ingestion Data Quality — line 357](bre_dashboard_sources_ca.sql#L357) | Amazon Redshift | 2 | `post_ingestion` | Default Daily; select Weekly/Monthly as required |
| [SRE HER Cluster Specific Generation Stats — line 443](bre_dashboard_sources_ca.sql#L443) | Apps Script Addon | 2 | `her_generation` | period = Daily / Weekly / Monthly; select exactly one |
| [SRE Quality Disagg — line 565](bre_dashboard_sources_ca.sql#L565) | Amazon Redshift | 1 | `disagg_quality` | Default Daily; select Weekly/Monthly as required |
| [SRE Email Statistics — line 588](bre_dashboard_sources_ca.sql#L588) | Apps Script Addon | 4 | `email_statistics` | Default Daily; select Weekly/Monthly as required |
| [SRE HER Schedule Specific Statistics — line 611](bre_dashboard_sources_ca.sql#L611) | Apps Script Addon | 3 | `her_schedules` | Default Daily; select Weekly/Monthly as required |
| [SRE NBI Gen Quality Generic Tag — line 675](bre_dashboard_sources_ca.sql#L675) | Amazon Redshift | 1 | `nbi_generic_tags` | Default Daily; select Weekly/Monthly as required |
| [SRE SQS Queue Metrics By Day — line 698](bre_dashboard_sources_ca.sql#L698) | Amazon Redshift | 0 | — | Inventory only: zero charts |
| [SRE HER Generation Statistics — line 725](bre_dashboard_sources_ca.sql#L725) | Amazon Redshift | 0 | — | Inventory only: zero charts |
| [SRE NBI Gen Quality Generic Tag — line 748](bre_dashboard_sources_ca.sql#L748) | Apps Script Addon | 1 | `nbi_generic_tags` | Default Daily; select Weekly/Monthly as required |
| [SRE Quality Disagg — line 771](bre_dashboard_sources_ca.sql#L771) | Apps Script Addon | 1 | `disagg_quality` | Default Daily; select Weekly/Monthly as required |
| [SRE Ingestion Failure Statistics #1 — line 794](bre_dashboard_sources_ca.sql#L794) | Extract Data | 1 | `ingestion_failures` | Reuse underlying Apps Script failure family |
| [SRE Email Statistics — line 798](bre_dashboard_sources_ca.sql#L798) | Amazon Redshift | 1 | `email_statistics` | Default Daily; select Weekly/Monthly as required |
| [SRE Invoice Statistics — line 821](bre_dashboard_sources_ca.sql#L821) | Apps Script Addon | 9 | `invoice_statistics` | Default Daily; select Weekly/Monthly as required |
| [SRE HER Quality Statistics — line 881](bre_dashboard_sources_ca.sql#L881) | Amazon Redshift | 1 | `her_automation_quality` | period = Daily / Weekly / Monthly; select exactly one |
| [SRE NBI EMR Metrics — line 993](bre_dashboard_sources_ca.sql#L993) | Amazon Redshift | 0 | — | Inventory only: zero charts |
| [SRE Email Reco Statistics — line 1027](bre_dashboard_sources_ca.sql#L1027) | Amazon Redshift | 1 | `email_recommendations` | Default Daily; select Weekly/Monthly as required |
| [SRE Quality Disagg - CA — line 1048](bre_dashboard_sources_ca.sql#L1048) | Amazon Redshift | 1 | `disagg_quality` | Default Daily; select Weekly/Monthly as required |
| [SRE Billing Cycle Length — line 1071](bre_dashboard_sources_ca.sql#L1071) | Apps Script Addon | 0 | — | Inventory only: zero charts |
| [SRE Email Statistics — line 1080](bre_dashboard_sources_ca.sql#L1080) | Amazon Redshift | 2 | `email_statistics` | Default Daily; select Weekly/Monthly as required |
| [SRE Ingestion Audit — line 1103](bre_dashboard_sources_ca.sql#L1103) | Amazon Redshift | 1 | `ingestion_audit` | Default Daily; select Weekly/Monthly as required |
| [SRE Ingestion Audit — line 1126](bre_dashboard_sources_ca.sql#L1126) | Apps Script Addon | 7 | `ingestion_audit` | Default Daily; select Weekly/Monthly as required |
| [SRE HER Cluster Specific Failure Rate — line 1149](bre_dashboard_sources_ca.sql#L1149) | Apps Script Addon | 2 | `her_failures` | period = Daily / Weekly / Monthly; select exactly one |
| [SRE Email Failure Statistics — line 1208](bre_dashboard_sources_ca.sql#L1208) | Apps Script Addon | 2 | `email_failures` | Default Daily; select Weekly/Monthly as required |
| [SRE SQS Metrics By Hour — line 1243](bre_dashboard_sources_ca.sql#L1243) | Amazon Redshift | 0 | — | Inventory only: zero charts |
| [SRE SQS Queue Metrics — line 1267](bre_dashboard_sources_ca.sql#L1267) | Amazon Redshift | 0 | — | Inventory only: zero charts |
| [SRE Email Reco Statistics — line 1271](bre_dashboard_sources_ca.sql#L1271) | Apps Script Addon | 1 | `email_recommendations` | Default Daily; select Weekly/Monthly as required |
| [SRE NBI Engine Daily Run Statistics — line 1292](bre_dashboard_sources_ca.sql#L1292) | Apps Script Addon | 6 | `nbi_generation` | Default Daily; select Weekly/Monthly as required |
| [SRE_NBI_FALED_JOB_COUNT — line 1315](bre_dashboard_sources_ca.sql#L1315) | Amazon Redshift | 0 | — | Inventory only: zero charts |
| [SRE Email Daily Tracker — line 1368](bre_dashboard_sources_ca.sql#L1368) | Amazon Redshift | 3 | `email_tracker` | Default Daily; select Weekly/Monthly as required |
| [SRE Failure Statistics — line 1391](bre_dashboard_sources_ca.sql#L1391) | Apps Script Addon | 3 | `processing_failures` | failure_scope = Top Three |
| [SRE Ingestion Failure Statistics — line 1429](bre_dashboard_sources_ca.sql#L1429) | Extract Data | 0 | — | Inventory only: zero charts |
| [HER Aggregated Generation Stats — line 1433](bre_dashboard_sources_ca.sql#L1433) | Apps Script Addon | 3 | `her_generation` | period = Daily / Weekly / Monthly; select exactly one |
### EU

14 source entries; 13 active non-Google-Analytics entries map to 13 families.

| Original source and line | Connector | Charts | Replacement family | Required setting / status |
|---|---|---:|---|---|
| [User Analytics — line 1](bre_dashboard_sources_eu.sql#L1) | Google Analytics | 8 | — | Excluded: Google Analytics marked not required |
| [SRE Billing Cycle Length — line 5](bre_dashboard_sources_eu.sql#L5) | Amazon Redshift | 1 | `billing_length` | Default Daily; select Weekly/Monthly as required |
| [SRE Post Ingestion Data Quality — line 14](bre_dashboard_sources_eu.sql#L14) | Amazon Redshift | 3 | `post_ingestion` | Default Daily; select Weekly/Monthly as required |
| [SRE Master Pilot List — line 100](bre_dashboard_sources_eu.sql#L100) | Amazon Redshift | 1 | `pilot_reporting` | Default Daily; select Weekly/Monthly as required |
| [SRE Ingestion Audit — line 179](bre_dashboard_sources_eu.sql#L179) | Amazon Redshift | 7 | `ingestion_audit` | Default Daily; select Weekly/Monthly as required |
| [SRE Email Statistics — line 202](bre_dashboard_sources_eu.sql#L202) | Amazon Redshift | 6 | `email_statistics` | Default Daily; select Weekly/Monthly as required |
| [SRE Ingestion Failure Statistics — line 225](bre_dashboard_sources_eu.sql#L225) | Amazon Redshift | 2 | `ingestion_failures` | Default Daily; select Weekly/Monthly as required |
| [SRE Email Reco Statistics — line 261](bre_dashboard_sources_eu.sql#L261) | Amazon Redshift | 2 | `email_recommendations` | Default Daily; select Weekly/Monthly as required |
| [SRE Email Daily Tracker — line 282](bre_dashboard_sources_eu.sql#L282) | Amazon Redshift | 3 | `email_tracker` | Default Daily; select Weekly/Monthly as required |
| [SRE Invoice Statistics — line 305](bre_dashboard_sources_eu.sql#L305) | Amazon Redshift | 9 | `invoice_statistics` | Default Daily; select Weekly/Monthly as required |
| [SRE All Active Users — line 365](bre_dashboard_sources_eu.sql#L365) | Amazon Redshift | 2 | `active_users` | Default Daily; select Weekly/Monthly as required |
| [SRE Email Failure Statistics — line 396](bre_dashboard_sources_eu.sql#L396) | Amazon Redshift | 3 | `email_failures` | Default Daily; select Weekly/Monthly as required |
| [SRE Failure Statistics — line 431](bre_dashboard_sources_eu.sql#L431) | Amazon Redshift | 3 | `processing_failures` | failure_scope = Top Three |
| [SRE Quality Disagg — line 469](bre_dashboard_sources_eu.sql#L469) | Amazon Redshift | 3 | `disagg_quality` | Default Daily; select Weekly/Monthly as required |

## Field naming and aggregation

Shared dimensions retain their source names where possible: `pilot_id`, `ingestion_type`, `meter_type`, `fuel_type`, `module_name`, `email_type`, `bc_end_week_number`, `cluster_id`, schedule dates, and failure/detail attributes. A field is NULL when its selected family does not supply it.

| Original field or expression | Explore field | Conversion / meaning |
|---|---|---|
| Numeric or string `pilot_id` | `pilot_id` | Explicit VARCHAR casts for regional joins and labels |
| Pilot-directory name | `pilot_name` | Original rule: use the substring starting at `(` when present |
| Pilot ID + separator + pilot name | `pilot_id_name` | Original label; left-joined sources retain their empty-name fallback |
| Fact-source `pilot_name` in active users or ingestion audit | `source_pilot_name` | Original source text, separate from the cleaned directory name |
| `analysis_date`, `reporting_date` | Same names | CAST to DATE; no time-zone shifting |
| Original analysis/reporting value | `source_analysis_value`, `source_reporting_value` | Text representation before DATE normalization, including timestamps where supplied |
| `rank`, `rn`, `rnk` | `source_rank` | Original ROW_NUMBER output, not a recomputed rank after dashboard filters |
| `Period` / `period` in HER sources | `source_period` | Hidden diagnostic dimension; use the `period` parameter to choose rows |
| `last_updated_timestap` in email tracker | `last_updated_timestamp` | Original source spelling retained in SQL |
| Replacement directory `time_zone` | `time_zone` | Metadata only; does not shift source reporting dates |

Family-specific numeric dimensions use `<family>_<source_column>`. Their sum measures end in `_sum`; explicitly unweighted percentage averages end in `_average`. Source percentages are not rescaled and are not replaced by ratios of totals. Values such as repeated failure denominators, recommendation denominators and overlapping billing-cycle counts remain detail dimensions without unrestricted sum measures.

The three text count columns in Email Statistics are exposed as BIGINT dimensions/measures. The corresponding `_source_text` dimensions preserve their original text. CAST is strict; invalid incoming dates/counts are not silently converted to NULL. `source_row_count` counts source rows, not users.

The field tables below cover the source-output columns and their exact replacements. All names are relative to `bre_dashboard.`. Generated pilot labels map as above for every active family except the original billing-length query, which did not return a label; that family receives it as additional metadata. The top-three Processing Failures source's extra cleaned `pilot_name` maps to the common `pilot_name` field.

<details>
<summary>Active Users field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `pilot_name` | `source_pilot_name` | — |
| `total_uuid` | `active_users_total_uuid` | `active_users_total_uuid_sum` |
| `enabled_uuid` | `active_users_enabled_uuid` | `active_users_enabled_uuid_sum` |
| `disabled_uuid` | `active_users_disabled_uuid` | `active_users_disabled_uuid_sum` |
| `active_uuid` | `active_users_active_uuid` | `active_users_active_uuid_sum` |
| `reporting_date` | `reporting_date` | — |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `analysis_date` | `analysis_date` | — |
| `total_active_electric_uuid` | `active_users_total_active_electric_uuid` | `active_users_total_active_electric_uuid_sum` |
| `total_active_gas_uuid` | `active_users_total_active_gas_uuid` | `active_users_total_active_gas_uuid_sum` |
| `total_active_uuid` | `active_users_total_active_uuid` | `active_users_total_active_uuid_sum` |
| `total_active_user_meters` | `active_users_total_active_user_meters` | `active_users_total_active_user_meters_sum` |
| `total_active_electric_meters` | `active_users_total_active_electric_meters` | `active_users_total_active_electric_meters_sum` |
| `total_active_gas_meters` | `active_users_total_active_gas_meters` | `active_users_total_active_gas_meters_sum` |
| `rn` | `source_rank` | — |

</details>

<details>
<summary>Pilot Reporting Dates field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |

</details>

<details>
<summary>Ingestion Audit field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `pilot_name` | `source_pilot_name` | — |
| `ingestion_type` | `ingestion_type` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `total_files_processed` | `ingestion_audit_total_files_processed` | `ingestion_audit_total_files_processed_sum` |
| `total_chunks_processed` | `ingestion_audit_total_chunks_processed` | `ingestion_audit_total_chunks_processed_sum` |
| `total_records_count` | `ingestion_audit_total_records_count` | `ingestion_audit_total_records_count_sum` |
| `total_success_record_count` | `ingestion_audit_total_success_record_count` | `ingestion_audit_total_success_record_count_sum` |
| `total_failure_record_count` | `ingestion_audit_total_failure_record_count` | `ingestion_audit_total_failure_record_count_sum` |
| `success_percentage` | `ingestion_audit_success_percentage` | `ingestion_audit_success_percentage_average` |
| `failure_percentage` | `ingestion_audit_failure_percentage` | `ingestion_audit_failure_percentage_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |

</details>

<details>
<summary>Ingestion Failures field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `ingestion_type` | `ingestion_type` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `application_error_code` | `application_error_code` | — |
| `failed_record_count` | `ingestion_failures_failed_record_count` | `ingestion_failures_failed_record_count_sum` |
| `total_failed_record_count` | `ingestion_failures_total_failed_record_count` | — |
| `failure_percentage` | `ingestion_failures_failure_percentage` | `ingestion_failures_failure_percentage_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `rank` | `source_rank` | — |

</details>

<details>
<summary>Post-Ingestion Quality field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `meter_type` | `meter_type` | — |
| `fuel_type` | `fuel_type` | — |
| `ingestion_type` | `ingestion_type` | — |
| `user_raw_with_delay_0_3` | `post_ingestion_user_raw_with_delay_0_3` | `post_ingestion_user_raw_with_delay_0_3_sum` |
| `user_raw_with_delay_4_7` | `post_ingestion_user_raw_with_delay_4_7` | `post_ingestion_user_raw_with_delay_4_7_sum` |
| `user_raw_with_delay_8_15` | `post_ingestion_user_raw_with_delay_8_15` | `post_ingestion_user_raw_with_delay_8_15_sum` |
| `user_raw_with_delay_gt_15` | `post_ingestion_user_raw_with_delay_gt_15` | `post_ingestion_user_raw_with_delay_gt_15_sum` |
| `user_invoice_with_delay_0_7` | `post_ingestion_user_invoice_with_delay_0_7` | `post_ingestion_user_invoice_with_delay_0_7_sum` |
| `user_invoice_with_delay_7_15` | `post_ingestion_user_invoice_with_delay_7_15` | `post_ingestion_user_invoice_with_delay_7_15_sum` |
| `user_invoice_with_delay_15_30` | `post_ingestion_user_invoice_with_delay_15_30` | `post_ingestion_user_invoice_with_delay_15_30_sum` |
| `user_invoice_with_delay_gt_30` | `post_ingestion_user_invoice_with_delay_gt_30` | `post_ingestion_user_invoice_with_delay_gt_30_sum` |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `overlapping_bc_count` | `post_ingestion_overlapping_bc_count` | — |

</details>

<details>
<summary>Invoice Statistics field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `meter_type` | `meter_type` | — |
| `fuel_type` | `fuel_type` | — |
| `reporting_date` | `reporting_date` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_frequency` | `reporting_frequency` | — |
| `module_name` | `module_name` | — |
| `total_invoices` | `invoice_statistics_total_invoices` | `invoice_statistics_total_invoices_sum` |
| `failed_itemisation_pct` | `invoice_statistics_failed_itemisation_pct` | `invoice_statistics_failed_itemisation_pct_average` |
| `successful_itemisation_pct` | `invoice_statistics_successful_itemisation_pct` | `invoice_statistics_successful_itemisation_pct_average` |
| `delay_in_days` | `delay_in_days` | — |
| `trigger_flag` | `trigger_flag` | — |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `rnk` | `source_rank` | — |

</details>

<details>
<summary>Disagg Quality field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `reporting_date` | `reporting_date` | — |
| `analysis_date` | `analysis_date` | — |
| `meter_type` | `meter_type` | — |
| `fuel_type` | `fuel_type` | — |
| `istou` | `istou` | — |
| `appliances_kwh_variance_pct_1` | `disagg_quality_appliances_kwh_variance_pct_1` | `disagg_quality_appliances_kwh_variance_pct_1_average` |
| `appliances_kwh_variance_pct_2` | `disagg_quality_appliances_kwh_variance_pct_2` | `disagg_quality_appliances_kwh_variance_pct_2_average` |
| `total_cost_deviation_pct_1` | `disagg_quality_total_cost_deviation_pct_1` | `disagg_quality_total_cost_deviation_pct_1_average` |
| `total_cost_deviation_pct_2` | `disagg_quality_total_cost_deviation_pct_2` | `disagg_quality_total_cost_deviation_pct_2_average` |
| `cost_per_kwh_deviation_pct` | `disagg_quality_cost_per_kwh_deviation_pct` | `disagg_quality_cost_per_kwh_deviation_pct_average` |
| `seasonal_appliance_usage_deviation_pct` | `disagg_quality_seasonal_appliance_usage_deviation_pct` | `disagg_quality_seasonal_appliance_usage_deviation_pct_average` |
| `single_appliance_domination_deviation_pct` | `disagg_quality_single_appliance_domination_deviation_pct` | `disagg_quality_single_appliance_domination_deviation_pct_average` |
| `missing_dwelliing_pct` | `disagg_quality_missing_dwelliing_pct` | `disagg_quality_missing_dwelliing_pct_average` |
| `ao_pct_non_tou` | `disagg_quality_ao_pct_non_tou` | `disagg_quality_ao_pct_non_tou_average` |
| `ac_pct_non_tou` | `disagg_quality_ac_pct_non_tou` | `disagg_quality_ac_pct_non_tou_average` |
| `sh_pct_non_tou` | `disagg_quality_sh_pct_non_tou` | `disagg_quality_sh_pct_non_tou_average` |
| `other_pct_non_tou` | `disagg_quality_other_pct_non_tou` | `disagg_quality_other_pct_non_tou_average` |
| `solar_pct_non_tou` | `disagg_quality_solar_pct_non_tou` | `disagg_quality_solar_pct_non_tou_average` |
| `missing_solar_pct_non_tou` | `disagg_quality_missing_solar_pct_non_tou` | `disagg_quality_missing_solar_pct_non_tou_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |

</details>

<details>
<summary>Processing Failures field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `meter_type` | `meter_type` | — |
| `fuel_type` | `fuel_type` | — |
| `reporting_date` | `reporting_date` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_frequency` | `reporting_frequency` | — |
| `module_name` | `module_name` | — |
| `event_type` | `event_type` | — |
| `failure_reason` | `failure_reason` | — |
| `failure_percentage` | `processing_failures_failure_percentage` | `processing_failures_failure_percentage_average` |
| `delay_in_days` | `delay_in_days` | — |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `trigger_flag` | `trigger_flag` | — |
| `failure_count` | `processing_failures_failure_count` | `processing_failures_failure_count_sum` |
| `total_failure_count` | `processing_failures_total_failure_count` | — |
| `rank` | `source_rank` | — |

</details>

<details>
<summary>Email Statistics field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `reporting_date` | `reporting_date` | — |
| `analysis_date` | `analysis_date` | — |
| `bc_end_week_number` | `bc_end_week_number` | — |
| `email_type` | `email_type` | — |
| `cnt_bills_ingested` | `email_statistics_cnt_bills_ingested` | `email_statistics_cnt_bills_ingested_sum` |
| `cnt_bills_emails_sent` | `email_statistics_cnt_bills_emails_sent` | `email_statistics_cnt_bills_emails_sent_sum` |
| `cnt_bills_emails_delivered` | `email_statistics_cnt_bills_emails_delivered` | `email_statistics_cnt_bills_emails_delivered_sum` |
| `email_sent_pct` | `email_statistics_email_sent_pct` | `email_statistics_email_sent_pct_average` |
| `email_not_sent_pct` | `email_statistics_email_not_sent_pct` | `email_statistics_email_not_sent_pct_average` |
| `cnt_expected_invoices` | `email_statistics_cnt_expected_invoices` | `email_statistics_cnt_expected_invoices_sum` |
| `cnt_bills_item_available` | `email_statistics_cnt_bills_item_available` | `email_statistics_cnt_bills_item_available_sum` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |

</details>

<details>
<summary>Email Daily Tracker field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `email_type` | `email_type` | — |
| `delivery_mode` | `delivery_mode` | — |
| `delivered_notification_id` | `email_tracker_delivered_notification_id` | `email_tracker_delivered_notification_id_sum` |
| `generated_notification_id` | `email_tracker_generated_notification_id` | `email_tracker_generated_notification_id_sum` |
| `last_updated_timestap` | `last_updated_timestamp` | — |
| `invoice_ingested` | `email_tracker_invoice_ingested` | `email_tracker_invoice_ingested_sum` |

</details>

<details>
<summary>Email Recommendation Quality field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `reporting_date` | `reporting_date` | — |
| `analysis_date` | `analysis_date` | — |
| `bc_end_week_number` | `bc_end_week_number` | — |
| `appliance_name` | `appliance_name` | — |
| `fuel_type` | `fuel_type` | — |
| `email_type` | `email_type` | — |
| `metric_name` | `metric_name` | — |
| `metric_notification_count` | `email_recommendations_metric_notification_count` | `email_recommendations_metric_notification_count_sum` |
| `total_notification_count` | `email_recommendations_total_notification_count` | — |
| `notification_pct` | `email_recommendations_notification_pct` | `email_recommendations_notification_pct_average` |
| `user_count` | `email_recommendations_user_count` | `email_recommendations_user_count_sum` |
| `total_user_count` | `email_recommendations_total_user_count` | — |
| `user_pct` | `email_recommendations_user_pct` | `email_recommendations_user_pct_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |

</details>

<details>
<summary>Email Failures field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `reporting_date` | `reporting_date` | — |
| `analysis_date` | `analysis_date` | — |
| `email_type` | `email_type` | — |
| `bc_end_week_number` | `bc_end_week_number` | — |
| `failure_reason` | `failure_reason` | — |
| `failure_count` | `email_failures_failure_count` | `email_failures_failure_count_sum` |
| `total_failure_count` | `email_failures_total_failure_count` | — |
| `failure_pct` | `email_failures_failure_pct` | `email_failures_failure_pct_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `rank` | `source_rank` | — |

</details>

<details>
<summary>HER Generation field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `cluster_id` | `cluster_id` | — |
| `analysis_date` | `analysis_date` | — |
| `schedule_start` | `schedule_start` | — |
| `schedule_end` | `schedule_end` | — |
| `fuel_type` | `fuel_type` | — |
| `period` | `source_period` | — |
| `expected_eligible_users` | `her_generation_expected_eligible_users` | `her_generation_expected_eligible_users_sum` |
| `actual_eligible_users` | `her_generation_actual_eligible_users` | `her_generation_actual_eligible_users_sum` |
| `actual_generation_count` | `her_generation_actual_generation_count` | `her_generation_actual_generation_count_sum` |
| `weekly_actual_failure_count` | `her_generation_weekly_actual_failure_count` | `her_generation_weekly_actual_failure_count_sum` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |

</details>

<details>
<summary>HER Schedule Status field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `cluster_id` | `cluster_id` | — |
| `fuel_type` | `fuel_type` | — |
| `schedule_start` | `schedule_start` | — |
| `schedule_end` | `schedule_end` | — |
| `total_eligible_users` | `her_schedules_total_eligible_users` | `her_schedules_total_eligible_users_sum` |
| `total_generated_notification_id` | `her_schedules_total_generated_notification_id` | `her_schedules_total_generated_notification_id_sum` |
| `total_scheduled_notification_id` | `her_schedules_total_scheduled_notification_id` | `her_schedules_total_scheduled_notification_id_sum` |
| `total_queued_notification_id` | `her_schedules_total_queued_notification_id` | `her_schedules_total_queued_notification_id_sum` |
| `total_printed_notification_id` | `her_schedules_total_printed_notification_id` | `her_schedules_total_printed_notification_id_sum` |
| `total_mailed_notification_id` | `her_schedules_total_mailed_notification_id` | `her_schedules_total_mailed_notification_id_sum` |
| `total_failed_notification_id` | `her_schedules_total_failed_notification_id` | `her_schedules_total_failed_notification_id_sum` |
| `reporting_date` | `reporting_date` | — |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `analysis_date` | `analysis_date` | — |
| `total_swept_notification_id` | `her_schedules_total_swept_notification_id` | `her_schedules_total_swept_notification_id_sum` |

</details>

<details>
<summary>HER Generation Failures field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `cluster_id` | `cluster_id` | — |
| `schedule_start` | `schedule_start` | — |
| `schedule_end` | `schedule_end` | — |
| `fuel_type` | `fuel_type` | — |
| `failure_reason` | `failure_reason` | — |
| `failure_count` | `her_failures_failure_count` | `her_failures_failure_count_sum` |
| `total_failure_count` | `her_failures_total_failure_count` | — |
| `period` | `source_period` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `failure_percentage` | `her_failures_failure_percentage` | `her_failures_failure_percentage_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `rank` | `source_rank` | — |

</details>

<details>
<summary>HER Non-PSEG Quality field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `low_bc_duration_count` | `her_non_pseg_quality_low_bc_duration_count` | `her_non_pseg_quality_low_bc_duration_count_sum` |
| `high_bc_duration_count` | `her_non_pseg_quality_high_bc_duration_count` | `her_non_pseg_quality_high_bc_duration_count_sum` |
| `staleness_count` | `her_non_pseg_quality_staleness_count` | `her_non_pseg_quality_staleness_count_sum` |
| `solar_template_count` | `her_non_pseg_quality_solar_template_count` | `her_non_pseg_quality_solar_template_count_sum` |
| `solar_consistency_count` | `her_non_pseg_quality_solar_consistency_count` | `her_non_pseg_quality_solar_consistency_count_sum` |
| `solar_generation_count` | `her_non_pseg_quality_solar_generation_count` | `her_non_pseg_quality_solar_generation_count_sum` |
| `report_consistency_count` | `her_non_pseg_quality_report_consistency_count` | `her_non_pseg_quality_report_consistency_count_sum` |
| `itemization_count` | `her_non_pseg_quality_itemization_count` | `her_non_pseg_quality_itemization_count_sum` |
| `bill_change_consistency_count` | `her_non_pseg_quality_bill_change_consistency_count` | `her_non_pseg_quality_bill_change_consistency_count_sum` |
| `ev_itemization_count` | `her_non_pseg_quality_ev_itemization_count` | `her_non_pseg_quality_ev_itemization_count_sum` |
| `tou_template_count` | `her_non_pseg_quality_tou_template_count` | `her_non_pseg_quality_tou_template_count_sum` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |
| `nbi_occurance_count` | `her_non_pseg_quality_nbi_occurance_count` | `her_non_pseg_quality_nbi_occurance_count_sum` |
| `nbi_value_count` | `her_non_pseg_quality_nbi_value_count` | `her_non_pseg_quality_nbi_value_count_sum` |
| `nbi_appliance_itemisation_count` | `her_non_pseg_quality_nbi_appliance_itemisation_count` | `her_non_pseg_quality_nbi_appliance_itemisation_count_sum` |
| `nbi_non_null_insight_count` | `her_non_pseg_quality_nbi_non_null_insight_count` | `her_non_pseg_quality_nbi_non_null_insight_count_sum` |
| `nbi_unicode_count` | `her_non_pseg_quality_nbi_unicode_count` | `her_non_pseg_quality_nbi_unicode_count_sum` |
| `nbi_extreme_insight_count` | `her_non_pseg_quality_nbi_extreme_insight_count` | `her_non_pseg_quality_nbi_extreme_insight_count_sum` |

</details>

<details>
<summary>HER Automation Quality field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `reporting_date` | `reporting_date` | — |
| `analysis_date` | `analysis_date` | — |
| `low_bc_duration_cnt` | `her_automation_quality_low_bc_duration_cnt` | `her_automation_quality_low_bc_duration_cnt_sum` |
| `high_bc_duration_cnt` | `her_automation_quality_high_bc_duration_cnt` | `her_automation_quality_high_bc_duration_cnt_sum` |
| `staleness_cnt` | `her_automation_quality_staleness_cnt` | `her_automation_quality_staleness_cnt_sum` |
| `solar_template_cnt` | `her_automation_quality_solar_template_cnt` | `her_automation_quality_solar_template_cnt_sum` |
| `solar_consistency_cnt` | `her_automation_quality_solar_consistency_cnt` | `her_automation_quality_solar_consistency_cnt_sum` |
| `solar_generation_cnt` | `her_automation_quality_solar_generation_cnt` | `her_automation_quality_solar_generation_cnt_sum` |
| `report_consistency_cnt` | `her_automation_quality_report_consistency_cnt` | `her_automation_quality_report_consistency_cnt_sum` |
| `itemization_cnt` | `her_automation_quality_itemization_cnt` | `her_automation_quality_itemization_cnt_sum` |
| `bill_change_consistency_cnt` | `her_automation_quality_bill_change_consistency_cnt` | `her_automation_quality_bill_change_consistency_cnt_sum` |
| `ev_itemization_cnt` | `her_automation_quality_ev_itemization_cnt` | `her_automation_quality_ev_itemization_cnt_sum` |
| `tou_template_cnt` | `her_automation_quality_tou_template_cnt` | `her_automation_quality_tou_template_cnt_sum` |
| `nbi_occurence_cnt` | `her_automation_quality_nbi_occurence_cnt` | `her_automation_quality_nbi_occurence_cnt_sum` |
| `nbi_value_cnt` | `her_automation_quality_nbi_value_cnt` | `her_automation_quality_nbi_value_cnt_sum` |
| `nbi_appliance_itemization_cnt` | `her_automation_quality_nbi_appliance_itemization_cnt` | `her_automation_quality_nbi_appliance_itemization_cnt_sum` |
| `nbi_non_null_insight_cnt` | `her_automation_quality_nbi_non_null_insight_cnt` | `her_automation_quality_nbi_non_null_insight_cnt_sum` |
| `nbi_unicode_cnt` | `her_automation_quality_nbi_unicode_cnt` | `her_automation_quality_nbi_unicode_cnt_sum` |
| `nbi_extreme_insight_cnt` | `her_automation_quality_nbi_extreme_insight_cnt` | `her_automation_quality_nbi_extreme_insight_cnt_sum` |
| `nbi_seasonal_appliance_cnt` | `her_automation_quality_nbi_seasonal_appliance_cnt` | `her_automation_quality_nbi_seasonal_appliance_cnt_sum` |
| `overall_report_count` | `her_automation_quality_overall_report_count` | `her_automation_quality_overall_report_count_sum` |
| `period` | `source_period` | — |

</details>

<details>
<summary>NBI Generation field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `total_users_successful` | `nbi_generation_total_users_successful` | `nbi_generation_total_users_successful_sum` |
| `total_users_with_200_errorcode` | `nbi_generation_total_users_with_200_errorcode` | `nbi_generation_total_users_with_200_errorcode_sum` |
| `total_users_with_300_errorcode` | `nbi_generation_total_users_with_300_errorcode` | `nbi_generation_total_users_with_300_errorcode_sum` |
| `nbi_error_pct` | `nbi_generation_nbi_error_pct` | `nbi_generation_nbi_error_pct_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |

</details>

<details>
<summary>NBI Generic Tags field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `total_nbi_users` | `nbi_generic_tags_total_nbi_users` | `nbi_generic_tags_total_nbi_users_sum` |
| `total_nbi_users_with_generic_tag` | `nbi_generic_tags_total_nbi_users_with_generic_tag` | `nbi_generic_tags_total_nbi_users_with_generic_tag_sum` |
| `pct_users_with_generic_tag` | `nbi_generic_tags_pct_users_with_generic_tag` | `nbi_generic_tags_pct_users_with_generic_tag_average` |
| `last_updated_timestamp` | `last_updated_timestamp` | — |

</details>

<details>
<summary>Billing-Cycle Length field mapping</summary>

| Source output | Dimension | Measure |
|---|---|---|
| `pilot_id` | `pilot_id` | — |
| `bc_1_15_count` | `billing_length_bc_1_15_count` | `billing_length_bc_1_15_count_sum` |
| `bc_15_30_count` | `billing_length_bc_15_30_count` | `billing_length_bc_15_30_count_sum` |
| `bc_31_45_count` | `billing_length_bc_31_45_count` | `billing_length_bc_31_45_count_sum` |
| `bc_45_60_count` | `billing_length_bc_45_60_count` | `billing_length_bc_45_60_count_sum` |
| `bc_61_75_count` | `billing_length_bc_61_75_count` | `billing_length_bc_61_75_count_sum` |
| `bc_76_90_count` | `billing_length_bc_76_90_count` | `billing_length_bc_76_90_count_sum` |
| `bc_gt_90_count` | `billing_length_bc_gt_90_count` | `billing_length_bc_gt_90_count_sum` |
| `analysis_date` | `analysis_date` | — |
| `reporting_date` | `reporting_date` | — |
| `ingestion_type` | `ingestion_type` | — |

</details>

## Preserved source behavior

- The pilot replacement is `reporting.pilot_consolidated_product_type_events`, using the confirmed one-row-per-pilot contract. Original inner/left pilot matching is preserved. Billing length adds a left metadata join, so its original rows are retained.
- Active Users selects the latest reporting-date snapshot per pilot before dashboard filters. Its counts are snapshots, not values to sum over historical days. Pilot Reporting Dates retains independent maxima across the original six source tables.
- Invoice Statistics handles SCHEDULED and ADHOC in one ranked query. Delay remains part of the SCHEDULED partition only; other trigger types remain excluded. Null source percentages retain the original zero fallback.
- Ingestion, processing and email failure ranks retain their original partitions and descending NULLS FIRST ordering. Processing Top Three is applied after ranking. Dashboard filters do not recalculate those ranks. The old queries do not define a deterministic winner for ties; no new tie policy is introduced.
- HER Generation reuses one full-join definition for Daily/Weekly/Monthly. Weekly and monthly eligibility use MAX, generation uses SUM, and the expected-minus-generated calculation is retained. Its original output omits reporting_date, so the common field is NULL for this family.
- HER Schedule Status retains the latest schedule snapshots and pilot 10037's quarter-specific schedule treatment. HER failures and automation quality preserve grouping by both analysis and reporting periods, including their boundary differences. HER failure division returns NULL for a zero denominator.
- `sre_her_qc_data` and `public.her_automation_query_results` remain separate quality sources. No pilot exclusion is inferred solely from a source's non-PSEG title.
- Post-Ingestion Quality preserves the original overlap-error join keys and multiplicity. Its overlapping count must not be summed indiscriminately across meter/fuel rows. This migration does not silently correct source business rules.
- Every family has a hidden, query-local row identifier. It preserves duplicate rows and satisfies the view's primary-key requirement; it is not a durable identifier, a deduplication rule, or a key for joining different families. There are no fact-to-fact joins in either explore.

All source-family views use non-persistent LookML derived tables. No physical tables, grants or data loads are created by these models. Do not add date predicates inside the original latest-row or ranking calculations merely to improve pushdown: that can change results. Runtime performance and data checks are deferred until the separate loading work is complete.

## Validation and next stage

From the repository root:

```sh
uv run scripts/validate_bre_models.py --output-dir /private/tmp/bre-validation
```

The script pins its parser dependencies, checks all 26 LookML files, and renders 108 combinations covering both regions, all families, all three periods, both processing-failure scopes, and invalid selectors. It checks field references, catalog isolation, a stable output schema, typed inactive branches, and regional field availability. Its optional output directory contains planning-only SQL fixtures.

All 108 rendered SQL combinations previously passed Starburst `EXPLAIN (TYPE VALIDATE)` without reading table data. See [the recorded validation results](bre_model_validation.json). The Starburst query tool requires removing the fixture's final semicolon before submission.

**Looker Validator and Looker-generated SQL inspection are pending.** The local renderer is not the Looker compiler, and the recorded SQL checks must not be described as Looker validation. When Looker access is available, validate both models and inspect the actual generated SQL, especially inheritance/alias resolution, family selection, period behavior, and inactive measures. Do not run data queries as part of that check.

Next, agree the CA dashboard filters, tile meanings and measure aggregation choices using this mapping, then create the LookML dashboard replacements. Apply the shared design to EU afterward. Source chart counts alone do not establish each tile's exact field selections or aggregation.


## CA Ingestion dashboard implementation — 2026-09-13

The [CA Ingestion dashboard design](bre_ca_ingestion_dashboard_design.md) records the agreed eight query tiles and five controls. The dashboard uses the existing bre_dashboard Explore with four selected families. Both regional models expose the new shared calculations; only bre_ca includes the dashboard.

The 25th shared view, bre_ingestion_filter_values, supplies dynamic filter suggestions through a hidden Explore. A second hidden Explore exposes the existing pilot directory for consistent pilot suggestions. There are still 20 source families and one user-facing dashboard Explore per model. No fact joins or PDTs were introduced.

Ingestion uses a separate Sunday-start ingestion_period_date field; existing Monday grouping and HER source periods are preserved. The user approved treating OPOWER as Billing in the File Type control and in the Users (M)/day invoice calculation. Other ingestion-type values remain dynamic. New file comparisons use exact median and average over source rows and compare the selected calendar range with the immediately preceding equal-length range.
