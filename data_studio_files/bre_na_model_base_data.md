# BRE NA dashboards: tile specifications and source reference

This file records the current NA (North America) Data Studio / Looker Studio dashboards, their tile specifications, and the supplied source inventory and queries. Complete the dashboard and tile records here before implementing separate NA LookML dashboards and an NA model, then integrating them into the single BRE application alongside CA (Canada) and EU (Europe). `TODO` means information has not been supplied or verified; use `None` or `Not applicable` only after confirming that it does not apply.

## Navigation

- [Dashboard outline](#dashboard-structure) and [capture instructions](#how-to-document-dashboards-and-tiles)
- [Dashboard capture worksheets](#dashboard-capture-worksheets)
- [Reusable tile specification template](#tile-specification-template)
- [Readiness for NA implementation](#readiness-for-na-implementation)
- [Source inventory](#source-inventory) and [source query records](#source-query-records)

## Scope and status

- Region: NA, as labeled in the supplied notes. The connection and catalog are TODO.
- Dashboard/report URLs and page links: capture per dashboard below.
- The inventory describes the existing Data Studio / Looker Studio sources. The NA LookML dashboards and model are a later implementation step; their exact mappings remain TODO.
- Source names, aliases, connector types, report usage counts, and statuses below are preserved from the supplied inventory. `Working` is the copied status, not a new validation result; counts are a snapshot.
- Supplied queries and field definitions are recorded under the source aliases below. They have not been executed or checked against the NA schema during this documentation update. Some source status labels and SQL TODO comments predate the pasted queries; reconcile those while reviewing each source.
- Local LookML contains CA and EU BRE models and a draft `bre_na` model for Ingestion. NA implementation status and unresolved mappings are tracked in the [Ingestion implementation review](bre_na_ingestion_implementation.md). CA/EU behavior is not automatically an NA definition.

## Documented query conventions

The original notes specify Starburst/Trino SQL and `reporting.pilot_consolidated_product_type_events` as the pilot directory instead of a `data_sanity` table. Column types, join compatibility, pilot uniqueness, and the NA catalog still need verification when a query is completed. The existing two-part table names depend on the connection's current catalog.

These conventions describe the intended source queries. Connector labels alone do not establish the underlying database engine. For an Extract Data source, record the upstream source alias, original query, extraction filters, and refresh schedule. For Google Analytics, record the property and connector configuration; SQL may not apply.

## How to add a source query

1. Find the exact alias in the inventory and follow its source link. The alias identifies the source; display names are not unique.
2. Fill in that source's metadata and replace its SQL comment with the source query. Keep extract sources and their upstream sources separate.
3. Record the output grain (what one row represents), join keys, date fields, filter mappings, and chart calculations. Keep source SQL separate from report-level calculations and blends.
4. Add fields created outside the source SQL to the optional dimensions and metrics tables in that source section.
5. Record verification evidence and date when available. A query that has only been pasted remains unverified.

Use the [source inventory](#source-inventory) and [source query records](#source-query-records) as the source reference. Link tile records to those entries instead of copying source SQL into each tile.

## Dashboard structure

The sections below come from the supplied outline. Follow each dashboard link to fill in its controls and tile register. The registers are blank capture forms, not an assertion about the number or names of existing tiles. Source-to-section and source-to-tile mappings remain TODO.

| Dashboard | Sections | Documented controls |
| --- | --- | --- |
| [1. Ingestion](#na-ingestion) | 1.a. Data Governance Ingestion; 1.b. Queue Metrics Ingestion | For 1.a: Time Period, Date Granularity (Period), Pilot ID, Pilot Name, File Type, Cluster IDs. Field mappings and per-tile applicability: TODO. |
| [2. Aggregation](#na-aggregation) | 2.a. Data Governance Aggregation | TODO |
| [3. Disaggregation](#na-disaggregation) | 3.a. Data Governance Disaggregation; 3.b. Queue Metrics Disaggregation | TODO |
| [4. TOU](#na-tou) | 4.a. Data Governance TOU | TODO |
| [5. Rate Comparison](#na-rate-comparison) | 5.a. Data Governance Rate Comparison | 8 tiles implemented as draft; Looker/report validation pending |
| [6. Email](#na-email) | 6.a. Data Governance Email; 6.b. Queue Metrics Email | Two separate drafts: 8 governance + 10 queue tiles; Looker/report validation pending |
| [7. HER](#na-her) | 7.a. Data Governance HER; 7.b. Queue Metrics HER | Two separate drafts: 7 governance + 10 queue tiles; Looker/report validation pending |
| [8. NBI](#na-nbi) | 8.a. Data Governance NBI; 8.b. EMR Metrics NBI | 8a and 8b drafts complete; native Looker/report parity pending |

### Filter definitions still to capture

| Control | Supplied information | Missing information |
| --- | --- | --- |
| Time Period | Listed for Data Governance Ingestion | Date field per tile, default range, time zone, and comparison behavior |
| Date Granularity (Period) | Daily, Weekly, Monthly options are described in the original notes | Control/calculated-field definition, grouping date, week start, and affected tiles |
| Pilot ID / Pilot Name | Pilot dropdown sources were mentioned in the original notes | Actual source alias and output field used by each control, dropdown dependencies, and affected tiles |
| File Type | Listed for Data Governance Ingestion | Source alias, field, value mapping, and affected tiles |
| Cluster IDs | Listed for Data Governance Ingestion | Source alias, field, available values, and affected tiles |

Document the Period control and its grouping formula separately from the ingestion audit source SQL. A query returning ingestion audit rows does not itself establish Daily/Weekly/Monthly control behavior. The local CA/EU [Period parameter](views/bre/bre_dashboard_fields.view.lkml) is related reference material, not confirmation of the NA report's configuration.



## How to document dashboards and tiles

1. Open the current NA report and record its URL, page names, and capture date under the appropriate dashboard. Include hidden pages/tiles if they are part of the intended migration, and note any exclusions explicitly.
2. Record dashboard/page/group controls in that dashboard's control table. Give each control a stable ID, for example `NA-1-F01`. Include fixed report/page filters even if there is no visible control.
3. Add one register row per actual tile in its section, using IDs such as `NA-1A-T01`, `NA-1A-T02`, and `NA-1B-T01`. Keep IDs stable when tiles are reordered. Record text/instruction tiles too, with sources and fields marked `Not applicable` where appropriate.
4. Copy the [tile specification template](#tile-specification-template) into that section's **Tile specifications** area for every tile, replacing `TILE-ID` with its ID. Replace the register's `TODO` title with a link to the copied heading, for example `[Exact chart title](#na-1a-t01--exact-chart-title)`.
5. Link each tile to its exact `SRC-xx` record and alias. Fill in dimensions, metrics, formulas, date behavior, filters, and presentation from the current report. Add the tile ID to each referenced source's **Dashboard section / tiles** field to keep reverse lookup possible.
6. For every dashboard control, explicitly record whether it affects that tile, which field it targets, and any override. Keep fixed chart filters separate from inherited controls and source SQL/extract restrictions.
7. Save a representative result with its date range, filter selections, and capture time. Mark the tile `Ready for implementation` only when its current behavior is fully documented; later implementation and result validation have separate statuses.

**Status values:** `Not started`, `In progress`, `Needs clarification`, `Ready for implementation`. The starter register rows are placeholders; add as many rows as needed. Source inventory chart counts are a copied report-wide snapshot, not a dashboard tile count or a reliable source-to-tile mapping.

**Formula entry:** Preserve the original formula and expression language. Put long or multiline formulas in fenced `text` blocks under the tile and reference them by name in tables. Escape literal pipes in Markdown table cells as `\|`. Reuse source-level field definitions by linking to their `SRC-xx` record; document chart-level overrides explicitly.

## NA gauge display convention

User-approved direction (2026-10-03): the maximum fills the gauge and the numeric value stays visible. Apply this convention to every documented NA gauge as its dashboard is implemented.

- Use a semicircular gauge with a pale background arc, a colored value arc, and a large centered value with units. Show the minimum and maximum on the scale.
- Percentage metrics use 0–100%. At 100%, the arc is full. Values above 100% keep their actual numeric label while the arc remains full; do not change the metric calculation to cap the result.
- User/meter counts use a zero-based explicit maximum, displayed on the scale. Choose a suitable range per metric when implementing its dashboard; this maximum is a display scale, not a target. Ingestion users uses 0–20 M, based on the observed default PSEG seven-day result of 15.4 M (September 26–October 2, 2026). Values at or above the maximum fill the arc while the center retains the actual value. Retain each metric's documented units.
- Use blue for counts, green for success/availability/accuracy, and red for failures/errors/deviation. Avoid invented warning thresholds or target values.
- Zero displays as zero with an empty value arc. Missing data remains missing, not a fabricated zero. Use two decimals for percentages and values in millions; retain more detail in tooltips.
- Existing NA Ingestion gauge tiles: NA-1A-T04 (users in millions) and NA-1A-T05 (success percentage). The same convention applies to the remaining gauge tiles when those dashboards are built.

## Dashboard capture worksheets

Report-wide controls can be documented once in a dashboard table and referenced by ID from other dashboards, provided their scope and applicable pages are explicit. Do not assume a control applies to every tile or that CA/EU behavior is the same as NA.

<a id="na-ingestion"></a>

### 1. Ingestion

**Implementation review (2026-10-03):** Ingestion is implemented as two separate draft LookML dashboards: [1a Data Governance](../dashboards/bre_na_ingestion_governance.dashboard.lookml) (8 tiles, `bre_na::bre_na_ingestion_governance`) and [1b Queue Metrics](../dashboards/bre_na_ingestion_queue_metrics.dashboard.lookml) (10 tiles, `bre_na::bre_na_ingestion_queue_metrics`). Frontend tabs will be added later. See the [NA Ingestion implementation review](bre_na_ingestion_implementation.md) for tile mappings, validation, and unresolved source/visualization details. The Rate Comparison series and Rate Plan ID filter are implemented with the confirmed exact-timestamp left join; original-report result parity is pending.

**Confirmed queue filter:** `SQS Ingestion Module Filter` means include `module_name = 'Ingestion'` (confirmed by the user on 2026-10-03).

**Confirmed Ingestion blend:** `SRE Ingestion Audit (ED)` LEFT JOIN `SRE Rate Comparison Tracker` on Pilot and last updated timestamp (confirmed by the user on 2026-10-03). Pilot is interpreted as `pilot_id`; the user confirmed Date & Time (full timestamp), including the time component. No day truncation or extra analysis-date join key is applied.

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** Not started / TODO

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

#### 1.a. Data Governance Ingestion

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-1A-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 1a | User Analytics | Last 7 Days | TODO |
| NA-1A-F02 | Date Granularity (Period/Weekly/Monthly) | Applied to all tiles in this dashboards - 1a | SRE Ingestion Audit (ED) | Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-1A-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboards - 1a | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-1A-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboards - 1a | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-1A-F05 | File Type (File Type) | Applied to all tiles in this dashboards - 1a | SRE Ingestion Audit (ED) | Source Field - ingestion_type | Cross filtered with Date range dimension - analysis_date |
| NA-1A-F06 | Rate Plan ID (Rate Plan ID) | Applied to all tiles in this dashboards - 1a | SRE Rate Comparison Tracker | Source Field - current_plan_number | Cross filtered with Date range dimension - analysis_date |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-1A-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension -reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Not started |
| NA-1A-T02 | # of Files per Day - Average | Single Value compared to previous period | SRE Ingestion Audit (ED) | Average of total_files_processed, previous period Average | Not started |
| NA-1A-T03 | # of Files per Day - Median | Single Value compared to previous period | SRE Ingestion Audit (ED) | Median of total_files_processed, previous period Median | Not started |
| NA-1A-T04 | Daily Average - Users (M)/ day | Single Value in gauge (Date range dimension - analysis_date) | SRE Post Ingestion Data Quality | Sum of (Gauge Value) total_users_across_age_buckets| Not started |
| NA-1A-T05 | Daily Average - Success % | Single Value (Date range dimension - analysis_date) | SRE Ingestion Audit (ED) | Average of (Gauge Value) sucess_percentage| Not started |
| NA-1A-T06 | Daily Ingestion Statistics | Combo Chart with Bars and Line Graphs | SRE Ingestion Audit (ED) left outer join SRE Rate Comparison Tracker | X-Axis: Analysis Date, Y- Axis: Metric - Total File # (sum of total_files_processed) - Bar, Total Chunk # (Sum of total_chunks_processed) - Bar, Total Records # (Sum of total_records_count) - Bar, Success % (Average of success_percentage) - Line, Expected RC # (Sum of expected_total_rate_plan_count) - Bar, Successful RC # (Sum of successful_total_rate_plan_count) - Bar, Missing RC % (Average of missing_total_rate_plan_pct) - Line | Not started |
| NA-1A-T07 | Daily Post-Ingestion Data Quality Report (Only for Elec/Gas AMI** ) | Combo Chart with Bars and Line Graphs | SRE Post Ingestion Data Quality | Dimension - X axis - period (Dynamic), y-axis - Metric - Y axis - total_users_across_age_buckets (sum), user_raw_with_delay_0_3 (count), user_raw_with_delay_4_7 (count), user_raw_with_delay_8_15 (count), user_raw_with_delay_gt_15 (count), avg_users_receiving_raw_per_day (Sum), user_invoice_with_delay_0_7 (sum), user_invoice_with_delay_7_15 (sum), user_invoice_with_delay_15_30 (sum),user_invoice_with_delay_gt_30 (sum) -- Date range dimension - analysis_date on all | Not started |
| NA-1A-T08 | Daily Top Ingestion Failure Reasons | Combo Chart with Bars (breakdown on application_error_codes) | SRE Ingestion Failure Statistics | Dimension - X axis
period (Dynamic), Breakdown dimension
application_error_code, Metric - Y axis
Metric Toggle (show only <= 3 rank values) (Date range dimension - analysis_date) | Not started |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-1A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

#### 1.b. Queue Metrics Ingestion

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-1B-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 1b | User Analytics | Last 7 Days | TODO |
| NA-1B-F02 | event_timestamp_str | Applied to all tiles in this dashboards - 1b | SRE SQS Queue Metrics - Starburst | control field - event_timestamp_str , metric- avg of metric_value, filter on this - SQS Ingestion Module Filter | TODO |
| NA-1B-F03 | module_name | Applied to all tiles in this dashboards - 1b | SRE SQS Queue Metrics - Starburst | control field - module_name , metric- avg of metric_value, filter on this - SQS Ingestion Module Filter | TODO |
| NA-1B-F04 | queue_name | Applied to all tiles in this dashboards - 1b | SRE SQS Queue Metrics - Starburst | control field - queue_name , metric- avg of metric_value, filter on this - SQS Ingestion Module Filter | TODO |
| NA-1B-F05 | queue_type | Applied to all tiles in this dashboards - 1b | SRE SQS Queue Metrics - Starburst | control field - queue_type , metric- avg of metric_value, filter on this - SQS Ingestion Module Filter | TODO |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-1B-T01 | Key KPIs - Environment Health Score (A composite score (0-100) combining success rate, backlog, and latency) | Single Value | SRE SQS Queue Health Metrics by Day | average of health_score, filtered on SQS Ingestion Module Filter, Date range dimension - analysis_date | Not started |
| NA-1B-T02 | Key KPIs - Total Ingestion Volume (Measures the overall data ingestion activity, indicating system workload) | Line chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - total_messages_received, Filtered on SQS Ingestion Module Filter, Date range dimension - ingestion_hour (Date) | Not started |
| NA-1B-T03 | Key KPIs - Ingestion Success Rate (Percentage of messages successfully processed)| Single Value | SRE SQS Metrics by Hour - Starburst | Metric - success_rate as Rate, Filtered on SQS Ingestion Module Filter, Date range dimension - ingestion_hour (Date) | Not started |
| NA-1B-T04 | Key KPIs - Queue Backlog Volume (Average number of messages waiting in queues. Highlights potential delays or bottlenecks in processing.) | Single Value | SRE SQS Metrics by Hour - Starburst | Metric - average of average_queue_backlog, Filtered on SQS Ingestion Module Filter, Date range dimension - analysis_date | Not started |
| NA-1B-T05 | Trends - Ingestion Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - total_messages_received, Filtered on SQS Ingestion Module Filter, Date range dimension - ingestion_hour (Date) | Not started |
| NA-1B-T06 | Trends - Queue Size: Backlog Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - average_queue_backlog, Filtered on SQS Ingestion Module Filter, Date range dimension - ingestion_hour (Date) | Not started |
| NA-1B-T07 | Trends - Processed Messages Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - total_messages_sent, Filtered on SQS Ingestion Module Filter, Date range dimension - ingestion_hour (Date) | Not started |
| NA-1B-T08 | Trends - Health Score by Queue Name | Bar Graph - Stacked | SRE SQS Queue Health Metrics by Day | Dimension - X axis - analysis_date, Breakdown dimension - environment, Metric - Y axis - average of health_score, Filtered on SQS Ingestion Module Filter, Date range dimension - analysis_date | Not started |
| NA-1B-T09 | Trends - Processing Efficiency | Line Chart | SRE SQS Queueu Metrics by Day - Starburst | Dimension - X axis - ingestion_day (Date), Metric - Y axis - average of total_messages_received, Filtered on SQS Ingestion Module Filter, Date range dimension - ingestion_day (Date) | Not started |
| NA-1B-T10 | Trends - Oldest Message Age Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - Max of max_latency_in_days, Filtered on SQS Ingestion Module Filter, Date range dimension - ingestion_hour (Date) | Not started |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-1B-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

<a id="na-aggregation"></a>

### 2. Aggregation

**Implementation review (2026-10-03):** All eight Aggregation tiles are implemented in [`bre_na::bre_na_aggregation`](../dashboards/bre_na_aggregation.dashboard.lookml) using the supplied SRC-29 SQL. The user confirmed the NA-2-T06 Unique Users mapping and `sucess_perc = 100*(total_datapoints/total_expected_datapoints)`. See the [Aggregation implementation review](bre_na_aggregation_implementation.md) for checks and remaining Looker/report-parity validation.

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** Not started / TODO

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-2-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 1b | User Analytics | Last 7 Days | TODO |
| NA-2-F02 | Date Granularity (Period/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE Ingestion Audit (ED) | Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-2-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-2-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-2-F05 | File Granularity (File Granularity) | Applied to all tiles in this dashboard | SRE Ingestion Stats | Source Field - duration as Granularity | Cross filtered with Date range dimension - reporting_date |

#### 2.a. Data Governance Aggregation

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-2-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension - reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Implemented draft; Looker/report parity pending |
| NA-2-T02 | # of Raw Datapoints Per Day (Average) | Single Value showing compared to previous period | SRE Aggregation Stats | Shows Average of total_datapoints, Date range dimension - reporting_date, Compared to previous period | Implemented draft; Looker/report parity pending |
| NA-2-T03 | # of Raw Datapoints Per Day (Median) | Single Value showing compared to previous period | SRE Aggregation Stats | Shows Median of total_datapoints, Date range dimension - reporting_date, Compared to previous period | Implemented draft; Looker/report parity pending |
| NA-2-T04 | Daily Averages -  Meters/Day| Gauge | SRE Aggregation Stats | Shows Averages for total_meters, Date range dimension - reporting_date | Implemented draft; Looker/report parity pending |
| NA-2-T05 | Daily Averages -  Availability | Gauge | SRE Aggregation Stats | Shows Averages for sucess_perc, Date range dimension - reporting_date | Implemented draft; Looker/report parity pending |
| NA-2-T06 | Daily Aggregated Raw Data Statistics (T+7) | Combo of Bar and Line graphs | SRE Aggregation Stats | Shows aggregated raw data statistics for T+7, Dimension - X axis - Analysis Date, Metric - Y axis - Expected Datapoints (sum of total_expected_datapoints as Bar), Actual Datapoints Received (sum of total_datapoints as Bar), Data Availability % (Avg of success_perc as Line), Unique Users # (sum of total_negative_consumption_datapoints as Line), Unique Meters # (sum of total_meters as Line), Date range dimension - reporting_date | Implemented draft; Looker/report parity pending |
| NA-2-T07 | Daily Aggregated Raw Data Quality (User) (T+7) | Line Chart | SRE Aggregation Stats | Shows aggregated raw data quality statistics for T+7, Dimension - X axis - Analysis Date, Metric - Y axis - Users With At-least One -ve RAW Datapoint (sum of negative_consumption_users), Users With Net -ve Consumption for the Day  (sum of total_negative_consumption_users), Users with at least one 0 consumption datapoint  (sum of zero_consumption_users) , Users with net 0 consumption for the day  (sum of total_zero_consumption_users), Users with at least one missing  (sum of missing_datapoint_users), Date range dimension - reporting_date | Implemented draft; Looker/report parity pending |
| NA-2-T08 | Daily Aggregated Raw Data Quality (Meter) (T+7) | Line Chart | SRE Aggregation Stats | Shows aggregated raw data quality statistics for T+7, Dimension - X axis - Analysis Date, Metric - Y axis - Meters With At-least One -ve RAW Datapoint (sum of negative_consumption_meters), Meters With Net -ve Consumption for the Day (sum of total_negative_consumption_meters), Meters with at least one 0 consumption datapoint (sum of zero_consumption_meters), Meters with net 0 consumption for the day (sum of total_zero_consumption_meters), Meters with at least one missing datapoint (sum of missing_datapoint_meters), Date range dimension - reporting_date | Implemented draft; Looker/report parity pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-2A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

<a id="na-disaggregation"></a>

### 3. Disaggregation

**Implementation review (2026-10-03):** Separate drafts are implemented for [3a Data Governance](../dashboards/bre_na_disaggregation_governance.dashboard.lookml) (8 tiles, `bre_na::bre_na_disaggregation_governance`) and [3b Queue Metrics](../dashboards/bre_na_disaggregation_queue_metrics.dashboard.lookml) (10 tiles, `bre_na::bre_na_disaggregation_queue_metrics`). See the [Disaggregation implementation review](bre_na_disaggregation_implementation.md) for source semantics, controls, validation, and remaining acceptance checks.

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** Not started / TODO

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

#### 3.a. Data Governance Disaggregation

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-3A-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 1a | User Analytics | Last 7 Days | TODO |
| NA-3A-F02 | Date Granularity (Period/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE Ingestion Audit (ED) | Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-3A-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-3A-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-3A-F05 | Meter Type (Meter Type) | Applied to all tiles in this dashboard | SRE Invoice Stats New - Starburst, field - meter_type | TODO | Cross filtered with Date range dimension - reporting_date |
| NA-3A-F06 | Fuel Type (Fuel Type) | Applied to all tiles in this dashboard | SRE Invoice Stats New - Starburst, field - fuel_type | TODO | Cross filtered with Date range dimension - reporting_date |
| NA-3A-F07 | Module Name (Module Name) | Applied to all tiles in this dashboard | SRE Invoice Stats New - Starburst, field - module_name | TODO | Cross filtered with Date range dimension - reporting_date |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-3A-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension - reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Implemented draft; Looker/report parity pending |
| NA-3A-T02 | # of Invoices Per Day - Average | Single Value showing compared to previous period | SRE Invoice Statistics | Metric - On Average of total_invoices, Date range dimension - analysis_date & Compared to Previous Period | Implemented draft; Looker/report parity pending |
| NA-3A-T03 | # of Invoices Per Day - Median | Single Value showing compared to previous period | SRE Invoice Statistics | Metric - Median of total_invoices, Date range dimension - analysis_date & Compared to Previous Period | Implemented draft; Looker/report parity pending |
| NA-3A-T04 | Average Success % - T+7 day | Gauge Value | SRE Invoice Statistics | sum of sucessful_itemisation_t_7%, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-3A-T05 | Average Success % - T+2 day | Gauge Value | SRE Invoice Statistics | sum of sucessful_itemisation_t_2%, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-3A-T06 | Daily Invoice Ingestion vs Hybrid Disagg Processing Success % | Line Chart with multiple series | SRE Invoice Stats New - Starburst | Dimension - X axis - Analysis Date, Metric - Y axis - Total Invoice # (max of total_invoices), successful_itemisation_t_2% (average), successful_itemisation_t_7% (average),successful_itemisation_correction% (max) | Implemented draft; Looker/report parity pending |
| NA-3A-T07 | Daily Disagg Quality Report (Only for Elec AMI** ) | Line Chart with multiple series | SRE Quality Disagg New - Starburst | Dimension - X axis - Analysis Date, all as average Metric - Y axis - $/KWH Across Appliances %Var (Flag 1) (appliances_kwh_variance_pct_1), $/KWH Across Appliances %Var (Flag 2) (appliances_kwh_variance_pct_2), Total $ Across Appliances Out of Range (Flag 1) (total_cost_deviation_pct_1), Total $ Across Appliances Out of Range (Flag 2) (total_cost_deviation_pct_2), $/KWH Out of Range (cost_per_kwh_deviation_pct), Non-Seasonal Appliance Usage (seasonal_appliance_usage_deviation_pct), AO I/O % Dev (ao_pct_non_tou), SH I/O % Dev (sh_pct_non_tou), Other I/O % Dev (other_pct_non_tou), Zero Solar Estimation (solar_pct_non_tou), Single Appliance Domination (single_appliance_domination_deviation_pct), Missing Dwelling Type (missing_dwelliing_pct) -- Date range dimension - reporting_date | Implemented draft; Looker/report parity pending |
| NA-3A-T08 | Daily Top Disagg/Itemisation Failure Reasons | Stacked Bar Chart | SRE Failure Statistics New - Starburst | Dimension - X axis -analysis_date, Breakdown dimension - failure_reason, Metric - Y axis - Average of failure_percentage (ranke filter <= 3), Date range dimension - reporting_date | Implemented draft; Looker/report parity pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-3A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

#### 3.b. Queue Metrics Disaggregation

**Confirmed SQS Agg/Disagg Module Filter:** `module_name IN ('Disaggregation', 'Aggregation', 'UploadEventSplitter')`. Applies to all ten queue tiles.

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-3B-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 3b | User Analytics | Last 7 Days | TODO |
| NA-3B-F02 | Environment | Applied to all tiles in this dashboards - 3b | SRE SQS Queue Metrics - Starburst | control field - environment , metric- avg of metric_value, filter on this - SQS Agg/Disagg Module Filter | TODO |
| NA-3B-F03 | Module Name | Applied to all tiles in this dashboards - 3b | SRE SQS Queue Metrics - Starburst | control field - module_name , metric- avg of metric_value, filter on this - SQS Agg/Disagg Module Filter | TODO |
| NA-3B-F04 | Queue Name | Applied to all tiles in this dashboards - 3b | SRE SQS Queue Metrics - Starburst | control field - queue_name , metric- avg of metric_value, filter on this - SQS Agg/Disagg Module Filter | TODO |
| NA-3B-F05 | Queue Type | Applied to all tiles in this dashboards - 3b | SRE SQS Queue Metrics - Starburst | control field - queue_type , metric- avg of metric_value, filter on this - SQS Agg/Disagg Module Filter | TODO |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-3B-T01 | Key KPIs - Environment Health Score (A composite score (0-100) combining success rate, backlog, and latency) | Single Value | SRE SQS Queue Health Metrics by Day | average of health_score as Score, filtered on SQS Agg/Disagg Module Filter, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-3B-T02 | Key KPIs - Total Message Volume (Measures the overall data disagg activity, indicating system workload) | Line chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - total_messages_received, Filtered on SQS Agg/Disagg Module Filter, Date range dimension - ingestion_hour (Date) | Implemented draft; Looker/report parity pending |
| NA-3B-T03 | Key KPIs - Disagg Success Rate (Percentage of messages successfully processed)| Single Value | SRE SQS Metrics by Hour - Starburst | Metric - success_rate as Rate, Filtered on SQS Agg/Disagg Module Filter, Date range dimension - ingestion_hour (Date) | Implemented draft; Looker/report parity pending |
| NA-3B-T04 | Key KPIs - Queue Backlog Volume (Average number of messages waiting in queues. Highlights potential delays or bottlenecks in processing.) | Single Value | SRE SQS Metrics by Hour - Starburst | Metric - average of avg_queue_backlog as Avg(per hour), Filtered on SQS Agg/Disagg Module Filter, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-3B-T05 | Trends - Message Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - total_messages_received, Filtered on SQS Agg/Disagg Module Filter, Date range dimension - ingestion_hour (Date) | Implemented draft; Looker/report parity pending |
| NA-3B-T06 | Trends - Queue Size: Backlog Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - avg_queue_backlog as Avg(per hour), Filtered on SQS Agg/Disagg Module Filter, Date range dimension - ingestion_hour (Date) | Implemented draft; Looker/report parity pending |
| NA-3B-T07 | Trends - Oldest Messages Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - max of max_latency_in_days, Filtered on SQS Agg/Disagg Module Filter, Date range dimension - ingestion_hour (Date) | Implemented draft; Looker/report parity pending |
| NA-3B-T08 | Trends - Health Score by Queue Name | Bar Graph - Stacked | SRE SQS Queue Health Metrics by Day | Dimension - X axis - analysis_date, Breakdown dimension - queue_name, Metric - Y axis - average of health_score, Filtered on SQS Agg/Disagg Module Filter, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-3B-T09 | Trends - Processing Efficiency | Line Chart | SRE SQS Queueu Metrics by Day - Starburst | Dimension - X axis - ingestion_day (Date), Metric - Y axis - average of empty_receives_ratio, Filtered on SQS Agg/Disagg Module Filter, Date range dimension - ingestion_day (Date) | Implemented draft; Looker/report parity pending |
| NA-3B-T10 | Trends - Oldest Message Age Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Metric - Y axis - Sum of delayed_messages, Filtered on SQS Agg/Disagg Module Filter, Date range dimension - ingestion_hour (Date) | Implemented draft; Looker/report parity pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-3B-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

<a id="na-tou"></a>

### 4. TOU

**Implementation review (2026-10-03):** All six TOU tiles are implemented in [`bre_na::bre_na_tou`](../dashboards/bre_na_tou.dashboard.lookml). Uses SRC-35 and the user-confirmed report success/failure fractions. See the [TOU implementation review](bre_na_tou_implementation.md) for controls, source semantics, validation, and remaining Looker/report acceptance checks.

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** Not started / TODO

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-4-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 3b | User Analytics | Last 7 Days | TODO |
| NA-4-F02 | Date Granularity (Period/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE Ingestion Audit (ED) | Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-4-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-4-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-4-F05 | TOU Mode | Applied to all tiles in this dashboard | SRE TOU Appliance Batch Aggregation | Control Field: tou_mode, Default: COMPLETE_BILLING_CYCLE | TODO |
| NA-4-F06 | Delay (Days) | Applied to all tiles in this dashboard | SRE TOU Appliance Batch Aggregation | Control Field: delay_in_days, Default: 1 | TODO |

#### 4.a. Data Governance TOU

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-4A-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension - reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Implemented draft; Looker/report parity pending |
| NA-4A-T02 | # of Successful TOU Aggregation - Average | Single Value showing compared to previous period | SRE TOU Appliance Batch Aggregation | Average of successful_tou_eligible_invoices, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-4A-T03 | # of Successful TOU Aggregation - Median | Single Value showing compared to previous period | SRE TOU Appliance Batch Aggregation | Median of successful_tou_eligible_invoices, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-4A-T04 | Distribution - Success | Gauge Value | SRE TOU Appliance Batch Aggregation | average of tou_success_pct, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-4A-T05 | Distribution - Failure | Gauge Value | SRE TOU Appliance Batch Aggregation | average of tou_failure_pct, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-4A-T06 | Daily TOU Pipeline Run Outcomes (Available for DESC, PNM-AMI, PSEG & OGE only) | Combo Chart for Bars and Lines Chart | SRE TOU Appliance Batch Aggregation | Dimension - X axis - Analysis Date, Metric - Y axis - Expected Elegible BC# (sum of total_tou_eligible_invoices) - Bar, Successful TD# (sum of total_disagg_tou_invoices) - Bar, Actual Eligible BC# (sum of actual_total_tou_invoices) - Bar, Successful BC# (sum of successful_tou_eligible_invoices) - Bar, Success % (avg of tou_success_pct) - Line , filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-4A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

<a id="na-rate-comparison"></a>

### 5. Rate Comparison

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** Eight tiles implemented as a draft. Native Looker validation and original-report comparison pending; see implementation review.

**Implementation review (2026-10-04):** [Rate Comparison](../dashboards/bre_na_rate_comparison.dashboard.lookml), `bre_na::bre_na_rate_comparison`, implements all eight tiles. See the [implementation review](bre_na_rate_comparison_implementation.md) for source semantics, controls, and evidence. The notification source currently ends at analysis date 2026-08-22, so recent anomaly tiles may be empty. Historical DESC queries were used for validation.

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-5-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 3b | User Analytics | Last 7 Days | TODO |
| NA-5-F02 | Date Granularity (Period/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE Ingestion Audit (ED) | Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-5-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-5-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-5-F05 | Email Type (Exclude) | Applied to all tiles in this dashboard | SRE RC Email Anomaly KPI 1 - Starburst | Control Field - email_type, Default - None , Cross filtered with Date range dimension - analysis_date | TODO |
| NA-5-F06 | Promotion (Exclude) | Applied to all tiles in this dashboard | SRE RC Email Anomaly KPI 1 - Starburst | Control Field - missing_promotion_flag, Default - None , Cross filtered with Date range dimension - analysis_date | TODO |

#### 5.a. Data Governance Rate Comparison

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-5A-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension - reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Implemented draft; validation pending |
| NA-5A-T02 | Missing Load Shift Count​ ( < 3 days)- Average | Single Value showing compared to previous period | SRE RC Email Anomaly KPI 1 - Starburst| Average of rc_missing_anomaly, filtered on Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-5A-T03 | Missing Load Shift Count​ ( < 3 days) - Median | Single Value showing compared to previous period | SRE RC Email Anomaly KPI 1 - Starburst | Median of rc_missing_anomaly, filtered on Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-5A-T04 | Distribution - Accuracy % | Gauge Value | SRE RC Email Anomaly KPI 1 - Starburst | average of accuracy_perc, filtered on Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-5A-T05 | Distribution - Deviation % | Gauge Value | SRE RC Email Anomaly KPI 1 - Starburst | average of deviation_perc, filtered on Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-5A-T06 | MS/BP Email Promotion Section Validation (Only Available for DESC-RESI) | Combo chart of Bars and Line | SRE RC Email Anomaly KPI 1 - Starburst | Dimension - X axis - period, Metric - Y axis - Favourable # (sum of favourable_count) - Bar, Anomaly # (sum of anomaly_count) - Bar, Accuracy % (average of accuracy_perc) - Line -- Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-5A-T07 | Track TOU and RC Triggers Post-Invoice (Only Available for DESC-RESI) | Combo chart of Bars and Line | SRE RC Email Anomaly KPI 2 - Starburst | Dimension - X axis - pilot_id_name, Metric - Y axis - Total Invoice # (sum of total_records) - Bar, Missing TOU Trigger # (sum of missing_tou_count) - Bar, Missing RC Trigger # (sum of missing_rc_count) - Bar, Avg Invoice-TOU Trigger Delay (hrs) (average of avg_invoice_to_tou_latency_hrs) - Line, Avg TOU-RC Trigger Delay (hrs) (average of avg_tou_to_rc_latency_hrs) - Line -- Date range dimension - reporting_date | Implemented draft; validation pending |
| NA-5A-T08 | Post-Production Monitoring KPIs – MS/BP Emails, Rate Comparison and Invoice Pipeline (Only Available for DESC-RESI) | Combo chart of Bars and Line | SRE RC Email Anomaly KPI 1 - Starburst | Dimension - X axis - period, Metric - Y axis - RC Out-Of-Order Trigger # (sum of rc_ooo_trigger_anomaly) - Bar, RC Low Latency Trigger # (sum of rc_early_trigger_anomally) - Bar, LS Missing # ( &lt; 3 days) (sum of rc_missing_anomaly) - Bar, LS Low Value # ( &lt; $20) (sum of ls_low_value_anomally) - Bar -- Date range dimension - analysis_date | Implemented draft; validation pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-5A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

<a id="na-email"></a>

### 6. Email

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** All 18 tiles implemented as separate 6a/6b drafts. Native Looker and original-report validation pending.

**Implementation review (2026-10-04):** [6a Data Governance](../dashboards/bre_na_email_governance.dashboard.lookml), `bre_na::bre_na_email_governance`, implements 8 tiles. [6b Queue Metrics](../dashboards/bre_na_email_queue_metrics.dashboard.lookml), `bre_na::bre_na_email_queue_metrics`, implements 10 tiles. See the [implementation review](bre_na_email_implementation.md) for calculations, controls, and validation. The user confirmed `module_name = 'Emailer'` for the SQS Email Module Filter and the documented Metric Toggle/Period expressions. Failure Metric initially displays percentage; the source rank is retained without an undocumented top-N cutoff.

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

#### 6.a. Data Governance Email

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-6A-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 6a | User Analytics | Last 7 Days | TODO |
| NA-6A-F02 | Date Granularity (Daily/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE Ingestion Audit (ED) | Daily / Weekly / Monthly noted; default - Daily, Control Field - Period | TODO |
| NA-6A-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-6A-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-6A-F05 | Reporting Frequency (Reporting Frequency) | Applied to all tiles in this dashboard | SRE Email Daily Weekly Combined Tracking - Starburst  | Control Field - delivery_mode as Reporting Frequency: Daily / Weekly / Monthly noted; default - Daily , Cross filtered with Date range dimension - analysis_date | TODO |
| NA-6A-F06 | Email Type (Email Type) | Applied to all tiles in this dashboard | SRE Email Daily Weekly Combined Tracking - Starburst | Control Field - email_type, Cross filtered with Date range dimension - analysis_date | TODO |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-6A-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension - reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Implemented draft; validation pending |
| NA-6A-T02 | # of Email Delivered - Average | Single Value showing compared to previous period | SRE Email Daily Weekly Combined Tracking - Starburst | Average of delivery_cnt, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6A-T03 | # of Email Delivered - Median | Single Value showing compared to previous period | SRE Email Daily Weekly Combined Tracking - Starburst | Median of delivery_cnt, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6A-T04 | Metrics Average - Generation | Gauge Value  | SRE Email Daily Weekly Combined Tracking - Starburst | average of calc_generation_perc, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6A-T05 | Metrics Average - Delivery | Gauge Value | SRE Email Daily Weekly Combined Tracking - Starburst |  average of calc_delivery_perc, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6A-T06 | Weekly/Daily Email Delivery Statistics | Combo Bar and Line Chart | SRE Email Daily Weekly Combined Tracking - Starburst |  Dimension - X axis - period, Metric - Y axis - Eligible Invoices # (sum of invoice_ingested) - Bar, Email Generation # (sum of generation_cnt) - Bar, Email Delivery # (sum of delivery_cnt) - Bar, average of calc_generation_perc as line graph, average of calc_delivery_perc as line graph -- Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6A-T07 | Weekly Email Reco Quality Report | Stacked Bar Chart | SRE Email Reco Statistics |  Dimension - X axis - Analysis Date, Breakdown dimension - metric_name, Metric - Y axis - % Email (average of notification_pct) , Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6A-T08 | Weekly Top Email Failure Reasons | Stacked Bar Chart | SRE Email Failure Statistics |  Dimension - X axis period, Breakdown dimension - failure_reason, Metric - Y axis - Metric Toggle (average of Metric Toggle) , Date range dimension - analysis_date | Implemented draft; validation pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-6A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

#### 6.b. Queue Metrics Email

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-6B-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 6b | User Analytics | Last 7 Days | TODO |
| NA-6B-F02 | Environment | Applied to all tiles in this dashboards - 6b | SRE SQS Queue Metrics - Starburst | control field - environment , metric- avg of metric_value, filter on this - SQS Email Module Filter | TODO |
| NA-6B-F03 | Module Name | Applied to all tiles in this dashboards - 6b | SRE SQS Queue Metrics - Starburst | control field - module_name , metric- avg of metric_value, filter on this - SQS Email Module Filter | TODO |
| NA-6B-F04 | Queue Type | Applied to all tiles in this dashboards - 6b | SRE SQS Queue Metrics - Starburst | control field - queue_type , metric- avg of metric_value, filter on this - SQS Email Module Filter | TODO |
| NA-6B-F05 | Queue Name | Applied to all tiles in this dashboards - 6b | SRE SQS Queue Metrics - Starburst | control field - queue_name , metric- avg of metric_value, filter on this - SQS Email Module Filter | TODO |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-6B-T01 | Key KPIs - Environment Health Score (A composite score (0-100) combining success rate, backlog, and latency) | Single Value | SRE SQS Queue Health Metrics by Day | average of health_score as Score, filter on this - SQS Email Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6B-T02 | Key KPIs - Total Message Volume (Measures the overall data ingestion activity, indicating system workload) | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), sum of total_message_received, filter on this - SQS Email Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6B-T03 | Key KPIs - Msg Processing Success Rate (Percentage of messages successfully processed) | Single Value | SRE SQS Metrics by Hour - Starburst | average of success_rate as Rate, filter on this - SQS Email Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6B-T04 | Key KPIs - Queue Backlog Volume (Average number of messages waiting in queues. Highlights potential delays or bottlenecks in processing.) | Single Value | SRE SQS Metrics by Hour - Starburst | average of avg_queue_backlog as Avg (per hr), filter on this - SQS Email Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6B-T05 | Trends​ (Line charts by hour) - Message Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), sum of total_messages_received as Total Msg Recieved, filter on this - SQS Email Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-6B-T06 | Trends​ (Line charts by hour) - Backlog Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), average of avg_queue_backlog as Average Queue Backlog, filter on this - SQS Email Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-6B-T07 | Trends​ (Line charts by hour) - Oldest Message Age Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Max of max_latency_in_days, filter on this - SQS Email Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-6B-T08 | Trends​ (Line charts by hour) - Health Score by Queue Name | Stacked Bar Chart | SRE SQS Queue Health Metrics by Day | Dimension - X axis - Analysis Days, Breakdown dimension - queue_name, Avg of health_score as Health Score, filter on this - SQS Email Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-6B-T09 | Trends​ (Line charts by hour) - Processing Efficiency | Line Chart | SRE SQS Queue Metrics by Day - Starburst | Dimension - X axis - Analysis Days, Avg of empty_receives_ratio as Empty Receives Ratio %, filter on this - SQS Email Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-6B-T10 | Trends​ (Line charts by hour) - Delayed Messages Impact | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), sum of delayed_messages as Delayed Messages, filter on this - SQS Email Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |


**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-6B-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

<a id="na-her"></a>

### 7. HER

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** All 17 tiles implemented as separate 7a/7b drafts. Native Looker and original-report validation pending.

**Implementation review (2026-10-04):** [7a Data Governance](../dashboards/bre_na_her_governance.dashboard.lookml), `bre_na::bre_na_her_governance`, implements 7 tiles. [7b Queue Metrics](../dashboards/bre_na_her_queue_metrics.dashboard.lookml), `bre_na::bre_na_her_queue_metrics`, implements 10 tiles. The user supplied SRC-34, confirmed `success_pct = 100 * SUM(actual_generation_count) / SUM(actual_eligible_users)`, and confirmed `module_name = 'HER'` for all queue sources. See the [implementation review](bre_na_her_implementation.md) for source semantics, tests, and current PSEG data limitations.

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

#### 7.a. Data Governance HER

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-7A-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards | User Analytics | Last 7 Days | TODO |
| NA-7A-F02 | Date Granularity (Daily/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE HER Cluster Specific Generation Stats | Control field - period, Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-7A-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-7A-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-7A-F05 | Fuel Type | Applied to all tiles in this dashboard | SRE HER Cluster Specific Generation Stats | Control Field - fuel_type, Date range dimension - analysis_date | TODO |
| NA-7A-F06 | Cluster IDs | Applied to all tiles in this dashboard | SRE HER Cluster Specific Generation Stats | Control Field - cluster_ids, Date range dimension - analysis_date | TODO |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-7A-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension - reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Implemented draft; validation pending |
| NA-7A-T02 | HER Expected vs Generation # - Expected Gen # | Single Value | SRE HER Schedule Specific Statistics | sum of total_eligible_users as Expected_Gen #, filtered on Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7A-T03 | HER Expected vs Generation # - Total Actual Gen # | Single Value | SRE HER Schedule Specific Statistics | sum of total_generated_notification_id as Total_Actual_Gen #, filtered on Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7A-T04 | HER Schedule(s) | Table | SRE HER Schedule Specific Statistics | Dimension - Start (schedule_start), End (schedule_end), Metric - Expt Gen# (sum of total_eligible_users), Actual Gen# (sum of total_generated_notification_id), Failed Gen# (sum of total_failed_notification_id), Schld # (sum of total_scheduled_notification_id), Swept # (sum of total_swept_notification_id), Queued # (sum of total_queued_notification_id), Printed # (sum of total_printed_notification_id), Mailed # (sum of total_mailed_notification_id), Revoked # (sum of total_revoked_notification_id), Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7A-T05 | HER Generation Daily Stats | Combo Chart of Bar and Line | HER Aggregated Generation Stats | Dimension - X axis - Analysis Date, Metric - Y axis - Expected Generation Count (sum of expected_eligible_users) - Bar, Eligible Generation Count (sum of actual_eligible_users) - Bar, Actual Generation Count (sum of actual_generation_count) - Bar, Success % (avg of sucess_pct) - Line, Filtered on Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7A-T06 | Daily HER Quality Report (Only for HER 2.0**) | Line Chart | SRE HER Quality Statistics - Starburst | Dimension - X axis - Analysis Date, Metric - Y axis - BC > 70 days # (sum of high_bc_duration_cnt), Stale BC # (sum of staleness_cnt),Solar Reports with Cost-based Section # (sum of solar_template_cnt), Solar Report for Non-Solar (sum of solar_consistency_cnt), Solar Estimation 0 or Null (sum of solar_generation_cnt), Inconsistency Between Cost & Consumption Across Sections (sum of report_consistency_cnt), BC <23 days (sum of low_bc_duration_cnt),Itemisation Mismatch # (sum of itemization_cnt), Invalid Bill Change Calculations (sum of bill_change_consistency_cnt), EV Report for EV undetected in Itemisation (sum of ev_itemization_cnt), TOU Report for Non-TOU BC # (sum of tou_template_cnt), Missing NBI Unit/Format Token (e.g. "%", "$", "kWh") (sum of nbi_occurence_cnt), Inconsistency in Insight Calculations (>10%) (sum of nbi_value_cnt), Missing Appliances in Itemisation Referenced by NBI Insights (sum of nbi_appliance_itemization_cnt), Missing or Invalid Numeric NBI Insight Value (nbi_non_null_insight_cnt), Unicode in the NBI Insights # (sum of nbi_unicode_cnt), Extreme Insight Values (sum of nbi_extreme_insight_cnt), Season-based Blocked Appliances in NBI Insights # (sum of nbi_seasonal_appliance_cnt), Overall Report # (sum of overall_report_count), Inconsistency in Bill-Change cost between Billing Data and Notification # (bill_change_consistency_cnt) , Filtered on Date range dimension - reporting_date | Implemented draft; validation pending |
| NA-7A-T07 | Daily HER Generation Failure Reasons | Stacked Bar Chart | SRE HER Cluster Specific Failure Rate | Dimension - X axis - analysis_date, Breakdown dimension - Failure Reasons (calc_failure_reason), Metric - Y axis - Failure % or Count from Metric Toggle,Date range dimension - analysis_date | Implemented draft; validation pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-7A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

#### 7.b. Queue Metrics HER

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-7B-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards - 7b | User Analytics | Last 7 Days | TODO |
| NA-7B-F02 | Environment | Applied to all tiles in this dashboards - 7b | SRE SQS Queue Metrics - Starburst | control field - environment , metric- avg of metric_value, filter on this - SQS HER Module Filter | TODO |
| NA-7B-F03 | Module Name | Applied to all tiles in this dashboards - 7b | SRE SQS Queue Metrics - Starburst | control field - module_name , metric- avg of metric_value, filter on this - SQS HER Module Filter | TODO |
| NA-7B-F04 | Queue Type | Applied to all tiles in this dashboards - 7b | SRE SQS Queue Metrics - Starburst | control field - queue_type , metric- avg of metric_value, filter on this - SQS HER Module Filter | TODO |
| NA-7B-F05 | Queue Name | Applied to all tiles in this dashboards - 7b | SRE SQS Queue Metrics - Starburst | control field - queue_name , metric- avg of metric_value, filter on this - SQS HER Module Filter | TODO |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-7B-T01 | Key KPIs - Environment Health Score (A composite score (0-100) combining success rate, backlog, and latency) | Single Value | SRE SQS Queue Health Metrics by Day | average of health_score as Score, filter on this - SQS HER Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7B-T02 | Key KPIs - Total Message Volume (Measures the overall data ingestion activity, indicating system workload) | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), sum of total_message_received, filter on this - SQS HER Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7B-T03 | Key KPIs - Msg Processing Success Rate (Percentage of messages successfully processed) | Single Value | SRE SQS Metrics by Hour - Starburst | average of success_rate as Rate, filter on this - SQS HER Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7B-T04 | Key KPIs - Queue Backlog Volume (Average number of messages waiting in queues. Highlights potential delays or bottlenecks in processing.) | Single Value | SRE SQS Metrics by Hour - Starburst | average of avg_queue_backlog as Avg (per hr), filter on this - SQS HER Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7B-T05 | Trends​ (Line charts by hour) - Message Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), sum of total_messages_received as Total Msg Recieved, filter on this - SQS HER Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-7B-T06 | Trends​ (Line charts by hour) - Backlog Volume Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), average of avg_queue_backlog as Average Queue Backlog, filter on this - SQS HER Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-7B-T07 | Trends​ (Line charts by hour) - Oldest Message Age Over Time | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), Max of max_latency_in_days, filter on this - SQS HER Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-7B-T08 | Trends​ (Line charts by hour) - Health Score by Queue Name | Stacked Bar Chart | SRE SQS Queue Health Metrics by Day | Dimension - X axis - Analysis Days, Breakdown dimension - queue_name, Avg of health_score as Health Score, filter on this - SQS HER Module Filter, Date range dimension - analysis_date | Implemented draft; validation pending |
| NA-7B-T09 | Trends​ (Line charts by hour) - Processing Efficiency | Line Chart | SRE SQS Queue Metrics by Day - Starburst | Dimension - X axis - Analysis Days, Avg of empty_receives_ratio as Empty Receives Ratio %, filter on this - SQS HER Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |
| NA-7B-T10 | Trends​ (Line charts by hour) - Delayed Messages Impact | Line Chart | SRE SQS Metrics by Hour - Starburst | Dimension - X axis - ingestion_hour (Date Hour), sum of delayed_messages as Delayed Messages, filter on this - SQS HER Module Filter, Date range dimension - ingestion_hour (Date Hour) | Implemented draft; validation pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-7B-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.


<a id="na-nbi"></a>

### 8. NBI

- **NA report URL / page names and links:** TODO
- **Purpose / operational questions answered:** TODO
- **Captured by / capture date / evidence link:** TODO
- **Report time zone / refresh or data freshness expectations:** TODO
- **Inventory completeness (tiles captured / total observed, including hidden tiles):** TODO / TODO
- **Capture status / open questions:** 8a and 8b: 8/8 tiles each implemented as separate local drafts. Blend source grouping and all three join keys confirmed on 2026-10-04. Native Looker and original-report validation pending. See [NBI review](bre_na_nbi_implementation.md).

**Controls and inherited filters**

Record one row per visible control or fixed report/page/group filter. Scope must identify the actual pages, sections, or tile IDs. For controls, capture single/multi-select behavior and how available values are populated or constrained by other controls.

#### 8.a. Data Governance NBI

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-8A-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards | User Analytics | Last 7 Days | TODO |
| NA-8A-F02 | Date Granularity (Daily/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE Ingestion Audit (ED) | Control field - period, Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-8A-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-8A-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-8A-T01 | Active Users out of Total | Single Value showing active and total UUIDs (Date range dimension - reporting_date) | SRE All Active Users | pilot_name, total_uuid, active_uuid | Implemented draft; Looker/report parity pending |
| NA-8A-T02 | # of NBI Insight Generation - Average | Single Value compared to previous period | SRE NBI Engine Daily Run Statistics | average of total_users_successful, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8A-T03 | # of NBI Insight Generation - Median | Single Value compared to previous period | SRE NBI Engine Daily Run Statistics | median of total_users_successful, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8A-T04 | Failure Distribution - Format Error | Gauge Value | SRE NBI Engine Daily Run Statistics | average of nbi_200_error_pct, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8A-T05 | Failure Distribution - Value Error  | Gauge Value | SRE NBI Engine Daily Run Statistics | average of nbi_300_error_pct, filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8A-T06 | Daily NBI Generation Statistics | Combo Chart of Bar and Line | SRE NBI Engine Daily Run Statistics | Dimension - X axis - Analysis Date, Metric - Y axis - NBI Users Base (avg of total_users_nbi_generated) - Bar, Successful Generation # (avg of total_users_successful) -  Bar, NBI Success % (avg of nbi_success_pct) - Line ,filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8A-T07 | Daily NBI Users Count With Generic Tag  | Line Chart | SRE NBI Gen Quality Generic Tags | Dimension - X axis - Analysis Date, Metric - Y axis - sum of total_nbi_users_with_generic_tag as NBI Users# with Generic Tag - Line ,filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8A-T08 | Daily Top NBI Failure Reasons Statistics | Stacked Bar Chart | SRE NBI Engine Daily Run Statistics | Dimension - X axis - Analysis Date, Metric - Y axis - NBI_FORMAT_ERROR (200) - avg of total_users_with_200_errorcode, NBI_VALUE_ERROR (300) - avg of total_users_with_300_errorcode ,filtered on Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-8A-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

#### 8.b. EMR Metrics NBI

| Control / filter ID | Exact label and type | Scope / affected sections or tile IDs | Source alias and exact field / parameter | Default, allowed values, selection behavior | Predicate / dependencies / evidence |
| --- | --- | --- | --- | --- | --- |
| NA-8B-F01 | Time Period (Date Filter) | Applied to all tiles in this dashboards | User Analytics | Last 7 Days | TODO |
| NA-8B-F02 | Date Granularity (Daily/Weekly/Monthly) | Applied to all tiles in this dashboard | SRE Ingestion Audit (ED) | Control field - period, Daily / Weekly / Monthly noted; default - Daily | TODO |
| NA-8B-F03 | Pilot ID (Pilot ID) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - 10037 | Cross filtered with Date range dimension - analysis_date |
| NA-8B-F04 | Pilot Name (Pilot Name) | Applied to all tiles in this dashboard | SRE Master Pilot List | Default - PSEG | Cross filtered with Date range dimension - analysis_date |
| NA-8B-F05 | Module Name (Module Name) | Applied to all tiles in this dashboard | SRE NBI EMR Metrics - Starburst | Control field - Module Name (module_name) | Cross filtered with Date range dimension - analysis_date |

| Tile ID | Exact title / specification link | Chart type | Source IDs / aliases | What it shows | Capture status |
| --- | --- | --- | --- | --- | --- |
| NA-8B-T01 | Key KPIs - Total Jobs (Count of all jobs run during the selected period) | Single Value | SRE NBI EMR Metrics - Starburst | shows cluster_id count, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8B-T02 | Key KPIs - Success Rate (Percentage of jobs fully completed without any stage failures) | Single Value | SRE NBI EMR Metrics - Starburst | shows sucess_rate_perc average, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8B-T03 | Key KPIs - Failure Rate (Percentage of Jobs Marked as Failed or Incomplete) | Single Value | SRE NBI EMR Metrics - Starburst | shows failure_rate_perc avg, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8B-T04 | Key KPIs - Average Job Duration (Average time for completion per job) | Single Value | SRE NBI EMR Metrics - Starburst | shows avg of duration_seconds in hh:mm:ss format, Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8B-T05 | Trends​ (Bar/line charts by dates) - Job Execution Overview | Bar Chart | SRE NBI Engine Daily Run Statistics, SRE NBI EMR Metrics - Starburst and SRE NBI Failed Jobs Count - Starburst (inner joins on pilot_id, pilot_id_name and analysis_date) | Dimension - X axis - period, Breakdown dimension - cluster_type, Metric - Y axis - Duration (avg of duration_seconds), Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8B-T06 | Trends​ (Bar/line charts by dates) - NBI Failure Statistics Correlation | Bar and Line Chart | SRE NBI Engine Daily Run Statistics, SRE NBI EMR Metrics - Starburst and SRE NBI Failed Jobs Count - Starburst (inner joins on pilot_id, pilot_id_name and analysis_date) |Dimension - X axis - Analysis Date, Metric - Y axis - Failed Generation# (sum of failure_count), Failed Generation% (avg of nbi_error_pct), Failed Generation% (avg of nbi_error_pct), EMR Failed Jobs# (sum of is_failed), EMR Job Failure% (avg of failure_rate_perc), Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8B-T07 | Trends​ (Bar/line charts by dates) - Failed Jobs vs Total Runs (Scatter Chart) | Scatter Chart | SRE NBI Engine Daily Run Statistics, SRE NBI EMR Metrics - Starburst and SRE NBI Failed Jobs Count - Starburst (inner joins on pilot_id, pilot_id_name and analysis_date)| Dimension - Analysis Date, Metric - X axis - Failed Jobs# (sum of is_failed), Metric - Y axis - Total Jobs Run# (sum of stages_present), Bubble size metric - NBI Interaction Gen Error % (avg of nbi_error_pct), Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |
| NA-8B-T08 | Trends​ (Bar/line charts by dates) - Details | Table | SRE NBI EMR Metrics - Starburst | Dimension - Module (module_name) , Cluster# (cluster_id), creation_time, end_time_str, Stage# (cluster_type),Status (metric_value),Reason (reason_code), Step Status (steps_status), Metric - Duration (sum of duration_seconds), Filter - filter_running (exclude metric_value = RUNNNIG), Date range dimension - analysis_date | Implemented draft; Looker/report parity pending |

**Confirmed shared blend (2026-10-04)**

All three tiles T05–T07 use `SRE_NBI_EMR_FAILURE_CORR_BLEND`. The user supplied the blend-editor screenshot and confirmed both joins use pilot ID, pilot name (`pilot_id_name`), and analysis_date. Both joins are INNER; Period is not a join key.

| Input | Dimensions in the source box | Metrics in the source box | Date range / filters |
| --- | --- | --- | --- |
| SRC-41 / ds352 | analysis_date, nbi_error_pct, failure_count, period, pilot_id_name, pilot_id | None | Auto on analysis_date; no input filter |
| SRC-32 / sre_nbi_emr_metrics_starburst | analysis_date, cluster_id, module_name, cluster_type, metric_name, metric_value, period, pilot_id_name, pilot_id | AVG(duration_seconds), Auto failed_job_cnt, Auto failure_rate_perc | Auto on analysis_date; no input filter |
| SRC-18 / sre_nbi_failed_job_ct_starburst | analysis_date, pilot_id, has_failed_stage, stages_present, period, pilot_id_name | SUM(is_failed) | Auto on analysis_date; no input filter |

The implementation groups each input before joining and retains repeated daily counts across matching EMR groups. See [NBI implementation review](bre_na_nbi_implementation.md) for formulas, validation evidence, and scatter configuration.

**Tile specifications**

TODO: Copy the [tile specification template](#tile-specification-template) here for `NA-8B-T01` and each additional tile. Rename the starter ID if needed to match the actual inventory.

## Tile specification template

Copy from the `TILE-ID` heading through the end of **Future NA implementation mapping** into the relevant section above. Replace placeholders with observed settings; do not infer a metric's aggregation from its label or a tile's source from its title.

##### TILE-ID — Exact chart title

**Identity and purpose**

| Item | Current NA Data Studio / Looker Studio configuration |
| --- | --- |
| Dashboard / section / page | TODO |
| Report/page URL / chart ID if available / screenshot or evidence | TODO |
| Position / size / visible or hidden | TODO: row/order, relative width/height, and visibility conditions |
| Visualization type | TODO: scorecard, time series, table, pivot, bar, text, etc. |
| What this tile shows / question it answers | TODO: explain in plain language, including population and units |
| Capture status / captured by / date | Not started / TODO / TODO |
| Open questions / intentional differences requested for NA LookML | TODO |

**Sources and blends**

For a single source, use one row. For blends, use one row per input and retain each exact alias, even if display names match. Source SQL remains in the linked source record.

| Source ID / link | Exact alias | Role / input order | Row grain / unique keys used by this tile | Source fields used |
| --- | --- | --- | --- | --- |
| TODO: link to SRC-xx | TODO | Primary or blend input TODO | TODO | TODO |

- **Blend configuration:** TODO or confirmed `None`. Capture blend name, join types, join keys with input aliases, input-level grouping/aggregation, and expected join cardinality (one-to-one, one-to-many, etc.).
- **Blend filter/date behavior:** TODO. Record filters and date ranges applied to each input before the join and filters applied after the blend.
- **Source restrictions relevant to this tile:** TODO. Link SQL `WHERE`/`HAVING` restrictions and extract filters/date windows/refresh settings. Note any restriction on the available history or NA population even when dashboard controls allow broader selections.

**Dimensions**

Add a row for every grouping, breakdown, pivot, date, or hidden sorting dimension. Preserve exact source field names and chart labels separately.

| Display label | Exact field / formula reference | Source alias or blend input | Role (group, breakdown, pivot, date, sort) | Type / granularity / formatting | Null handling / value mapping |
| --- | --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO | TODO |

**Metrics**

Record the aggregation actually configured in the chart (`SUM`, `AVG`, `COUNT`, `COUNT_DISTINCT`, `MAX`, `Auto`, etc.). For rates and percentages, capture numerator, denominator, and whether the chart aggregates row-level ratios or computes a ratio of aggregated values. Include hidden metrics used for sorting or comparisons.

| Display label | Exact field / formula reference | Source alias or blend input | Chart aggregation / distinct key | Units / format / decimal places | Null / zero / divide-by-zero behavior |
| --- | --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO | TODO |

**Calculated fields and parameters**

Use this table for chart-specific formulas, overrides, running totals, comparison calculations, and parameter-driven choices. Link unchanged source-level formulas instead of duplicating them.

| Name | Defined in (source, blend, chart) | Original formula / linked definition | Inputs / parameter values and default | Evaluation order / aggregation notes |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

**Date and comparison behavior**

| Setting | Current behavior |
| --- | --- |
| Date-range field / source alias | TODO: include separate fields per blend input if applicable |
| Default date range / fixed override | TODO: relative or absolute range, include/exclude today, completed periods only or partial periods |
| Time zone / date conversion | TODO |
| Period control | TODO: control ID, exact grouping formula, day/week/month options, week start, calendar/fiscal rules |
| Comparison period | TODO or confirmed None: previous equal-length range, previous year, fixed dates; absolute or percentage change formula |
| Missing dates / empty periods / partial data | TODO: omitted, zero-filled, or shown as null; freshness assumptions |

**Dashboard control applicability**

Add a row for every control/inherited filter in the dashboard table, including controls that do not affect this tile. This table will later drive LookML filter/listen mappings.

| Control / filter ID | Applies? (Yes / No / TODO) | Tile field / parameter / blend input | Inherited default or tile override | Dependencies / evidence / reason if ignored |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

**Fixed tile filters**

Record exact include/exclude conditions, values, case sensitivity, and AND/OR grouping. Distinguish dimension filters applied before aggregation from metric filters applied after aggregation. Use confirmed `None` if there are no fixed tile filters.

| Filter name | Field / formula and source alias | Include / exclude | Operator / exact values / AND-OR expression | Application stage / scope |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

**Presentation and interactions**

| Setting | Current behavior |
| --- | --- |
| Sort / secondary sort / ranking | TODO: exact fields, directions, tie behavior |
| Row limit / top N / pagination | TODO: limit, Other bucket, and whether excluded rows contribute to totals |
| Totals / subtotals | TODO: enabled, calculation, and filtered population |
| Axes / series / stacking / labels | TODO: units, scale, series order, legend, and number formatting |
| Conditional formatting / thresholds / reference lines | TODO: exact rules, colors, and thresholds |
| Interactions / drilldowns / cross-filtering / links | TODO: enabled actions and target fields/pages |
| Tooltip / explanatory text / empty-state behavior | TODO |

**Reference result for later validation**

| Capture time / evidence | Date range / time zone | Filter and parameter selections (including defaults) | Expected result / representative rows / units | Allowed tolerance / reason |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

Capture the default state and at least one meaningful filtered state where applicable. Include important edge cases such as an empty result, a zero denominator, or a different Period selection when they change the tile's interpretation. Record data freshness so later comparisons can use equivalent data.

**Future NA implementation mapping**

Complete these after current behavior is captured. Proposed identifiers are planning notes until implemented and validated.

- **Target NA model / dashboard / element ID:** TODO
- **Target Explore / view / fields / source family (if applicable):** TODO
- **Candidate CA/EU equivalent / reuse or NA-specific behavior:** TODO; link the exact file/element if one exists.
- **BRE app dashboard label / navigation grouping / model association:** TODO
- **Implementation status / result-validation evidence / unresolved differences:** Not started / TODO / TODO

## Readiness for NA implementation

Use this checklist after completing the worksheets. Current CA and EU code can guide implementation structure, but the captured NA report defines NA behavior.

- [ ] All eight dashboards and all 13 listed sections have a confirmed tile inventory; additional or excluded sections/pages are recorded explicitly.
- [ ] Every tile has a completed specification, evidence, and `Ready for implementation` status; unknown behavior is resolved or recorded as an agreed exception.
- [ ] Every tile source maps to an exact inventory ID and alias; blends, extracts, and non-SQL connectors have enough configuration to reproduce the result.
- [ ] Every dimension, metric, formula, aggregation, unit, and date/comparison rule is captured, including any chart-level overrides.
- [ ] Every dashboard control has explicit per-tile applicability and field mappings; fixed filters and source restrictions are documented separately.
- [ ] Representative results and filter selections are saved for later comparison with NA LookML output.
- [ ] The NA connection/catalog, model name, dashboard identifiers, and any reused CA/EU views are confirmed before implementation.
- [ ] BRE app integration requirements are captured below before adding NA to the application.

### Future NA model and BRE app integration

| Decision | Planned value / evidence |
| --- | --- |
| NA Looker connection / catalog / schema | TODO |
| Separate NA model identifier / label | TODO |
| Dashboard identifiers and section-to-dashboard mapping | Ingestion: separate 1a `bre_na::bre_na_ingestion_governance` and 1b `bre_na::bre_na_ingestion_queue_metrics`, for later frontend tabs. Other groups: TODO. |
| Shared vs. NA-specific views / Explores / source families | TODO: map from completed tile specifications |
| BRE application repository / configuration location | TODO |
| NA region selector label / navigation order / dashboard labels | TODO |
| Model-to-dashboard associations / routing or embed identifiers | TODO |
| App filter defaults / URL parameters / access requirements | TODO |
| End-to-end verification evidence | TODO: region selection, expected NA dashboards, correct model, filters, and reference results |

Existing implementation references: [CA model](models/bre_ca.model.lkml), [EU model](models/bre_eu.model.lkml), and [CA Ingestion dashboard](dashboards/bre_ca_ingestion.dashboard.lookml). These are references for the later implementation phase, not confirmed NA mappings.

## Source inventory

52 source entries (SRC-01 through SRC-52) are present in their original order. Sources with zero charts are retained. All copied variable counts are zero. The empty `Actions` UI column is omitted. Spelling in source names and aliases is preserved for exact lookup.

| Source | Display name | Alias | Connector | Type | Charts | Variables | Copied status |
| --- | --- | --- | --- | --- | ---: | ---: | --- |
| [SRC-01](#src-01) | SRE SQS Metrics By Hour - Starburst | `sre_sqs_metrics_hour_starburst` | Apps Script Addon | Reusable | 28 | 0 | Working |
| [SRC-02](#src-02) | SRE HER Generation Statistics - Starburst | `ds513` | Apps Script Addon | Reusable | 0 | 0 | Working |
| [SRC-03](#src-03) | SRE HER Cluster Specific Generation Stats | `ds350` | Apps Script Addon | Reusable | 3 | 0 | Working |
| [SRC-04](#src-04) | SRE Invoice Statistics | `ds450` | Extract Data | Reusable | 0 | 0 | Working |
| [SRC-05](#src-05) | SRE Email Daily Weekly Combined Tracking - Starburst | `sre_daily_weekly_combined_tracking_starburst` | Apps Script Addon | Reusable | 8 | 0 | Working |
| [SRC-06](#src-06) | SRE HER Cluster Specific Failure Rate | `ds355` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-07](#src-07) | SRE Quality Disagg - Starburst | `sre_quality_disagg_starburst` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-08](#src-08) | SRE Invoice Statistics #1 | `ds502` | Extract Data | Reusable | 4 | 0 | Working |
| [SRC-09](#src-09) | SRE Email Daily Tracker - Starburst | `sre_email_daily_tracker_starburst` | Apps Script Addon | Reusable | 0 | 0 | Working |
| [SRC-10](#src-10) | SRE Quality Disagg New - Starburst | `sre_quality_disagg_new_starburst` | Apps Script Addon | Reusable | 2 | 0 | Working |
| [SRC-11](#src-11) | User Analytics | `ds49` | Google Analytics | Reusable | 42 | 0 | Working |
| [SRC-12](#src-12) | SRE HER QC Data PSEG - Starburst | `sre_her_qc_data_pseg_starburst` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-13](#src-13) | SRE HER Cluster Specific Failure Rate #1 | `ds503` | Extract Data | Reusable | 3 | 0 | Working |
| [SRC-14](#src-14) | SRE Post Ingestion Data Quality | `ds342` | Apps Script Addon | Reusable | 5 | 0 | Working |
| [SRC-15](#src-15) | SRE Rate Comparison Tracker #1 | `ds504` | Extract Data | Open | 1 | 0 | Working |
| [SRC-16](#src-16) | SRE All Active Users #1 | `ds505` | Extract Data | Reusable | 1 | 0 | Working |
| [SRC-17](#src-17) | SRE Rate Comparison Tracker | `ds453` | Extract Data | Reusable | 1 | 0 | Working |
| [SRC-18](#src-18) | SRE_NBI_FALED_JOB_COUNT - Starburst | `sre_nbi_failed_job_ct_starburst` | Apps Script Addon | Reusable | 3 | 0 | Working |
| [SRC-19](#src-19) | SRE HER Quality Statistics (non-PSEG) - Starburst | `sre_her_quality_stats_starburst` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-20](#src-20) | SRE NBI Gen Quality Generic Tag | `ds351` | Apps Script Addon | Reusable | 2 | 0 | Working |
| [SRC-21](#src-21) | SRE RC Email Anomaly KPI 2 - Starburst | `sre_rc_email_anomaly_kpi_2_starurst` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-22](#src-22) | SRE HER Schedule Specific Statistics | `ds357` | Apps Script Addon | Reusable | 3 | 0 | Working |
| [SRC-23](#src-23) | SRE Master Pilot List #1 | `ds506` | Extract Data | Reusable | 1 | 0 | Working |
| [SRC-24](#src-24) | SRE SQS Queue Metrics By Day - Starburst | `sre_sqs_queue_day_starburst` | Apps Script Addon | Reusable | 4 | 0 | Working |
| [SRC-25](#src-25) | SRE Failure Statistics - Starburst | `sre_failure_stats_starburst` | Apps Script Addon | Reusable | 2 | 0 | Working |
| [SRC-26](#src-26) | SRE Email Reco Statistics #1 | `ds507` | Extract Data | Reusable | 2 | 0 | Working |
| [SRC-27](#src-27) | SRE Ingestion Failure Statistics #1 | `ds509` | Extract Data | Reusable | 4 | 0 | Working |
| [SRC-28](#src-28) | SRE RC Email Anomaly KPI 1 - Starburst | `sre_rc_email_anomaly_kpi_1_starburst` | Apps Script Addon | Reusable | 8 | 0 | Working |
| [SRC-29](#src-29) | SRE Aggregation Stats | `ds486` | Extract Data | Reusable | 1 | 0 | Working |
| [SRC-30](#src-30) | HER Aggregated Generation Stats #1 | `ds510` | Extract Data | Reusable | 2 | 0 | Working |
| [SRC-31](#src-31) | SRE Billing Cycle Length | `ds388` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-32](#src-32) | SRE NBI EMR Metrics - Starburst | `sre_nbi_emr_metrics_starburst` | Apps Script Addon | Reusable | 9 | 0 | Working |
| [SRC-33](#src-33) | SRE Email Failure Statistics #1 | `ds511` | Extract Data | Reusable | 4 | 0 | Working |
| [SRC-34](#src-34) | HER Aggregated Generation Stats | `ds466` | Extract Data | Reusable | 1 | 0 | Working |
| [SRC-35](#src-35) | SRE TOU Appliance Batch Aggregation | `ds367` | Apps Script Addon | Reusable | 9 | 0 | Working |
| [SRC-36](#src-36) | SRE Invoice Stats New - Starburst | `sre_invoice_stats_new_starburst` | Apps Script Addon | Reusable | 5 | 0 | Working |
| [SRC-37](#src-37) | SRE Failure Statistics | `ds451` | Extract Data | Reusable | 0 | 0 | Working |
| [SRC-38](#src-38) | SRE Ingestion Audit (ED) #1 | `ds512` | Extract Data | Reusable | 6 | 0 | Working |
| [SRC-39](#src-39) | SRE Email Statistics - Starburst | `sre_email_stats_starburst` | Apps Script Addon | Reusable | 0 | 0 | Working |
| [SRC-40](#src-40) | SRE Aggregation Stats #1 | `ds501` | Extract Data | Reusable | 10 | 0 | Working |
| [SRC-41](#src-41) | SRE NBI Engine Daily Run Statistics | `ds352` | Apps Script Addon | Reusable | 11 | 0 | Working |
| [SRC-42](#src-42) | SRE Ingestion Audit (ED) | `ds449` | Extract Data | Reusable | 1 | 0 | Working |
| [SRC-43](#src-43) | SRE Invoice Statistics - Starburst | `sre_invoice_stats_starburst` | Apps Script Addon | Reusable | 0 | 0 | Working |
| [SRC-44](#src-44) | SRE All Active Users | `ds343` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-45](#src-45) | HER Aggregated Generation Stats | `ds468` | Apps Script Addon | Reusable | 0 | 0 | Working |
| [SRC-46](#src-46) | SRE SQS Queue Metrics - Starburst | `sre_sqs_queue_metrics_starburst` | Apps Script Addon | Reusable | 16 | 0 | Working |
| [SRC-47](#src-47) | SRE Ingestion Audit - Starburst | `sre_ingestion_audit_starburst` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-48](#src-48) | SRE HER Quality Statistics - Starburst | `sre_her_quality_stats_starburst_1` | Apps Script Addon | Reusable | 1 | 0 | Working |
| [SRC-49](#src-49) | SRE Invoice Stat Simple - Starburst | `sre_invoice_stat_simple_starburst` | Apps Script Addon | Reusable | 0 | 0 | Working |
| [SRC-50](#src-50) | SRE Master Pilot List | `ds508` | Apps Script Addon | Reusable | 0 | 0 | Working |
| [SRC-51](#src-51) | SRE Failure Statistics New - Starburst | `sre_failure_stats_startburst` | Apps Script Addon | Reusable | 4 | 0 | Working |
| [SRC-52](#src-52) | SRE SQS Queue Health Metrics By Day | `ds341` | Apps Script Addon | Reusable | 8 | 0 | Working |

## Source query records

Each record corresponds to exactly one inventory alias. All mappings, backend details, and SQL below are pending unless explicitly filled in. For an extract or a non-SQL connector, the source definition may be a reference/configuration instead of executable SQL.

### Optional field format

Each source has separate tables for additional dimensions and metrics created outside its SQL. Add one row per field and preserve the exact formula in its original expression language. `Defined in` records the tool and scope, such as a Looker Studio data source, a specific chart, or a LookML view. Include the chart/view name when relevant.

For metrics, record the configured aggregation separately from the formula; use `Auto` or `None` only when confirmed. Output type/format can describe Date & Time, Number, Percent, or a custom display format. Use `TODO` for details not yet captured. If a source has no additional dimensions or metrics, replace that table's placeholder row with `None` in the first column and dashes in the remaining columns. A `TODO` row does not mean there are no fields.

Long formulas can be placed in a fenced `text` block below the table and referenced by field name. Additional notes about filters, null handling, or affected tiles can also go below the relevant table. These formulas are separate from source SQL and have not been translated to Trino.

### SRC-01

- **Name:** SRE SQS Metrics By Hour - Starburst
- **Alias:** `sre_sqs_metrics_hour_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query and three additional field formulas captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_sqs_metrics_hour_starburst.
-- engine: starburst
SELECT
    date_format(date_trunc('hour', analysis_date) AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS ingestion_hour_str,
    environment,
    module_name,
    queue_type,
    queue_name,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) AS total_messages_received,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesSent' THEN metric_value ELSE 0 END) AS total_messages_sent,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) AS total_messages_deleted,
    AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) AS avg_queue_backlog,
    MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) AS max_latency,
    -- Success rate calculation (percentage)
    ROUND(
        SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0),
    2) AS success_rate,  -- Rounded to 2 decimal places
    SUM(CASE WHEN metric_name = 'ApproximateNumberOfMessagesDelayed' THEN metric_value ELSE 0 END) AS delayed_messages
FROM reporting.sre_queue_metrics_fact
WHERE analysis_date >= current_timestamp - INTERVAL '7' DAY  -- Reduce the date range (11.8M+ unfiltered rows otherwise -> connector timeout)
GROUP BY date_trunc('hour', analysis_date), environment, module_name, queue_type, queue_name
ORDER BY date_trunc('hour', analysis_date) DESC
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| `ingestion_hour` | `PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", ingestion_hour_str)` | Date & Time | TODO |
| `max_latency_in_days` | `max_latency/86400` | Number | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | `count(module_name)` | Formula uses COUNT; configured aggregation: TODO | Number | TODO |

### SRC-02

- **Name:** SRE HER Generation Statistics - Starburst
- **Alias:** `ds513`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds513.
-- engine: starburst
SELECT
    coalesce(CAST(m.pilot_id AS VARCHAR), s.pilot_id) || ' : ' || coalesce(m.pilot_name, 'Unknown Pilot') AS pilot_id_name,
    s.*
FROM
    reporting.sre_quality_her_statistics s
LEFT JOIN
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-03

- **Name:** SRE HER Cluster Specific Generation Stats
- **Alias:** `ds350`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds350.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events
) AS m
JOIN
(
select pilot_id,cluster_id,analysis_date,schedule_start,schedule_end,fuel_type,'Daily' as "Period",
expected_eligible_users as expected_eligible_users,
actual_eligible_users as actual_eligible_users,
actual_generation_count as actual_generation_count,
expected_eligible_users-actual_generation_count as weekly_actual_failure_count,last_updated_timestamp
from
(
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
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
and a.measurement_type=b.measurement_type
)
union all
select pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,'Weekly' as "Period",
max(expected_eligible_users) as weekly_expected_eligible_users,
max(actual_eligible_users) as weekly_actual_eligible_users,
sum(actual_generation_count) as weekly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as weekly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
COALESCE(a.pilot_id, b.pilot_id) AS pilot_id,
COALESCE(a.cluster_id, b.cluster_id) AS cluster_id,
COALESCE(a.analysis_date, b.analysis_date) AS analysis_date,
COALESCE(a.reporting_date, b.reporting_date) AS reporting_date,
CAST(date_trunc('week', COALESCE(a.analysis_date, b.analysis_date)) AS DATE) AS analysis_week,
COALESCE(a.schedule_start, b.schedule_start) AS schedule_start,
COALESCE(a.schedule_end, b.schedule_end) AS schedule_end,
COALESCE(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,'Weekly'
union all
select pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,'Monthly' as "Period",
max(expected_eligible_users) as monthly_expected_eligible_users,
max(actual_eligible_users) as monthly_actual_eligible_users,
sum(actual_generation_count) as monthly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as monthly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
COALESCE(a.pilot_id, b.pilot_id) AS pilot_id,
COALESCE(a.cluster_id, b.cluster_id) AS cluster_id,
COALESCE(a.analysis_date, b.analysis_date) AS analysis_date,
COALESCE(a.reporting_date, b.reporting_date) AS reporting_date,
CAST(date_trunc('month', COALESCE(a.analysis_date, b.analysis_date)) AS DATE) AS analysis_month,
COALESCE(a.schedule_start, b.schedule_start) AS schedule_start,
COALESCE(a.schedule_end, b.schedule_end) AS schedule_end,
COALESCE(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,'Monthly'
)AS s ON m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period_date | CASE
    WHEN period="Daily" then analysis_date
    WHEN period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| actual_eligible_users_sum | CASE
  WHEN period = "Daily" THEN SUM(actual_eligible_users)
  WHEN period = "Weekly" THEN MAX(actual_eligible_users) + 3 * MAX(actual_generation_count)
  WHEN period = "Monthly" THEN MAX(actual_eligible_users) + 3 * MAX(actual_generation_count)
END
 | TODO | Number | TODO |
| daily_expected_elligible_users | SUM(expected_eligible_users) | TODO | Number | TODO |
| days_in_current_period | COUNT_DISTINCT(FORMAT_DATETIME("%Y-%m-%d", period_date)) | TODO | Number | TODO |
| expected_eligible_users_agg | CASE
  WHEN period = "Daily" THEN SUM(expected_eligible_users)
  WHEN period = "Weekly" THEN MAX(expected_eligible_users)
  WHEN period = "Monthly" THEN MAX(expected_eligible_users)
END
 | TODO | Number | TODO |
| success_pct | 100*SUM(actual_generation_count)/actual_eligible_users_sum | TODO | Number | TODO |

### SRC-04

- **Name:** SRE Invoice Statistics
- **Alias:** `ds450`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL supplied; NA Disaggregation local and Starburst planning checks pass. Native Looker and original-report comparison remain pending.

#### Source SQL

```sql
-- based on SRE Invoice Statistics - Starburst
-- engine: starburst
Select *
from
(
    SELECT
    s.pilot_id  || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name,
    s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
    COALESCE(s.failed_itemisation_pct,0) as failed_itemisation_pct,
    COALESCE(s.successful_itemisation_pct,0) as successful_itemisation_pct,
    s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
    s.fuel_type,module_name, s.analysis_date,s.delay_in_days,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
    FROM (select * from reporting.sre_invoice_statistics where trigger_flag='SCHEDULED')s left join
    (
        SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
        FROM reporting.pilot_consolidated_product_type_events
    ) as m
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
) where rnk=1
union all
Select *
from
(
    SELECT
    s.pilot_id  || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name,
    s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
    COALESCE(s.failed_itemisation_pct,0) as failed_itemisation_pct,
    COALESCE(s.successful_itemisation_pct,0) as successful_itemisation_pct,
    s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
    s.fuel_type,module_name, s.analysis_date,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
    FROM (select * from reporting.sre_invoice_statistics where trigger_flag='ADHOC')s left join
    (
        SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
        FROM reporting.pilot_consolidated_product_type_events
    ) as m
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
) where rnk=1
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

**Disaggregation calculated-field confirmation:** The user confirmed conditional success for SCHEDULED delay 2 / delay 7 and ADHOC correction, each returning NULL outside its condition; failed percentage is zero for NULL, otherwise `failed_itemisation_pct / 100`. `daily_total_invoice#` is `CASE WHEN COUNT_DISTINCT(analysis_date) = 1 THEN AVG(total_invoices) ELSE SUM(total_invoices) END`; Record Count is `COUNT(pilot_id)`. See the implementation review for chart-specific aggregations.

### SRC-05

- **Name:** SRE Email Daily Weekly Combined Tracking - Starburst
- **Alias:** `sre_daily_weekly_combined_tracking_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** Email NA-6A-T02 through T06.
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract/semantic checks, Starburst planning, and bounded sample execution pass. Native Looker/original-report validation pending; see [Email review](bre_na_email_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias sre_daily_weekly_combined_tracking_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events) m
JOIN
    (SELECT
        pilot_id,
        analysis_date,
        reporting_date,
        email_type,
        delivery_mode,
        delivery_cnt,
        generation_cnt,
        invoice_ingested,
        generation_rate,
        delivery_rate,
        last_updated_timestamp
    FROM (
        SELECT
            pilot_id,
            analysis_date,
            reporting_date,
            email_type,
            'Daily' AS delivery_mode,
            delivered_notification_id AS delivery_cnt,
            generated_notification_id AS generation_cnt,
            invoice_ingested,
            CASE
                WHEN invoice_ingested > 0
                THEN (CAST(generated_notification_id AS DOUBLE) / CAST(invoice_ingested AS DOUBLE))
                ELSE CAST(0 AS DOUBLE)
            END AS generation_rate,
            CASE
                WHEN generated_notification_id > 0
                THEN (CAST(delivered_notification_id AS DOUBLE) / CAST(generated_notification_id AS DOUBLE))
                ELSE CAST(0 AS DOUBLE)
            END AS delivery_rate,
            last_updated_timestap AS last_updated_timestamp
        FROM reporting.sre_email_daily_tracker
        WHERE analysis_date IS NOT NULL

        UNION ALL

        SELECT
            pilot_id,
            CAST(analysis_date AS DATE) AS analysis_date,
            CAST(reporting_date AS DATE) AS reporting_date,
            email_type,
            'Weekly' AS delivery_mode,
            CAST(cnt_bills_emails_delivered AS BIGINT) AS delivery_cnt,
            CAST(cnt_bills_emails_sent AS BIGINT) AS generation_cnt,
            CAST(cnt_bills_ingested AS BIGINT) AS invoice_ingested,
            CASE
                WHEN CAST(cnt_bills_ingested AS BIGINT) > 0
                THEN (CAST(cnt_bills_emails_sent AS DOUBLE) / CAST(CAST(cnt_bills_ingested AS BIGINT) AS DOUBLE))
                ELSE CAST(0 AS DOUBLE)
            END AS generation_rate,
            CASE
                WHEN CAST(cnt_bills_emails_sent AS BIGINT) > 0
                THEN (CAST(cnt_bills_emails_delivered AS DOUBLE) / CAST(CAST(cnt_bills_emails_sent AS BIGINT) AS DOUBLE))
                ELSE CAST(0 AS DOUBLE)
            END AS delivery_rate,
            last_updated_timestamp
        FROM reporting.sre_quality_email_stats
        WHERE analysis_date IS NOT NULL
    ) union_stats) s
ON CAST(m.pilot_id AS VARCHAR) = s.pilot_id
ORDER BY pilot_id_name, analysis_date, delivery_mode
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| last_updated_timestamp | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", last_updated_timestamp_str) | Date & Time | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| calc_delivery_perc | SUM(delivery_cnt)/SUM(generation_cnt) | TODO | Number | TODO |
| calc_generation_perc | SUM(generation_cnt) / SUM(invoice_ingested) | TODO | Number | TODO |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-06

- **Name:** SRE HER Cluster Specific Failure Rate
- **Alias:** `ds355`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** HER NA-7A-T07.
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract/semantic checks and Starburst planning pass. Native Looker/original-report validation pending; see [HER review](bre_na_her_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias ds355.
-- engine: starburst
with cte as
(
    select analysis_date,reporting_date,pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Daily' as "Period",
    failure_count,last_updated_timestamp
    from reporting.sre_her_schedule_errors
    union all
    select CAST(date_trunc('week', analysis_date) AS DATE) as analysis_date, CAST(date_trunc('week', reporting_date) AS DATE) as reporting_date,
    pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Weekly' as "Period",
    sum(failure_count) as failure_count,max(last_updated_timestamp) as last_updated_timestamp
    from reporting.sre_her_schedule_errors
    group by 1,2,3,4,5,6,7,8
    union all
    select CAST(date_trunc('month', analysis_date) AS DATE) as analysis_date, CAST(date_trunc('month', reporting_date) AS DATE) as reporting_date,
    pilot_id,cluster_id,schedule_start,schedule_end,failure_reason,measurement_type,'Monthly' as "Period",
    sum(failure_count) as failure_count,max(last_updated_timestamp) as last_updated_timestamp
    from reporting.sre_her_schedule_errors
    group by 1,2,3,4,5,6,7,8
),
her_errors as
(
select pilot_id,cluster_id,schedule_start,schedule_end,measurement_type as fuel_type,failure_reason,failure_count,
    SUM(failure_count) OVER (
        PARTITION BY pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date,reporting_date
    ) as total_failure_count,
    "period", analysis_date, reporting_date,
    round(
        (100.00*failure_count) / SUM(failure_count) OVER (
            PARTITION BY pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date,reporting_date
        ), 2
    ) as failure_percentage,
    last_updated_timestamp,
    ROW_NUMBER() OVER (PARTITION BY pilot_id,cluster_id,schedule_start,schedule_end,measurement_type,"period",analysis_date ORDER BY failure_count DESC) AS rank
from cte
)
select  CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,s.*
from her_errors s
join
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events
) as m ON m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| calc_failure_reason | IFNULL(failure_reason,'UNKNOWN') | Text | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| calc_failure_perc | 100*SUM(failure_count)/SUM(total_failure_count) | TODO | Number | TODO |
| Metric Toggle | CASE
  WHEN Metric = 'failure_percentage' THEN calc_failure_perc
  WHEN Metric = 'failure_count' THEN SUM(failure_count)
END | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Metric | failure_percentage (% Failure)/failure_count (# Failure) | TODO | TODO | TODO |

### SRC-07

- **Name:** SRE Quality Disagg - Starburst
- **Alias:** `sre_quality_disagg_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_quality_disagg_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_quality_disagg s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| last_updated_timestamp | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", last_updated_timestamp_str) | Date & Time | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date_d
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date_d, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date_d, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-08

- **Name:** SRE Invoice Statistics #1
- **Alias:** `ds502`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds502.
-- same as SRE Invoice Statistics (Extract Data)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |



### SRC-09

- **Name:** SRE Email Daily Tracker - Starburst
- **Alias:** `sre_email_daily_tracker_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_email_daily_tracker_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_email_daily_tracker s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| last_updated_timestamp | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", last_updated_timestamp) | Date & Time | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-10

- **Name:** SRE Quality Disagg New - Starburst
- **Alias:** `sre_quality_disagg_new_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_quality_disagg_new_starburst.
-- engine: starburst
WITH
    bounds AS (
        SELECT MIN(CAST(analysis_date AS DATE)) AS min_date, MAX(CAST(analysis_date AS DATE)) AS max_date
        FROM reporting.sre_quality_disagg
    ),
    anchors AS (
        SELECT
            CAST(date_add('day', -1 * (day_of_week(MIN(min_date)) % 7), MIN(min_date)) AS DATE) AS week_anchor,
            CAST(date_trunc('month', MIN(min_date)) AS DATE) AS month_anchor
        FROM bounds
    ),

-- Daily records - unchanged
daily AS (
    SELECT
        pilot_id,
        reporting_date,
        analysis_date,
        meter_type,
        fuel_type,
        istou,
        appliances_kwh_variance_pct_1,
        appliances_kwh_variance_pct_2,
        total_cost_deviation_pct_1,
        total_cost_deviation_pct_2,
        cost_per_kwh_deviation_pct,
        seasonal_appliance_usage_deviation_pct,
        single_appliance_domination_deviation_pct,
        missing_dwelliing_pct,
        ao_pct_non_tou,
        ac_pct_non_tou,
        sh_pct_non_tou,
        other_pct_non_tou,
        solar_pct_non_tou,
        missing_solar_pct_non_tou,
        last_updated_timestamp,
        'Daily' AS period
    FROM reporting.sre_quality_disagg
),

-- Weekly aggregation with proper reporting_date
weekly_base AS (
    SELECT
        pilot_id,
        CAST(analysis_date AS DATE) AS analysis_date_dt,
        CAST(date_add('day', (date_diff('day', a.week_anchor, CAST(analysis_date AS DATE)) / 7) * 7, a.week_anchor) AS DATE) AS week_start,
        meter_type,
        fuel_type,
        istou,
        appliances_kwh_variance_pct_1,
        appliances_kwh_variance_pct_2,
        total_cost_deviation_pct_1,
        total_cost_deviation_pct_2,
        cost_per_kwh_deviation_pct,
        seasonal_appliance_usage_deviation_pct,
        single_appliance_domination_deviation_pct,
        missing_dwelliing_pct,
        ao_pct_non_tou,
        ac_pct_non_tou,
        sh_pct_non_tou,
        other_pct_non_tou,
        solar_pct_non_tou,
        missing_solar_pct_non_tou,
        last_updated_timestamp
    FROM reporting.sre_quality_disagg
        CROSS JOIN anchors a
),
weekly AS (
    SELECT
        pilot_id,
        CAST(MAX(analysis_date_dt) AS VARCHAR) AS reporting_date, -- Latest date in the week
        CAST(week_start AS VARCHAR) AS analysis_date, -- Week start
        meter_type,
        fuel_type,
        istou,
        AVG(appliances_kwh_variance_pct_1) AS appliances_kwh_variance_pct_1,
        AVG(appliances_kwh_variance_pct_2) AS appliances_kwh_variance_pct_2,
        AVG(total_cost_deviation_pct_1) AS total_cost_deviation_pct_1,
        AVG(total_cost_deviation_pct_2) AS total_cost_deviation_pct_2,
        AVG(cost_per_kwh_deviation_pct) AS cost_per_kwh_deviation_pct,
        AVG(
            seasonal_appliance_usage_deviation_pct
        ) AS seasonal_appliance_usage_deviation_pct,
        AVG(
            single_appliance_domination_deviation_pct
        ) AS single_appliance_domination_deviation_pct,
        AVG(missing_dwelliing_pct) AS missing_dwelliing_pct,
        AVG(ao_pct_non_tou) AS ao_pct_non_tou,
        AVG(ac_pct_non_tou) AS ac_pct_non_tou,
        AVG(sh_pct_non_tou) AS sh_pct_non_tou,
        AVG(other_pct_non_tou) AS other_pct_non_tou,
        AVG(solar_pct_non_tou) AS solar_pct_non_tou,
        AVG(missing_solar_pct_non_tou) AS missing_solar_pct_non_tou,
        MAX(last_updated_timestamp) AS last_updated_timestamp,
        'Weekly' AS period
    FROM weekly_base
    GROUP BY
        pilot_id,
        week_start,
        meter_type,
        fuel_type,
        istou
),

-- Monthly aggregation with proper reporting_date
monthly_base AS (
    SELECT
        pilot_id,
        CAST(analysis_date AS DATE) AS analysis_date_dt,
        CAST(date_add('month', date_diff('month', a.month_anchor, CAST(analysis_date AS DATE)), a.month_anchor) AS DATE) AS month_start,
        meter_type,
        fuel_type,
        istou,
        appliances_kwh_variance_pct_1,
        appliances_kwh_variance_pct_2,
        total_cost_deviation_pct_1,
        total_cost_deviation_pct_2,
        cost_per_kwh_deviation_pct,
        seasonal_appliance_usage_deviation_pct,
        single_appliance_domination_deviation_pct,
        missing_dwelliing_pct,
        ao_pct_non_tou,
        ac_pct_non_tou,
        sh_pct_non_tou,
        other_pct_non_tou,
        solar_pct_non_tou,
        missing_solar_pct_non_tou,
        last_updated_timestamp
    FROM reporting.sre_quality_disagg
        CROSS JOIN anchors a
),
monthly AS (
    SELECT
        pilot_id,
        CAST(MAX(analysis_date_dt) AS VARCHAR) AS reporting_date, -- Latest date in the month
        CAST(month_start AS VARCHAR) AS analysis_date, -- Month start
        meter_type,
        fuel_type,
        istou,
        AVG(appliances_kwh_variance_pct_1) AS appliances_kwh_variance_pct_1,
        AVG(appliances_kwh_variance_pct_2) AS appliances_kwh_variance_pct_2,
        AVG(total_cost_deviation_pct_1) AS total_cost_deviation_pct_1,
        AVG(total_cost_deviation_pct_2) AS total_cost_deviation_pct_2,
        AVG(cost_per_kwh_deviation_pct) AS cost_per_kwh_deviation_pct,
        AVG(
            seasonal_appliance_usage_deviation_pct
        ) AS seasonal_appliance_usage_deviation_pct,
        AVG(
            single_appliance_domination_deviation_pct
        ) AS single_appliance_domination_deviation_pct,
        AVG(missing_dwelliing_pct) AS missing_dwelliing_pct,
        AVG(ao_pct_non_tou) AS ao_pct_non_tou,
        AVG(ac_pct_non_tou) AS ac_pct_non_tou,
        AVG(sh_pct_non_tou) AS sh_pct_non_tou,
        AVG(other_pct_non_tou) AS other_pct_non_tou,
        AVG(solar_pct_non_tou) AS solar_pct_non_tou,
        AVG(missing_solar_pct_non_tou) AS missing_solar_pct_non_tou,
        MAX(last_updated_timestamp) AS last_updated_timestamp,
        'Monthly' AS period
    FROM monthly_base
    GROUP BY
        pilot_id,
        month_start,
        meter_type,
        fuel_type,
        istou
),

-- Combine all periods
stats AS (
    SELECT *
    FROM daily
    UNION ALL
    SELECT *
    FROM weekly
    UNION ALL
    SELECT *
    FROM monthly
)

-- Join with pilot information
SELECT CAST(m.pilot_id AS VARCHAR) || ' : ' || COALESCE(m.pilot_name, '') AS pilot_id_name, s.*
FROM stats s
    JOIN (
        SELECT
            pilot_id, CASE
                WHEN POSITION('(' IN pilot_name) > 0 THEN SUBSTRING(
                    pilot_name
                    FROM POSITION('(' IN pilot_name)
                )
                ELSE pilot_name
            END AS pilot_name
        FROM reporting.pilot_consolidated_product_type_events
    ) m ON s.pilot_id = CAST(m.pilot_id AS VARCHAR)
ORDER BY s.analysis_date DESC, s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| last_updated_timestamp | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", last_updated_timestamp_str) | Date & Time | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | COUNT(pilot_id) | TODO | TODO | TODO |

### SRC-11

- **Name:** User Analytics
- **Alias:** `ds49`
- **Connector:** Google Analytics
- **Dashboard section / tiles:** TODO
- **Property / connector configuration:** TODO; SQL applicability is unconfirmed.
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds49.
-- not required in looker, data studio base source
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-12

- **Name:** SRE HER QC Data PSEG - Starburst
- **Alias:** `sre_her_qc_data_pseg_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_her_qc_data_pseg_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    (select

pilot_id,

CAST(reporting_date AS DATE) as reporting_date,

CAST(analysis_date AS DATE) as analysis_date,

COALESCE(revoked_low_bc_duration, 0) AS revoked_low_bc_duration,

COALESCE(revoked_solar_user, 0) AS revoked_solar_user,

COALESCE(revoked_BB_with_cost, 0) AS revoked_BB_with_cost,

COALESCE(revoked_NBB_with_consumption, 0) AS revoked_NBB_with_consumption,

COALESCE(revoked_stale_BC, 0) AS revoked_stale_BC,

COALESCE(revoked_zero_Billing, 0) AS revoked_zero_Billing,

COALESCE(revoked_solar_cluster, 0) AS revoked_solar_cluster,

COALESCE(revoked_survey_check_failed, 0) AS revoked_survey_check_failed,

COALESCE(revoked_itemization_check_failed, 0) AS revoked_itemization_check_failed,

COALESCE(homecategorization_BB_both_known, 0) AS homecategorization_BB_both_known,

COALESCE(homecategorization_NBB_both_known, 0) AS homecategorization_NBB_both_known,

COALESCE(homecategorization_NBB_both_unknown, 0) AS homecategorization_NBB_both_unknown,

COALESCE(homecategorization_BB_both_unknown, 0) AS homecategorization_BB_both_unknown,

COALESCE(homecategorization_BB_LA_unknown, 0) AS homecategorization_BB_LA_unknown,

COALESCE(homecategorization_NBB_LA_unknown, 0) AS homecategorization_NBB_LA_unknown,

COALESCE(homecategorization_NBB_dwelling_unknown, 0) AS homecategorization_NBB_dwelling_unknown,

COALESCE(homecategorization_BB_dwelling_unknown, 0) AS homecategorization_BB_dwelling_unknown,

COALESCE(costconsumption_NBB_COST_COST, 0) AS costconsumption_NBB_COST_COST,

COALESCE(costconsumption_BB_CONSUMPTION_CONSUMPTION, 0) AS costconsumption_BB_CONSUMPTION_CONSUMPTION,

COALESCE(costconsumption_NBB_null_COST, 0) AS costconsumption_NBB_null_COST,

COALESCE(costconsumption_BB_null_CONSUMPTION, 0) AS costconsumption_BB_null_CONSUMPTION,

COALESCE(costconsumption_NBB_COST_null, 0) AS costconsumption_NBB_COST_null,

COALESCE(costconsumption_NBB_null_null, 0) AS costconsumption_NBB_null_null,

COALESCE(costconsumption_BB_CONSUMPTION_null, 0) AS costconsumption_BB_CONSUMPTION_null,

COALESCE(costconsumption_BB_null_null, 0) AS costconsumption_BB_null_null,

COALESCE(itemisationshc_NBB_Y_Y, 0) AS itemisationshc_NBB_Y_Y,

COALESCE(itemisationshc_BB_Y_Y, 0) AS itemisationshc_BB_Y_Y,

COALESCE(itemisationshc_NBB_N_Y, 0) AS itemisationshc_NBB_N_Y,

COALESCE(itemisationshc_BB_N_Y, 0) AS itemisationshc_BB_N_Y,

COALESCE(itemisationshc_NBB_Y_N, 0) AS itemisationshc_NBB_Y_N,

COALESCE(itemisationshc_NBB_N_N, 0) AS itemisationshc_NBB_N_N,

COALESCE(itemisationshc_BB_Y_N, 0) AS itemisationshc_BB_Y_N,

COALESCE(itemisationshc_BB_N_N, 0) AS itemisationshc_BB_N_N,

'Daily' as "Period",

last_updated_timestamp

from reporting.sre_her_qc_data_budget_billing

union all

select

pilot_id,

CAST(date_trunc('week', CAST(reporting_date AS DATE)) AS DATE) as reporting_date,

CAST(date_trunc('week', CAST(analysis_date AS DATE)) AS DATE) as analysis_date,

sum(COALESCE(revoked_low_bc_duration,0)) as revoked_low_bc_duration,

sum(COALESCE(revoked_solar_user,0)) as revoked_solar_user,

sum(COALESCE(revoked_BB_with_cost,0)) as revoked_BB_with_cost,

sum(COALESCE(revoked_NBB_with_consumption,0)) as revoked_NBB_with_consumption,

sum(COALESCE(revoked_stale_BC,0)) as revoked_stale_BC,

sum(COALESCE(revoked_zero_Billing,0)) as revoked_zero_Billing,

sum(COALESCE(revoked_solar_cluster,0)) as revoked_solar_cluster,

sum(COALESCE(revoked_survey_check_failed,0)) as revoked_survey_check_failed,

sum(COALESCE(revoked_itemization_check_failed,0)) as revoked_itemization_check_failed,

sum(COALESCE(homecategorization_BB_both_known,0)) as homecategorization_BB_both_known,

sum(COALESCE(homecategorization_NBB_both_known,0)) as homecategorization_NBB_both_known,

sum(COALESCE(homecategorization_NBB_both_unknown,0)) as homecategorization_NBB_both_unknown,

sum(COALESCE(homecategorization_BB_both_unknown,0)) as homecategorization_BB_both_unknown,

sum(COALESCE(homecategorization_BB_LA_unknown,0)) as homecategorization_BB_LA_unknown,

sum(COALESCE(homecategorization_NBB_LA_unknown,0)) as homecategorization_NBB_LA_unknown,

sum(COALESCE(homecategorization_NBB_dwelling_unknown,0)) as homecategorization_NBB_dwelling_unknown,

sum(COALESCE(homecategorization_BB_dwelling_unknown,0)) as homecategorization_BB_dwelling_unknown,

sum(COALESCE(costconsumption_NBB_COST_COST,0)) as costconsumption_NBB_COST_COST,

sum(COALESCE(costconsumption_BB_CONSUMPTION_CONSUMPTION,0)) as costconsumption_BB_CONSUMPTION_CONSUMPTION,

sum(COALESCE(costconsumption_NBB_null_COST,0)) as costconsumption_NBB_null_COST,

sum(COALESCE(costconsumption_BB_null_CONSUMPTION,0)) as costconsumption_BB_null_CONSUMPTION,

sum(COALESCE(costconsumption_NBB_COST_null,0)) as costconsumption_NBB_COST_null,

sum(COALESCE(costconsumption_NBB_null_null,0)) as costconsumption_NBB_null_null,

sum(COALESCE(costconsumption_BB_CONSUMPTION_null,0)) as costconsumption_BB_CONSUMPTION_null,

sum(COALESCE(costconsumption_BB_null_null,0)) as costconsumption_BB_null_null,

sum(COALESCE(itemisationshc_NBB_Y_Y,0)) as itemisationshc_NBB_Y_Y,

sum(COALESCE(itemisationshc_BB_Y_Y,0)) as itemisationshc_BB_Y_Y,

sum(COALESCE(itemisationshc_NBB_N_Y,0)) as itemisationshc_NBB_N_Y,

sum(COALESCE(itemisationshc_BB_N_Y,0)) as itemisationshc_BB_N_Y,

sum(COALESCE(itemisationshc_NBB_Y_N,0)) as itemisationshc_NBB_Y_N,

sum(COALESCE(itemisationshc_NBB_N_N,0)) as itemisationshc_NBB_N_N,

sum(COALESCE(itemisationshc_BB_Y_N,0)) as itemisationshc_BB_Y_N,

sum(COALESCE(itemisationshc_BB_N_N, 0)) as itemisationshc_BB_N_N,

'Weekly' as "Period",

max(last_updated_timestamp) as last_updated_timestamp

from reporting.sre_her_qc_data_budget_billing

group by 1,2,3

union all

select

pilot_id,

CAST(date_trunc('month', CAST(reporting_date AS DATE)) AS DATE) as reporting_date,

CAST(date_trunc('month', CAST(analysis_date AS DATE)) AS DATE) as analysis_date,

sum(COALESCE(revoked_low_bc_duration,0)) as revoked_low_bc_duration,

sum(COALESCE(revoked_solar_user,0)) as revoked_solar_user,

sum(COALESCE(revoked_BB_with_cost,0)) as revoked_BB_with_cost,

sum(COALESCE(revoked_NBB_with_consumption,0)) as revoked_NBB_with_consumption,

sum(COALESCE(revoked_stale_BC,0)) as revoked_stale_BC,

sum(COALESCE(revoked_zero_Billing,0)) as revoked_zero_Billing,

sum(COALESCE(revoked_solar_cluster,0)) as revoked_solar_cluster,

sum(COALESCE(revoked_survey_check_failed,0)) as revoked_survey_check_failed,

sum(COALESCE(revoked_itemization_check_failed,0)) as revoked_itemization_check_failed,

sum(COALESCE(homecategorization_BB_both_known,0)) as homecategorization_BB_both_known,

sum(COALESCE(homecategorization_NBB_both_known,0)) as homecategorization_NBB_both_known,

sum(COALESCE(homecategorization_NBB_both_unknown,0)) as homecategorization_NBB_both_unknown,

sum(COALESCE(homecategorization_BB_both_unknown,0)) as homecategorization_BB_both_unknown,

sum(COALESCE(homecategorization_BB_LA_unknown,0)) as homecategorization_BB_LA_unknown,

sum(COALESCE(homecategorization_NBB_LA_unknown,0)) as homecategorization_NBB_LA_unknown,

sum(COALESCE(homecategorization_NBB_dwelling_unknown,0)) as homecategorization_NBB_dwelling_unknown,

sum(COALESCE(homecategorization_BB_dwelling_unknown,0)) as homecategorization_BB_dwelling_unknown,

sum(COALESCE(costconsumption_NBB_COST_COST,0)) as costconsumption_NBB_COST_COST,

sum(COALESCE(costconsumption_BB_CONSUMPTION_CONSUMPTION,0)) as costconsumption_BB_CONSUMPTION_CONSUMPTION,

sum(COALESCE(costconsumption_NBB_null_COST,0)) as costconsumption_NBB_null_COST,

sum(COALESCE(costconsumption_BB_null_CONSUMPTION,0)) as costconsumption_BB_null_CONSUMPTION,

sum(COALESCE(costconsumption_NBB_COST_null,0)) as costconsumption_NBB_COST_null,

sum(COALESCE(costconsumption_NBB_null_null,0)) as costconsumption_NBB_null_null,

sum(COALESCE(costconsumption_BB_CONSUMPTION_null,0)) as costconsumption_BB_CONSUMPTION_null,

sum(COALESCE(costconsumption_BB_null_null,0)) as costconsumption_BB_null_null,

sum(COALESCE(itemisationshc_NBB_Y_Y,0)) as itemisationshc_NBB_Y_Y,

sum(COALESCE(itemisationshc_BB_Y_Y,0)) as itemisationshc_BB_Y_Y,

sum(COALESCE(itemisationshc_NBB_N_Y,0)) as itemisationshc_NBB_N_Y,

sum(COALESCE(itemisationshc_BB_N_Y,0)) as itemisationshc_BB_N_Y,

sum(COALESCE(itemisationshc_NBB_Y_N,0)) as itemisationshc_NBB_Y_N,

sum(COALESCE(itemisationshc_NBB_N_N,0)) as itemisationshc_NBB_N_N,

sum(COALESCE(itemisationshc_BB_Y_N,0)) as itemisationshc_BB_Y_N,

sum(COALESCE(itemisationshc_BB_N_N, 0)) as itemisationshc_BB_N_N,

'Monthly' as "Period",

max(last_updated_timestamp) as last_updated_timestamp

from reporting.sre_her_qc_data_budget_billing

group by 1,2,3) as s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | TODO | TODO |

### SRC-13

- **Name:** SRE HER Cluster Specific Failure Rate #1
- **Alias:** `ds503`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds503.
-- base source is SRE HER Cluster Specific Failure Rate (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| calc_failure_perc | 100*SUM(failure_count)/SUM(total_failure_count) | TODO | TODO | TODO |
| Metric Toggle | CASE
  WHEN Metric = 'failure_percentage' THEN calc_failure_perc
  WHEN Metric = 'failure_count' THEN SUM(failure_count)
END | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Metric | failure_percentage (% Failure)/failure_count (# Failure) | TODO | TODO | TODO |

### SRC-14

- **Name:** SRE Post Ingestion Data Quality
- **Alias:** `ds342`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds342.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*,
    e.overlapping_bc_count
FROM
(
    SELECT
        COALESCE(a.pilot_id, b.pilot_id) AS pilot_id,
        COALESCE(a.meter_type, b.meter_type) AS meter_type,
        COALESCE(a.fuel_type, b.fuel_type) AS fuel_type,
        COALESCE(a.ingestion_type, b.ingestion_type) AS ingestion_type,
        user_with_delay_0_3 AS user_raw_with_delay_0_3,
        user_with_delay_4_7 AS user_raw_with_delay_4_7,
        user_with_delay_8_15 AS user_raw_with_delay_8_15,
        user_with_delay_gt_15 AS user_raw_with_delay_gt_15,
        invoice_with_delay_0_7 AS user_invoice_with_delay_0_7,
        invoice_with_delay_7_15 AS user_invoice_with_delay_7_15,
        invoice_with_delay_15_30 AS user_invoice_with_delay_15_30,
        invoice_with_delay_gt_30 AS user_invoice_with_delay_gt_30,
        COALESCE(a.analysis_date, b.analysis_date) AS analysis_date,
        COALESCE(a.reporting_date, b.reporting_date) AS reporting_date,
        COALESCE(a.last_updated_timestamp, b.last_updated_timestamp) AS last_updated_timestamp
    FROM
    (
        SELECT
            pilot_id, meter_type, fuel_type,
            user_with_delay_0_3, user_with_delay_4_7, user_with_delay_8_15, user_with_delay_gt_15,
            analysis_date, reporting_date, last_updated_timestamp,
            'CONSUMPTION' AS ingestion_type
        FROM reporting.sre_raw_consumption_delay
    ) a
    FULL JOIN
    (
        SELECT
            pilot_id, meter_type, fuel_type,
            invoice_with_delay_0_7, invoice_with_delay_7_15, invoice_with_delay_15_30, invoice_with_delay_gt_30,
            analysis_date, reporting_date, last_updated_timestamp,
            CASE
                WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
                THEN 'OPOWER'
                ELSE 'BILLING'
            END AS ingestion_type
        FROM reporting.sre_invoice_delay_tracker
    ) b
    ON a.pilot_id = b.pilot_id
       AND a.meter_type = b.meter_type
       AND a.fuel_type = b.fuel_type
       AND a.ingestion_type = b.ingestion_type
) s
LEFT JOIN (
    SELECT
        pilot_id,
        failed_record_count AS overlapping_bc_count,
        analysis_date,
        reporting_date,
        last_updated_timestamp,
        CASE
            WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
            THEN 'OPOWER'
            ELSE 'BILLING'
        END AS ingestion_type
    FROM reporting.sre_ingestion_errors_statistic
    WHERE application_error_code = 'ERROR_CONFLICTING_INVOICE_DATA'
) e
ON s.pilot_id = e.pilot_id
   AND s.analysis_date = e.analysis_date
   AND s.ingestion_type = e.ingestion_type
JOIN
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events
) m
ON m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| avg_users_receiving_invoice_per_day | (NULLIF(user_invoice_with_delay_0_7,0) + NULLIF(user_invoice_with_delay_7_15,0) + NULLIF(user_invoice_with_delay_15_30,0) + NULLIF(user_invoice_with_delay_gt_30,0))/1000000 | TODO | TODO |
| avg_users_receiving_raw_per_day | (NULLIF(user_raw_with_delay_0_3,0) + NULLIF(user_raw_with_delay_4_7,0) + NULLIF(user_raw_with_delay_8_15,0) + NULLIF(user_raw_with_delay_gt_15,0))/1000000 | TODO | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| TODO | TODO |
| total_users_across_age_buckets | CASE
  WHEN ingestion_type = "CONSUMPTION" THEN avg_users_receiving_raw_per_day
  WHEN ingestion_type = "BILLING" THEN avg_users_receiving_invoice_per_day
END | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-15

- **Name:** SRE Rate Comparison Tracker #1
- **Alias:** `ds504`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds504.
-- based as SRE Rate Comparison Tracker (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-16

- **Name:** SRE All Active Users #1
- **Alias:** `ds505`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds505.
-- based on SRE All Active Users (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-17

- **Name:** SRE Rate Comparison Tracker
- **Alias:** `ds453`
- **Connector:** Extract Data
- **Dashboard section / tiles:** 1.a. Data Governance Ingestion — NA-1A-T06 and NA-1A-F06 (Rate Plan ID).
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** Source rows are retained. Dashboard blend: Ingestion Audit LEFT JOIN Rate Comparison on pilot_id and full last_updated_timestamp. Original Looker Studio input grouping remains unverified.
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Upstream query captured; NA schema and implementation SQL planning validated on 2026-10-03. Full timestamp join confirmed by the user. Native Looker validation and result parity remain pending.

#### Source SQL

```sql
-- TODO: Source query for alias ds453.
-- based on SRE Rate Comparison Tracker (App Script Addon)
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*,
    'BILLING' as ingestion_type
FROM
    (SELECT
        CASE
            WHEN position('(' IN pilot_name) > 0
            THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
            ELSE pilot_name -- Keep the original name if '(' doesn't exist
        END AS pilot_name,
        pilot_id,
        islaunchpadpilot,
        pilot_type,
        isevpilot,
        timezone
    FROM data_sanity.master_pilot_list) AS m
JOIN
    reporting.sre_rate_plan_tracker s
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-18

- **Name:** SRE_NBI_FALED_JOB_COUNT - Starburst
- **Alias:** `sre_nbi_failed_job_ct_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_nbi_failed_job_ct_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    (SELECT
    pilot_id,
    CAST(analysis_date AS DATE) AS analysis_date,

    COUNT(DISTINCT cluster_type) AS stages_present,

    -- Check if any known stage is marked as failed
    MAX(
        CASE
            WHEN metric_value IN ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED')
            THEN 1
            ELSE 0
        END
    ) AS has_failed_stage,

    -- Final failure condition: either missing a stage or any stage failed
    CASE
        WHEN COUNT(DISTINCT cluster_type) < 3
             OR MAX(CASE
                      WHEN metric_value IN ('FAILED', 'TERMINATED_WITH_ERRORS', 'CANCELLED', 'INTERRUPTED')
                      THEN 1
                      ELSE 0
                  END) = 1
        THEN 1
        ELSE 0
    END AS is_failed

FROM
    reporting.sre_emr_metrics_fact
GROUP BY
    pilot_id, CAST(analysis_date AS DATE)) s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| Record Count | record_count | Number | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-19

- **Name:** SRE HER Quality Statistics (non-PSEG) - Starburst
- **Alias:** `sre_her_quality_stats_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_her_quality_stats_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    (select
pilot_id,
CAST(reporting_date AS DATE) as reporting_date,
CAST(analysis_date AS DATE) as analysis_date,
COALESCE(low_bc_duration_count, 0) AS low_bc_duration_count,
COALESCE(high_bc_duration_count, 0) AS high_bc_duration_count,
COALESCE(staleness_count, 0) AS staleness_count,
COALESCE(solar_template_count, 0) AS solar_template_count,
COALESCE(solar_consistency_count, 0) AS solar_consistency_count,
COALESCE(solar_generation_count, 0) AS solar_generation_count,
COALESCE(report_consistency_count, 0) AS report_consistency_count,
COALESCE(itemization_count, 0) AS itemization_count,
COALESCE(bill_change_consistency_count, 0) AS bill_change_consistency_count,
COALESCE(ev_itemization_count, 0) AS ev_itemization_count,
COALESCE(tou_template_count, 0) AS tou_template_count,
COALESCE(nbi_occurance_count, 0) AS nbi_occurance_count,
COALESCE(nbi_value_count, 0) AS nbi_value_count,
COALESCE(nbi_appliance_itemisation_count, 0) AS nbi_appliance_itemisation_count,
COALESCE(nbi_non_null_insight_count, 0) AS nbi_non_null_insight_count,
COALESCE(nbi_unicode_count, 0) AS nbi_unicode_count,
COALESCE(nbi_extreme_insight_count, 0) AS nbi_extreme_insight_count,
'Daily' as "Period",
last_updated_timestamp
from reporting.sre_her_qc_data
union all

select

pilot_id,

CAST(date_trunc('week', CAST(reporting_date AS DATE)) AS DATE) as reporting_date,

CAST(date_trunc('week', CAST(analysis_date AS DATE)) AS DATE) as analysis_date,

sum(COALESCE(low_bc_duration_count,0)) as low_bc_duration_count,

sum(COALESCE(high_bc_duration_count,0)) as high_bc_duration_count,

sum(COALESCE(staleness_count,0)) as staleness_count,

sum(COALESCE(solar_template_count,0)) as solar_template_count,

sum(COALESCE(solar_consistency_count,0)) as solar_consistency_count,

sum(COALESCE(solar_generation_count,0)) as solar_generation_count,

sum(COALESCE(report_consistency_count,0)) as report_consistency_count,

sum(COALESCE(itemization_count,0)) as itemization_count,

sum(COALESCE(bill_change_consistency_count,0)) as bill_change_consistency_count,

sum(COALESCE(ev_itemization_count,0)) as ev_itemization_count,

sum(COALESCE(tou_template_count,0)) as tou_template_count,

sum(COALESCE(nbi_occurance_count,0)) as nbi_occurance_count,

sum(COALESCE(nbi_value_count,0)) as nbi_value_count,

sum(COALESCE(nbi_appliance_itemisation_count,0)) as nbi_appliance_itemisation_count,

sum(COALESCE(nbi_non_null_insight_count,0)) as nbi_non_null_insight_count,

sum(COALESCE(nbi_unicode_count,0)) as nbi_unicode_count,

sum(COALESCE(nbi_extreme_insight_count, 0)) as nbi_extreme_insight_count,

'Weekly' as "Period",

max(last_updated_timestamp) as last_updated_timestamp

from reporting.sre_her_qc_data

group by 1,2,3

union all

select

pilot_id,

CAST(date_trunc('month', CAST(reporting_date AS DATE)) AS DATE) as reporting_date,

CAST(date_trunc('month', CAST(analysis_date AS DATE)) AS DATE) as analysis_date,

sum(COALESCE(low_bc_duration_count,0)) as low_bc_duration_count,

sum(COALESCE(high_bc_duration_count,0)) as high_bc_duration_count,

sum(COALESCE(staleness_count,0)) as staleness_count,

sum(COALESCE(solar_template_count,0)) as solar_template_count,

sum(COALESCE(solar_consistency_count,0)) as solar_consistency_count,

sum(COALESCE(solar_generation_count,0)) as solar_generation_count,

sum(COALESCE(report_consistency_count,0)) as report_consistency_count,

sum(COALESCE(itemization_count,0)) as itemization_count,

sum(COALESCE(bill_change_consistency_count,0)) as bill_change_consistency_count,

sum(COALESCE(ev_itemization_count,0)) as ev_itemization_count,

sum(COALESCE(tou_template_count,0)) as tou_template_count,

sum(COALESCE(nbi_occurance_count,0)) as nbi_occurance_count,

sum(COALESCE(nbi_value_count,0)) as nbi_value_count,

sum(COALESCE(nbi_appliance_itemisation_count,0)) as nbi_appliance_itemisation_count,

sum(COALESCE(nbi_non_null_insight_count,0)) as nbi_non_null_insight_count,

sum(COALESCE(nbi_unicode_count,0)) as nbi_unicode_count,

sum(COALESCE(nbi_extreme_insight_count, 0)) as nbi_extreme_insight_count,

'Monthly' as "Period",

max(last_updated_timestamp) as last_updated_timestamp

from reporting.sre_her_qc_data

group by 1,2,3) as s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| Record Count | record_count | Integer | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-20

- **Name:** SRE NBI Gen Quality Generic Tag
- **Alias:** `ds351`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds351.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users, s.total_nbi_users_with_generic_tag, s.pct_users_with_generic_tag, s.last_updated_timestamp
 FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_nbi_generic_tag_users s
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-21

- **Name:** SRE RC Email Anomaly KPI 2 - Starburst
- **Alias:** `sre_rc_email_anomaly_kpi_2_starurst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** Rate Comparison NA-5A-T07.
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract and semantic checks plus Starburst planning pass; native Looker/original-report validation pending. See [Rate Comparison review](bre_na_rate_comparison_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias sre_rc_email_anomaly_kpi_2_starurst.
-- engine: starburst
SELECT
    CAST(rd.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    rd.notification_type AS email_type,
    rd.reporting_date,
    rd.analysis_date,
    COUNT(user_id || CAST(billing_start_time AS VARCHAR) || CAST(billing_end_time AS VARCHAR)) AS total_records,
    COALESCE(
        AVG(
            CASE
                WHEN nl.tou_run_timestamp IS NOT NULL
                     AND nl.invoice_ingested_timestamp IS NOT NULL
                THEN (nl.tou_run_timestamp - nl.invoice_ingested_timestamp) / (1000.0 * 3600)
            END
        ), 0
    ) AS avg_invoice_to_tou_latency_hrs,
    COALESCE(
        AVG(
            CASE
                WHEN nl.rc_run_timestamp IS NOT NULL
                     AND nl.tou_run_timestamp IS NOT NULL
                THEN (nl.rc_run_timestamp - nl.tou_run_timestamp) / (1000.0 * 3600)
            END
        ), 0
    ) AS avg_tou_to_rc_latency_hrs,
    COUNT(CASE WHEN nl.tou_run_timestamp IS NULL THEN user_id || CAST(billing_start_time AS VARCHAR) || CAST(billing_end_time AS VARCHAR) END) AS missing_tou_count,
    COUNT(CASE WHEN nl.rc_run_timestamp IS NULL THEN user_id || CAST(billing_start_time AS VARCHAR) || CAST(billing_end_time AS VARCHAR) END) AS missing_rc_count,
    CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END AS missing_promotion_flag
FROM reporting.reporting_dates_map rd
LEFT JOIN reporting.sre_notification_report nl
  ON rd.pilot_id = nl.pilot_id
 AND rd.notification_type = nl.notification_type
 AND rd.analysis_date = nl.analysis_date
JOIN (
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events
) m ON rd.pilot_id = m.pilot_id
GROUP BY rd.pilot_id, m.pilot_name, rd.notification_type,
         rd.reporting_date, rd.analysis_date,
         CAST(rd.pilot_id AS VARCHAR) || ' : ' || m.pilot_name,
         CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | TODO | TODO |

parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-22

- **Name:** SRE HER Schedule Specific Statistics
- **Alias:** `ds357`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** HER NA-7A-T02 through T04.
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract/semantic checks and Starburst planning pass. Native Looker/original-report validation pending; see [HER review](bre_na_her_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias ds357.
-- engine: starburst
select
m.pilot_id, CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,s.cluster_id,s.fuel_type,s.schedule_start,s.schedule_end,
s.total_eligible_users,s.total_generated_notification_id,s.total_scheduled_notification_id,s.total_queued_notification_id,s.total_printed_notification_id,
s.total_mailed_notification_id,s.total_failed_notification_id,s.total_swept_notification_id,s.total_revoked_notification_id,
s.reporting_date,s.analysis_date,s.last_updated_timestamp
from
(
    with generated_her as
    (
        select s.pilot_id,s.cluster_id,s.measurement_type as fuel_type,s.schedule_start,s.schedule_end,
        s.total_eligible_users,s.total_generated_notification_id,s.total_scheduled_notification_id,s.total_queued_notification_id,s.total_printed_notification_id,
        s.total_mailed_notification_id,s.total_failed_notification_id,s.reporting_date,
        s.last_updated_timestamp ,s.analysis_date,s.total_swept_notification_id
        FROM
        (
            select pilot_id,schedule_start,schedule_end,measurement_type,cluster_id,
            sum(total_eligible_users) as total_eligible_users,
            sum(total_generated_notification_id) as total_generated_notification_id,
            sum(total_scheduled_notification_id) as total_scheduled_notification_id,
            sum(total_swept_notification_id) as total_swept_notification_id,
            sum(total_queued_notification_id) as total_queued_notification_id,
            sum(total_printed_notification_id) as total_printed_notification_id,
            sum(total_mailed_notification_id) as total_mailed_notification_id,
            sum(total_failed_notification_id) as total_failed_notification_id,
            max(analysis_date) as analysis_date,
            max(reporting_date) as reporting_date,
            max(last_updated_timestamp) as last_updated_timestamp
            from
            (
                Select pilot_id,cluster_id,measurement_type,
                case when schedule_quarter_start < schedule_start then schedule_start else schedule_quarter_start end schedule_start ,
                CAST(date_add('day', -1, date_add('quarter', 1, schedule_quarter_start)) AS DATE) as schedule_end,
                total_eligible_users,total_generated_notification_id,total_scheduled_notification_id,total_swept_notification_id,total_queued_notification_id,total_printed_notification_id,total_mailed_notification_id,total_failed_notification_id,
                reporting_date,analysis_date,last_updated_timestamp
                from
                (
                    Select *,CAST(date_trunc('quarter', analysis_date) AS DATE) as schedule_quarter_start,
                    row_number()over(partition by pilot_id,cluster_id,measurement_type,schedule_start,schedule_end,date_trunc('quarter',analysis_date) order by reporting_date desc) as rk
                    from reporting.sre_daily_her_tracker
                    where pilot_id='10037'
                )x where rk=1
                union
                Select pilot_id,cluster_id,measurement_type,schedule_start,schedule_end,
                total_eligible_users,total_generated_notification_id,total_scheduled_notification_id,total_swept_notification_id,total_queued_notification_id,total_printed_notification_id,total_mailed_notification_id,total_failed_notification_id,
                reporting_date,analysis_date,last_updated_timestamp
                from
                (
                    Select *,
                    row_number()over(partition by pilot_id,cluster_id,measurement_type,schedule_start,schedule_end order by reporting_date desc) as rk
                    from reporting.sre_daily_her_tracker
                    where pilot_id<>'10037'
                )x where rk=1
            )
            group by pilot_id,schedule_start,schedule_end,measurement_type,cluster_id
        )s
),
revoked_her as
(
    select pilot_id,cluster_id,fuel_type,
    case when schedule_quarter_start < schedule_start then schedule_start else schedule_quarter_start end schedule_start,
    CAST(date_add('day', -1, date_add('quarter', 1, schedule_quarter_start)) AS DATE) as schedule_end,total_revoked_users,last_updated_timestamp,reporting_date,analysis_date
    from
    (
        select *,CAST(date_trunc('quarter', analysis_date) AS DATE) as schedule_quarter_start,
        row_number()over(partition by pilot_id,cluster_id,fuel_type,schedule_start,schedule_end,date_trunc('quarter',analysis_date) order by reporting_date desc) as rk

        from reporting.sre_her_revoked_users
        where pilot_id=10037
    )x where x.rk=1
    union
    select pilot_id,cluster_id,fuel_type,
    schedule_start,schedule_end,total_revoked_users,last_updated_timestamp,reporting_date,analysis_date
    from
    (
        select *,row_number()over(partition by pilot_id,cluster_id,schedule_start,schedule_end,fuel_type order by reporting_date desc) as rn
        from reporting.sre_her_revoked_users
        where pilot_id<>10037
    )x where x.rn=1
)
select
COALESCE(a.pilot_id, CAST(b.pilot_id AS VARCHAR)) pilot_id,
coalesce(a.cluster_id,b.cluster_id) cluster_id,
coalesce(a.fuel_type,b.fuel_type) fuel_type,
coalesce(a.schedule_start,b.schedule_start) schedule_start,
coalesce(a.schedule_end,b.schedule_end) schedule_end,
COALESCE(a.total_eligible_users,0) total_eligible_users,
COALESCE(a.total_generated_notification_id,0) total_generated_notification_id,
COALESCE(a.total_scheduled_notification_id,0) total_scheduled_notification_id,
COALESCE(a.total_queued_notification_id,0) total_queued_notification_id,
COALESCE(a.total_printed_notification_id,0) total_printed_notification_id,
COALESCE(a.total_mailed_notification_id,0) total_mailed_notification_id,
COALESCE(a.total_failed_notification_id,0) total_failed_notification_id,
COALESCE(a.total_swept_notification_id,0) total_swept_notification_id,
COALESCE(b.total_revoked_users,0) as total_revoked_notification_id,
coalesce(a.analysis_date,b.analysis_date) analysis_date,
coalesce(a.reporting_date,b.reporting_date) reporting_date,
coalesce(a.last_updated_timestamp,b.last_updated_timestamp) last_updated_timestamp
from generated_her a
full join revoked_her b on a.pilot_id=CAST(b.pilot_id AS VARCHAR)
and a.cluster_id=b.cluster_id
and a.fuel_type=b.fuel_type
and a.schedule_start=b.schedule_start
and a.schedule_end=b.schedule_end
)s
JOIN
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events
) m ON CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-23

- **Name:** SRE Master Pilot List #1
- **Alias:** `ds506`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds506.
-- based on SRE Master Pilot List (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-24

- **Name:** SRE SQS Queue Metrics By Day - Starburst
- **Alias:** `sre_sqs_queue_day_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_sqs_queue_day_starburst.
-- engine: starburst
SELECT
    date_trunc('day', analysis_date) AS ingestion_day,
    module_name,
    environment,
    queue_type,
    queue_name,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) AS total_messages_received,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesSent' THEN metric_value ELSE 0 END) AS total_messages_sent,
    SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) AS total_messages_deleted,
    AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) AS avg_queue_backlog,
    MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) AS max_latency,
        -- Success rate calculation (percentage)
    ROUND(
        SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) * 100.0 /
        NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0),
    2) AS success_rate,  -- Rounded to 2 decimal places
    ROUND(
        SUM(CASE WHEN metric_name = 'NumberOfEmptyReceives' THEN metric_value ELSE 0 END) /
        NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END) +
               SUM(CASE WHEN metric_name = 'NumberOfEmptyReceives' THEN metric_value ELSE 0 END), 0) * 100, 2) AS empty_receives_ratio
FROM reporting.sre_queue_metrics_fact
--WHERE analysis_date >= current_timestamp - INTERVAL '7' DAY  -- Reduce the date range
GROUP BY date_trunc('day', analysis_date), module_name, environment, queue_type, queue_name
ORDER BY ingestion_day DESC
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | COUNT(pilot_id) | COUNT | Integer | TODO |

### SRC-25

- **Name:** SRE Failure Statistics - Starburst
- **Alias:** `sre_failure_stats_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_failure_stats_starburst.
-- engine: starburst
select * from (
SELECT
    sfs.*,
    ROW_NUMBER() OVER (
        PARTITION BY analysis_date, pilot_id, module_name
        ORDER BY failure_percentage DESC
    ) AS rank
FROM
    (SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_failure_statistics s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id) as sfs
ORDER BY
    analysis_date DESC,
    pilot_id,
    module_name,
    failure_percentage desc)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| calc_delay_in_days | CASE
  WHEN delay_in_days = 2 THEN "T-2"
  WHEN delay_in_days = 7 THEN "T-7"
  ELSE "> T-7"
END | Number | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | COUNT(pilot_id) | COUNT | Integer | TODO |

parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-26

- **Name:** SRE Email Reco Statistics #1
- **Alias:** `ds507`
- **Connector:** Extract Data
- **Dashboard section / tiles:** Email NA-6A-T07.
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract/semantic checks, Starburst planning, and bounded sample execution pass. Native Looker/original-report validation pending; see [Email review](bre_na_email_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias ds507.
-- based on SRE Email Reco Statistics (App Script Addon)
-- engine: starburst
SELECT
    s.pilot_id || ' : ' || coalesce(m.pilot_name, '') AS pilot_id_name,
    s.*
FROM reporting.sre_quality_reco_stats s
LEFT JOIN
    (SELECT
        CASE
            WHEN position('(' IN pilot_name) > 0
            THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
            ELSE pilot_name -- Keep the original name if '(' doesn't exist
        END AS pilot_name,
        CAST(pilot_id AS VARCHAR) AS pilot_id
    FROM reporting.pilot_consolidated_product_type_events) AS m
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-27

- **Name:** SRE Ingestion Failure Statistics #1
- **Alias:** `ds509`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds509.
-- based on SRE Ingestion Failure Statistics (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Metric Toggle | CASE
  WHEN Metric = 'failure_percentage' THEN AVG(failure_percentage)
  WHEN Metric = 'failed_record_count' THEN SUM(failed_record_count)
END | TODO | Number | TODO |

| parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |
| Metric | failure_percentage (% Failure)/ failed_record_count (Failure Count) | TODO | TODO | TODO |

### SRC-28

- **Name:** SRE RC Email Anomaly KPI 1 - Starburst
- **Alias:** `sre_rc_email_anomaly_kpi_1_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** Rate Comparison NA-5A-T02 through T06 and T08.
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract and semantic checks plus Starburst planning pass; native Looker/original-report validation pending. See [Rate Comparison review](bre_na_rate_comparison_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias sre_rc_email_anomaly_kpi_1_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    (
    WITH base AS (
        SELECT
            pilot_id, analysis_date, reporting_date, notification_type, notification_id, loadshiftamount,
            rc_run_timestamp, tou_run_timestamp, email_generation_timestamp,
            CAST(date_add('second', CAST(invoice_ingested_timestamp / 1000 AS BIGINT), TIMESTAMP '1970-01-01 00:00:00') AS TIMESTAMP(3)) AS invoice_ingested_ts,
            CAST(date_add('second', CAST(rc_run_timestamp / 1000 AS BIGINT), TIMESTAMP '1970-01-01 00:00:00') AS TIMESTAMP(3)) AS rc_run_ts
        FROM reporting.sre_notification_report
    ),
    agg AS (
        SELECT
            pilot_id, analysis_date, reporting_date, notification_type AS email_type,
            count(notification_id) AS total_invoices,
            count(CASE WHEN (rc_run_timestamp NOT BETWEEN tou_run_timestamp AND email_generation_timestamp)
                         OR (loadshiftamount = '' AND date_diff('day', date(invoice_ingested_ts), date(rc_run_ts)) < 3)
                  THEN notification_id ELSE NULL END) AS anomaly_count,
            count(CASE WHEN date_diff('hour', date_trunc('hour', invoice_ingested_ts), date_trunc('hour', rc_run_ts)) < 1
                         AND rc_run_timestamp > tou_run_timestamp
                  THEN notification_id ELSE NULL END) AS rc_early_trigger_anomally,
            count(CASE WHEN loadshiftamount = '' AND date_diff('day', date(invoice_ingested_ts), date(rc_run_ts)) < 3
                  THEN notification_id ELSE NULL END) AS rc_missing_anomaly,
            count(CASE WHEN (rc_run_timestamp NOT BETWEEN tou_run_timestamp AND email_generation_timestamp)
                  THEN notification_id ELSE NULL END) AS rc_ooo_trigger_anomaly,
            count(CASE WHEN loadshiftamount != '' AND try_cast(loadshiftamount AS DOUBLE) < 20
                  THEN notification_id ELSE NULL END) AS ls_low_value_anomally,
            CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END AS missing_promotion_flag
        FROM base
        GROUP BY pilot_id, analysis_date, reporting_date, notification_type, CASE WHEN loadshiftamount = '' THEN 'Absent' ELSE 'Present' END
    ),
    with_deviation AS (
        SELECT *,
            total_invoices - anomaly_count AS favourable_count,
            round(1.00 * anomaly_count / total_invoices, 3) AS deviation_perc
        FROM agg
    )
    SELECT *, 1 - deviation_perc AS accuracy_perc
    FROM with_deviation
    ) s
ON
    m.pilot_id = s.pilot_id order by s.reporting_date desc
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | COUNT(pilot_id) | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-29

- **Name:** SRE Aggregation Stats
- **Alias:** `ds486`
- **Connector:** Extract Data
- **Dashboard section / tiles:** Aggregation 2.a, NA-2-T02 through NA-2-T08.
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Upstream SQL supplied. Local rendered SQL and Starburst planning checks pass; original-report parity and extract settings remain pending.

#### Source SQL

```sql
-- based on SRE Aggregation Stats (App Script Addon)
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
        CASE
            WHEN position('(' IN pilot_name) > 0
            THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
            ELSE pilot_name -- Keep the original name if '(' doesn't exist
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_raw_data_analysis s
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| sucess_perc | `100*(total_datapoints/total_expected_datapoints)` | AVG in NA-2-T05 and NA-2-T06 | Percentage on 0–100 scale | User-confirmed report calculated field; LookML uses floating-point arithmetic and NULL for a zero denominator. |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-30

- **Name:** HER Aggregated Generation Stats #1
- **Alias:** `ds510`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds510.
-- based on HER Aggregated Generation Stats (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-31

- **Name:** SRE Billing Cycle Length
- **Alias:** `ds388`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds388.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
(select pilot_id,bc_1_15_count,bc_15_30_count,bc_31_45_count,bc_45_60_count,bc_61_75_count,
bc_76_90_count,bc_gt_90_count,analysis_date,reporting_date, CASE
            WHEN pilot_id IN (10021,10024,10043,10046,10047,10048,10049,10050,10051,10055,10064,10068,10070,10082,10110)
            THEN 'OPOWER'
            ELSE 'BILLING'
        END AS ingestion_type from reporting.utility_billing_length_tracker) as s
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-32

- **Name:** SRE NBI EMR Metrics - Starburst
- **Alias:** `sre_nbi_emr_metrics_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_nbi_emr_metrics_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    date_format(s.analysis_date AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS analysis_date_str,
    s.pilot_id,s.module_name,s.cluster_id,s.cluster_type,s.metric_name,s.metric_value,s.reason_code,s.steps_status,

    -- Duration in seconds
    date_diff('second', s.creation_time, s.end_time) AS duration_seconds,

    -- Timestamps casted to ISO 8601 string format
    date_format(s.creation_time AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS creation_time,
    date_format(s.end_time AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS end_time,
    date_format(s.event_timestamp AT TIME ZONE 'UTC', '%Y-%m-%dT%H:%i:%s') AS event_timestamp

FROM
    (
        SELECT
            CASE
                WHEN POSITION('(' IN pilot_name) > 0
                THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                ELSE pilot_name
            END AS pilot_name,
            pilot_id
        FROM reporting.pilot_consolidated_product_type_events
    ) AS m
JOIN
    reporting.sre_emr_metrics_fact s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |
| analysis_date | PARSE_DATE("%Y%m", analysis_date_str) | Date | TODO |
| creation_time_str | PARSE_DATE("%Y%m", creation_time) | Date | TODO |
| end_time_str | PARSE_DATE("%Y%m", end_time) | Date | TODO |
| event_timestamp_str | PARSE_DATE("%Y%m", event_timestamp) | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | COUNT(pilot_id) | SUM | Integer | TODO |
| failed_job_cnt | 1-COUNT_DISTINCT(cluster_type) | SUM | Integer | TODO |
| failure_rate_perc | COUNT(
  CASE
    WHEN metric_value IN ("FAILED", "TERMINATED_WITH_ERRORS", "CANCELLED", "INTERRUPTED")
    THEN 1
    ELSE NULL
  END
)
/ COUNT(metric_value) * 100 | AVG | Number | TODO |
| success_rate_perc | 100.0 * COUNT(
  CASE
    WHEN (metric_value = 'TERMINATED' AND reason_code = 'ALL_STEPS_COMPLETED')
         OR metric_value = 'RUNNING'
    THEN 1
    ELSE NULL
  END
) / NULLIF(COUNT(metric_value), 0) | AVG | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-33

- **Name:** SRE Email Failure Statistics #1
- **Alias:** `ds511`
- **Connector:** Extract Data
- **Dashboard section / tiles:** Email NA-6A-T08.
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract/semantic checks, Starburst planning, and bounded sample execution pass. Native Looker/original-report validation pending; see [Email review](bre_na_email_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias ds511.
-- based on SRE Email Failure Statistics (App Script Addon)
-- engine: starburst
SELECT
    sfs.*,
    ROW_NUMBER() OVER (
        PARTITION BY analysis_date, pilot_id, email_type
        ORDER BY failure_count DESC
    ) AS rank
FROM
    (SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN position('(' IN pilot_name) > 0
        THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
        ELSE pilot_name -- Keep the original name if '(' doesn't exist
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_email_failure_reasons s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id) as sfs
ORDER BY
    analysis_date DESC,
    pilot_id,
    email_type,
    failure_count DESC
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Metric Toggle | CASE
  WHEN Metric = 'failure_pct' THEN AVG(failure_pct)
  WHEN Metric = 'failure_count' THEN SUM(failure_count)
END | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |
| Metric | failure_pct (% Failure)/ failure_count (Failure Count) | TODO | TODO |

### SRC-34

- **Name:** HER Aggregated Generation Stats
- **Alias:** `ds466`
- **Connector:** Extract Data
- **Dashboard section / tiles:** HER NA-7A-T05.
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract/semantic checks and Starburst planning pass. Native Looker/original-report validation pending; see [HER review](bre_na_her_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias ds466.
-- based on HER Aggregated Generation Stats (App Script Addon)
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
(
SELECT
       CASE
           WHEN position('(' IN pilot_name) > 0
           THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
           ELSE pilot_name -- Keep the original name if '(' doesn't exist
       END AS pilot_name,
       pilot_id
   FROM reporting.pilot_consolidated_product_type_events

) AS m
JOIN

(
select pilot_id,cluster_id,analysis_date,schedule_start,schedule_end,fuel_type,'Daily' as "Period",
expected_eligible_users as expected_eligible_users,
actual_eligible_users as actual_eligible_users,
actual_generation_count as actual_generation_count,
expected_eligible_users-actual_generation_count as weekly_actual_failure_count,last_updated_timestamp
from
(
SELECT
coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
and a.measurement_type=b.measurement_type
)
union all
select pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,'Weekly' as "Period",
max(expected_eligible_users) as weekly_expected_eligible_users,
max(actual_eligible_users) as weekly_actual_eligible_users,
sum(actual_generation_count) as weekly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as weekly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
CAST(date_trunc('week', coalesce(a.analysis_date, b.analysis_date)) AS date) AS analysis_week,
coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by 1,2,3,4,5,6
union all
select pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,'Monthly' as "Period",
max(expected_eligible_users) as monthly_expected_eligible_users,
max(actual_eligible_users) as monthly_actual_eligible_users,
sum(actual_generation_count) as monthly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as monthly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
CAST(date_trunc('month', coalesce(a.analysis_date, b.analysis_date)) AS date) AS analysis_month,
coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by 1,2,3,4,5,6
)AS s ON m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| success_pct | 100 * SUM(actual_generation_count) / SUM(actual_eligible_users) | Ratio of sums; user-confirmed | Percentage points | Looker Studio calculated field |

### SRC-35

- **Name:** SRE TOU Appliance Batch Aggregation
- **Alias:** `ds367`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL supplied; NA TOU local and Starburst planning checks pass. Native Looker and original-report comparison remain pending.

#### Source SQL

```sql
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    (select pilot_id,analysis_date,reporting_date,delay_in_days,trigger_name,tou_mode,
total_tou_eligible_invoices,
actual_total_tou_invoices,
successful_tou_eligible_invoices,
total_tou_eligible_invoices-successful_tou_eligible_invoices as failed_tou_eligible_invoices,
last_updated_timestamp,trigger_flag,trigger_name,total_disagg_tou_invoices,
case when total_disagg_tou_invoices != actual_total_tou_invoices then
case when total_tou_eligible_invoices >0 then round(100.00*successful_tou_eligible_invoices/total_tou_eligible_invoices,2) else 0 end
else case when total_disagg_tou_invoices >0 then round(100.00*successful_tou_eligible_invoices/total_disagg_tou_invoices,2) else 0 end
end as successful_tou_eligible_invoices_pct,
case when total_disagg_tou_invoices != actual_total_tou_invoices then
case when total_tou_eligible_invoices >0 then round(100.00*(total_tou_eligible_invoices-successful_tou_eligible_invoices)/total_tou_eligible_invoices,2) else 0 end
else case when total_disagg_tou_invoices >0 then round(100.00*(total_tou_eligible_invoices-successful_tou_eligible_invoices)/total_disagg_tou_invoices,2) else 0 end
end as failed_tou_eligible_invoices_pct,last_updated_timestamp
from reporting.sre_tou_appliance_batch_aggregation) as s
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | Daily: analysis_date; Weekly: DATE(DATETIME_TRUNC(analysis_date, WEEK)); Monthly: DATE(DATETIME_TRUNC(analysis_date, MONTH)) | Date | User-confirmed report calculation; Sunday-start weeks. |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| tou_success_pct | `successful_tou_eligible_invoices / total_tou_eligible_invoices` | AVG in charts | Fraction, displayed as percent | User-confirmed report calculation, distinct from SQL percentage fields. |
| tou_failure_pct | `1 - tou_success_pct` | AVG in gauge | Fraction, displayed as percent | User-confirmed report calculation. |

### SRC-36

- **Name:** SRE Invoice Stats New - Starburst
- **Alias:** `sre_invoice_stats_new_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL supplied; NA Disaggregation local and Starburst planning checks pass. Native Looker and original-report comparison remain pending.

#### Source SQL

```sql
-- engine: starburst
WITH bounds AS (
    SELECT
        MIN(analysis_date) AS min_date,
        MAX(analysis_date) AS max_date
    FROM reporting.sre_invoice_statistics
),

anchors AS (
    SELECT
        CAST(date_add('day', -1 * (day_of_week(MIN(min_date)) % 7), MIN(min_date)) AS DATE) AS week_anchor,
        CAST(date_trunc('month', MIN(min_date)) AS DATE) AS month_anchor
    FROM bounds
),

calendar AS (
    -- generate all dates from min_date to max_date (not from anchor)
    SELECT
        date_add('day', seq, (SELECT min_date FROM bounds)) AS calendar_date
    FROM (
        SELECT ROW_NUMBER() OVER () - 1 AS seq
        FROM reporting.sre_invoice_statistics
        LIMIT 5000
    ) n
    WHERE date_add('day', seq, (SELECT min_date FROM bounds)) <= (SELECT max_date FROM bounds)
),

daily AS (
    SELECT
        c.calendar_date AS reporting_date,
        c.calendar_date AS analysis_date,
        s.pilot_id,
        s.meter_type,
        s.fuel_type,
        s.reporting_frequency,
        s.module_name,
        COALESCE(SUM(s.total_invoices),0) AS total_invoices,
        ROUND(100.0 * SUM(s.failed_itemisation_cnt) / NULLIF(SUM(s.total_invoices),0),2) AS failed_itemisation_pct,
        ROUND(100.0 * SUM(s.successful_itemisation_cnt) / NULLIF(SUM(s.total_invoices),0),2) AS successful_itemisation_pct,
        s.delay_in_days,
        MAX(s.last_updated_timestamp) AS last_updated_timestamp,
        s.trigger_flag,
        COALESCE(SUM(s.failed_itemisation_cnt),0) AS failed_itemisation_cnt,
        COALESCE(SUM(s.successful_itemisation_cnt),0) AS successful_itemisation_cnt,
        'Daily' AS period
    FROM calendar c
    LEFT JOIN reporting.sre_invoice_statistics s
      ON s.analysis_date = c.calendar_date
    GROUP BY
        c.calendar_date, s.pilot_id, s.meter_type, s.fuel_type, s.reporting_frequency, s.module_name, s.trigger_flag, s.delay_in_days
),

weekly_base AS (
    SELECT
        s.analysis_date,
        CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) AS week_start,
        s.pilot_id,
        s.meter_type,
        s.fuel_type,
        s.reporting_frequency,
        s.module_name,
        s.delay_in_days,
        s.trigger_flag,
        s.total_invoices,
        s.failed_itemisation_cnt,
        s.successful_itemisation_cnt,
        s.last_updated_timestamp
    FROM reporting.sre_invoice_statistics s
    CROSS JOIN anchors a
),

weekly AS (
    SELECT
        -- Use the MAX date in the week period as reporting_date so it appears in Looker filters
        MAX(wb.analysis_date) AS reporting_date,
        wb.week_start AS analysis_date,
        wb.pilot_id,
        wb.meter_type,
        wb.fuel_type,
        wb.reporting_frequency,
        wb.module_name,
        COALESCE(SUM(wb.total_invoices),0) AS total_invoices,
        ROUND(100.0 * SUM(wb.failed_itemisation_cnt) / NULLIF(SUM(wb.total_invoices),0),2) AS failed_itemisation_pct,
        ROUND(100.0 * SUM(wb.successful_itemisation_cnt) / NULLIF(SUM(wb.total_invoices),0),2) AS successful_itemisation_pct,
        wb.delay_in_days,
        MAX(wb.last_updated_timestamp) AS last_updated_timestamp,
        wb.trigger_flag,
        COALESCE(SUM(wb.failed_itemisation_cnt),0) AS failed_itemisation_cnt,
        COALESCE(SUM(wb.successful_itemisation_cnt),0) AS successful_itemisation_cnt,
        'Weekly' AS period
    FROM weekly_base wb
    GROUP BY
        wb.week_start,
        wb.pilot_id, wb.meter_type, wb.fuel_type, wb.reporting_frequency, wb.module_name, wb.trigger_flag, wb.delay_in_days
),

monthly_base AS (
    SELECT
        s.analysis_date,
        CAST(date_add('month', date_diff('month', a.month_anchor, s.analysis_date), a.month_anchor) AS DATE) AS month_start,
        s.pilot_id,
        s.meter_type,
        s.fuel_type,
        s.reporting_frequency,
        s.module_name,
        s.delay_in_days,
        s.trigger_flag,
        s.total_invoices,
        s.failed_itemisation_cnt,
        s.successful_itemisation_cnt,
        s.last_updated_timestamp
    FROM reporting.sre_invoice_statistics s
    CROSS JOIN anchors a
),

monthly AS (
    SELECT
        -- Use the MAX date in the month period as reporting_date so it appears in Looker filters
        MAX(mb.analysis_date) AS reporting_date,
        mb.month_start AS analysis_date,
        mb.pilot_id,
        mb.meter_type,
        mb.fuel_type,
        mb.reporting_frequency,
        mb.module_name,
        COALESCE(SUM(mb.total_invoices),0) AS total_invoices,
        ROUND(100.0 * SUM(mb.failed_itemisation_cnt) / NULLIF(SUM(mb.total_invoices),0),2) AS failed_itemisation_pct,
        ROUND(100.0 * SUM(mb.successful_itemisation_cnt) / NULLIF(SUM(mb.total_invoices),0),2) AS successful_itemisation_pct,
        mb.delay_in_days,
        MAX(mb.last_updated_timestamp) AS last_updated_timestamp,
        mb.trigger_flag,
        COALESCE(SUM(mb.failed_itemisation_cnt),0) AS failed_itemisation_cnt,
        COALESCE(SUM(mb.successful_itemisation_cnt),0) AS successful_itemisation_cnt,
        'Monthly' AS period
    FROM monthly_base mb
    GROUP BY
        mb.month_start,
        mb.pilot_id, mb.meter_type, mb.fuel_type, mb.reporting_frequency, mb.module_name, mb.trigger_flag, mb.delay_in_days
),

stats AS (
    SELECT * FROM daily
    UNION ALL
    SELECT * FROM weekly
    UNION ALL
    SELECT * FROM monthly
)

SELECT
    stats.*,
    CAST(stats.pilot_id AS VARCHAR) || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name
FROM stats
JOIN (
    SELECT
        pilot_id,
        CASE
            WHEN POSITION('(' IN pilot_name) > 0 THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name
    FROM reporting.pilot_consolidated_product_type_events
) m
  ON CAST(m.pilot_id AS VARCHAR) = stats.pilot_id

```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| failed_itemisation_% | CASE
  WHEN failed_itemisation_pct IS NULL THEN 0
  ELSE failed_itemisation_pct/100
END | Number | TODO |
| successful_itemisation_correction% | CASE
    WHEN trigger_flag='ADHOC' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |
| successful_itemisation_t_2% | CASE
    WHEN delay_in_days = 2 AND trigger_flag='SCHEDULED' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |
| successful_itemisation_t_7% | CASE
    WHEN delay_in_days = 7 AND trigger_flag='SCHEDULED' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | TODO | TODO |

**Disaggregation calculated-field confirmation:** The user confirmed conditional success for SCHEDULED delay 2 / delay 7 and ADHOC correction, each returning NULL outside its condition; failed percentage is zero for NULL, otherwise `failed_itemisation_pct / 100`. `daily_total_invoice#` is `CASE WHEN COUNT_DISTINCT(analysis_date) = 1 THEN AVG(total_invoices) ELSE SUM(total_invoices) END`; Record Count is `COUNT(pilot_id)`. See the implementation review for chart-specific aggregations.

### SRC-37

- **Name:** SRE Failure Statistics
- **Alias:** `ds451`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds451.
-- based on SRE Failure Statistics (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then _analysis_date_Snapshot
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(_analysis_date_Snapshot, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(_analysis_date_Snapshot, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-38

- **Name:** SRE Ingestion Audit (ED) #1
- **Alias:** `ds512`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds512.
-- based on SRE Ingestion Audit (ED) (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then _analysis_date_Snapshot
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(_analysis_date_Snapshot, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(_analysis_date_Snapshot, MONTH))
END | Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-39

- **Name:** SRE Email Statistics - Starburst
- **Alias:** `sre_email_stats_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_email_stats_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_quality_email_stats s
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| cf_last_updated_timestamp | PARSE_DATETIME('%Y%m%d', CAST(last_updated_timestamp AS STRING)) | Date & Time | TODO |
| email_sent_pct_vs_expected | (cnt_bills_emails_sent/cnt_expected_invoices)*100 | Number | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-40

- **Name:** SRE Aggregation Stats #1
- **Alias:** `ds501`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds501.
-- based on SRE Aggregation Stats (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-41

- **Name:** SRE NBI Engine Daily Run Statistics
- **Alias:** `ds352`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds352.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.pilot_id, s.analysis_date, s.reporting_date, s.total_nbi_users as total_users_successful, s.total_users_with_200_errorcode, s.total_users_with_300_errorcode, s.nbi_error_pct, s.last_updated_timestamp
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_nbi_generated_errors s
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| failure_count | total_users_with_200_errorcode+total_users_with_300_errorcode | Number | TODO |
| failure_reasons | CASE
  WHEN total_users_with_200_errorcode> 0 THEN 'DATA_FORMAT_RELATED_ISSUE'
  WHEN total_users_with_300_errorcode> 0 THEN 'DATA_VALUE_RELATED_ISSUE'
  ELSE 'FAILURE'
END | Text | TODO |
| nbi_200_error_pct | total_users_with_200_errorcode/NULLIF(failure_count,0) | Number | TODO |
| nbi_300_error_pct | total_users_with_300_errorcode/NULLIF(failure_count,0) | Number | TODO |
| nbi_success_pct | 100-nbi_error_pct | Number | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |
| total_users_nbi_generated | total_users_successful+total_users_with_200_errorcode+total_users_with_300_errorcode | Number | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Metric Toggle | CASE
  WHEN Metric = 'failure_percentage' THEN AVG(nbi_error_pct)
  WHEN Metric = 'failure_count' THEN SUM(failure_count)
END | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |
| Metric | nbi_error_pct (% Failure)/ failure_count (# Failure) | TODO | TODO | TODO |


### SRC-42

- **Name:** SRE Ingestion Audit (ED)
- **Alias:** `ds449`
- **Connector:** Extract Data
- **Dashboard section / tiles:** TODO
- **Upstream source alias / extraction filters / refresh schedule:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds449.
-- based on SRE Ingestion Audit - Starburst (App Script Addon)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-43

- **Name:** SRE Invoice Statistics - Starburst
- **Alias:** `sre_invoice_stats_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_invoice_stats_starburst.
-- engine: starburst
Select *
from
(
    SELECT
    s.pilot_id  || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name,
    s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
    COALESCE(s.failed_itemisation_pct,0) as failed_itemisation_pct,
    COALESCE(s.successful_itemisation_pct,0) as successful_itemisation_pct,
    s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
    s.fuel_type,module_name, s.analysis_date,s.delay_in_days,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
    FROM (select * from reporting.sre_invoice_statistics where trigger_flag='SCHEDULED')s left join
    (
        SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
        FROM reporting.pilot_consolidated_product_type_events
    ) as m
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
) where rnk=1
union all
Select *
from
(
    SELECT
    s.pilot_id  || ' : ' || COALESCE(m.pilot_name,'') AS pilot_id_name,
    s.pilot_id, s.meter_type,s.fuel_type,s.reporting_date,s.analysis_date,s.reporting_frequency,s.module_name,s.total_invoices,
    COALESCE(s.failed_itemisation_pct,0) as failed_itemisation_pct,
    COALESCE(s.successful_itemisation_pct,0) as successful_itemisation_pct,
    s.delay_in_days,s.trigger_flag,s.last_updated_timestamp, row_number() over(partition by s.pilot_id,s.meter_type,
    s.fuel_type,module_name, s.analysis_date,s.trigger_flag order by s.last_updated_timestamp desc) as rnk
    FROM (select * from reporting.sre_invoice_statistics where trigger_flag='ADHOC')s left join
    (
        SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
        FROM reporting.pilot_consolidated_product_type_events
    ) as m
ON
    CAST(m.pilot_id AS VARCHAR) = s.pilot_id
) where rnk=1
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| failed_itemisation_% | CASE
  WHEN failed_itemisation_pct IS NULL THEN 0
  ELSE failed_itemisation_pct/100
END | Number | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |
| successful_itemisation_correction% | CASE
    WHEN trigger_flag='ADHOC' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |
| successful_itemisation_t_2% | CASE
    WHEN delay_in_days = 2 AND trigger_flag='SCHEDULED' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |
| successful_itemisation_t_7% | CASE
    WHEN delay_in_days = 7 AND trigger_flag='SCHEDULED' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| daily_total_invoice# | CASE
  WHEN COUNT_DISTINCT(analysis_date) = 1 THEN AVG(total_invoices)
  ELSE SUM(total_invoices)
END | TODO | Number | TODO |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-44

- **Name:** SRE All Active Users
- **Alias:** `ds343`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds343.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (
        SELECT
            CASE
                WHEN POSITION('(' IN pilot_name) > 0
                THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                ELSE pilot_name
            END AS pilot_name,
            pilot_id
        FROM reporting.pilot_consolidated_product_type_events
    ) AS m
JOIN (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY pilot_id ORDER BY reporting_date DESC) AS rn
        FROM reporting.sre_total_active_users
    ) t
    WHERE rn = 1
) s
ON m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

### SRC-45

- **Name:** HER Aggregated Generation Stats
- **Alias:** `ds468`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds468.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
(
SELECT
       CASE
           WHEN position('(' IN pilot_name) > 0
           THEN substring(pilot_name FROM position('(' IN pilot_name)) -- Extract from the '(' onward
           ELSE pilot_name -- Keep the original name if '(' doesn't exist
       END AS pilot_name,
       pilot_id
   FROM reporting.pilot_consolidated_product_type_events

) AS m
JOIN

(
select pilot_id,cluster_id,analysis_date,schedule_start,schedule_end,fuel_type,'Daily' as "Period",
expected_eligible_users as expected_eligible_users,
actual_eligible_users as actual_eligible_users,
actual_generation_count as actual_generation_count,
expected_eligible_users-actual_generation_count as weekly_actual_failure_count,last_updated_timestamp
from
(
SELECT
coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
and a.measurement_type=b.measurement_type
)
union all
select pilot_id,cluster_id,analysis_week,schedule_start,schedule_end,fuel_type,'Weekly' as "Period",
max(expected_eligible_users) as weekly_expected_eligible_users,
max(actual_eligible_users) as weekly_actual_eligible_users,
sum(actual_generation_count) as weekly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as weekly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
CAST(date_trunc('week', coalesce(a.analysis_date, b.analysis_date)) AS date) AS analysis_week,
coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by 1,2,3,4,5,6
union all
select pilot_id,cluster_id,analysis_month,schedule_start,schedule_end,fuel_type,'Monthly' as "Period",
max(expected_eligible_users) as monthly_expected_eligible_users,
max(actual_eligible_users) as monthly_actual_eligible_users,
sum(actual_generation_count) as monthly_actual_generation_count,
max(expected_eligible_users)-sum(actual_generation_count) as monthly_actual_failure_count,
max(last_updated_timestamp) as last_updated_timestamp
from
(
SELECT
coalesce(a.pilot_id, b.pilot_id) AS pilot_id,
coalesce(a.cluster_id, b.cluster_id) AS cluster_id,
coalesce(a.analysis_date, b.analysis_date) AS analysis_date,
coalesce(a.reporting_date, b.reporting_date) AS reporting_date,
CAST(date_trunc('month', coalesce(a.analysis_date, b.analysis_date)) AS date) AS analysis_month,
coalesce(a.schedule_start, b.schedule_start) AS schedule_start,
coalesce(a.schedule_end, b.schedule_end) AS schedule_end,
coalesce(a.measurement_type, b.measurement_type) AS fuel_type,
a.eligible_users AS expected_eligible_users,
b.total_cluster_users AS actual_eligible_users,
b.total_missing_notification AS actual_failure_count,
b.total_generated_notification AS actual_generation_count,
a.last_updated_timestamp
FROM reporting.sre_cluster_eligible_users a
FULL JOIN reporting.sre_her_schedule_tracker b
ON a.pilot_id = b.pilot_id
AND a.cluster_id = b.cluster_id
AND a.analysis_date = b.analysis_date
AND a.schedule_start = b.schedule_start
AND a.schedule_end = b.schedule_end
AND a.measurement_type = b.measurement_type
)
group by 1,2,3,4,5,6
)AS s ON m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| success_pct | 100*(SUM(actual_generation_count)/SUM(actual_eligible_users)) | TODO | Number | TODO |

### SRC-46

- **Name:** SRE SQS Queue Metrics - Starburst
- **Alias:** `sre_sqs_queue_metrics_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_sqs_queue_metrics_starburst.
-- engine: starburst
select * from reporting.sre_queue_metrics_fact
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| analysis_date | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", analysis_date_str) | Date & Time | TODO |
| event_timestamp | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", event_timestamp_str) | Date & Time | TODO |
| reporting_date | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", reporting_date_str) | Date & Time | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-47

- **Name:** SRE Ingestion Audit - Starburst
- **Alias:** `sre_ingestion_audit_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_ingestion_audit_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    reporting.sre_ingestion_audit s
ON
    m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| last_updated_timestamp | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", last_updated_timestamp_str) | Date & Time | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-48

- **Name:** SRE HER Quality Statistics - Starburst
- **Alias:** `sre_her_quality_stats_starburst_1`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** HER NA-7A-T06.
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** SQL captured. Local source-contract/semantic checks and Starburst planning pass. Native Looker/original-report validation pending; see [HER review](bre_na_her_implementation.md).

#### Source SQL

```sql
-- TODO: Source query for alias sre_her_quality_stats_starburst_1.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
(
    SELECT
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name,
        pilot_id
    FROM reporting.pilot_consolidated_product_type_events
) AS m
JOIN
(
    -- Daily
    SELECT
        pilot_id,
        date_add('day', 1, CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE)) AS reporting_date,
        CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE) AS analysis_date,
        SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
        SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
        SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
        SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
        SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
        SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
        SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
        SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
        SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
        SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
        SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
        SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
        SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
        SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
        SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
        SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
        SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
        SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
        SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
        'Daily' AS period
    FROM public.her_automation_query_results
    GROUP BY 1,2,3

    UNION ALL

    -- Weekly
    SELECT
        pilot_id,
        CAST(date_trunc('week', date_add('day', 1, CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE))) AS DATE) AS reporting_date,
        CAST(date_trunc('week', CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE)) AS DATE) AS analysis_date,
        SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
        SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
        SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
        SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
        SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
        SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
        SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
        SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
        SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
        SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
        SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
        SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
        SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
        SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
        SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
        SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
        SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
        SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
        SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
        'Weekly' AS period
    FROM public.her_automation_query_results
    GROUP BY 1,2,3

    UNION ALL

    -- Monthly
    SELECT
        pilot_id,
        CAST(date_trunc('month', date_add('day', 1, CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE))) AS DATE) AS reporting_date,
        CAST(date_trunc('month', CAST(date_add('day', epoch_day, DATE '1970-01-01') AS DATE)) AS DATE) AS analysis_date,
        SUM(CASE WHEN low_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS low_bc_duration_cnt,
        SUM(CASE WHEN high_bc_duration_check = 'bad' THEN 1 ELSE 0 END) AS high_bc_duration_cnt,
        SUM(CASE WHEN staleness_check = 'bad' THEN 1 ELSE 0 END) AS staleness_cnt,
        SUM(CASE WHEN solar_template_check = 'bad' THEN 1 ELSE 0 END) AS solar_template_cnt,
        SUM(CASE WHEN solar_consistency_check = 'bad' THEN 1 ELSE 0 END) AS solar_consistency_cnt,
        SUM(CASE WHEN solar_generation_check = 'bad' THEN 1 ELSE 0 END) AS solar_generation_cnt,
        SUM(CASE WHEN report_consistency_check = 'bad' THEN 1 ELSE 0 END) AS report_consistency_cnt,
        SUM(CASE WHEN itemization_check = 'bad' THEN 1 ELSE 0 END) AS itemization_cnt,
        SUM(CASE WHEN bill_change_consistency_check = 'bad' THEN 1 ELSE 0 END) AS bill_change_consistency_cnt,
        SUM(CASE WHEN ev_itemization_check = 'bad' THEN 1 ELSE 0 END) AS ev_itemization_cnt,
        SUM(CASE WHEN tou_template_check = 'bad' THEN 1 ELSE 0 END) AS tou_template_cnt,
        SUM(CASE WHEN nbi_occurence_check = 'bad' THEN 1 ELSE 0 END) AS nbi_occurence_cnt,
        SUM(CASE WHEN nbi_value_check = 'bad' THEN 1 ELSE 0 END) AS nbi_value_cnt,
        SUM(CASE WHEN nbi_appliance_in_itemization_check = 'bad' THEN 1 ELSE 0 END) AS nbi_appliance_itemization_cnt,
        SUM(CASE WHEN nbi_non_null_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_non_null_insight_cnt,
        SUM(CASE WHEN nbi_unicode_check = 'bad' THEN 1 ELSE 0 END) AS nbi_unicode_cnt,
        SUM(CASE WHEN nbi_extreme_insight_check = 'bad' THEN 1 ELSE 0 END) AS nbi_extreme_insight_cnt,
        SUM(CASE WHEN nbi_seasonal_appliance_check = 'bad' THEN 1 ELSE 0 END) AS nbi_seasonal_appliance_cnt,
        SUM(CASE WHEN report_type = 'bad' THEN 1 ELSE 0 END) AS overall_report_count,
        'Monthly' AS period
    FROM public.her_automation_query_results
    GROUP BY 1,2,3
) AS s
ON m.pilot_id = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | Number | TODO |

### SRC-49

- **Name:** SRE Invoice Stat Simple - Starburst
- **Alias:** `sre_invoice_stat_simple_starburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_invoice_stat_simple_starburst.
-- engine: starburst
SELECT
    CAST(m.pilot_id AS VARCHAR) || ' : ' || m.pilot_name AS pilot_id_name,
    s.*
FROM
    (SELECT
    CASE
        WHEN POSITION('(' IN pilot_name) > 0
        THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
        ELSE pilot_name
    END AS pilot_name,
    pilot_id
FROM reporting.pilot_consolidated_product_type_events) as m
JOIN
    (SELECT
    pilot_id,
    analysis_date,
    max(reporting_date) as reporting_date,
    meter_type,
    fuel_type,
    module_name,
    trigger_flag,
    delay_in_days,
    reporting_frequency,
    MAX(total_invoices) AS total_invoices,
    MAX(successful_itemisation_cnt) AS successful_itemisation_cnt,
    MIN(failed_itemisation_cnt) AS failed_itemisation_cnt,
    MAX(successful_itemisation_pct) AS successful_itemisation_pct,
    MIN(failed_itemisation_pct) AS failed_itemisation_pct,
    MAX(last_updated_timestamp) AS last_updated_timestamp
FROM reporting.sre_invoice_statistics
GROUP BY
    pilot_id,
    analysis_date,
    meter_type,
    fuel_type,
    module_name,
    trigger_flag,
    delay_in_days,
    reporting_frequency
ORDER BY
    analysis_date,
    pilot_id) s
ON CAST(m.pilot_id AS VARCHAR) = s.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| last_updated_timestamp | PARSE_DATETIME("%Y-%m-%dT%H:%M:%S", last_updated_timestamp_str) | Date & Time | TODO |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |
| successful_itemisation_correction% | CASE
    WHEN trigger_flag='ADHOC' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |
|successful_itemisation_t_2% | CASE
    WHEN delay_in_days = 2 AND trigger_flag='SCHEDULED' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |
|successful_itemisation_t_7% | CASE
    WHEN delay_in_days = 7 AND trigger_flag='SCHEDULED' THEN successful_itemisation_pct
    ELSE NULL
END | Number | TODO |
|failed_itemisation_% | CASE
  WHEN failed_itemisation_pct IS NULL THEN 0
  ELSE failed_itemisation_pct/100
END | Number | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-50

- **Name:** SRE Master Pilot List
- **Alias:** `ds508`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds508.
-- engine: starburst
WITH all_data AS (
    SELECT
        CAST(pilot_id AS VARCHAR) AS pilot_id,
        CAST(analysis_date AS TIMESTAMP) AS analysis_date,
        CAST(reporting_date AS TIMESTAMP) AS reporting_date
    FROM reporting.sre_ingestion_audit

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_invoice_statistics

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_quality_email_stats

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_nbi_generated_errors

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_cluster_eligible_users

    UNION ALL

    SELECT
        CAST(pilot_id AS VARCHAR),
        CAST(analysis_date AS TIMESTAMP),
        CAST(reporting_date AS TIMESTAMP)
    FROM reporting.sre_email_daily_tracker
),

latest_data AS (
    SELECT
        pilot_id,
        MAX(analysis_date) AS analysis_date,
        MAX(reporting_date) AS reporting_date
    FROM all_data
    GROUP BY pilot_id
),

master_cleaned AS (
    SELECT
        CAST(pilot_id AS VARCHAR) AS pilot_id,
        CASE
            WHEN POSITION('(' IN pilot_name) > 0
            THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
            ELSE pilot_name
        END AS pilot_name
    FROM reporting.pilot_consolidated_product_type_events
)

SELECT
    m.pilot_id || ' : ' || m.pilot_name AS pilot_id_name,
    l.pilot_id,
    l.analysis_date,
    l.reporting_date
FROM latest_data l
JOIN master_cleaned m
ON l.pilot_id = m.pilot_id
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| period | CASE
    WHEN Period="Daily" then analysis_date
    WHEN Period="Weekly" then DATE(DATETIME_TRUNC(analysis_date, WEEK))
    WHEN Period="Monthly" then DATE(DATETIME_TRUNC(analysis_date, MONTH))
END| Date | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Period | Daily/Weekly/Monthly | TODO | TODO | TODO |

### SRC-51

- **Name:** SRE Failure Statistics New - Starburst
- **Alias:** `sre_failure_stats_startburst`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias sre_failure_stats_startburst.
-- engine: starburst
WITH bounds AS (
    SELECT
        MIN(analysis_date) AS min_date,
        MAX(analysis_date) AS max_date
    FROM reporting.sre_failure_statistics
),

anchors AS (
    SELECT
        CAST(date_add('day', -1 * (day_of_week(MIN(min_date)) % 7), MIN(min_date)) AS DATE) AS week_anchor,
        CAST(date_trunc('month', MIN(min_date)) AS DATE) AS month_anchor
    FROM bounds
),

-- Daily records - unchanged
daily AS (
    SELECT
        pilot_id,
        'Daily' AS period,
        meter_type,
        fuel_type,
        reporting_date,
        analysis_date,
        reporting_frequency,
        module_name,
        event_type,
        failure_reason,
        failure_percentage,
        failure_count,
        total_failure_count,
        delay_in_days,
        trigger_flag,
        last_updated_timestamp
    FROM reporting.sre_failure_statistics
),

-- Calculate week-level totals
weekly_totals AS (
    SELECT
        pilot_id,
        meter_type,
        fuel_type,
        CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) AS week_start,
        reporting_frequency,
        module_name,
        event_type,
        delay_in_days,
        trigger_flag,
        SUM(failure_count) AS total_failure_count
    FROM reporting.sre_failure_statistics s
    CROSS JOIN anchors a
    GROUP BY
        pilot_id, meter_type, fuel_type,
        CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE),
        reporting_frequency, module_name, event_type, delay_in_days, trigger_flag
),

-- Weekly aggregation with proper reporting_date
weekly AS (
    SELECT
        s.pilot_id,
        'Weekly' AS period,
        s.meter_type,
        s.fuel_type,
        MAX(s.analysis_date) AS reporting_date,  -- Latest date in the week
        CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) AS analysis_date,  -- Week start
        s.reporting_frequency,
        s.module_name,
        s.event_type,
        s.failure_reason,
        ROUND(100.0 * SUM(s.failure_count) / NULLIF(wt.total_failure_count, 0), 2) AS failure_percentage,
        SUM(s.failure_count) AS failure_count,
        wt.total_failure_count,
        s.delay_in_days,
        s.trigger_flag,
        MAX(s.last_updated_timestamp) AS last_updated_timestamp
    FROM reporting.sre_failure_statistics s
    CROSS JOIN anchors a
    JOIN weekly_totals wt
        ON s.pilot_id = wt.pilot_id
        AND s.meter_type = wt.meter_type
        AND s.fuel_type = wt.fuel_type
        AND CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE) = wt.week_start
        AND s.event_type = wt.event_type
        AND s.delay_in_days = wt.delay_in_days
        and s.trigger_flag = wt.trigger_flag
        AND s.module_name = wt.module_name
    GROUP BY
        s.pilot_id, s.meter_type, s.fuel_type,
        CAST(date_add('day', (date_diff('day', a.week_anchor, s.analysis_date) / 7) * 7, a.week_anchor) AS DATE),
        s.reporting_frequency, s.module_name, s.event_type, s.failure_reason,
        s.delay_in_days, s.trigger_flag, wt.total_failure_count
),

-- Calculate month-level totals
monthly_totals AS (
    SELECT
        pilot_id,
        meter_type,
        fuel_type,
        CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE) AS month_start,
        reporting_frequency,
        module_name,
        event_type,
        delay_in_days,
        trigger_flag,
        SUM(failure_count) AS total_failure_count
    FROM reporting.sre_failure_statistics s
    CROSS JOIN anchors a
    GROUP BY
        pilot_id, meter_type, fuel_type,
        CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE),
        reporting_frequency, module_name, event_type, delay_in_days, trigger_flag
),

-- Monthly aggregation with proper reporting_date
monthly AS (
    SELECT
        s.pilot_id,
        'Monthly' AS period,
        s.meter_type,
        s.fuel_type,
        MAX(s.analysis_date) AS reporting_date,
        CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE) AS analysis_date,
        s.reporting_frequency,
        s.module_name,
        s.event_type,
        s.failure_reason,
        ROUND(100.0 * SUM(s.failure_count) / NULLIF(mt.total_failure_count, 0), 2) AS failure_percentage,
        SUM(s.failure_count) AS failure_count,
        mt.total_failure_count,
        s.delay_in_days,
        s.trigger_flag,
        MAX(s.last_updated_timestamp) AS last_updated_timestamp
    FROM reporting.sre_failure_statistics s
    CROSS JOIN anchors a
    JOIN monthly_totals mt
        ON s.pilot_id = mt.pilot_id
        AND s.meter_type = mt.meter_type
        AND s.fuel_type = mt.fuel_type
        AND CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE) = mt.month_start
        AND s.event_type = mt.event_type
        AND s.delay_in_days = mt.delay_in_days
        and s.trigger_flag = mt.trigger_flag
        AND s.module_name = mt.module_name
    GROUP BY
        s.pilot_id, s.meter_type, s.fuel_type,
        CAST(date_add('month', date_diff('month', date_trunc('month', a.month_anchor), date_trunc('month', s.analysis_date)), a.month_anchor) AS DATE),
        s.reporting_frequency, s.module_name, s.event_type, s.failure_reason,
        s.delay_in_days, s.trigger_flag, mt.total_failure_count
),

stats AS (
    SELECT * FROM daily
    UNION ALL
    SELECT * FROM weekly
    UNION ALL
    SELECT * FROM monthly
),

-- Join with pilot information
joined_data AS (
    SELECT
        s.*,
        m.pilot_name,
        s.pilot_id || ' : ' || COALESCE(m.pilot_name, '') AS pilot_id_name
    FROM stats s
    LEFT JOIN (
        SELECT
            pilot_id,
            CASE
                WHEN POSITION('(' IN pilot_name) > 0
                THEN SUBSTRING(pilot_name FROM POSITION('(' IN pilot_name))
                ELSE pilot_name
            END AS pilot_name
        FROM reporting.pilot_consolidated_product_type_events
    ) m ON s.pilot_id = CAST(m.pilot_id AS VARCHAR)
),

-- Add ranking
ranked_data AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY analysis_date, pilot_id, module_name, period
            ORDER BY failure_percentage DESC
        ) AS rank
    FROM joined_data
)

SELECT *
FROM ranked_data
--WHERE rank <= 3
ORDER BY analysis_date DESC, pilot_id, module_name, period, failure_percentage DESC
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| calc_delay_in_days | CASE
  WHEN delay_in_days = 2 THEN "T+2"
  WHEN delay_in_days = 7 THEN "T+7"
  ELSE "> T+7"
END | Text | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Record Count | count(pilot_id) | TODO | Number | TODO |

| Parameters name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| Metric | failure_percentage (% Failure)/ failed_record_count (# Failure) | TODO | TODO | TODO |

### SRC-52

- **Name:** SRE SQS Queue Health Metrics By Day
- **Alias:** `ds341`
- **Connector:** Apps Script Addon
- **Dashboard section / tiles:** TODO
- **Engine / connection / catalog / source tables:** TODO
- **Output grain / keys / joins:** TODO
- **Date fields / filters / calculations / blends:** TODO
- **Verification status:** Query not captured; not validated.

#### Source SQL

```sql
-- TODO: Source query for alias ds341.
-- engine: starburst
SELECT
    module_name,
    environment,
    queue_type,
    queue_name,
    CAST(date_trunc('day', analysis_date) AS DATE) AS analysis_date,
    ROUND(
        (
            (SUM(CASE WHEN metric_name = 'NumberOfMessagesDeleted' THEN metric_value ELSE 0 END) /
             NULLIF(SUM(CASE WHEN metric_name = 'NumberOfMessagesReceived' THEN metric_value ELSE 0 END), 0) * 50)  -- Success rate (50%)
            + (100 - LEAST(AVG(CASE WHEN metric_name = 'ApproximateNumberOfMessagesVisible' THEN metric_value ELSE 0 END) / 1000, 1) * 100) * 0.3  -- Backlog (30%, capped at 1000)
            + (100 - LEAST(MAX(CASE WHEN metric_name = 'ApproximateAgeOfOldestMessage' THEN metric_value ELSE 0 END) / 3600, 1) * 100) * 0.2  -- Latency (20%, capped at 1 hour)
        ), 0
    ) AS health_score
FROM reporting.sre_queue_metrics_fact
GROUP BY module_name, environment, queue_type, queue_name, date_trunc('day', analysis_date)
```

#### Additional dimensions (optional)

| Dimension name | Formula / expression | Output type / format | Defined in |
| --- | --- | --- | --- |
| TODO | TODO | TODO | TODO |

#### Additional metrics (optional)

| Metric name | Formula / expression | Aggregation | Output type / format | Defined in |
| --- | --- | --- | --- | --- |
| TODO | TODO | TODO | TODO | TODO |
