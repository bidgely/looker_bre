# NA NBI implementation review

Status, 2026-10-04: **all 16 tiles implemented as two separate draft dashboards**, eight tiles each for Governance 8a and EMR 8b. The blend input grouping and three join keys were confirmed from the user screenshot and reply. Native Looker validation and original-report comparison remain pending.

## Dashboard separation

- [8a Governance](../dashboards/bre_na_nbi_governance.dashboard.lookml): `bre_na::bre_na_nbi_governance`.
- [8b EMR Metrics](../dashboards/bre_na_nbi_emr_metrics.dashboard.lookml): `bre_na::bre_na_nbi_emr_metrics`.
- [NA model](../models/bre_na.model.lkml) explicitly includes both dashboards and four source explores plus a blend explore and daily scatter-point explore. No BRE portal integration is included in this change.

## Sources and controls

SRC-41 generation, SRC-20 generic-tag users, SRC-32 EMR metrics, and SRC-18 failed-stage counts preserve the supplied SQL and pilot-directory joins. Changes are NA catalog qualification, exposing the already joined pilot name, and adding query-local row identifiers. No source deduplication or extra NBI module predicate is introduced. Filters apply after source processing; SRC-18 retains its per-pilot/day grouping before filters. All tables remain query-time derived tables.

Both dashboards default to PSEG / pilot 10037 and the last seven completed days. Governance trends group Daily, Sunday-start Weekly, or Monthly. Governance scorecards aggregate the selected range independently of Period; Active Users uses its existing latest-snapshot/reporting-date behavior. EMR Period controls T05's time buckets. T06 retains daily analysis dates as specified; its input period is functionally dependent on those dates. T07 is explicitly one point per analysis date, so Period does not rebucket it. Scorecards and Details aggregate the selected range without date bucketing.

## Governance tiles

| Tile | Implementation |
| --- | --- |
| NA-8A-T01 | Existing NA Active Users / Total UUID snapshot tile. |
| NA-8A-T02 | AVG(total_users_successful) and change against the preceding equal-length analysis-date range. |
| NA-8A-T03 | Exact median of the same source count and preceding-range comparison. NULLs omitted; even-sized samples average the central pair. |
| NA-8A-T04 | AVG(format-error count / total failure count), multiplied by 100 for percentage display. |
| NA-8A-T05 | AVG(value-error count / total failure count), multiplied by 100 for percentage display. |
| NA-8A-T06 | Average NBI user base and successful users as bars; AVG(100 - nbi_error_pct) as the success line. |
| NA-8A-T07 | SUM(total_nbi_users_with_generic_tag) as a line, as specified for NA. |
| NA-8A-T08 | Average format/value error counts as stacked columns; no additional top-N restriction. |

Failure shares are unweighted averages of row-level fractions, not ratios of summed counts. Float division preserves fractional shares; zero total failures yields NULL. The source's rounded nbi_error_pct is preserved, so a small positive failure count may still accompany a displayed 100% success rate.

Both gauges are red, span 0–100%, show the actual numeric value, and fill the arc at or above 100%. Zero has an empty arc. Missing values are not replaced by zero. [Gauge preview](bre_na_nbi_gauge_preview.png) tests zero, partial, full, and above-maximum cases using the established Highcharts configuration; it is not a Looker UI screenshot.

## EMR tiles and confirmed blend

| Tile | Implementation / remaining information |
| --- | --- |
| NA-8B-T01 | Confirmed COUNT(cluster_id), not COUNT(pilot_id) or distinct cluster count. |
| NA-8B-T02 | Source success_rate_perc aggregate formula; includes RUNNING and TERMINATED with reason ALL_STEPS_COMPLETED. |
| NA-8B-T03 | Source failure_rate_perc aggregate formula; FAILED, TERMINATED_WITH_ERRORS, CANCELLED, INTERRUPTED over all non-NULL statuses. |
| NA-8B-T04 | AVG(duration_seconds), rounded to whole seconds and displayed as hh:mm:ss; hours do not wrap at 24. |
| NA-8B-T05 | Average of input-group AVG(duration_seconds), by period with cluster_type as a pivot. |
| NA-8B-T06 | SUM(failure_count) and SUM(is_failed) bars; AVG(nbi_error_pct) and AVG(input failure_rate_perc) lines, grouped by analysis_date. The duplicated nbi_error_pct inventory entry is displayed once. |
| NA-8B-T07 | Per analysis date: X = SUM(is_failed), Y = SUM(stages_present), bubble size = AVG(nbi_error_pct), all after the confirmed blend. |
| NA-8B-T08 | Details at the documented dimension grain, SUM(duration_seconds), excludes RUNNING. |

T02/T03 use the supplied aggregate formulas at the scorecard grain, without invalid nested AVG(COUNT(...)). The inventory's descriptions of fully completed/failed pipelines are broader than those formulas: RUNNING counts as success, and missing stages are checked only by SRC-18. Original-report comparison remains necessary.

