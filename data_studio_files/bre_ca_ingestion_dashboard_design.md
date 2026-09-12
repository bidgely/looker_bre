# CA Ingestion dashboard design and implementation

Status: implemented in `dashboards/bre_ca_ingestion.dashboard.lookml`; local validation passes. Native LookML validation and visual review of this new dashboard remain with the user in the Looker web UI.

## Scope and evidence

Build CA Ingestion first, followed by CA Disagg, Email, HER and NBI. EU Ingestion, Disagg and Email follow the agreed CA designs with regional differences.

The [CA structure export](bre_dashboard_structure_ca.txt) supplies seven tile titles and five controls. It does not supply chart types, selected fields, calculated fields, aggregations, chart-level filters, date bindings or layout. The user has now clarified that Active UUID and Total UUID appear together in one tile, using source pilot_name, active_uuid and total_uuid with only the source query's latest reporting_date selection per pilot. The user also confirmed that Files Per Day contains Average and Median of total_files_processed, both from Ingestion Audit, filtered on analysis_date and compared with the immediately preceding equal-length date range. The sections below record the subsequent tile-by-tile user decisions. No source data was queried.

All tiles use model `bre_ca`, Explore `bre_dashboard`. Four existing source families serve the tiles. Shared fields implement the additional metrics. Two hidden helper Explores supply pilot and ingestion-type suggestions; they are not separate tile Explores. No PDT is used. All field names below are relative to `bre_dashboard.`.

## Confirmed tile mapping

| Tile | Saved source_family | Presentation and fields | Decision still needed |
|---|---|---|---|
| Active UUID out of Total UUID | `activeusers` | One combined tile: `Active UUID: <active> out of Total UUID: <total>`; `active_users_active_uuid_sum` and `active_users_total_uuid_sum`; comma-separated integers; source pilot name is `source_pilot_name`; latest reporting_date snapshot per pilot | Confirmed: no additional date filter; no Time Period, Period or File Type listener |
| # of Files Per Day | `ingestionaudit` | Average and Median of `total_files_processed`, filtered on `analysis_date`; each compares with the immediately preceding equal-length date range | Confirmed default: last 7 completed days; comparison display formatting remains to settle |
| Daily Average — Users (M)/day | `postingestion` | Average of the confirmed CASE calculation using NULLIF bucket sums divided by 1,000,000; analysis_date filter; no comparison | Metric, aggregation and comparison behavior confirmed |
| Daily Average — Success % | `ingestionaudit` | Average of source success_percentage; analysis_date filter; no comparison | Metric, aggregation and comparison behavior confirmed |
| Daily Ingestion Statistics | `ingestionaudit` | Combo chart: stacked bars for SUM(files), SUM(chunks), SUM(records); line for AVG(success_percentage); analysis_date filter and Daily/Weekly/Monthly date axis | Source, metrics, aggregations and period grouping confirmed |
| Daily Post-Ingestion Data Quality Report (Only for Elec/Gas AMI) | `postingestion` | Line chart with ten summed series: raw/invoice calculated totals and eight delay buckets; analysis_date filter and Daily/Weekly/Monthly date axis | Confirmed: all series are lines; no additional chart-level filters |
| Daily Top Ingestion Failure Reasons | `ingestionfailures` | Stacked columns of AVG(failure_percentage), broken down by application_error_code; analysis_date filter and Daily/Weekly/Monthly date axis | Confirmed: source_rank <= 20 before chart aggregation |

Confirmed audit measures for the Daily Ingestion Statistics combo chart:

- `ingestion_audit_total_files_processed_sum`
- `ingestion_audit_total_chunks_processed_sum`
- `ingestion_audit_total_records_count_sum`
- `ingestion_audit_success_percentage_average`

The confirmed percentage measure averages supplied source percentages without weighting. It is not a ratio of summed record counts.

For post-ingestion quality, the user confirmed sums of the eight delay buckets and two calculated totals, as detailed below. Delay-band user counts can count the same user on successive days; preserve the requested sums rather than interpreting them as distinct users over the period. Overlapping billing-cycle count is not one of the ten selected metrics.

