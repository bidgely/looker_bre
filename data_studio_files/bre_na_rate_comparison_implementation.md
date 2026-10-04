# NA Rate Comparison implementation review

Status: all eight tiles implemented as a draft, 2026-10-04. Native Looker validation and original-report result comparison remain pending.

- [Dashboard](../dashboards/bre_na_rate_comparison.dashboard.lookml): `bre_na::bre_na_rate_comparison`.
- [KPI 1 view](../views/bre_na/bre_na_rate_comparison.view.lkml), [KPI 2 view](../views/bre_na/bre_na_rate_comparison_triggers.view.lkml), and [shared fields](../views/bre_na/bre_na_rate_comparison_fields.view.lkml).
- Sources: [SRC-28](bre_na_model_base_data.md#src-28), SRE RC Email Anomaly KPI 1; [SRC-21](bre_na_model_base_data.md#src-21), SRE RC Email Anomaly KPI 2; existing Active Users source.
- Included in `bre_na`, using `starburst_prod_na` and `delta_prodna`. Portal integration remains a later step.

## Source semantics

SRC-28 groups notifications by pilot, analysis date, reporting date, email type, and promotion flag, then joins the formatted pilot directory. Source counts, anomaly predicates, spelling (`anomally`), decimal arithmetic, three-place rounding expression, and join multiplicity are retained. Accuracy and deviation are source fractions; the dashboard averages each source-row fraction and multiplies by 100. It does not recompute a weighted ratio from total counts.

The sole calculation safeguard is `NULLIF(total_invoices, 0)` in the deviation denominator. A group containing only NULL notification IDs has zero counted invoices, so both percentages return NULL rather than failing the query. Original-report zero-denominator behavior still needs comparison. The anomaly's `< 3 days` test and low-load-shift `< 20` test remain inside the supplied source calculations; no extra chart predicates are inferred from titles.

SRC-21 retains the reporting-date map LEFT JOIN to notifications on pilot, notification type, and analysis date, followed by the pilot-directory join. Counts retain the supplied concatenated user/billing-date expression. A map row without a matching notification yields zero counts and zero coalesced latencies. Each chart latency is an unweighted average of source-row averages, including those source zero values. Reporting dates come from the map. Filters apply after source aggregation; both sources remain query-time derived tables without persistence.

Explicit pilot ID and formatted pilot name projections support the dashboard controls without changing grouping. Query-local row numbers preserve every source output row and provide primary keys. There are no cross-source joins in this dashboard.

## Tile mapping

| Tile | Implementation |
| --- | --- |
| NA-5A-T01 | Existing Active Users out of Total; latest snapshot per pilot before reporting-date filtering. |
| NA-5A-T02 | Source-row AVG(rc_missing_anomaly), with relative change versus the immediately preceding equal-length analysis-date range. |
| NA-5A-T03 | Exact median(rc_missing_anomaly), with the same comparison. Even row counts average the middle pair; NULLs are omitted. |
| NA-5A-T04 | AVG(accuracy_perc) × 100; green 0–100% gauge. |
| NA-5A-T05 | AVG(deviation_perc) × 100; red 0–100% gauge. |
| NA-5A-T06 | Favourable and anomaly count sums as grouped bars; average accuracy percentage as a line on a separate axis, grouped by Period. |
| NA-5A-T07 | Invoice, missing TOU, and missing RC count sums as bars by pilot_id_name; source-row average invoice-to-TOU and TOU-to-RC delays as lines on a separate hours axis. |
| NA-5A-T08 | Sums of out-of-order RC, early RC, missing load shift, and low load-shift counts as four grouped bar series by Period. No line metric was listed in the specification. |

Gauges display the actual number, show an empty arc at zero, and fill completely at or above 100%. Missing values remain missing. Previous-period relative changes return NULL when the previous value is zero or absent. Open-ended comparison ranges do not invent a prior interval.

## Controls

| Control | Default and scope |
| --- | --- |
| Time Period | Last seven completed days. Analysis date for T02–T06 and T08; reporting date for T01 and T07. |
| Period | Daily; Sunday-start Weekly or first-of-month Monthly. Changes T06 and T08 grouping. |
| Pilot ID | 10037; every tile. |
| Pilot Name | PSEG; every tile. |
| Email Type (Exclude) | Blank means no exclusion. Select values to remove from both anomaly sources, including prior-period rows. |
| Promotion (Exclude) | Blank means no exclusion. Select Absent and/or Present to remove from both anomaly sources. |

Exclusions use separate filter-only fields with positive selections interpreted as values to remove. NULL email types remain unless the exclusion condition explicitly matches NULL. The source promotion CASE treats NULL load-shift values as Present, exactly as supplied. Active Users has no email or promotion field, so these exclusions do not apply to T01. No artificial join is added to make unrelated controls affect it.

The “DESC-RESI only” titles are preserved. Neither source query supplies a fixed DESC restriction, so none is added. PSEG remains the documented default. The section's Time Period reference to “3b” is treated as a copied scope label.

## Validation and data availability

- [Local validator](../scripts/validate_bre_na_rate_comparison.py): eight tiles, thirteen rendered SQL variants, twenty-four semantic fixtures, and two source-contract checks pass. It verifies field references, layout, controls, gauges, comparisons, exact medians, source anomaly boundaries, zero denominators, LEFT JOIN zero rows, source-row latency averaging, exclusions, and date-field selection.
- All thirteen exports pass Starburst `EXPLAIN (TYPE VALIDATE)`: default tiles, Weekly/Monthly variants, and populated exclusions for each source. The reused Active Users configuration matches its existing validated tile.
- Five bounded historical queries ran for pilot 10078, DESC South Carolina Residential, August 16–22, 2026. Average missing load-shift count: 0.15789473684210525; median: 0; accuracy: 69.579%; deviation: 30.421%. Both previous-period statistics were zero, so relative changes were NULL. The trigger tile, using reporting dates, returned 14,687 records, 1 missing TOU, 6 missing RC, and source-row average delays of 207.9 and 6.0 hours.
- The underlying notification source's latest analysis date was **August 22, 2026**, and latest reporting date was **August 23, 2026**, when checked on October 4. There were no notification rows for September 27–October 3. The recent historical sample contained only pilot 10078. Empty recent anomaly results are therefore expected; default PSEG and dates have not been changed to conceal this.
- Eight standalone Highcharts gauge cases pass, and the [preview](bre_na_rate_comparison_gauge_preview.png) was visually inspected. This validates chart configuration, not the Looker UI.
- Ingestion, Aggregation, Disaggregation, and TOU local regressions pass, including ten CA/EU source-route checks. `git diff --check` passes.
- [Validation evidence](bre_na_rate_comparison_validation.json) includes query IDs, historical results, freshness checks, and gauge results.

Run `uv run scripts/validate_bre_na_rate_comparison.py` to regenerate local checks and SQL exports. The renderer is a focused local simulator, not Looker's compiler.

## Remaining acceptance checks

A connected Looker instance is required for native validation and target dashboard rendering; none is available in this session. Compare original-report results and exclusion behavior, confirm any undocumented pilot restrictions, and verify source freshness before final acceptance. Gauge overrides use the existing NA Highcharts configuration and require the same Looker chart-configuration support.
