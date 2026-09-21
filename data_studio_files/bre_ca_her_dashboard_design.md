# CA HER dashboard design

Status: all seven tiles and six controls are implemented; native Looker validation and execution remain pending. CA only; no EU dashboard is planned. Seven query tiles are implemented in `dashboards/bre_ca_her.dashboard.lookml`, included in model `bre_ca` using `starburst_prod_ca` and the shared `bre_dashboard` Explore.

## Implemented tiles

| Tile | Source family | Metric | Date filter |
|---|---|---|---|
| Active UUID / Total UUID | `activeusers` | Existing combined UUID summary, latest reporting-date snapshot per pilot | Independent of Time Period; Pilot ID and Pilot Name apply, matching Ingestion/Disagg |
| HER Expected vs Generation — Expected Gen # | `herschedules` | SUM(total_eligible_users) | `schedule_start` |
| HER Expected vs Generation — Total Actual Gen # | `herschedules` | SUM(total_generated_notification_id) | `schedule_start` |
| HER Schedule(s) | `herschedules` | Eight separate SUM columns grouped by schedule Start and End | `analysis_date` |
| HER Generation Daily Stats | `hergeneration` | Three SUM count bars and AVG row-level Success % line, grouped from Daily source rows | `analysis_date` |
| Daily HER Quality Report (Only for HER 2.0**) | `herautomationquality` | 19 SUM line series grouped from Daily source rows | `reporting_date` |
| Daily HER Generation Failure Reasons | `herfailures` | SUM(failure_count), stacked by failure_reason, grouped from Daily source rows | `analysis_date` |

The two generation tiles use SRE HER Schedule Specific Statistics (Apps Script Addon), mapped to the existing `bre_her_schedules` view over `delta_prodca.reporting.sre_daily_her_tracker`. Both shared sum measures already exist. There is no previous-period comparison or time grouping on these totals.

Time Period defaults to the last 7 completed days (`7 days ago for 7 days`). It filters the output `schedule_start` after the source selects its latest snapshots, retaining the source's special quarterly schedule segmentation for pilot 10037. It does not select snapshots by reporting date or match schedules merely overlapping the date range. Pilot ID and Pilot Name use the existing shared controls, defaulting to all pilots.

The user's proposed date-range dimension is `schedule_start`; this is the implemented binding, pending confirmation through their native dashboard review.

## HER Schedule(s) table

Uses the same SRE HER Schedule Specific Statistics source. Start (`schedule_start`) and End (`schedule_end`) are date columns, followed by these measures in order:

| Column | Aggregation |
|---|---|
| Expt Gen# | SUM(total_eligible_users) |
| Actual Gen# | SUM(total_generated_notification_id) |
| Failed Gen# | SUM(total_failed_notification_id) |
| Schld # | SUM(total_scheduled_notification_id) |
| Swept # | SUM(total_swept_notification_id) |
| Queued # | SUM(total_queued_notification_id) |
| Printed # | SUM(total_printed_notification_id) |
| Mailed # | SUM(total_mailed_notification_id) |

Time Period filters the source output `analysis_date`, after latest-snapshot selection, with the default last 7 completed days. Pilot ID and Pilot Name also apply. Rows group only by Start and End, summing across all selected pilots, clusters and fuel types that share those dates. Dates are not bucketed by Period. Initial sort is Start descending, then End descending. All measures and date dimensions reuse existing shared fields.

## HER Generation Daily Stats — implemented

Source: HER Aggregated Generation Stats (Apps Script Addon), mapped to `hergeneration`. Time Period filters `analysis_date`. Analysis Date on the X axis follows Daily/Weekly/Monthly selection. The requested chart has these series:

| Label | Aggregation | Visualization |
|---|---|---|
| Expected Eligible # | SUM(expected_eligible_users) | Bar, left count axis |
| Actual Eligible # | SUM(actual_eligible_users) | Bar, left count axis |
| Actual Generation # | SUM(actual_generation_count) | Bar, left count axis |
| Success % | AVG(success_pct) | Line, right percentage axis |

The three count measures already exist in the shared view. The user confirmed `success_pct = 100 * (actual_generation_count / actual_eligible_users)`. Shared fields now implement this row-level ratio with decimal division and NULL for zero eligibility, plus an unweighted AVG measure with literal percentage formatting. NULL ratios are omitted; zero generation with nonzero eligibility is retained. This is an average of row ratios, not a ratio of summed counts.

The user confirmed grouping Daily rows. The tile fixes the source `period` parameter to Daily, so Weekly/Monthly source aggregates are excluded. The separate `her_generation_chart_period` parameter controls the X-axis grouping: Daily, Sunday-start Weekly, or Monthly. The dashboard Period control affects Generation Daily Stats, HER Quality and HER Generation Failure Reasons; it does not affect the schedule table or scorecards.

Time Period filters the original Daily `analysis_date` before grouping. All three count measures sum Daily source rows, including repeated eligibility counts across days. Success % averages Daily source-row ratios within each displayed bucket. Existing source SQL is unchanged. The chart uses three side-by-side count bars on the left axis and the Success % line on the right axis.

## Daily HER Quality Report — implemented

Source: SRE HER Quality Statistics (the locally copied Redshift source), mapped to the existing `bre_her_automation_quality` view over Starburst `delta_prodca.public.her_automation_query_results`. No Redshift connection is used. The source builds daily bad-check counts by pilot and analysis/reporting dates; reporting date is epoch day plus one, while analysis date is epoch day.

