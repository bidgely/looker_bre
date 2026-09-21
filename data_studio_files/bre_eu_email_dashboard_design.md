# EU Email dashboard

Implemented on 2026-09-13 at the user's request, matching the current [CA Email dashboard](bre_ca_email_dashboard_design.md). Native Looker validation and dashboard execution remain for user review.

[bre_eu_email.dashboard.lookml](../dashboards/bre_eu_email.dashboard.lookml) is included only in model `bre_eu`, using `starburst_prod_eu`. The existing shared source views and dropdown helpers route to `delta_prodeu`. No new views, derived tables or PDTs are introduced; the model retains its 12-hour query cache.

All eight tiles and six controls match CA. Only dashboard identifiers, model references and regional titles/descriptions differ.

- Active UUID has no dashboard filter listeners, including pilot filters.
- Email count Average/Median compare with the preceding equal-length date range using reporting dates.
- Sent % scorecards use average source-row percentages without comparisons.
- Email Delivery Statistics retains the full outer join on email type and analysis date, eight series, and analysis-date filtering in both sources. BC End Week# filters its five Statistics series before aggregation; its three Daily Tracker series are unaffected by that control.
- Reco Quality uses average notification percentage by metric name. Failure Reasons uses average failure count by reason and source rank <= 3. Both filter reporting dates and group analysis dates by Period.
- Email Type suggestions come from EU Daily Tracker; BC End Week# suggestions come from EU Email Statistics. Date defaults remain Last 7 completed days, with Daily, Sunday-start Weekly and Monthly grouping.

`scripts/validate_bre_email_dashboard.py` checks parsed CA/EU dashboard parity, regional model connections/includes, field exposure and dropdown helpers. Existing rendered Trino SQL and synthetic checks cover both regional source paths. Evidence is recorded in [bre_eu_email_validation.json](bre_eu_email_validation.json). These local checks do not replace native Looker validation or live Trino execution. No warehouse data was read.

Data validation and the deferred EU pilot-dropdown investigation remain in the separate readiness-dependent stages of the [migration plan](bre_dashboard_migration_plan.md).
