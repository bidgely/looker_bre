# NA Aggregation implementation review

Status: all eight tiles implemented as a draft, 2026-10-03. Source: user-supplied [SRC-29](bre_na_model_base_data.md#src-29). Native Looker validation and original-report comparison remain pending.

Dashboard: [`bre_na::bre_na_aggregation`](../dashboards/bre_na_aggregation.dashboard.lookml), covering all eight tiles in section 2.a. The [source view](../views/bre_na/bre_na_aggregation.view.lkml) uses the existing `bre_na` model and `starburst_prod_na` connection. Frontend integration is a later step.

## Source discovery

The user supplied SRC-29 (`SRE Aggregation Stats`, `ds486`) SQL selecting raw rows from `delta_prodna.reporting.sre_raw_data_analysis`, inner joined to the pilot directory. The implementation reuses `bre_pilots` for the same parenthesis-based name formatting and exposes the source's combined `pilot_id_name`. No deduplication, extra T+7 predicate, or fixed history restriction is added. Dashboard pilot, duration, and reporting-date filters are pushed into the query-time derived table. There are no PDTs.

The user confirmed the report calculated field `sucess_perc = 100*(total_datapoints/total_expected_datapoints)`. The LookML field is spelled `success_perc`. It uses floating-point arithmetic to retain fractional percentages and returns NULL for a zero denominator. Charts use the unweighted average of source-row percentages, not a ratio of summed counts. Zero-denominator NULL handling is an implementation safeguard; original-report edge-case parity remains to be checked.

The source query itself does not constrain T+7. A bounded PSEG check for reporting dates 2026-09-26 through 2026-10-02 found seven rows, each with a seven-day analysis-to-reporting lag. This sample does not establish a universal source constraint. Extract refresh schedules and any additional Looker Studio extract restrictions remain undocumented.

Read-only metadata checks:

- Candidate-column discovery: Starburst query `20261003_165946_76555_msuxa`.
- Candidate schema: `SHOW COLUMNS FROM delta_prodna.reporting.sre_raw_data_analysis`, query `20261003_170019_54153_pi2vm`.

## Tile mapping and layout

Layout uses the existing 24-column dashboard grid. Metric aggregations below preserve the supplied specification and confirmed formulas; result comparison against the source report is pending.

| Tile | Display and metric | Layout (row, column, width, height) |
| --- | --- | --- |
| NA-2-T01 | Active Users out of Total; reuse the existing NA active-user tile and latest-snapshot behavior | 0, 0, 24, 3 |
| NA-2-T02 | Raw Datapoints Per Day — Average: AVG(total_datapoints), compared with the preceding equal-length reporting-date range | 3, 0, 6, 4 |
| NA-2-T03 | Raw Datapoints Per Day — Median: exact median(total_datapoints), same comparison range | 3, 6, 6, 4 |
| NA-2-T04 | Meters/Day: AVG(total_meters), semicircular gauge with the actual numeric value always visible | 3, 12, 6, 4 |
| NA-2-T05 | Availability: AVG(success_perc), semicircular 0–100% gauge; user-confirmed actual / expected × 100 formula | 3, 18, 6, 4 |
| NA-2-T06 | Raw Data Statistics: SUM(total_expected_datapoints) and SUM(total_datapoints) as bars; AVG(success_perc), documented Unique Users series, and SUM(total_meters) as lines | 7, 0, 24, 8 |
| NA-2-T07 | User Quality: SUM of negative_consumption_users, total_negative_consumption_users, zero_consumption_users, total_zero_consumption_users, missing_datapoint_users | 15, 0, 24, 8 |
| NA-2-T08 | Meter Quality: SUM of negative_consumption_meters, total_negative_consumption_meters, zero_consumption_meters, total_zero_consumption_meters, missing_datapoint_meters | 23, 0, 24, 8 |

NA-2-T06 calls `SUM(total_negative_consumption_datapoints)` “Unique Users #”. This counts negative datapoints according to the field name, whereas the candidate table also has `total_users`. The user explicitly confirmed this mapping; it is preserved as documented.

For gauges, retain the authorized behavior from Ingestion: zero is an empty arc; the configured maximum fills the arc; values above the maximum keep the actual numeric label. The meters display range is 0–1,500,000, based on the default PSEG sample averaging 1,020,963.43 meters (query `20261003_171517_18532_mwky8`). It is a display range, not an operational target.

## Controls

| Control | Intended behavior |
| --- | --- |
| Time Period | Default to the last seven completed days, consistent with NA Ingestion. Apply to reporting_date for all eight tiles. Comparison tiles must retain the preceding equal-length range as well. |
| Period | Daily / Weekly / Monthly, default Daily. Group analysis_date on the three trend tiles; Sunday week start follows the documented WEEK formula. Does not change the source-row aggregations in summary tiles. |
| Pilot ID | Default 10037; use existing NA pilot suggestions. Apply to all tiles. |
| Pilot Name | Default PSEG; use existing NA pilot suggestions. Apply to all tiles using the source pilot-name mapping. |
| File Granularity | Source duration, initially unrestricted. Applies to the seven Aggregation source tiles. Active Users has no duration field, so this control cannot affect it without an additional, justified source relationship. |

The source document's Time Period scope mentions “1b”; this is treated as a copy error in the Aggregation section. The specification explicitly uses reporting_date for these tiles, while trend grouping uses analysis_date. These dates must remain distinct.

## Validation

- [Local validator](../scripts/validate_bre_na_aggregation.py): eight tiles, thirteen rendered query variants, thirteen semantic fixtures, field/listen wiring, nonoverlapping layout, and gauge configuration checks pass. Fixtures cover exact median, missing and zero prior values, row-average percentages, percentage precision, Sunday/month grouping, and the confirmed Unique Users mapping.
- All thirteen exported query variants pass Starburst `EXPLAIN (TYPE VALIDATE)`, covering all seven new source tiles and Daily/Weekly/Monthly trend grouping. The reused Active Users tile retains the already-validated Ingestion query configuration.
- Four bounded tile queries ran for PSEG, reporting dates 2026-09-26 through 2026-10-02: average raw datapoints 98,008,762; median 98,018,202; average meters 1,020,963.43; average availability 99.99619715887476%. The average and median queries include prior-period comparisons.
- Existing Ingestion validation passes: 18 tiles, 37 query variants, ten semantic fixtures, and ten CA/EU source-route regressions.
- Eight standalone Highcharts gauge rendering cases pass: zero, partial, maximum, and above maximum, with actual numeric labels retained. [Gauge preview](bre_na_aggregation_gauge_preview.png) was visually inspected. This verifies the chart configuration outside Looker, not the target Looker UI.
- [Validation evidence](bre_na_aggregation_validation.json) records query IDs and results.

Run `uv run scripts/validate_bre_na_aggregation.py` to regenerate the local checks and planning SQL. The local renderer is a focused simulator, not Looker's SQL compiler.

## Remaining acceptance checks

Native LookML validation and actual dashboard rendering require the Looker connection, which is unavailable in this session. Compare original-report results and extract settings, including blank/zero cases. BRE portal integration remains a later step.