The user confirmed Daily source rows and one bill-change line. The tile fixes source `period` to Daily, filters daily `reporting_date` with Time Period (default last 7 completed days), and groups `analysis_date` into Daily, Sunday-start Weekly or Monthly buckets. A typed `her_quality_chart_date` alias reuses the generation chart calendar and its independent chart-period parameter. Pilot ID and Pilot Name apply. No additional HER 2.0 restriction is added.

All 19 metrics use the existing SUM measures, with these labels and order on one shared count axis:

| Source metric | Line label |
|---|---|
| `high_bc_duration_cnt` | BC > 70 days # |
| `staleness_cnt` | Stale BC # |
| `solar_template_cnt` | Solar Reports with Cost-based Section # |
| `solar_consistency_cnt` | Solar Report for Non-Solar |
| `solar_generation_cnt` | Solar Estimation 0 or Null |
| `report_consistency_cnt` | Inconsistency Between Cost & Consumption Across Sections |
| `low_bc_duration_cnt` | BC < 23 days |
| `itemization_cnt` | Itemisation Mismatch # |
| `bill_change_consistency_cnt` | Invalid Bill Change Calculations |
| `ev_itemization_cnt` | EV Report for EV undetected in Itemisation |
| `tou_template_cnt` | TOU Report for Non-TOU BC # |
| `nbi_occurence_cnt` | Missing NBI Unit/Format Token (e.g. "%", "$", "kWh") |
| `nbi_value_cnt` | Inconsistency in Insight Calculations (>10%) |
| `nbi_appliance_itemization_cnt` | Missing Appliances in Itemisation Referenced by NBI Insights |
| `nbi_non_null_insight_cnt` | Missing or Invalid Numeric NBI Insight Value |
| `nbi_unicode_cnt` | Unicode in the NBI Insights # |
| `nbi_extreme_insight_cnt` | Extreme Insight Values |
| `nbi_seasonal_appliance_cnt` | Season-based Blocked Appliances in NBI Insights # |
| `overall_report_count` | Overall Report # |

`bill_change_consistency_cnt` appears once as Invalid Bill Change Calculations. Overall Report # preserves the source definition: count of rows with `report_type = 'bad'`, not a count of all reports. The chart is full width below Generation Daily Stats, with chronological dates and a visible legend.

## Daily HER Generation Failure Reasons — implemented

Source: SRE HER Cluster Specific Failure Rate (Apps Script Addon), mapped to the existing `bre_her_failures` view over `delta_prodca.reporting.sre_her_schedule_errors`.

The metric is SUM(failure_count), labeled Failure Count, with `failure_reason` as the pivot/breakdown in normally stacked columns. Source `period` stays Daily. Time Period filters the original daily `analysis_date`, defaulting to last 7 completed days. The independent HER chart Period groups dates into Daily, Sunday-start Weekly or Monthly buckets through the typed `her_failures_chart_date` calendar alias. Pilot ID and Pilot Name also apply. No rank or top-N restriction is added. Source ranking and joins remain unchanged.

The chart is full width beneath HER Quality. Zero counts remain zero and NULL counts retain the existing SUM behavior. All three time-series charts share the Period control; the schedule table and scorecards retain their existing bindings.

## Fuel Type and Cluster IDs — implemented

Both controls get dynamic values from SRE HER Cluster Specific Generation Stats (`bre_her_generation`) through the CA-only hidden `bre_her_filters` Explore. The source exposes `fuel_type` and `cluster_id` as strings, preserving source values without fixed lists or renamed options. Each control allows multiple selections and defaults to all values.

| Tile | Fuel Type | Cluster IDs |
|---|---|---|
| Active UUID / Total UUID | No — explicitly excluded | No — explicitly excluded |
| Expected Gen # | Yes | Yes |
| Total Actual Gen # | Yes | Yes |
| HER Schedule(s) | Yes | Yes |
| HER Generation Daily Stats | Yes | Yes |
| Daily HER Quality Report | No — source has no fuel_type | No — source has no cluster_id |
| Daily HER Generation Failure Reasons | Yes | Yes |

Quality source rows are already aggregated by pilot and dates; both fields are NULL in the shared source contract. No attribution or new joins are invented to apply these filters. Active UUID retains its existing Pilot ID / Pilot Name listeners.

All seven tiles and six controls are implemented: Time Period, Period, Pilot ID, Pilot Name, Fuel Type and Cluster IDs. Native Looker validation and execution remain pending; data validation remains deferred until data readiness.

## Validation

Local checks cover dashboard parsing, CA-only inclusion, field exposure, filter listeners and Trino parsing of the two sum queries with schedule-start date predicates and the schedule table query grouped by Start/End with an analysis-date predicate. Generation validation also covers all three chart periods, Daily-only source selection, sum/average semantics, date boundaries and zero/NULL ratios. Quality validation covers all 19 sums, Daily-only source selection, the three calendar periods, and reporting-date filtering independently of analysis dates, including week/month boundaries. Failure-chart validation covers SUM by reason for all three periods, Daily-only selection, date boundaries, zero/NULL counts and inclusion of source ranks above three. Filter validation checks the generation source for both dropdowns, five compatible tile listeners per control, explicit UUID/Quality exclusions, and multi-value filtering. Existing source SQL is reused, with shared chart grouping, Success % fields and two dropdown dimensions added; no PDTs are added. Native LookML validation and dashboard execution remain for the user in Looker. Warehouse data validation remains deferred until migration and EMR repointing are complete.
