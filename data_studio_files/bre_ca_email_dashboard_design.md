# CA Email dashboard design

Status: started on 2026-09-13. Eight tiles are implemented in `dashboards/bre_ca_email.dashboard.lookml`, included in `bre_ca`: Active UUID / Total UUID, Emails Sent Average and Median, Averages Sent % versus Expected and Eligible counts, Email Delivery Statistics, Weekly Email Reco Quality Report, and Weekly Top Email Failure Reasons. Six controls are implemented: Pilot ID, Pilot Name, Time Period, Period, Email Type and BC End Week#. Active UUID is independent of all dashboard controls; BC End Week# applies to the five Statistics series in the delivery blend. Native Looker validation and execution remain pending; data validation remains deferred until transfer and EMR updates are complete.

## Active UUID / Total UUID

The user confirmed this tile is the same as the approved dashboards. Reuse the CA Disagg UUID fields and snapshot logic, with `bre_dashboard.source_family: activeusers`, `active_users_uuid_summary` and the hidden `active_users_total_uuid_sum` measure. It displays `Active UUID: <active count> out of Total UUID: <total count>` from SRE All Active Users (`reporting.sre_total_active_users`), using the existing latest reporting-date snapshot per pilot.

The user subsequently requested no dashboard filters on this tile. Its listener map is empty, including for Pilot ID and Pilot Name. It shows the latest reporting-date snapshot per pilot across all pilots. The internal `source_family: activeusers` selector is retained to select the correct dataset. Shared views, source SQL and measures are reused without changes; no PDT is added.

## # of Emails Sent Per Week — Average and Median

User-confirmed source: SRE Email Statistics, Apps Script Addon, mapped to `reporting.sre_quality_email_stats` through the shared `emailstatistics` family. Both tiles aggregate `cnt_bills_emails_sent` directly over source rows and filter on `reporting_date`. The title does not introduce a weekly sum or a division by elapsed weeks.

The two tiles display the unweighted average and exact median, respectively. The median omits NULLs, retains zeros, and averages the central pair for an even row count, using Trino sorted arrays. Each displays percentage change against the preceding equal-length date range, following the Ingestion/Disagg comparison convention. Previous values are retained as hidden query fields; a zero or absent previous value produces NULL percentage change.

Time Period defaults to Last 7 completed days (`7 days ago for 7 days`) and binds to the new `email_comparison_date_range` filter. Typed `reporting_date::date` comparisons preserve both current and previous rows through `email_in_comparison_window`, avoiding a direct date restriction that would remove previous-period rows. Open-ended ranges have no previous-period comparison. Pilot ID and Pilot Name apply to both tiles. The UUID tile is independent of dashboard controls.

Shared fields live in `bre_dashboard_fields`, exposed in the Email Statistics set in both regional models for later EU reuse. No source SQL, derived table or persistence setting changed.

## Averages Sent % — vs Expected # and vs Eligible #

User-confirmed source: SRE Email Statistics, Apps Script Addon, using the same `emailstatistics` family. Both are single-value tiles with no previous-period comparison. They use the existing pilot filters and, following the preceding Email tiles, bind Time Period directly to `reporting_date`, defaulting to Last 7 completed days.

- **vs Expected #:** unweighted `AVG(cnt_bills_emails_sent / cnt_expected_invoices * 100)` over source rows. The shared row-level dimension casts the numerator to DOUBLE to prevent Trino integer division and uses `NULLIF(cnt_expected_invoices, 0)` to avoid division by zero. Zero or missing denominators produce NULL ratios, which AVG omits. A zero numerator with a nonzero denominator contributes zero. This is an average of row percentages, not a ratio of summed counts.
- **vs Eligible #:** reuse `email_statistics_email_sent_pct_average`, the unweighted average of source `email_sent_pct` with no rescaling.

Both display two decimal places and a literal percent sign. The expected-count dimension and measure are exposed in the shared Email Statistics set for later EU reuse. No source query or PDT was added.

Local validation: `scripts/validate_bre_email_dashboard.py` checks field exposure and filter bindings, parses eight rendered Trino SQL cases (four metrics in each region), and passes 27 synthetic checks covering averages/medians, row-percentage aggregation, NULL/zero handling, date boundaries and prior ranges. The no-PDT audit passes. Evidence: `bre_ca_email_validation.json`. These checks do not replace native Looker validation or execution.

