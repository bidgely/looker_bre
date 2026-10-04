# NA Email implementation review

Status, 2026-10-04: **all 18 tiles implemented as two separate draft dashboards**: 6a Data Governance (8 tiles) and 6b Queue Metrics (10 tiles). Native Looker validation and original-report comparison remain pending.

## Dashboard separation

- [6a Data Governance](../dashboards/bre_na_email_governance.dashboard.lookml): `bre_na::bre_na_email_governance`, all eight tiles.
- [6b Queue Metrics](../dashboards/bre_na_email_queue_metrics.dashboard.lookml): `bre_na::bre_na_email_queue_metrics`, all ten tiles. The confirmed module scope is `module_name = 'Emailer'` in every queue source.
- The dashboards will remain separate for the later frontend tab mechanism. BRE portal integration remains a later step.

## Governance sources and tiles

[Delivery view](../views/bre_na/bre_na_email_delivery.view.lkml) and [shared fields](../views/bre_na/bre_na_email_fields.view.lkml) use SRC-05, SRE Email Daily Weekly Combined Tracking. The supplied query's Daily/Weekly UNION ALL, numeric casts, exclusion of NULL analysis dates, original row-level rates, and formatted pilot-directory inner join are retained. Pilot name is explicitly projected for filtering. No deduplication, persistence, or additional fixed pilot restriction is added. Query-local row numbers retain source row multiplicity and provide primary keys.

| Tile | Implementation |
| --- | --- |
| NA-6A-T01 | Existing latest Active Users snapshot, then reporting-date filtering. |
| NA-6A-T02 | Source-row average of delivery_cnt, compared with the preceding equal-length analysis-date range. |
| NA-6A-T03 | Exact median of delivery_cnt, with the same comparison. NULLs omitted; even counts average the middle pair. |
| NA-6A-T04 | SUM(generation_cnt) / SUM(invoice_ingested) × 100; generation gauge. |
| NA-6A-T05 | SUM(delivery_cnt) / SUM(generation_cnt) × 100; delivery gauge. |
| NA-6A-T06 | Eligible invoice, generated email, and delivered email sums as grouped bars; both calculated percentages as lines on a separate axis. |
| NA-6A-T07 | AVG(notification_pct), stacked by metric_name at analysis-date grain, using SRC-26. |
| NA-6A-T08 | Confirmed Metric Toggle: AVG(failure_pct) or SUM(failure_count), stacked by failure_reason and grouped by Period, using SRC-33. |

The tile inventory calls the calculated percentages “average,” but SRC-05 explicitly defines them as ratios of sums. Those aggregate formulas take precedence: the implementation does not average source row rates or nest AVG around an aggregate ratio. It uses floating-point division and returns NULL for a zero denominator. The source report's zero-denominator display remains to be verified.

Both gauges are green, span 0–100%, show an empty arc at zero, and fill at or above the maximum while displaying the actual value. Values are not clamped. Relative period changes return NULL when the previous value is zero or absent; open-ended dates do not invent a prior interval.

SRC-26 preserves the supplied LEFT JOIN to the formatted pilot directory and all recommendation source rows. SRC-33 preserves its pilot-directory INNER JOIN followed by ROW_NUMBER partitioned by original analysis_date, pilot_id, and email_type, ordered by failure_count descending. All dashboard predicates remain outside the ranked source. Its date text is cast to DATE for filtering and chart grouping, without changing source ranking. Both new views explicitly project pilot_name for controls.

The failure source calculates rank but does not filter by rank; no top-N cutoff was supplied, so every failure reason is retained. Failure Metric defaults to `failure_pct` as an implementation choice, with `failure_count` available in the control. Both source percentage fields are displayed without rescaling or weighting. The toggle's selected aggregation is the final chart aggregate; no extra AVG wraps its SUM branch. The original report's default and any undocumented top-N restriction remain acceptance checks.

## Controls

Defaults are the last seven completed days, Pilot ID 10037, Pilot Name PSEG, Period Daily, Reporting Frequency Daily, and unrestricted Email Type.

Period groups analysis dates by day, Sunday-start week, or month for T06 and T08. T07 retains its specified analysis-date grain. Reporting Frequency filters the source delivery_mode independently. The supplied source has only Daily and Weekly branches; Monthly grouping is available, but there are no Monthly delivery-mode rows. Source suggestions expose actual values.

