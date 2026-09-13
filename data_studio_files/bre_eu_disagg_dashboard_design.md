# EU Disagg dashboard

Status: implemented from the user-approved CA dashboard on 2026-09-13. Local validation passes; EU native LookML validation and dashboard execution remain with the user.

The user accepted CA and requested the same dashboard for EU, satisfying the CA-first delivery gate. [bre_eu_disagg.dashboard.lookml](../dashboards/bre_eu_disagg.dashboard.lookml) is included only in model `bre_eu`, using connection `starburst_prod_eu`. Shared source views route to `delta_prodeu`.

All eight tiles, seven controls, labels, layouts and calculations match the [CA definition](bre_ca_disagg_dashboard_design.md). Only dashboard identifiers, model references and regional titles/descriptions differ.

- Date defaults remain the last seven completed days. The date filter uses reporting_date; chart axes group analysis_date by Daily, Sunday-start Weekly or Monthly.
- Invoice Average/Median retain previous equal-length-period comparisons. Success T-7/T-2 and the invoice/disagg combo reuse the approved shared measures.
- Quality retains its 13 average line series. Failure reasons retain average failure_percentage, failure_reason breakdown and explicit `failure_scope: Top Three` before Period aggregation.
- Meter Type, Fuel Type and Module Name dropdowns use EU Invoice Statistics through the existing `bre_invoice_filters` helper. All three apply to invoice and failure tiles; quality supports Meter/Fuel only. UUID remains a latest-snapshot tile controlled only by Pilot ID and Pilot Name.
- Pilot suggestions use the existing regional pilot helper. The previously deferred EU pilot-dropdown investigation remains in the separate data-validation stage.

No new views, derived tables or PDTs were introduced. The existing model-level 12-hour query cache remains in place.

Validation: `scripts/validate_bre_disagg_dashboard.py` checks CA/EU parity, model routing, model includes, field exposure and dropdown helpers, and renders shared SQL for both catalogs. Evidence is in [bre_eu_disagg_validation.json](bre_eu_disagg_validation.json). Local parsing and synthetic fixtures do not replace native Looker validation or live Trino execution. No warehouse data was queried.

Data correctness remains deferred until the user confirms data transfer and EMR updates, as recorded in the [migration plan](bre_dashboard_migration_plan.md).
