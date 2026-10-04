# NA Ingestion implementation review

Status: draft, 2026-10-03. Source: [NA specification](bre_na_model_base_data.md#na-ingestion).

Ingestion is the first NA dashboard group in the requested sequence. Per the requested split, 1a Data Governance (eight tiles) and 1b Queue Metrics (ten tiles) are separate LookML dashboards, each with its own controls. Both layouts start at row zero. Frontend tabs will be added later. The NA model uses `starburst_prod_na` and the verified `delta_prodna` catalog. BRE portal integration and cross-region standardization are later steps.

- [NA model](../models/bre_na.model.lkml)
- [1a Data Governance Ingestion](../dashboards/bre_na_ingestion_governance.dashboard.lookml) — embed ID `bre_na::bre_na_ingestion_governance`
- [1b Queue Metrics Ingestion](../dashboards/bre_na_ingestion_queue_metrics.dashboard.lookml) — embed ID `bre_na::bre_na_ingestion_queue_metrics`
- [NA source router and overrides](../views/bre_na/bre_dashboard_na.view.lkml)
- [Local validation script](../scripts/validate_bre_na_ingestion.py)

## Tile mapping

| Source tile | LookML element | Implementation / remaining differences |
| --- | --- | --- |
| NA-1A-T01 | `active_uuid` | Active UUIDs out of total; latest snapshot per pilot, then reporting-date filtering. |
| NA-1A-T02 | `files_average` | Source-row average and percentage change vs. preceding equal-length date range. |
| NA-1A-T03 | `files_median` | Exact source-row median and percentage change vs. preceding equal-length date range. |
| NA-1A-T04 | `daily_users` | Documented SUM of users in millions; semicircular 0–20 M gauge and centered numeric value. |
| NA-1A-T05 | `daily_success` | AVG of source success_percentage; semicircular 0–100% gauge with centered numeric value. |
| NA-1A-T06 | `daily_ingestion_statistics` | All seven series implemented. Audit LEFT JOIN Rate Comparison on pilot_id and full last_updated_timestamp; Rate Plan ID filters the joined tracker field. Original-report input grain and result parity remain pending. |
| NA-1A-T07 | `post_ingestion_quality` | Raw age buckets use COUNT; invoice buckets use SUM; totals use source formulas in millions. Totals plotted as lines and buckets as bars, pending visual confirmation. |
| NA-1A-T08 | `ingestion_failure_reasons` | Source rank <= 3, error-code breakdown, selectable AVG percentage / SUM failed records. |
| NA-1B-T01 | `na_1b_t01` | AVG of SRC-52 health_score. |
| NA-1B-T02 | `na_1b_t02` | Hourly SUM of received messages. |
| NA-1B-T03 | `na_1b_t03` | AVG of SRC-01 success_rate, pending chart aggregation confirmation. |
| NA-1B-T04 | `na_1b_t04` | AVG of SRC-01 avg_queue_backlog; date control targets the hourly source bucket. |
| NA-1B-T05 | `na_1b_t05` | Hourly SUM of received messages. |
| NA-1B-T06 | `na_1b_t06` | Hourly AVG of avg_queue_backlog. |
| NA-1B-T07 | `na_1b_t07` | Hourly SUM of sent messages, as specified for the Processed Messages chart. |
| NA-1B-T08 | `na_1b_t08` | AVG health_score by day, stacked by environment as specified; title still says Queue Name. |
| NA-1B-T09 | `na_1b_t09` | AVG of daily total_messages_received, as documented; not an efficiency ratio. |
| NA-1B-T10 | `na_1b_t10` | MAX latency in days, by hour. |

## Confirmed configuration

- User confirmed the SQS Ingestion Module Filter is exactly `module_name = 'Ingestion'`. It is enforced in all three queue source queries, independent of the editable module control.
- Starburst schema inspection confirmed the shared ingestion columns and queue source fields. Pilot `10037` is `PSEG` and has one directory row.
- Only five shared source files change: the NA catalog branch is added to pilots, active users, ingestion audit, ingestion failures, and post-ingestion. Their existing CA/EU rendered SQL is checked against Git HEAD.
- All new derived tables run at query time. There are no PDTs.
- The NA source fields extend the existing shared contract, with NA overrides for raw File Type, the users SUM, bucket COUNTs, and the failure metric selector. Other CA/EU definitions are unchanged.

## Controls and interpretation

Governance uses Time Period, Period, Pilot ID (default `10037`), Pilot Name (default `PSEG`), raw File Type, Rate Plan ID, and Failure Metric. Queue controls are Queue Time Period, Event Timestamp (UTC), Module Name, Queue Name, and Queue Type. Date defaults use the last seven completed days. Weekly grouping starts Sunday, matching the documented Data Studio WEEK formula.

Time Period filters Active Users by reporting_date. The source still selects the latest snapshot before date filtering; a historical selection can therefore return no active-user row. File Type and Rate Plan are not present in that source and are not artificially joined onto it. Period is relevant to grouped time-series charts, not to single-value tiles. Pilot controls do not affect queues because the queue source has no pilot_id.

Queue filters run on raw source facts before aggregation. Event Timestamp accepts the exact UTC string `YYYY-MM-DDTHH:MM:SS`; a dropdown with observed timestamp suggestions has not been implemented. Queue timestamp grouping uses UTC. SRC-01's rolling seven-day SQL restriction is preserved, so an older dashboard range cannot retrieve older hourly history and the earliest completed day may be partial. SRC-24 and SRC-52 have no such source history limit.

Source formulas are preserved even when names are misleading: the users KPI is a SUM despite “Daily Average” in its title; source NULLIF terms propagate nulls; OPOWER is omitted from the documented total_users_across_age_buckets CASE; queue backlog averages include source ELSE 0 rows. Source health-score rounding and weighting are unchanged, with no additional clamping.

## Rate Comparison blend

- Source: [SRC-17](../bre_na_model_base_data.md#src-17), implemented in [bre_na_rate_plan_tracker](../views/bre_na/bre_na_rate_plan_tracker.view.lkml). The supplied `data_sanity.master_pilot_list` is replaced with the existing shared consolidated pilot directory, following this migration's documented convention. The original source query is preserved in the specification.
- Blend: [bre_na_ingestion_rate_comparison](../views/bre_na/bre_na_ingestion_rate_comparison.view.lkml), exposed through its own NA Explore.
- Left side: SRE Ingestion Audit (ED). Right side: SRE Rate Comparison Tracker.
- Confirmed keys: `pilot_id` and `last_updated_timestamp`, using Date & Time equality. The tracker timestamp is cast to the same TIMESTAMP(6) representation used by the shared audit source; source millisecond precision is retained.
- No extra equality on analysis_date, period, ingestion_type, or plan number is inferred. The chart groups by the audit analysis date and selected Period. Time Period, Pilot ID, Pilot Name, and File Type filter the audit input.
- Without a selected plan, unmatched audit rows remain and RC measures are NULL. A Rate Plan selection filters `current_plan_number` on the joined result, so unmatched audit rows are excluded. The other governance and queue tiles do not listen to Rate Plan ID.
- Repeated source matches are retained. This implementation does not silently deduplicate, preaggregate, or rebalance the confirmed join; source blend input-grain and result parity still need review.
- Bounded warehouse check for PSEG (`10037`), analysis dates September 26–October 2, 2026: 22 audit rows and 22 tracker rows exist, but there are **zero exact timestamp matches**. Audit update times and tracker update times differ. Blank RC series for that range are therefore expected with the confirmed join, rather than converted to zeros or matched by day.

## Gauge display

The user authorized a consistent design on 2026-10-03: maximum means full gauge, with the numeric value always visible. Both Ingestion gauges use the native Looker column visualization with a `solidgauge` JSON override, one constant category, and the existing measure. This adds no metric aggregation change and requires no Marketplace visualization installation.

Users (M) uses an explicit 0–20 M display scale; it is not a target or completion percentage. The default PSEG result for September 26–October 2, 2026 was 15.4 M (Starburst query `20261003_152712_65246_mktfe`), which informed this range. Longer periods or other pilots can exceed the scale. Success uses a fixed 0–100% scale. Center labels retain the actual value even when it exceeds the scale. Zero produces an empty arc and a visible zero. The design introduces no target or warning thresholds. Counts are blue and success is green.

Implementation references: [Looker solid gauges](https://docs.cloud.google.com/looker/docs/solid-gauge), [dashboard override parameter](https://docs.cloud.google.com/looker/docs/reference/param-lookml-dashboard-column-chart#advanced_vis_config). Solid-gauge support is available from Looker 24.8; authoring overrides requires `can_override_vis_config`. Eight standalone Highcharts 11.4.8 rendering cases passed in headless Chrome: partial, zero, maximum, and above-maximum values, including both scales. See the [gauge preview](bre_na_ingestion_gauge_preview.png). Actual target-instance rendering is still an acceptance check. Automatic maximum was rejected after the standalone solid-gauge preview failed to derive a valid range; explicit bounds are used.

## Information still needed

1. **Rate Comparison parity:** SRC-17 SQL and the exact timestamp join are now supplied. The draft retains source rows and join multiplicity. Compare against the original blend input grouping and extraction restrictions; these can change sums if a key matches multiple source rows. The Rate Plan control currently filters the joined tracker field after the left join; confirm this against the original report during result review.
2. **Gauge rendering acceptance:** The user authorized the new gauge design. Both Ingestion gauges are implemented; visual acceptance in the target Looker instance remains pending, rather than requiring the old Data Studio gauge settings.
3. **Queue aggregations:** NA-1B-T03 does not specify how success_rate is aggregated across queue/hour rows. The draft uses an unweighted average of the supplied rounded percentages, not a ratio of aggregate received/deleted counts. SUM is provisionally used for message-volume series and AVG for backlog trends where the chart aggregation was omitted.
4. **Aliases/date mapping:** SRC-01 outputs `avg_queue_backlog` and `ingestion_hour_str`; it does not output the `average_queue_backlog` or `analysis_date` aliases written for NA-1B-T04. The draft maps these to the actual backlog field and the derived hour bucket date.
5. **Extract parity:** Audit and failure extract settings were not captured. The draft reuses existing BRE upstream query definitions with NA routing. Confirm that the NA extracts do not add filtering, deduplication, or stale snapshots beyond those upstream definitions.
6. **Filter applicability:** The outline says all governance controls apply to all tiles, but some sources lack those fields. Confirm the effective behavior in Data Studio, including date-dependent pilot suggestions. Rate Plan ID affects only the blended statistics tile. No joins are added to the other sources to imitate unsupported filters.
7. **Reference results and visual review:** The original dashboard has no captured reference outputs or screenshots. The new gauge design is authorized. Looker validation and comparison to the original dashboard are still required before acceptance.

## Validation

Validation on 2026-10-03 (rerun after splitting 1a and 1b): all 37 local query variants, ten semantic fixtures, and ten CA/EU source-route regressions passed. The original seven source queries and unchanged 15 tile queries retain their prior Starburst planning checks. The two new source queries and replacement statistics tile passed fresh Starburst planning checks for all three Period values. Both gauge tile queries passed fresh planning checks after adding their constant category dimension. Two gauge configurations also pass local structural checks. See [validation evidence](bre_na_ingestion_validation.json). This is SQL planning, not result-parity validation.

Run:

```sh
uv run scripts/validate_bre_na_ingestion.py --output-dir /private/tmp/bre-na-ingestion-validation
```

The script checks includes, inherited fields, dashboard wiring, layout, catalog isolation, source routing, Trino syntax, and semantic fixtures. It exports 37 tile query variants and nine source planning queries. The fixture renderer is not the Looker SQL compiler. Starburst `EXPLAIN (TYPE VALIDATE)` checks the exported SQL against NA metadata without executing the analytical queries.

The legacy `validate_bre_ingestion_dashboard.py` stops at its CA/EU equality assertion. The referenced CA/EU dashboard files are unchanged by this work; the failure is in the pre-existing expectation. The NA validator independently checks that all ten CA/EU source-route combinations remain identical to HEAD.

No connected Looker tool provides `validate_project`, query execution, or LookML data tests in this session. Native LookML validation, rendered dashboard inspection, and original-report result parity remain pending. Do not treat local parsing or Starburst SQL planning as those checks.
