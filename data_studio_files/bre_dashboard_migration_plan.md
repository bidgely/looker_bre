# BRE dashboard migration plan

Updated: 2026-09-13.

## Current progress

- Source inventory, table availability checks and missing-table DDL preparation are complete. The user created the tables in both Starburst catalogs.
- Shared LookML views and separate `bre_ca` / `bre_eu` models are implemented, using `starburst_prod_ca` / `starburst_prod_eu`. Derived tables remain query-time only; no PDTs are allowed.
- [CA Ingestion](bre_ca_ingestion_dashboard_design.md) is implemented. The user accepted the dashboard structure; data correctness remains unvalidated.
- [EU Ingestion](bre_eu_ingestion_dashboard_design.md) is implemented from the approved CA design. Missing Pilot ID / Pilot Name dropdown values remain an open issue; investigation is deferred at the user's request.
- [CA Disagg](bre_ca_disagg_dashboard_design.md) has eight implemented tiles and seven controls. The user accepted the CA version and requested EU, satisfying the CA-first delivery gate.
- [EU Disagg](bre_eu_disagg_dashboard_design.md) is implemented with the same tiles and controls using shared views and model `bre_eu`. Local parity and SQL checks pass; EU native Looker validation and execution remain for user review. Data correctness remains deferred for both regions.
- Remaining dashboard construction after Disagg: CA Email, HER and NBI; EU Email. Continue tile-by-tile agreement on sources, metrics, filters and presentation.

## Data readiness prerequisite

Shared dashboard convention confirmed by the user: every dashboard uses the same combined Active UUID / Total UUID tile as Ingestion, from SRE All Active Users with the latest reporting-date snapshot per pilot. Only Pilot ID and Pilot Name controls affect it. Reuse the existing shared measures across CA and EU.

The user will complete the Redshift-to-Starburst data transfer into the required tables in both environments and point the EMR jobs to those Starburst tables. Wait for the user's confirmation that these steps are complete before starting the validation stages below. Data readiness is a prerequisite, not proof that all dashboard queries and results are correct.

Only Starburst may be queried by the assistant. Any direct Redshift comparison remains with the user.

## Added validation stages

1. **CA dashboard data validation — pending data readiness.** Validate the completed CA dashboards against populated `delta_prodca` sources. Check tile results against the agreed formulas and source grains, date and period controls, pilot and ingestion-type filters, previous-period comparisons, and unexpected NULLs or query errors. Investigate differences, apply approved fixes and have the user review the results in Looker.
2. **EU dashboard data validation — pending data readiness.** Validate the completed EU dashboards against populated `delta_prodeu` sources using the same checks. Resume the Pilot ID / Pilot Name dropdown investigation, confirm the rule for EU pilot membership, and verify that the options and tile filtering work correctly. Investigate differences, apply approved fixes and have the user review the results in Looker.

Track structure/native LookML validation separately from data validation. Neither regional data-validation stage is complete yet.