For ingestion failures, `source_rank` was calculated within each original analysis date, pilot and ingestion type. The query does not restrict it to three. `failure_scope` controls Processing Failures only and must not be used to implement this tile's top-N rule. The repeated `ingestion_failures_total_failed_record_count` denominator must not be summed across error codes.

## Confirmed first tile: Active UUID out of Total UUID

User-supplied display example: `Active UUID: 1,210,693 out of Total UUID: 2,770,421`. These are formatting examples, not verified current values and not constants to put in the dashboard.

| Original source field | Explore field | Use |
|---|---|---|
| `active_uuid` | `active_users_active_uuid_sum` | Active count; do not substitute total_active_uuid |
| `total_uuid` | `active_users_total_uuid_sum` | Total count |
| `pilot_name` from the active-user source | `source_pilot_name` | Preserve the source name; common pilot_name comes from the replacement pilot directory and may be cleaned differently |
| `reporting_date` | `reporting_date` | Source query selects latest row per pilot; no additional tile date filter |

Use the existing numeric measures, summing the selected pilot snapshots when more than one pilot is selected. The precise pilot-name grouping/display and empty-result presentation can be matched when the tile is authored. No new metric or derived table is required for the confirmed fields.

The user clarified that reporting_date filtering means the source query's latest-row selection only. Preserve the latest reporting_date row per pilot, with no extra tile-level or dashboard-range date filter. Pilot filtering applies; dashboard Time Period, Daily/Weekly Period and File Type do not affect this tile.

## Confirmed second tile: # of Files Per Day

- Model: `bre_ca`; Explore: `bre_dashboard`; saved `source_family`: `ingestionaudit`.
- Source: SRE Ingestion Audit, backed by `reporting.sre_ingestion_audit`.
- Source metric: `total_files_processed`, exposed as `ingestion_audit_total_files_processed`.
- Two displayed statistics: **Average** and **Median** of that field over the filtered source rows. The user confirmed Median, correcting the earlier wording "mean".
- Date filter: `analysis_date` for both statistics.
- Comparison: recalculate each statistic over the immediately preceding date range with the same number of days. For example, September 8–14 compares with September 1–7. Preserve the same pilot and file-type selections for both ranges.

Implement the confirmed field aggregations directly; no preliminary summing by day or missing-day zero-filling has been requested. Source rows vary by pilot, date and ingestion type, so these are not automatically averages or medians of daily totals across all pilots.

The new shared selected/previous Average and Median measures implement both statistics and their comparisons. The filter-only date range keeps both periods available to the query. No PDT is used. The default is the last 7 completed days, compared with the preceding 7 completed days. File statistics display two decimal places and the comparison displays percentage change with one decimal place.

## Confirmed third tile: Daily Average

This section contains two separate subtiles in the same dashboard group. Each uses the existing bre_ca / bre_dashboard Explore with its own source-family selection; no join between the families is needed.

### Users (M)/day

- Original source: SRE Post Ingestion Data Quality, Amazon Redshift connector.
- Source family: `postingestion`.
- Date filter: `analysis_date`.
- Display metric: `total_users_across_age_buckets`, using this user-supplied Data Studio expression:

```text
CASE
  WHEN ingestion_type = "CONSUMPTION" THEN avg_users_receiving_raw_per_day/1000000
  WHEN ingestion_type = "BILLING" THEN avg_users_receiving_invoice_per_day/1000000
END
```

The user supplied the two underlying calculated-field definitions:

```text
avg_users_receiving_invoice_per_day =
  NULLIF(user_invoice_with_delay_0_7, 0)
  + NULLIF(user_invoice_with_delay_7_15, 0)
  + NULLIF(user_invoice_with_delay_15_30, 0)
  + NULLIF(user_invoice_with_delay_gt_30, 0)

avg_users_receiving_raw_per_day =
  NULLIF(user_raw_with_delay_0_3, 0)
  + NULLIF(user_raw_with_delay_4_7, 0)
  + NULLIF(user_raw_with_delay_8_15, 0)
  + NULLIF(user_raw_with_delay_gt_15, 0)
```

These are row-level bucket sums despite the avg/per_day names: neither formula contains AVG or a day denominator. The user confirmed that the final chart aggregation is Average of total_users_across_age_buckets. Apply the CASE and division by 1,000,000 per source row, then take the unweighted average over the filtered rows. Do not add a day denominator or first sum across pilots or dates.