Pilot and Time Period controls apply to every implemented tile. T02–T08 use analysis_date; T01 uses reporting_date. Email Type applies to T02–T08. Reporting Frequency applies to T02–T06; it does not exist on the recommendation/failure sources or Active Users. The weekly titles are retained without inventing a fixed weekly predicate. T02–T03 preserve both current and prior ranges before calculation. Filters do not alter the source UNION ALL logic.

## Queue dashboard

All three queue views reuse the established NA source formulas, with the confirmed fixed condition `module_name = 'Emailer'` applied before aggregation. Each of the ten tiles listens to Time Period, Environment, Module, Queue Name, and Queue Type. Hourly SRC-01 retains its original rolling seven-day source-history limit. Dates use the source's UTC bucket rules; the default is the last seven completed days.

| Tile | Implementation |
| --- | --- |
| NA-6B-T01 | AVG daily health_score. |
| NA-6B-T02 | SUM hourly total_messages_received. The singular field spelling in the inventory resolves to this source column. |
| NA-6B-T03 | AVG source success_rate, explicitly specified for Email. |
| NA-6B-T04 | AVG hourly avg_queue_backlog. |
| NA-6B-T05 | SUM hourly total_messages_received trend. |
| NA-6B-T06 | AVG hourly avg_queue_backlog trend. |
| NA-6B-T07 | MAX hourly max_latency_in_days trend. |
| NA-6B-T08 | AVG daily health_score, stacked by queue_name. |
| NA-6B-T09 | AVG daily empty_receives_ratio. SRC-24 contains daily buckets, so the inventory's hourly date-field reference maps to the daily source date. |
| NA-6B-T10 | SUM hourly delayed_messages trend. |

The queue dashboard starts at row zero and has independent controls, ready for the later frontend tabs. No pilot control is added to queue data, which lacks pilot identifiers.

## Validation

- [Local validator](../scripts/validate_bre_na_email.py): eighteen tiles, twenty-four rendered query variants, thirty-two semantic fixtures, and three source-query contract checks pass. Tests cover both Metric Toggle branches, retained rank 4, recommendation LEFT JOIN behavior, failure INNER JOIN behavior, text date grouping, and Emailer/environment isolation, alongside delivery calculations.
- All twenty-four rendered SQL exports pass Starburst `EXPLAIN (TYPE VALIDATE)`, including both Failure Metric choices across Daily/Weekly/Monthly grouping and all ten queue tiles. Active Users reuses the existing validated configuration.
- Four bounded PSEG/Daily queries for September 27–October 3, 2026 return average delivery count 19,609.428571428572, median 72, generation 965.4122706807339%, and delivery 95.54721814245839%. The preceding averages/medians are 15,384.714285714286 and 7.
- A separate raw-source sum check returns 14,881 invoices, 143,663 generated emails, and 137,266 delivered emails. These reproduce the documented aggregate percentages, including generation above 100%. The value is retained, not corrected or capped.
- Five additional bounded executions return recommendation percentages and both failure-metric branches for PSEG. For example, DELIVERY_MODE_EMAIL_NOT_AVAILABLE returns 50.85% or 19,971 failures. Emailer health-score average is 96; hourly processing-success average is 99.92166666666667% for the tested range and source rolling-window intersection.
- Eight standalone gauge cases pass, including the observed 965.41% value. The [preview](bre_na_email_gauge_preview.png) was visually inspected. It is not a Looker UI rendering.
- Ingestion, Aggregation, Disaggregation, TOU, and Rate Comparison local validators pass after the model additions, including ten CA/EU source-route checks.
- [Evidence](bre_na_email_validation.json) records query IDs and results. Run `uv run scripts/validate_bre_na_email.py` to reproduce local checks and planning exports; the renderer is a simulator, not Looker's compiler.

## Remaining acceptance checks

All supplied Email source queries and confirmed formulas are implemented. Native Looker validation, original-report parity, and target dashboard rendering remain pending because no Looker connection is available in this session. Verify the original Failure Metric default, any unrecorded top-N filter, zero-denominator display, and the inventory's hourly reference for the daily efficiency source. The implementation choices are recorded above and do not block the separate dashboard drafts.
