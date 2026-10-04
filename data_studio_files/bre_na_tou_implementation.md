# NA TOU implementation review

Status: all six tiles implemented as a draft, 2026-10-03. Native Looker validation and original-report result comparison remain pending.

- [Dashboard](../dashboards/bre_na_tou.dashboard.lookml): `bre_na::bre_na_tou`.
- [Source view](../views/bre_na/bre_na_tou.view.lkml) and [fields](../views/bre_na/bre_na_tou_fields.view.lkml).
- [Source specification](bre_na_model_base_data.md#src-35): SRC-35, SRE TOU Appliance Batch Aggregation (`ds367`).
- Uses the existing `bre_na` model, `starburst_prod_na` connection, and `delta_prodna` catalog. BRE portal integration remains a later step.

## Source and calculations

The supplied SQL selects TOU batch rows and inner joins the formatted pilot directory. Its row grain, source calculations, and join are preserved; no latest-row selection or pilot allow-list is added. The repeated `trigger_name` and `last_updated_timestamp` projections are each emitted once, avoiding duplicate column names without changing row values.

The user confirmed these report calculations:

```text
tou_success_pct = successful_tou_eligible_invoices / total_tou_eligible_invoices
tou_failure_pct = 1 - tou_success_pct
```

These are fractions on a 0–1 scale. The chart measures average row-level fractions and multiply by 100 for percentage-point display. They do not use a ratio of summed counts or the SQL's alternative-denominator percentage columns. A fixture where the SQL success percentage is 100 but the report fraction is 0.5 verifies that the dashboard displays 50%.

Floating-point division preserves fractional precision. A zero eligible denominator returns NULL, and failure remains NULL for that row. This is an implementation safeguard; the source report's zero-denominator display behavior is not documented. NULLs are omitted from averages; values are not capped at 100 or forced to zero.

The derived table runs at query time, with pilot, TOU mode, delay, and date predicates applied to the supplied source output. Comparison queries retain the preceding equal-length analysis-date range. No PDT is introduced.

## Tile mapping

| Tile | Implementation |
| --- | --- |
| NA-4A-T01 | Reused NA Active Users out of Total; latest snapshot per pilot before reporting-date filtering. |
| NA-4A-T02 | Source-row AVG(successful_tou_eligible_invoices), compared with the preceding equal-length analysis-date range. |
| NA-4A-T03 | Exact median(successful_tou_eligible_invoices), with the same comparison range. |
| NA-4A-T04 | AVG of the confirmed success fraction, displayed as a percentage; green gauge. |
| NA-4A-T05 | AVG of the confirmed failure fraction, displayed as a percentage; red gauge. |
| NA-4A-T06 | SUM total_tou_eligible_invoices, total_disagg_tou_invoices, actual_total_tou_invoices, and successful_tou_eligible_invoices as grouped bars; average report success percentage as a line on a separate axis. |

Both gauges use a 0–100% semicircular arc with a visible numeric value. Zero leaves an empty arc; at or above maximum the arc is full while the actual number remains visible. Source missing values remain missing. Titles and series labels preserve the specification, including the pipeline chart's stated pilot availability; no additional fixed pilot restriction was supplied.

## Controls

| Control | Default and scope |
| --- | --- |
| Time Period | Last seven completed days. analysis_date for TOU metrics; reporting_date for Active Users. |
| Period | Daily; Weekly uses Sunday starts and Monthly uses the first of the month. Changes the pipeline chart's analysis-date grouping. |
| Pilot ID | 10037; applies to every tile. |
| Pilot Name | PSEG; applies to every tile. |
| TOU Mode | COMPLETE_BILLING_CYCLE; applies to the five TOU source tiles. |
| Delay (Days) | 1; applies to the five TOU source tiles. |

Mode and delay are editable selections, not fixed source restrictions. Active Users lacks these fields and is not artificially joined to TOU rows. The source document's Time Period scope referring to “3b” is interpreted as a copy error in section 4.

## Validation

- [Local validator](../scripts/validate_bre_na_tou.py): six tiles, seven rendered query variants, and seventeen semantic fixtures pass. Checks include source references, filters, layout, exact median and comparisons, zero/NULL behavior, percentage precision, report-versus-SQL formula selection, mode/delay/pilot isolation, and Sunday/month grouping.
- All seven exported queries pass Starburst `EXPLAIN (TYPE VALIDATE)`, including Daily/Weekly/Monthly pipeline variants. The reused Active Users query configuration matches the existing validated tile.
- Four bounded queries ran for PSEG, analysis dates 2026-09-26 through 2026-10-02, COMPLETE_BILLING_CYCLE, delay 1: average successful invoices 5,725.21, median 8, success 49.48453078558372%, failure 50.51546921441627%. Comparison queries also returned prior-period values.
- Eight standalone Highcharts gauge cases pass. [Gauge preview](bre_na_tou_gauge_preview.png) was visually inspected for colors, numeric labels, and arc behavior. This is not target Looker rendering.
- Existing Ingestion, Aggregation, and Disaggregation validators pass after the model additions, including ten CA/EU source-route regressions. Their existing definitions are unchanged by this step.
- [Validation evidence](bre_na_tou_validation.json) records query IDs and sample results.

Run `uv run scripts/validate_bre_na_tou.py` to regenerate local checks and planning SQL. The local renderer is a focused simulator, not Looker's compiler.

## Remaining acceptance checks

Native LookML validation and target dashboard rendering need a Looker connection, which is unavailable in this session. Compare the original report's results, empty selections, zero denominators, and any undocumented source/chart restrictions before final acceptance.