Preserve NULLIF exactly. If any of the four relevant buckets is zero or NULL, its NULL propagates through the entire addition and the resulting row value is NULL. Do not change this to COALESCE or zero-filled arithmetic. The confirmed Average aggregation omits those NULL rows; if no non-NULL rows remain, the result is NULL rather than zero.

The user explicitly approved extending the original BILLING branch to include OPOWER, so both use the invoice-bucket calculation. CONSUMPTION uses the raw-bucket calculation; USER_META and other types still return NULL. This is an approved change to the original Data Studio expression, consistent with grouping OPOWER under Billing in the dashboard filter. Preserve both row-level NULLIF calculations and the final unweighted Average, with no zero fallback or previous-period comparison. The division expresses the result in millions; use single-quoted string literals and decimal division in Trino to avoid integer truncation.

The approved calculation to implement, using the shared row-level bucket fields, is:

```sql
CASE
  WHEN ingestion_type = 'CONSUMPTION'
    THEN avg_users_receiving_raw_per_day / 1000000.0
  WHEN ingestion_type IN ('BILLING', 'OPOWER')
    THEN avg_users_receiving_invoice_per_day / 1000000.0
END
```

### Success %

- Original source: SRE Ingestion Audit, Apps Script connector.
- Source family: `ingestionaudit`.
- Date filter: `analysis_date`.
- Source metric: `success_percentage`, exposed as `ingestion_audit_success_percentage`.
- Confirmed aggregation: Average. Use `ingestion_audit_success_percentage_average`, the unweighted average of source percentages. Preserve the source percentage scale; do not replace this with a ratio of total records.

Confirmed: neither Daily Average subtile has a previous-period comparison.

## Confirmed fourth tile: Daily Ingestion Statistics

- Original source: SRE Ingestion Audit, Apps Script add-on connector, backed by `reporting.sre_ingestion_audit`.
- Model: `bre_ca`; Explore: `bre_dashboard`; saved `source_family`: `ingestionaudit`.
- Visualization: combo chart with three stacked bar series and one line series.
- Date filter: original `analysis_date`, applied before grouping.
- X-axis: analysis_date grouped by the selected Period using the user-supplied formula below: Daily, Sunday-start Weekly, or Monthly.

| Display series | Source field | Aggregation | Existing Explore measure | Rendering |
|---|---|---|---|---|
| Files # | `total_files_processed` | Sum | `ingestion_audit_total_files_processed_sum` | Stacked bar |
| Chunks # | `total_chunks_processed` | Sum | `ingestion_audit_total_chunks_processed_sum` | Stacked bar |
| Records # | `total_records_count` | Sum | `ingestion_audit_total_records_count_sum` | Stacked bar |
| Success % | `success_percentage` | Average | `ingestion_audit_success_percentage_average` | Line |

For each date bucket, sum each count and take the unweighted average of success_percentage across the filtered source rows. Weekly and Monthly therefore show period totals for the counts, not daily averages. Do not first average daily percentages or replace the percentage with a ratio of summed records. Partial weeks/months contain only the dates included in the analysis_date filter.

All four measures already exist. Use a count axis for the bars and a separate percentage axis for the line, preserving the source percentage scale. The stack reproduces the original presentation of three different counts; its combined height is not an additional business metric. Sort the date axis chronologically. The shared date grouping needs the Sunday-start correction described below; no new source family, Explore or PDT is required.

## Confirmed fifth tile: Daily Post-Ingestion Data Quality Report (Only for Elec/Gas AMI)

- Original source: SRE Post Ingestion Data Quality, Redshift connector.
- Model: `bre_ca`; Explore: `bre_dashboard`; saved `source_family`: `postingestion`.
- Date filter: `analysis_date`, applied before grouping.
- X-axis: analysis_date grouped by Daily, Sunday-start Weekly or Monthly, using the same Period formula as Daily Ingestion Statistics.
- All ten metrics use **Sum** across the filtered source rows within each date bucket.

