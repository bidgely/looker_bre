# CA Disagg dashboard design

Status: CA implementation ready for native Looker review on 2026-09-13. `dashboards/bre_ca_disagg.dashboard.lookml` contains all eight query tiles: UUID, invoice Average/Median, T-7/T-2 success, the invoice/disagg combo chart, the Disagg Quality line chart, and stacked failure reasons, with seven dashboard controls, included only in `bre_ca`. Native Looker validation and execution remain pending.

## Delivery sequence

Agree on each CA tile, implement with model `bre_ca` and the existing `bre_dashboard` Explore, and have the user validate and run it in Looker. Create the EU version only after CA passes native LookML validation and runs without query errors. Data correctness will be checked in the separate regional validation stages after data transfer and EMR updates; see the [migration plan](bre_dashboard_migration_plan.md).

## Structure export

The [CA structure export](bre_dashboard_structure_ca.txt) lists the following tiles. It does not establish their aggregations, comparisons, date bindings or additional filters. Source families below are candidates based on the existing [source mapping](bre_source_view_mapping.md), pending tile-by-tile confirmation.

| Tile | Candidate source family | Definition status |
|---|---|---|
| Active UUID / Total UUID | `activeusers` | Confirmed and implemented: same combined snapshot tile as Ingestion, with pilot-only listeners; applies across all dashboards |
| # of Invoices Per Day | `invoicestatistics` | Implemented as Average and Median of total_invoices, filtered by reporting_date, each compared with the previous period |
| Averages Success % | `invoicestatistics` | Implemented: T-7 and T-2 unweighted averages of successful_itemisation_pct for matching SCHEDULED delay rows, filtered on reporting_date |
| Daily Invoice Ingestion vs Hybrid Disagg Processing Success % | `invoicestatistics` | Implemented: invoice bars, T-2/T-7 average lines and ADHOC maximum correction line; reporting_date filter, Analysis Date axis follows Daily/Weekly/Monthly Period selection |
| Daily Disagg Quality Report (Only for Elec AMI) | `disaggquality` | Confirmed and implemented: 13 average line series, reporting_date filter, analysis_date grouped by Period; Electric/AMI restriction is built into the source dataset, so no additional tile filters |
| Daily Top Disagg/Itemisation Failure Reasons | `processingfailures` | Confirmed and implemented: average failure_percentage, stacked by failure_reason, source rank <= 3, reporting_date filter and Period-grouped analysis_date |

Exported controls: Time Period, Period (Daily/Weekly), Pilot ID, Pilot Name, Meter Type (AMI/NSM), Fuel Type (Electric/Gas/Water), and Module Name (Itemization/PyAMIDisagg). These are exported labels, not confirmed exhaustive value lists. The user confirmed Daily/Weekly/Monthly grouping for the invoice/disagg combo chart; the Period control defaults to Daily. Meter Type, Fuel Type and Module Name use dynamic Invoice Statistics choices, with no default restriction and multiple selections allowed. Their source-compatible tile listeners are listed below.

## Meter Type, Fuel Type and Module Name controls

The user confirmed that all three controls get their values from SRE Invoice Statistics and should match other tiles wherever possible. Each is a dynamic, optional multi-select with no default restriction; raw values are matched exactly, without invented aliases or fixed option lists.

Both models expose the hidden `bre_invoice_filters` Explore using `view_name: bre_invoice_statistics`. Three dimensions on that existing source view supply the dashboard filter fields, preserving the source's latest-row selection and SCHEDULED/ADHOC scope. Dropdowns do not depend on the main Explore's default Source Family. All chart queries continue to use `bre_dashboard`; no new source query, view or PDT is introduced.

| Tiles | Meter Type | Fuel Type | Module Name |
|---|---|---|---|
| Invoice Average/Median, T-7/T-2 success, invoice/disagg combo | Yes | Yes | Yes |
| Disagg Quality | Yes | Yes | No: source does not provide module_name |
| Failure Reasons | Yes | Yes | Yes |
| Active UUID / Total UUID | No | No | No: source lacks these fields; agreed pilot-only snapshot retained |

Quality still has no fixed Electric/AMI tile restriction: its dataset handles that scope. Optional Meter/Fuel dashboard selections now apply to its matching fields. Filtering on a nonexistent Module Name would eliminate quality rows, so it is not wired to this chart. No module or meter/fuel attribution is inferred for UUID counts.

Validation includes six rendered suggestion queries across CA/EU and checks that all three controls resolve to the Invoice Statistics helper and only supported tile listeners are present. Dropdown contents and native UI behavior remain for user review after data readiness.

## Invoice scorecards

User-confirmed source: SRE Invoice Statistics, Apps Script Addon. Both scorecards use `reporting_date`, not `analysis_date`. The first averages source `total_invoices`; the second takes its exact median. Both compare against the previous period.

