# NA HER implementation review

Status, 2026-10-04: **all 17 tiles implemented as two separate draft dashboards**: 7a Data Governance (7 tiles) and 7b Queue Metrics (10 tiles). Native Looker validation and original-report comparison remain pending.

## Dashboard separation

- [7a Data Governance](../dashboards/bre_na_her_governance.dashboard.lookml): `bre_na::bre_na_her_governance`, all seven tiles.
- [7b Queue Metrics](../dashboards/bre_na_her_queue_metrics.dashboard.lookml): `bre_na::bre_na_her_queue_metrics`, all ten tiles. Every queue source uses the confirmed `module_name = 'HER'`.
- Uses the existing NA model, `starburst_prod_na`, and `delta_prodna`. BRE portal integration remains a later step.

## Implemented tiles and source semantics

| Tile | Implementation |
| --- | --- |
| NA-7A-T01 | Existing Active Users out of Total; latest snapshot before reporting-date filtering. |
| NA-7A-T02 | SUM(total_eligible_users) from SRC-22. |
| NA-7A-T03 | SUM(total_generated_notification_id) from SRC-22. |
| NA-7A-T04 | Schedule start/end table with the nine specified source-count sums from SRC-22. |
| NA-7A-T05 | SRC-34 eligibility/generation count sums as bars; user-confirmed success ratio of sums as a line on a separate axis. |
| NA-7A-T06 | Nineteen distinct source count sums by analysis date, from SRC-48, filtered on reporting_date. |
| NA-7A-T07 | Failure percentage/count by analysis date and calculated failure reason, from SRC-06. |

[Schedule view](../views/bre_na/bre_na_her_schedules.view.lkml) preserves SRC-22's latest-row selection. PSEG selects latest per schedule/cluster/fuel/quarter and adjusts schedule boundaries to that quarter. Other pilots select latest per schedule/cluster/fuel. Generated and revoked rows are FULL JOINed on the supplied keys, with the original count coalescing, then joined to the formatted pilot directory. All dashboard filters apply after these operations. Filtering raw history first would change the selected latest record, so no such pushdown is added.

[Generation view](../views/bre_na/bre_na_her_generation.view.lkml) uses the newly supplied SRC-34 SQL. Its FULL JOIN of eligibility and schedule-tracker rows and its three period branches are preserved. Daily rows retain original values; Weekly/Monthly rows use source MAX eligibility and SUM generation at the documented cluster/schedule/fuel grain. Dashboard filters run after this source aggregation, and the chart sums the selected output rows. The user confirmed `success_pct = 100 * SUM(actual_generation_count) / SUM(actual_eligible_users)`. Floating-point division preserves precision, and a zero denominator yields NULL. No outer AVG or alternate SRC-03 weekly/monthly formula is applied.

[Quality view](../views/bre_na/bre_na_her_quality.view.lkml) preserves SRC-48's Daily/Weekly/Monthly UNION ALL, epoch-day conversion, reporting-date offset, aggregate CASE expressions, and pilot INNER JOIN. Source `overall_report_count` counts `report_type = 'bad'`, not all rows. The tile inventory references `bill_change_consistency_cnt` twice under different labels; the one underlying metric is shown once with a combined descriptive label. The other eighteen unique metrics are included, including sums for the two fields whose inventory labels omit the word “sum.” No HER-version restriction beyond the supplied source is invented.

[Failure view](../views/bre_na/bre_na_her_failures.view.lkml) preserves SRC-06's period aggregation, denominator windows, ranking, and pilot INNER JOIN before applying controls. `calc_failure_reason` is `COALESCE(failure_reason, 'UNKNOWN')`. The documented Metric Toggle selects:

```text
failure_percentage: 100 * SUM(failure_count) / SUM(total_failure_count)
failure_count: SUM(failure_count)
```

Repeated source denominators are retained; the percentage is not an average of source failure percentages and is not recomputed over deduplicated denominators. Floating-point division retains precision, with NULL for a zero total denominator. Source `failure_percentage` is preserved but is not used by the tile. Source rank is retained without an undocumented top-N cutoff. Failure Metric starts at percentage as an implementation choice.

All new sources are query-time derived tables, without PDTs. Query-local row identifiers preserve all source output rows. The formatted pilot name is explicitly projected for dashboard controls; source-contract checks allow this projection and catalog qualification while requiring the remaining source SQL to match the document.

## Controls and dates

Defaults are last seven completed days, Pilot ID 10037, Pilot Name PSEG, and Period Daily. Fuel Type and Cluster IDs are unrestricted; Cluster IDs selects the source `cluster_id` field.