| Display series | Source field/calculation | Shared field coverage |
|---|---|---|
| Total Users Receiving Raw Data | `avg_users_receiving_raw_per_day` | Add SUM of the shared row-level raw NULLIF bucket calculation |
| Users' Raw Data Age Btw 0 to 3 days | `user_raw_with_delay_0_3` | `post_ingestion_user_raw_with_delay_0_3_sum` |
| Users' Raw Data Age Btw 4 to 7 days | `user_raw_with_delay_4_7` | `post_ingestion_user_raw_with_delay_4_7_sum` |
| Users' Raw Data Age Btw 8 to 15 days | `user_raw_with_delay_8_15` | `post_ingestion_user_raw_with_delay_8_15_sum` |
| Users' Raw Data Age > 15 days | `user_raw_with_delay_gt_15` | `post_ingestion_user_raw_with_delay_gt_15_sum` |
| Total Users Receiving Invoice Data | `avg_users_receiving_invoice_per_day` | Add SUM of the shared row-level invoice NULLIF bucket calculation |
| Users' Invoice Data Age Btw 0 to 7 days | `user_invoice_with_delay_0_7` | `post_ingestion_user_invoice_with_delay_0_7_sum` |
| Users' Invoice Data Age Btw 8 to 15 days | `user_invoice_with_delay_7_15` | `post_ingestion_user_invoice_with_delay_7_15_sum` |
| Users' Invoice Data Age Btw 16 to 30 days | `user_invoice_with_delay_15_30` | `post_ingestion_user_invoice_with_delay_15_30_sum` |
| Users' Invoice Data Age > 30 days | `user_invoice_with_delay_gt_30` | `post_ingestion_user_invoice_with_delay_gt_30_sum` |

Reuse the exact two row-level NULLIF bucket sums supplied for Daily Average above. Their avg/per_day names do not change this tile's confirmed SUM aggregation. Calculate each four-bucket expression per source row, then SUM the result; do not substitute addition of the four separately aggregated bucket measures. Any zero or NULL bucket makes that row's calculated total NULL, and SUM omits that row's total. Consequently, the calculated total can differ from the sum of the displayed bucket series. Preserve this behavior without COALESCE or zero-filling.

These ten series display user counts without division by 1,000,000 or a day denominator. The user repeated the definition of total_users_across_age_buckets, but it is not among this tile's ten selected metrics; retain it for the previously confirmed Users (M)/day subtile, which averages the CASE result. Preserve the supplied invoice labels (8–15 and 16–30) mapped to source fields ending in 7_15 and 15_30; do not rewrite bucket boundaries in source SQL.

The eight bucket SUM measures already exist. The two calculated-total SUM measures can share their row-level calculations with Daily Average. No new source family, Explore or PDT is needed. The user confirmed a line chart for all ten series, with no additional chart-level filters. Do not add meter/fuel restrictions based on the Elec/Gas AMI title. Preserve the existing source logic. The user believes the source tables already provide that scope; this is not an independently verified statement about their contents, and no data check is requested.

## Confirmed sixth tile: Daily Top Ingestion Failure Reasons