Following the Ingestion convention, the implementation uses the immediately preceding equal-length calendar range and displays percentage change. The starting date selection is the last seven completed days. These conventions were stated to the user; any differing Disagg requirements can override them. Additional chart-level filters were requested from the user but are not yet confirmed; none have been added. Meter, fuel and module dashboard controls apply to both comparison periods.

- Shared filter `invoice_comparison_date_range` supplies the date boundaries. Both scorecards listen to Time Period through this filter and retain current plus prior rows with `invoice_in_comparison_window`. Direct reporting-date filtering would remove the prior rows, so it is not applied separately to these queries.
- `invoice_statistics_invoices_selected_average` and `invoice_statistics_invoices_selected_median` aggregate the selected source rows directly. There is no preliminary daily sum or missing-day zero fill.
- Corresponding `previous_average` / `previous_median` measures and `average_change` / `median_change` measures supply the comparison. A zero or absent previous statistic returns NULL for percentage change.
- Median uses the existing Trino sorted-array method: ignore NULLs, retain zeros, average the middle pair for an even row count. Memory use grows with the number of source rows in the filtered window.
- Dates use typed LookML references (`::date`) throughout. No PDTs were introduced; model-level 12-hour result caching is separate from derived-table persistence.

Validation: `scripts/validate_bre_disagg_dashboard.py` passes fourteen rendered invoice/success/combo SQL cases, six quality SQL cases across CA/EU and all three periods, and 29 synthetic checks, including conflicting analysis/reporting dates, delay/trigger selection, unweighted success averages, zero preservation, invoice AVG/SUM branching, the ADHOC maximum, and daily/Sunday-weekly/monthly bucket boundaries. The model validator passes all 108 cases after the Invoice Statistics suggestion helper was added. The no-PDT audit passes. Results are recorded in `bre_ca_disagg_validation.json`; native Looker validation, execution and later data validation remain pending. Shared EU fields are checked locally, but no EU Disagg dashboard has been created.

## Average Success % — T-7 and T-2

User-confirmed source: SRE Invoice Statistics, Apps Script Addon. Both tiles filter on `reporting_date`. T-7 averages `CASE WHEN delay_in_days = 7 AND trigger_flag = 'SCHEDULED' THEN successful_itemisation_pct ELSE NULL END`; T-2 uses the same CASE with delay 2. These identify source delay categories; they do not shift the dashboard date range back seven or two days.

Shared row-level dimensions `invoice_statistics_successful_itemisation_t_7_pct` and `invoice_statistics_successful_itemisation_t_2_pct` expose the CASE expressions. Corresponding `_average` measures take unweighted averages and display the source's percentage scale with a literal percent sign. No multiplication by 100 or invoice-count weighting is applied. Nonmatching rows are NULL, not zero. The existing source query's COALESCE on successful_itemisation_pct remains unchanged.

Both tiles directly listen to Time Period through `reporting_date` and to the two pilot controls. Comparisons are currently off; the user was asked whether the original scorecards show a previous-period comparison, with no confirmation yet. The four invoice/success scorecards share one row beneath the UUID tile. All three meter/fuel/module dashboard controls apply to these tiles.

## Daily Invoice Ingestion vs Hybrid Disagg Processing Success %

User-confirmed source: SRE Invoice Statistics, Apps Script Addon. The chart filters on `reporting_date` but groups its x-axis by Analysis Date. The user confirmed that the Analysis Date axis follows the Daily/Weekly/Monthly Period selection. It uses `disagg_period_date`, a typed alias of the existing Sunday-start date grouping, preserving one shared calendar calculation. This chart, the Disagg Quality chart and the failure-reasons chart listen to Period; the scorecards and UUID tile do not. Analysis dates outside the selected reporting-date range are valid and are not independently excluded.

| Series | Calculation | Presentation |
|---|---|---|
| Daily Total Invoices | `CASE WHEN COUNT(DISTINCT analysis_date) = 1 THEN AVG(total_invoices) ELSE SUM(total_invoices) END` | Bars, left invoice-count axis |
| Success Rate (T-2) | Average of the confirmed SCHEDULED delay-2 CASE | Line, right percent axis |
| Success Rate (T-7) | Average of the confirmed SCHEDULED delay-7 CASE | Line, right percent axis |
| Correction Line | Maximum of `CASE WHEN trigger_flag = 'ADHOC' THEN successful_itemisation_pct ELSE NULL END` | Line, right percent axis |

The invoice expression is evaluated once per displayed group; it already contains aggregate functions and is not wrapped in another AVG. With a daily analysis-date axis, each non-NULL date group uses AVG; a Weekly/Monthly group containing multiple distinct analysis dates uses SUM. The count-distinct reference is typed as `${analysis_date::date}` to avoid formatted-string date calculations. A period with only one observed analysis date still uses AVG, regardless of the period label.

Shared measure `invoice_statistics_daily_total_invoices` supplies the bars. The T-2/T-7 measures are reused from the scorecards. Dimension `invoice_statistics_successful_itemisation_correction_pct` and its `_max` measure supply the Correction Line. All percentages retain their source scale. There is no chart-wide SCHEDULED or ADHOC restriction, so all four series can coexist. No new derived table or PDT is needed.