## Email Delivery Statistics

The user specified a single chart combining SRE Email Statistics and SRE Email Daily Tracker, with Analysis Date grouped by the selected Period. The daily metrics map to `reporting.sre_email_daily_tracker`; weekly metrics map to `reporting.sre_quality_email_stats`.

| Label | Source field | Aggregation | Series |
|---|---|---|---|
| Daily Eligible Invoices # | Tracker `invoice_ingested` | Sum | Line |
| Daily Email Generation # | Tracker `generated_notification_id` | Sum | Line |
| Daily Email Sent # | Tracker `delivered_notification_id` | Sum | Bar |
| Weekly Expected Email # | Statistics `cnt_expected_invoices` | Average | Bar |
| Weekly Eligible User # | Statistics `cnt_bills_item_available` | Average | Bar |
| Weekly Email Sent # | Statistics `cnt_bills_emails_sent` | Average | Line |
| Weekly Tracker Email Sent vs Eligible % | Statistics `email_sent_pct` | Average | Bar |
| Weekly Tracker Email Sent vs Expected % | Statistics `email_sent_pct_vs_expected` | Average | Bar |

The user confirmed that Time Period filters `analysis_date` in both sources and that the blend joins on `email_type` and `analysis_date`. This chart's date binding differs from the preceding Email scorecards, which use `reporting_date`. Match the sources on the daily analysis date before grouping the chart by Period. The shared `email_period_date` dimension is prepared with the existing Daily/Weekly/Monthly calendar (Sunday-start weeks).

The user confirmed a **full outer join** on `email_type` and `analysis_date`. Shared view and Explore `bre_email_delivery` implement the blend in both regional models for reuse; only the CA chart is added at this stage. The existing `bre_dashboard` Explore remains for single-source tiles.

The blend reuses the existing source views. It filters analysis date and both pilot controls independently in each source, aggregates each to email type/date, then performs the full outer join. Pilot ID is not added as a join key. This preserves dates/types present in either source and prevents billing-cycle-week or delivery-mode rows from multiplying the opposite source's counts. SQL equality leaves NULL join keys unmatched. Missing-side metrics remain NULL rather than being zero-filled.

Tracker sums are summed again at the selected Period. For each Statistics metric, the blend retains its sum and non-NULL row count, and calculates `SUM(total) / SUM(count)` at chart granularity. This preserves source-row averages across email types and dates, including when row counts differ; it does not average daily averages. Expected percentages use the same floating-point, zero-safe row formula as the scorecard. The blend contains no reporting-date restriction.

The chart uses three line series and five unstacked bar series exactly as specified above. Six count series use the left axis; the two percentage series use the right axis with literal-percent formatting. Period defaults to Daily and supports Weekly (Sunday start) and Monthly through the shared calendar. The inherited view fields are restricted by the dedicated Explore to fields supported by the blend. Both pilot controls bind to filter-only blend fields, so filtering occurs before aggregation on both sides.

Validation: `validate_bre_email_delivery.py`, invoked by the Email dashboard validator, adds six local Trino SQL parses (CA/EU × Daily/Weekly/Monthly) and eight synthetic checks. Cases cover repeated join keys, dates missing from either side, pre-join pilot/date filters, conflicting reporting dates, unequal source-row counts across periods, NULL join keys, an empty source and zero expected counts. No warehouse data was read and no PDT was added. Native Looker validation and execution remain pending.

## Weekly Email Reco Quality Report

User-confirmed source: SRE Email Reco Statistics, Apps Script Addon, mapped to `reporting.sre_quality_reco_stats` through the existing `emailrecommendations` source family. Reuse `email_recommendations_notification_pct_average` to calculate the unweighted average of source `notification_pct`, labeled `% Emails`. Display a stacked column chart with `metric_name` pivoted into the breakdown series. Stacking is normal, not normalized to 100%; source percentages are displayed with a literal percent sign without rescaling.

Time Period filters `reporting_date`, defaulting to Last 7 completed days. The Analysis Date axis uses the shared `email_period_date` dimension, following Daily, Weekly (Sunday start), or Monthly selection despite the weekly chart title. Pilot ID and Pilot Name apply through the existing dashboard listeners. No additional tile filters, comparison, views, measures or PDTs are added.

