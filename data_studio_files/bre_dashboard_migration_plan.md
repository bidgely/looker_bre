# BRE dashboard migration plan

Updated: 2026-09-13.

## Current progress

- Source inventory, table availability checks and missing-table DDL preparation are complete. The user created the tables in both Starburst catalogs.
- Shared LookML views and separate `bre_ca` / `bre_eu` models are implemented, using `starburst_prod_ca` / `starburst_prod_eu`. Derived tables remain query-time only; no PDTs are allowed.
- [CA Ingestion](bre_ca_ingestion_dashboard_design.md) is implemented. The user accepted the dashboard structure; data correctness remains unvalidated.
- [EU Ingestion](bre_eu_ingestion_dashboard_design.md) is implemented from the approved CA design. Missing Pilot ID / Pilot Name dropdown values remain an open issue; investigation is deferred at the user's request.
- [CA Disagg](bre_ca_disagg_dashboard_design.md) has eight implemented tiles and seven controls. The user accepted the CA version and requested EU, satisfying the CA-first delivery gate.
- [EU Disagg](bre_eu_disagg_dashboard_design.md) is implemented with the same tiles and controls using shared views and model `bre_eu`. Local parity and SQL checks pass; EU native Looker validation and execution remain for user review. Data correctness remains deferred for both regions.
- [CA Email](bre_ca_email_dashboard_design.md) is implemented: eight tiles are implemented—Active UUID / Total UUID, Emails Sent Average/Median with previous-period comparisons, Averages Sent % versus Expected/Eligible without comparisons, the full-outer Email Delivery Statistics blend, Weekly Email Reco Quality Report, and Weekly Top Email Failure Reasons (average failure count by reason, source rank <= 3)—with six controls. Email Type filters seven email-specific tiles using Daily Tracker suggestions; BC End Week# filters six complete tiles using Email Statistics suggestions. Active UUID has no dashboard filter listeners; BC End Week# also filters the five Statistics series in the Delivery blend while leaving its three Tracker series unaffected. The user requested the matching EU version; native validation and data correctness remain separate checks.
- [EU Email](bre_eu_email_dashboard_design.md) is implemented at the user’s request, matching all eight CA tiles and six controls through shared views and model `bre_eu`. Local regional parity and SQL checks pass; native Looker validation and execution remain for user review.
- [CA HER](bre_ca_her_dashboard_design.md) is in progress, CA only: Active UUID / Total UUID and the Expected Gen # / Total Actual Gen # sums are implemented. Both generation totals use HER Schedule Specific Statistics and filter on `schedule_start`. The HER Schedule(s) table is also implemented from that source: Start/End dates, eight summed metric columns, and an `analysis_date` date filter. HER Generation Daily Stats is implemented using only Daily source rows, three summed count bars and average row-level Success % on the secondary axis; its Period control groups Daily/Weekly/Monthly without selecting the source’s preaggregated rows. Daily HER Quality is implemented with 19 summed lines from Daily source rows, filtered by reporting_date and grouped by analysis date using the shared chart Period control; bill-change consistency appears once. Daily HER Generation Failure Reasons is implemented with SUM(failure_count) stacked by failure_reason, analysis_date filtering, Daily source rows grouped by the shared chart Period, and no rank restriction. All seven HER tiles and six controls are implemented. Fuel Type and Cluster IDs use Cluster Specific Generation Stats dropdown values and filter five compatible tiles; Active UUID is explicitly excluded and HER Quality lacks both fields. Native Looker validation and data validation remain pending.
- Remaining dashboard construction: CA NBI. CA HER structure is implemented and awaits native Looker review. No EU HER copy is planned.

## Data readiness prerequisite

Shared dashboard convention confirmed by the user: every dashboard uses the same combined Active UUID / Total UUID tile as Ingestion, from SRE All Active Users with the latest reporting-date snapshot per pilot. Only Pilot ID and Pilot Name controls affect it in Ingestion and Disagg. For Email, the user explicitly requested no dashboard filter listeners on Active UUID. Reuse the existing shared measures across CA and EU.

The user will complete the Redshift-to-Starburst data transfer into the required tables in both environments and point the EMR jobs to those Starburst tables. Wait for the user's confirmation that these steps are complete before starting the validation stages below. Data readiness is a prerequisite, not proof that all dashboard queries and results are correct.

Only Starburst may be queried by the assistant. Any direct Redshift comparison remains with the user.

## Added validation stages

1. **CA dashboard data validation — pending data readiness.** Validate the completed CA dashboards against populated `delta_prodca` sources. Check tile results against the agreed formulas and source grains, date and period controls, pilot and ingestion-type filters, previous-period comparisons, and unexpected NULLs or query errors. Investigate differences, apply approved fixes and have the user review the results in Looker.
2. **EU dashboard data validation — pending data readiness.** Validate the completed EU dashboards against populated `delta_prodeu` sources using the same checks. Resume the Pilot ID / Pilot Name dropdown investigation, confirm the rule for EU pilot membership, and verify that the options and tile filtering work correctly. Investigate differences, apply approved fixes and have the user review the results in Looker.

Track structure/native LookML validation separately from data validation. Neither regional data-validation stage is complete yet.
