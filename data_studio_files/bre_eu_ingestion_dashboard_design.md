# EU Ingestion dashboard

Implemented in `dashboards/bre_eu_ingestion.dashboard.lookml`, included only by `models/bre_eu.model.lkml`. All eight query tiles and five filter controls use model `bre_eu`, Explore `bre_dashboard`, on connection `starburst_prod_eu`. Existing shared views select the `delta_prodeu` catalog.

On 2026-09-13 the user accepted the CA dashboard structure and requested the same dashboard for EU. The [CA design](bre_ca_ingestion_dashboard_design.md) defines the shared metrics, filters, visualizations and layout. CA data review is deferred until the tables are fully populated; EU data correctness has not been assessed here.

The EU copy preserves the last seven completed days default, Sunday weekly grouping, separate Pilot ID and Pilot Name controls, dynamic File Type values with BILLING/OPOWER shown as Billing, prior equal-length range comparisons for files average/median, and source rank <= 20 for failure reasons. The UUID snapshot responds only to the pilot controls.

No new views, measures, derived tables or PDTs were needed. Shared typed date references from the CA runtime fix also apply to EU.

Validation: the existing dashboard validator now checks both regional definitions for parity, model-specific dashboard includes and filter bindings. All 48 local tile SQL fixtures, two suggestion fixtures and 25 synthetic checks passed, as did the project no-PDT audit. See [validation results](bre_eu_ingestion_validation.json). No warehouse data was read for this change. Native LookML validation and visual review remain with the user in Looker.
