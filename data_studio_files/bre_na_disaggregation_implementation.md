# NA Disaggregation implementation review

Status: both separate dashboards implemented as drafts, 2026-10-03. All 18 documented tiles are present. Native Looker validation and original-report result comparison remain pending.

- [3a Data Governance Disaggregation](../dashboards/bre_na_disaggregation_governance.dashboard.lookml): `bre_na::bre_na_disaggregation_governance`, 8 tiles.
- [3b Queue Metrics Disaggregation](../dashboards/bre_na_disaggregation_queue_metrics.dashboard.lookml): `bre_na::bre_na_disaggregation_queue_metrics`, 10 tiles.
- [NA model](../models/bre_na.model.lkml): `starburst_prod_na`, `delta_prodna` catalog. Frontend tabs and BRE portal integration remain later steps.
- [Source specification](bre_na_model_base_data.md#na-disaggregation).

## Sources and interpretation

The user supplied two distinct invoice queries. SRC-04 selects the latest SCHEDULED row per pilot, meter, fuel, module, analysis date, delay, and trigger; its ADHOC branch selects the latest row across delays. Its original left pilot join and NULL-percentage-to-zero handling are preserved. Dashboard filters run after this selection.

SRC-36 uses a calendar and Daily/Weekly/Monthly aggregates with ratios computed from summed invoice counts. It does not use SRC-04's latest-row selection. Its original 5,000-row calendar-generation limit, period aggregation, and inner pilot join are retained. The trend tile selects the requested source period; reporting-date filtering follows aggregation. The use of reporting_date follows the source's explicit filter comments and the documented control mappings; T06 itself did not specify its date-range field. Confirm this against the original chart during acceptance.

SRC-10 quality and SRC-51 failures also contain separate Daily/Weekly/Monthly rows. The Period control selects those source rows rather than averaging all three sets together. Their source reporting-date rules are retained. Failure ranking occurs before the dashboard's meter, fuel, module, reporting-date, and rank filters. The source's joins, denominators, and grouping keys are preserved even where they warrant later source-report review.

Queue sources reuse the implemented SRC-01 hourly, SRC-24 daily, and SRC-52 health definitions through LookML extensions with separate derived SQL. The user confirmed the fixed predicate:

```sql
module_name IN ('Disaggregation', 'Aggregation', 'UploadEventSplitter')
```

This predicate remains in effect when the Module Name control is cleared or changed. Environment, module, queue name, queue type, and date controls filter raw queue facts before aggregation. SRC-01 retains its rolling seven-day history restriction. Queue timestamps are grouped in UTC. All new derived tables run at query time; no PDTs are introduced.

## Governance tiles

| Tile | Implementation |
| --- | --- |
| NA-3A-T01 | Existing NA Active Users out of Total; latest snapshot before reporting-date filtering. |
| NA-3A-T02 | AVG(total_invoices) from SRC-04, compared with the preceding equal-length analysis-date range. |
| NA-3A-T03 | Exact median(total_invoices), with the same comparison behavior. Missing or zero previous values produce no relative change. |
| NA-3A-T04 | SUM of successful_itemisation_pct for SCHEDULED, delay 7 rows. |
| NA-3A-T05 | SUM of successful_itemisation_pct for SCHEDULED, delay 2 rows. |
| NA-3A-T06 | SRC-36: MAX(total_invoices), AVG T+2 success, AVG T+7 success, and MAX ADHOC correction success. Count and percentage series use separate axes. |
| NA-3A-T07 | AVG of all 12 documented quality fields from SRC-10. Source period and reporting date determine the rows. |
| NA-3A-T08 | AVG(failure_percentage), stacked by failure_reason, with original source rank <= 3. |

Both gauges preserve SUM as explicitly documented, even though their titles say Average. Each has a 0–100% semicircular scale, a full arc at or above 100, and the actual number always displayed. For the sampled PSEG analysis dates 2026-09-26 through 2026-10-02, the source yields 171.05% for T+7 and 363.51% for T+2. These are sums of percentages, not bounded success-rate averages.

The supplied calculated fields are preserved: conditional T+2/T+7/ADHOC success, failed percentage divided by 100 with NULL mapped to zero, `daily_total_invoice#` (AVG when there is one distinct analysis date, otherwise SUM), and COUNT(pilot_id). The latter two are available measures; they do not replace the trend chart's documented MAX.

## Queue tiles

| Tile | Implementation |
| --- | --- |
| NA-3B-T01 | AVG source health score. |
| NA-3B-T02 | SUM messages received by hour, shown as a line as specified. |
| NA-3B-T03 | AVG source hourly success_rate; the document does not specify its chart aggregation, so this follows the Ingestion convention pending comparison. |
| NA-3B-T04 | AVG source hourly avg_queue_backlog. |
| NA-3B-T05 | SUM messages received by hour. |
| NA-3B-T06 | AVG source backlog by hour. |
| NA-3B-T07 | MAX oldest-message latency in days, by hour. |
| NA-3B-T08 | AVG health score by day, stacked by queue_name. |
| NA-3B-T09 | AVG source daily empty_receives_ratio, in percent. |
| NA-3B-T10 | SUM delayed_messages by hour, as specified; its original Oldest Message Age title is retained despite the count metric. |

## Controls

Governance has Time Period (last seven completed days), Period (Daily by default), Pilot ID (10037), Pilot Name (PSEG), Meter Type, Fuel Type, and Module Name. The last three initially have no selection.

Active Users listens only to date and pilot controls. Invoice summaries and gauges use analysis_date; their source metrics have no period reaggregation. The three trend charts listen to Period. The quality source lacks module_name, so it does not listen to Module Name. Its Elec AMI title is retained, but no fixed fuel/meter predicate was supplied, so none is invented. Meter and Fuel controls apply where those columns exist.

Queue Metrics has independent Time Period, Environment, Module Name, Queue Name, and Queue Type controls. All ten queue tiles listen to all five controls. No pilot control is added to queue sources that lack pilot_id.

## Validation

- [Local validator](../scripts/validate_bre_na_disaggregation.py): 8 governance tiles, 10 queue tiles, 23 rendered query variants, 18 semantic fixtures, and three source-order checks pass. Includes source references, filter wiring, layout, gauges, exact median and comparisons, conditional success sums, latest-row selection across SCHEDULED/ADHOC delays, module membership, and environment filtering.
- All 23 exported tile query variants pass Starburst `EXPLAIN (TYPE VALIDATE)`. Daily, Weekly, and Monthly are covered for all three governance trends. The reused Active Users query configuration is checked against the existing dashboard.
- A bounded SRC-04 PSEG sample executes successfully: 10 source rows, average invoices 86,687.4, T+7 sum 171.05%, T+2 sum 363.51%.
- Eight standalone Highcharts gauge cases pass, including both observed values above 100%, zero, partial, and full arcs. [Gauge preview](bre_na_disaggregation_gauge_preview.png) was visually inspected. This is not target Looker rendering.
- Existing Ingestion and Aggregation validators pass after the model additions, including ten CA/EU source-route regressions. Their source and dashboard files are unchanged by this step.
- [Validation evidence](bre_na_disaggregation_validation.json) records planning query IDs and sample results.

Run `uv run scripts/validate_bre_na_disaggregation.py` to regenerate local checks and planning queries. The renderer is a focused simulator, not Looker's compiler.

## Remaining acceptance checks

Native LookML validation and actual dashboard rendering require a Looker connection, which is unavailable in this session. Compare results against the original report, including extract restrictions, T06's date field, the quality chart's fixed meter/fuel scope, and the unspecified queue success-rate aggregation. The two title/metric mismatches noted above are intentionally preserved from the specification.
