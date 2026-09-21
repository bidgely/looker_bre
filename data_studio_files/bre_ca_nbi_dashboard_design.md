# CA NBI dashboard design

Status: all eight tiles and four controls are implemented, CA only. Eight tiles are implemented in `dashboards/bre_ca_nbi.dashboard.lookml`, included only in model `bre_ca` using `starburst_prod_ca` and the shared `bre_dashboard` Explore. Native Looker validation and execution remain pending.

## Active UUID / Total UUID — implemented

Reuses the same tile as CA HER, Ingestion and Disagg, from SRE All Active Users (`activeusers`). The existing `active_users_uuid_summary` measure displays “Active UUID: … out of Total UUID: …”; `active_users_total_uuid_sum` remains a hidden supporting field. The shared source selects the latest reporting-date snapshot per pilot.

Pilot ID and Pilot Name controls apply, defaulting to all pilots with optional multiple selection. The tile is independent of date and Period controls and has no previous-period comparison. No new views, measures, derived tables or PDTs are needed.

## # of NBI Insight Generation — implemented

Two single-value tiles use SRE NBI Engine Daily Run Statistics (Apps Script Addon), mapped to the existing `nbigeneration` family. The source aliases `delta_prodca.reporting.sre_nbi_generated_errors.total_nbi_users` as `total_users_successful`.

- **On Average:** unweighted AVG(total_users_successful) over the selected source rows.
- **Median:** exact median of total_users_successful over the selected source rows; even row counts average the two central values.

Both use `analysis_date` and compare against the immediately preceding equal-length calendar-date range, displaying percentage change like the existing dashboards. Time Period defaults to the last 7 completed days (`7 days ago for 7 days`). Its listener uses the NBI comparison date filter so both selected and previous rows remain available. Pilot ID and Pilot Name apply to both periods. Active UUID remains independent of Time Period.

Shared NBI fields implement typed Trino date boundaries, conditional source-row values, AVG, and exact median using a sorted array. NULL input values are omitted and zeros are retained. An absent or zero prior statistic produces no percentage change. Open-ended ranges retain their current-period statistic with no previous-period comparison. No daily preaggregation, new source views or PDTs are introduced; the existing source grain is preserved.

## Failure Distribution — implemented

Two single-value tiles use SRE NBI Engine Daily Run Statistics, filtered on `analysis_date`: Format Error (`nbi_200_error_pct`) and Value Error (`nbi_300_error_pct`). No previous-period comparison is requested.

The user confirmed `failure_count = total_users_with_200_errorcode + total_users_with_300_errorcode`. Each ratio divides its respective error count by `NULLIF(failure_count, 0)`. Shared row-level dimensions implement these formulas with decimal division, preserve source NULLs and display the ratios as percentages. The user confirmed Average for both tiles: unweighted AVG of each row-level ratio, with NULL ratios omitted and zero ratios retained. Both use the shared Time Period control on analysis_date (last 7 completed days by default), plus Pilot ID and Pilot Name. There is no previous-period comparison. The two tiles occupy the row below the insight-generation scorecards.

## Daily NBI Generation Statistics — implemented

Source: SRE NBI Engine Daily Run Statistics (Apps Script Addon), shared `nbigeneration` family. Time Period filters `analysis_date` before grouping, defaulting to the last 7 completed days. The new Period control defaults to Daily and selects Daily, Sunday-start Weekly or Monthly analysis-date buckets through a typed alias of the shared calendar. It affects the Generation Statistics, Generic Tag and Failure Reasons charts. Pilot ID and Pilot Name also apply.

All three series use unweighted source-row averages within each displayed bucket:

| Series | Row-level value | Display |
|---|---|---|
| Total Users NBI Generated | total_users_successful + total_users_with_200_errorcode + total_users_with_300_errorcode | Bar, left count axis |
| Successful Generation # | total_users_successful | Bar, left count axis |
| Success % | 100 - nbi_error_pct | Line, right percentage axis |

Preserve source NULLs: a NULL component makes the generated-total formula NULL, which AVG omits; each metric averages its own non-NULL rows. Success % retains the source percentage-point scale with a literal percent sign. Source rows are neither preaggregated into daily averages nor replaced with ratios of summed counts. Existing scorecards retain their date and comparison behavior. No new derived tables or PDTs are needed.

## Daily NBI Users Count With Generic Tag — implemented

Source: SRE NBI Gen Quality Generic tag, mapped to existing `nbigenerictags` / `bre_nbi_generic_tags` over `delta_prodca.reporting.sre_nbi_generic_tag_users`. A single column series, **NBI Users# with Generic Tag**, uses the existing SUM(total_nbi_users_with_generic_tag) measure.

Time Period filters `analysis_date` before grouping, defaulting to the last 7 completed days. The X axis reuses `nbi_period_date` and the shared Period control for Daily, Sunday-start Weekly or Monthly buckets. Pilot ID and Pilot Name apply. The source grain and standard SUM NULL behavior are preserved; no new views, measures, joins or PDTs are required.

## Daily Top NBI Failure Reasons Statistics — implemented

Source: SRE NBI Engine Daily Run Statistics, shared `nbigeneration` family over `delta_prodca.reporting.sre_nbi_generated_errors`. Two normal stacked column series use source-row averages:

- **NBI_FORMAT_ERROR (200):** AVG(total_users_with_200_errorcode).
- **NBI_VALUE_ERROR (300):** AVG(total_users_with_300_errorcode).

Time Period filters `analysis_date` before grouping into Daily, Sunday-start Weekly or Monthly buckets with `nbi_period_date`. Pilot ID and Pilot Name apply. Each series omits NULLs and retains zero counts. These are counts, with no percentage normalization or rank restriction. Both error categories are displayed.

## Controls and remaining validation

All eight tiles are implemented. Time Period defaults to the last 7 completed days and applies to seven tiles; Active UUID remains independent of date. Period defaults to Daily and affects the three time-series charts. Pilot ID and Pilot Name apply to all eight tiles and default to all pilots. These are the four dashboard controls. No EU copy is planned.

Native Looker validation and dashboard execution remain pending user review. Data validation remains deferred until the user confirms the Starburst data transfer and EMR repointing are complete.