- Time Period uses analysis_date for schedule/generation/failure tiles, reporting_date for quality, and reporting_date for Active Users.
- Period selects the source's Daily, Weekly, or Monthly rows for generation, quality, and failures. It does not affect schedule statistics, which have no source Period field.
- The supplied Trino period queries use Monday-start weeks. These buckets are preserved; no extra Sunday rebucketing is applied to preaggregated HER rows. Date predicates apply to the already aggregated source dates.
- Fuel Type and Cluster IDs apply to schedule, generation, and failure sources. Quality and Active Users do not contain those fields, so no artificial joins are introduced.
- Failure Metric affects T07 only.

## Queue dashboard

The three queue views reuse the established NA source formulas with `module_name = 'HER'` applied before aggregation. All ten tiles listen to their own Time Period, Environment, Module, Queue Name, and Queue Type controls. The dashboard starts at row zero, independently of governance, for the later frontend tabs. The queue facts have no pilot fields.

| Tile | Implementation |
| --- | --- |
| NA-7B-T01 | AVG daily health_score. |
| NA-7B-T02 | SUM hourly total_messages_received; resolves the inventory's singular spelling to the actual source column. |
| NA-7B-T03 | AVG hourly source success_rate. |
| NA-7B-T04 | AVG hourly avg_queue_backlog. |
| NA-7B-T05 | SUM hourly total_messages_received trend. |
| NA-7B-T06 | AVG hourly avg_queue_backlog trend. |
| NA-7B-T07 | MAX hourly max_latency_in_days trend. |
| NA-7B-T08 | AVG daily health_score, stacked by queue_name. |
| NA-7B-T09 | AVG daily empty_receives_ratio. SRC-24 provides daily buckets, so the inventory's hourly date-field reference maps to that daily source date. |
| NA-7B-T10 | SUM hourly delayed_messages trend. |

The default is the last seven completed days, using source UTC date buckets. Hourly SRC-01 also retains its original rolling seven-day history restriction. Empty denominator and source rounding behavior remain unchanged.

## Validation and data availability

- [Local validator](../scripts/validate_bre_na_her.py): seventeen tiles, twenty-five rendered SQL variants, twenty-five semantic fixtures, and four source-contract checks pass.
- All twenty-five exports pass Starburst `EXPLAIN (TYPE VALIDATE)`, including all three generation/quality periods, both failure metrics over all three periods, and all ten queue tiles. Active Users matches the existing validated configuration.
- Fixtures verify latest PSEG rows per quarter, adjusted schedule boundaries, revoked-only FULL JOIN rows, filters after latest-row selection, period isolation, repeated failure denominators, UNKNOWN reasons, fuel/cluster filters, zero denominators, quality reporting-date behavior, the generation FULL JOIN and period-specific MAX/SUM rules, and HER/environment queue isolation.
- PSEG's default September 27–October 3, 2026 range returns no rows from these HER sources. The latest analysis date is **September 4, 2025** for the daily tracker, revoked users, and schedule errors. There are no PSEG rows in `public.her_automation_query_results`. Defaults are retained.
- Historical PSEG queries for September 1–7, 2025 return 476,968 expected and 393,504 generated reports for the July 1–September 30 schedule, plus the remaining schedule measures and failure percentages. Missing current data is not replaced with zero.
- Historical generation queries return the confirmed success ratios, including 14.046475399195119% for September 1, 2025 and 52.54145246542611% for September 2. The default current generation range is empty.
- Three bounded queue executions return current data. HER health-score average is 76.35714285714286; hourly success-rate average is 98.23005649717514%. Daily empty-receives percentages are also returned. Hourly results reflect the intersection with the source rolling seven-day limit.
- Ingestion, Aggregation, Disaggregation, TOU, Rate Comparison, and Email local validators pass after these model additions, including ten CA/EU source-route checks.
- [Evidence](bre_na_her_validation.json) records query IDs, sample results, and freshness. Run `uv run scripts/validate_bre_na_her.py` to regenerate the local checks and SQL exports. This renderer is a simulator, not Looker's compiler.

## Remaining acceptance checks

All supplied HER queries and confirmed formulas are implemented. Native Looker validation, original-report parity, and dashboard rendering remain pending because no Looker connection is available. Verify original-report extract settings, any undocumented failure-rank cutoff, the initial Failure Metric selection, the quality tile's duplicated bill-change label, and the daily efficiency source's hourly field reference. Current PSEG governance data availability is recorded above; dashboard defaults are not changed to hide empty source results.