## Daily Disagg Quality Report (Only for Elec AMI)

User-confirmed source: SRE Quality Disagg, Apps Script Addon, from `reporting.sre_quality_disagg`. The tile filters on `reporting_date` and groups `analysis_date` by Daily/Weekly/Monthly using the shared `disagg_period_date` field. It listens to Time Period, Period, Pilot ID and Pilot Name. All 13 series are lines and reuse the existing `disagg_quality_<source_field>_average` measures: unweighted source-row averages, ignoring NULLs and retaining zeros, with no percentage rescaling.

| Source field | Series label |
|---|---|
| `appliances_kwh_variance_pct_1` | $/KWH Across Appliances %Var (Flag 1) |
| `appliances_kwh_variance_pct_2` | $/KWH Across Appliances %Var (Flag 2) |
| `total_cost_deviation_pct_1` | Total $ Across Appliances Out of Range (Flag 1) |
| `total_cost_deviation_pct_2` | Total $ Across Appliances Out of Range (Flag 2) |
| `cost_per_kwh_deviation_pct` | $/KWH Out of Range |
| `seasonal_appliance_usage_deviation_pct` | Non-Seasonal Appliance Usage |
| `ao_pct_non_tou` | AO I/O % Dev |
| `ac_pct_non_tou` | AC I/O % Dev |
| `sh_pct_non_tou` | SH I/O % Dev |
| `other_pct_non_tou` | Other I/O % Dev |
| `solar_pct_non_tou` | Zero Solar Estimation |
| `single_appliance_domination_deviation_pct` | Single Appliance Domination |
| `missing_dwelliing_pct` | Missing Dwelling Type |

The source also contains `missing_solar_pct_non_tou`, which is not one of the requested 13 metrics and is excluded. The user confirmed that the Electric/AMI restriction is built into the source dataset. No additional meter/fuel filter is required or added to this tile. The original source query and shared view remain unchanged.

No new view, measure, derived table or PDT was required. The invoice/disagg combo, quality and failure-reasons charts listen to Period; the scorecards and UUID tile do not.

## Daily Top Disagg/Itemisation Failure Reasons

User-confirmed source: SRE Failure Statistics, Apps Script Addon, from `reporting.sre_failure_statistics`. The tile uses stacked vertical bars with Period on the x-axis, grouping `analysis_date` by Daily, Sunday-start Weekly or Monthly through `disagg_period_date`. The chart filters on `reporting_date` and listens to both pilot controls.

The breakdown is `failure_reason` (the source's `_failure_reason_` display label). The metric is the existing `processing_failures_failure_percentage_average`, labeled **Failure %**, taking the unweighted arithmetic mean of source percentages for each period/reason. Values are not rescaled or normalized to a 100% stack.

The only additional chart restriction is source rank <= 3. The tile explicitly saves `failure_scope: Top Three`, which applies `source_rank <= 3` in the shared router and avoids relying on different CA/EU defaults. The source uses ROW_NUMBER ordered by failure_percentage descending within analysis_date, pilot_id and module_name. Ranking and top-three selection occur before reporting-date filtering and Period aggregation, preserving source behavior. Weekly/monthly grouping does not rerank reasons; more than three distinct reasons can appear across dates, pilots and modules.

No extra meter/fuel/module restriction or new LookML field, view or PDT was added. All six local SQL cases for this chart pass across CA/EU and all three Period values, alongside the existing 20 SQL cases and 29 synthetic checks. The no-PDT audit passes. No warehouse data was read, and no EU dashboard is created by that validation. Native Looker validation and execution remain pending.

## Existing shared source behavior

Confirmed UUID definition: SRE All Active Users (`reporting.sre_total_active_users`), latest `reporting_date` per pilot as selected by the source query. Reuse `active_users_uuid_summary` and `active_users_total_uuid_sum`. Only Pilot ID and Pilot Name affect this tile; date, period, meter, fuel and module controls do not. No comparison or additional source/date filters.

- Invoice Statistics reads `reporting.sre_invoice_statistics`, keeps SCHEDULED/ADHOC rows, and selects the latest update per source partition. Shared fields expose total invoices and successful/failed itemisation percentages. The original source includes delay in the SCHEDULED partition.
- Disagg Quality reads `reporting.sre_quality_disagg`; existing shared fields expose the source quality percentages, meter/fuel types and TOU status.
- Processing Failures reads `reporting.sre_failure_statistics`, ranks within analysis date, pilot and module, and exposes failure reason, percentage and counts. The tile explicitly selects the approved `failure_scope: Top Three` setting.
- Active Users and pilot directory fields already exist. No new view is needed merely to start the Disagg design. Any additional calculations must use Trino-compatible SQL and query-time derived tables only; no PDTs.

No warehouse data was queried for this design review. The EU pilot dropdown investigation remains deferred.