SRC-32 emits ISO UTC timestamp strings. Its documented PARSE_DATE("%Y%m", ...) cannot parse those values; the implementation extracts the ISO date for analysis-date filtering, while retaining full UTC creation/end strings in Details. T08's RUNNNIG is treated as a spelling error for RUNNING, still awaiting explicit confirmation. No extra status restriction is applied to other tiles. A [string measure](https://docs.cloud.google.com/looker/docs/reference/param-measure-types#string) formats average duration while the numeric seconds measure remains available.

The shared blend is `SRE_NBI_EMR_FAILURE_CORR_BLEND`. Both inner joins use `pilot_id`, `pilot_id_name`, and `analysis_date`; the user confirmed that the extra condition is pilot name, represented by `pilot_id_name` in the screenshot. Period is not a join key. All input date ranges are Auto on analysis_date; no source-box filters are configured.

| Input | Dimensions before joining | Metrics before joining |
| --- | --- | --- |
| SRC-41 generation | analysis_date, nbi_error_pct, failure_count, period, pilot_id_name, pilot_id | None: SELECT DISTINCT these dimensions. |
| SRC-32 EMR | analysis_date, cluster_id, module_name, cluster_type, metric_name, metric_value, period, pilot_id_name, pilot_id | AVG(duration_seconds); Auto failed_job_cnt = 1 - COUNT(DISTINCT cluster_type); Auto failure_rate_perc using its documented count ratio. |
| SRC-18 failed jobs | analysis_date, pilot_id, has_failed_stage, stages_present, period, pilot_id_name | SUM(is_failed). |

Pilot name is also exposed from each source for dashboard filtering; it is already determined by the pilot ID/name dimensions, so it does not add grouping detail. Source grouping is performed before the inner joins. Original source SQL copies are checked against the independently validated source views.

Daily generation counts and failed-job indicators can repeat across matching EMR cluster/status groups. These repetitions are preserved to match the screenshot and the chart SUMs, rather than applying distinct sums or extra deduplication. For example, historical PSEG days with two NBI failures and three EMR stage groups display six blended failures and nine summed stages. A single-source KPI and a blended count can therefore differ by design.

T07 aggregates the filtered blend once per analysis date in a separate query-time view. This exposes the summed failed-job count as a numeric X dimension, summed stages as Y, and mean NBI error percentage as bubble size. The date remains in the query but is hidden from the plotted axes; identical coordinates on different dates remain distinct query rows. This uses the documented [scatter dimension hiding and size-by-field options](https://docs.cloud.google.com/looker/docs/reference/param-lookml-dashboard-scatter-chart). Its view references the blend SQL through SQL_TABLE_NAME; outer pilot/date predicates apply before calculating daily coordinates, independently of nested source-filter scope. Native Looker scatter rendering remains to be checked.

## Validation and data availability

- [Local validator](../scripts/validate_bre_na_nbi.py): 16 tiles, 27 rendered SQL variants, 44 semantic fixtures, and seven source-contract checks pass.
- All 27 rendered queries pass Starburst `EXPLAIN (TYPE VALIDATE)`. Active Users reuses the previously validated configuration.
- Fixtures exercise exact median/current-prior boundaries, zero prior values, unweighted error shares, NULL/zero denominators, date bucketing, non-NULL cluster counts, all four failure statuses, RUNNING success, duration formatting above 24/99 hours, negative/missing durations, and the SRC-18 missing-stage/failed-stage distinctions.
- Eight standalone gauge rendering cases pass in Chrome, including actual labels above the gauge maximum.
- All seven earlier NA group validators pass after the model additions, including the ten CA/EU routing regression checks. `git diff --check` passes.
- The September 27–October 3, 2026 PSEG range has no rows in the three underlying NBI sources. Latest generation and generic-tag analysis date: March 4, 2026. Latest EMR date: March 5, 2026. Defaults are retained; missing data is not filled with zero.
- Historical February 26–March 4, 2026 results: average successful users 573,262.75; median 573,306.5; format/value failure shares 0%/100%; EMR cluster count 12; average duration 00:53:03. Trend and detail queries also execute successfully.
- The seven new blend query variants pass Starburst planning. All three new tiles execute for both the empty default range and the populated historical range. Historical scatter results contain three daily points at (0 failed jobs, 9 summed stages) with 0% NBI error; duration trends contain nine stage/day groups.
- Blend fixtures verify source-group deduplication/aggregation, AVG of input averages rather than raw-row weighting, inner-join exclusions, pilot-name key mismatches, filter placement, period buckets, and scatter coordinates.
- [Evidence](bre_na_nbi_validation.json) retains query IDs, sample outputs, and the confirmed blend keys. Run `uv run scripts/validate_bre_na_nbi.py` to regenerate local checks and planning SQL. The renderer is a simulator, not Looker's compiler.