## Weekly Top Email Failure Reasons

User-confirmed source: SRE Email Failure Statistics, Apps Script Addon, mapped to `reporting.sre_email_failure_reasons` through the existing `emailfailures` family. The shared `email_failures_failure_count_average` measure calculates arithmetic `AVG(failure_count)` over selected source rows, displayed as Failure Count with `failure_reason` as the breakdown. Zeros contribute to the average; NULL counts do not. No percentage conversion or previous-period comparison applies.

Time Period filters `reporting_date`, with Last 7 completed days as the default. The Analysis Date axis follows Daily/Weekly/Monthly using `email_period_date` (Sunday-start weeks). The tile applies `source_rank <= 3` to the existing source `ROW_NUMBER()` ranking by descending failure count within original analysis date, pilot and email type. Ranking is not recalculated at weekly/monthly granularity or after dashboard date filtering. More than three distinct failure reasons may appear across selected dates, pilots and email types. Both pilot controls apply.

Stacked columns are the implementation assumption, matching the other failure-reason charts; the chart-type preference was asked separately. The new average measure is exposed through the shared Email Failures set in both models. No source query, derived table or persistence setting changed.

Local validation adds six rendered Trino query parses and six synthetic checks (CA/EU × Daily/Weekly/Monthly) covering rank filtering, reporting-date boundaries with conflicting analysis dates, grouping, and zero/NULL handling. Native Looker validation remains pending.

## Email Type and BC End Week# controls

The user specified Email Type suggestions from SRE Email Daily Tracker and BC End Week# suggestions from SRE Email Statistics. Hidden helper Explores in both regional models query the existing migrated source views: `bre_email_type_filters` exposes `bre_email_tracker.email_type` from `reporting.sre_email_daily_tracker`; `bre_email_week_filters` exposes `bre_email_statistics.bc_end_week_number` from `reporting.sre_quality_email_stats`. These dropdowns use dynamic source values, support multiple selections, and default to all values. No Redshift access or warehouse data validation was performed.

| Tile | Email Type | BC End Week# |
|---|---|---|
| Active UUID / Total UUID | Not connected; no dashboard controls apply | Not connected |
| Emails Sent Average | Applied | Applied |
| Emails Sent Median | Applied | Applied |
| Sent % vs Expected | Applied | Applied |
| Sent % vs Eligible | Applied | Applied |
| Email Delivery Statistics | Applied to coalesced email type after full outer join | Applied to its five Statistics series only |
| Weekly Email Reco Quality | Applied | Applied |
| Weekly Top Email Failure Reasons | Applied | Applied |

Email Type currently filters all seven email-specific tiles. For the full outer blend, filtering the coalesced email-type join key restricts both sources, including unmatched rows, before chart aggregation. BC End Week# fully filters six tiles via the shared dimension. Both filters apply alongside current/previous date windows on the comparison scorecards; failure ranking remains the original source ranking.

The user confirmed no filters for Active UUID and requested BC End Week# on Email Delivery Statistics. Active UUID now has no dashboard listeners, including pilot filters. The blend uses `blend_bc_end_week_number` to filter `s.bc_end_week_number` inside Email Statistics before aggregation and the full outer join. Its three Daily Tracker series are unaffected by BC week. This preserves Tracker-only rows even when the selected week matches no Statistics rows. The filter supports multiple values and defaults to all; both regional Explores expose it for reuse.

Validation checks dropdown source mappings in both models, field exposure, seven Email Type listeners, seven BC-week listeners, and an empty UUID listener map with unchanged source and measures. Two additional synthetic blend checks verify Email Type filtering for matched keys and types present on only one side. Time Period remains Last 7 completed days; Period affects the three time-series charts.

Create the EU equivalent after the CA dashboard is accepted in Looker, following the regional delivery sequence in the [migration plan](bre_dashboard_migration_plan.md).

BC-week validation adds two selected-week Trino parses and five synthetic checks covering Daily/Weekly/Monthly grouping, different BC weeks at a shared join key, multiple selections and no matching week. Tracker totals stay unchanged while Statistics averages are recalculated from matching source rows. No warehouse data was read; no PDT was added.