- Original source: SRE Ingestion Failure Statistics, Apps Script connector, backed by `reporting.sre_ingestion_errors_statistic`.
- Model: `bre_ca`; Explore: `bre_dashboard`; saved `source_family`: `ingestionfailures`.
- Visualization: stacked columns.
- Date filter: `analysis_date`, applied before chart aggregation while preserving the source window calculation.
- X-axis: analysis_date grouped by Daily, Sunday-start Weekly or Monthly using the same Period formula as the other time-series tiles.
- Breakdown: source application_error_code (shown as `_application_error_code_` in the user's configuration), exposed as `application_error_code`; pivot this dimension into chart series.
- Metric: Average of source `failure_percentage`, using existing `ingestion_failures_failure_percentage_average`.

For each date bucket and error code, take the unweighted average of the filtered source percentages. Do not replace it with a ratio of summed failures, sum the percentages, or normalize the stack to 100%. Preserve the source percentage scale. The required metric and breakdown fields already exist; no new source family, Explore or PDT is needed.

The additional filter named `rank filter` is confirmed as Include `source_rank <= 20`: the user supplied N = 20 in response to the proposed source_rank <= N condition. The source query calculates source_rank with ROW_NUMBER within each analysis_date/pilot_id/ingestion_type, ordered by failure_percentage descending. Apply the filter to these existing daily ranks before chart aggregation, including in Weekly/Monthly mode; do not recompute a period-wide ranking. This retains up to 20 source rows per day/pilot/ingestion type, not necessarily 20 distinct error-code series across the whole selected range. Do not impose an additional global 20-series limit.

## User-supplied Period grouping

```text
CASE
  WHEN Period="Daily" THEN analysis_date
  WHEN Period="Weekly" THEN DATE(DATETIME_TRUNC(analysis_date, WEEK))
  WHEN Period="Monthly" THEN DATE(DATETIME_TRUNC(analysis_date, MONTH))
END
```

This is a date-bucketing calculation: Daily retains the analysis date, Weekly returns the start of its week and Monthly returns the first of its month. It does not itself average counts or divide by days. The user supplied Monthly in addition to the Daily/Weekly options listed in the original structure export.

Looker Studio's WEEK truncation starts on Sunday, per the [official DATETIME_TRUNC documentation](https://cloud.google.com/looker/docs/studio/datetimetrunc). The dashboard uses the new shared ingestion_period_date dimension to match this rule. The existing period_date field, BRE model week settings and legacy HER source aggregation remain Monday-based; they are not used for these Ingestion chart axes.

## Dashboard filter bindings

| Control | Binding | Applies to | Behavior |
|---|---|---|---|
| Time Period | All tiles except UUID use `analysis_date`; UUID tile has no listener | All non-UUID tiles | Confirmed default: last 7 completed days, excluding today |
| Period | Daily/Weekly/Monthly date grouping based on analysis_date | Confirmed for Daily Ingestion Statistics, Daily Post-Ingestion Data Quality and Daily Top Ingestion Failure Reasons x-axes; not the UUID tile | Match Sunday-start WEEK in the supplied formula |
| Pilot ID | `pilot_id` | All tiles | Confirmed: retain as a separate control from Pilot Name |
| Pilot Name | `pilot_name`, using the shared pilot directory consistently across all tile queries | All tiles | Separate control from Pilot ID; raw source_pilot_name remains available as a source field |
| File Type | Shared filter dimension based on `ingestion_type`, grouping OPOWER with BILLING | Audit, post-ingestion and ingestion-failure tiles | Billing includes BILLING and OPOWER; no separate OPOWER option; other values come dynamically from source ingestion types |

UUID counts use only the latest reporting_date selection inside the source query. They do not listen to the dashboard date range, File Type or Period controls.

The user confirmed keeping Pilot ID and Pilot Name as two separate dashboard filters, rather than combining them into a pilot_id_name control. Both apply to every tile, including the UUID snapshot. When both are selected, their conditions apply together. Implementation defaults are no pilot restriction and multiple selection. Pilot Name filters on the canonical shared directory name for every family, including UUID, to avoid applying cleaned suggestions to raw source names. This does not change the original source_pilot_name field or the UUID latest-row selection.

The user corrected the File Type requirement: show Billing as the common option for BILLING and OPOWER, with no separate OPOWER option. Populate all other options from ingestion_type values present in the applicable sources; Billing, Consumption and User_Meta are examples, not an exhaustive allowed-value list. Implement a shared filter dimension that maps OPOWER and BILLING to the same Billing value, presents the known labels consistently and passes through other ingestion types. Keep the raw ingestion_type field for source logic, ranking and the previously supplied metric formulas. Use this mapped filter consistently across the audit, post-ingestion and ingestion-failure tiles. Ensure dynamic suggestions cover the applicable source families rather than only the Explore's default ingestionaudit family; do not query source data during this design stage. Leaving the filter unselected must not add a restriction to the three previously observed types. The user confirmed no additional chart-level meter/fuel filters for Daily Post-Ingestion Data Quality; preserve the existing source logic.

The default date range is the last 7 completed calendar days: from current date minus 7 days inclusive to current date exclusive, using the dashboard/query's effective timezone. Files Per Day compares this with current date minus 14 days inclusive to current date minus 7 days exclusive. This is a calendar-day range, not a rolling 168-hour interval including today. Keep the default relative so it advances each day.

## Implementation and review

All six CA Ingestion tile groups now have confirmed metric definitions. The combined UUID tile and Files Per Day metric/comparison definitions are confirmed. Both Daily Average subtiles are confirmed: Users (M)/day averages the supplied CASE result, and Success % averages the source percentage. Both filter on analysis_date and have no previous-period comparison. Daily Ingestion Statistics is confirmed as a combo chart with three summed count series in stacked bars and an average Success % line, filtered on analysis_date and grouped by Daily/Weekly/Monthly. Daily Post-Ingestion Data Quality is confirmed as ten summed line series with the same date filtering/grouping and no additional chart-level filters. Daily Top Ingestion Failure Reasons uses stacked columns, application_error_code breakdown, average failure_percentage, analysis_date filtering/Period grouping and source_rank <= 20. The implemented presentation defaults are recorded below.

The default date range is last 7 completed days. Billing includes OPOWER in both the filter and Users (M)/day invoice calculation; other filter choices are dynamic. Pilot ID and Pilot Name remain separate. Period defaults to Daily, with Sunday-start Weekly and first-of-month Monthly. Pilot and File Type controls default to no restriction and support multiple selection.

Implementation files:

- [CA dashboard](../dashboards/bre_ca_ingestion.dashboard.lookml): eight query tiles arranged as six agreed tile groups; five dashboard controls; explicitly included only by bre_ca.
- [Shared field view](../views/bre/bre_dashboard_fields.view.lkml): Sunday-start ingestion_period_date, mapped ingestion_file_type, comparison date filter and selected/previous file measures, row-level NULLIF totals, sum measures, users-in-millions average and UUID display HTML. The existing Monday period_date and HER preaggregation are unchanged.
- [Filter suggestion view](../views/bre/bre_ingestion_filter_values.view.lkml): query-time distinct ingestion types across the three applicable source families. Unknown types pass through; there is no fixed allowed-value list. Both regional models include hidden suggestion Explores, while every chart uses bre_dashboard.

Files Per Day displays percentage change against the preceding equal-length range. A zero or absent previous statistic produces no percentage-change value. Median uses a sorted array and the middle value/pair, not an approximate percentile. Exact median requires memory proportional to the number of selected non-NULL file-count rows. Bounded contiguous date ranges support equal-length comparisons; open-ended filters retain the current statistic and have no previous comparison.

UUID uses a numeric measure with HTML to display both counts in the requested sentence. Its total measure is selected but visually hidden. Pilot Name filter matching uses the shared directory consistently; original source_pilot_name remains available for inspection. The two pilot filters intersect if both are selected.

The failure chart applies source_rank <= 20 before chart aggregation and does not introduce a global top-20 ranking. Its pivot query allows up to 200 error-code columns and 5,000 date rows, standard visualization result limits to review if Looker reports truncation. Weekly/monthly buckets include only dates within the chosen date filter. There is no missing-day zero fill.

Validation:

- `uv run scripts/validate_bre_models.py --output-dir /private/tmp/bre-ingestion-model-validation`: full project no-PDT audit and 108 locally rendered all-field Trino cases across CA/EU.
- `uv run scripts/validate_bre_ingestion_dashboard.py`: dashboard fields, filters, listeners, includes and layout; 48 tile SQL cases across both models and three periods; two suggestion SQL cases; 23 synthetic checks covering exact median, current/prior boundaries, zero/NULL prior values, Sunday grouping, dynamic file types, OPOWER and NULLIF arithmetic.
- Synthetic expressions execute locally through SQLGlot translation to DuckDB, not against warehouse data. The local renderer simulates Looker date tags and is not the Looker compiler.
- Current results and planning-only Trino checks are recorded in `bre_ca_ingestion_validation.json`. The historical `bre_model_validation.json` retains the earlier source-model validation evidence.

The user validates the new dashboard's LookML, HTML rendering, comparisons, chart axes and dynamic filter suggestions in the Looker web UI. Data sanity and population remain with the other owner. No data queries, persistence or dashboard deployment are part of this implementation.

Reference documentation used: [Looker date filters](https://docs.cloud.google.com/looker/docs/filter-expressions), [Liquid field values](https://docs.cloud.google.com/looker/docs/liquid-variable-reference), [filter suggestions](https://docs.cloud.google.com/looker/docs/changing-filter-suggestions), [single-value comparisons](https://docs.cloud.google.com/looker/docs/reference/param-lookml-dashboard-single-value-chart), and [Trino arrays](https://trino.io/docs/current/functions/array.html).
