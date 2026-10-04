# BRE Operations Portal

The `bre::bre_portal` Looker extension embeds the dashboards registered in
`src/types.ts`. Regions appear in this order: North America (NA), Canada (CA),
Europe (EU). A new session opens NA Ingestion Governance with PSEG (10037).

NA contains 13 separate tabs, in source-document order:

- Ingestion Governance and Ingestion Queue Metrics
- Aggregation
- Disaggregation Governance and Disaggregation Queue Metrics
- TOU
- Rate Comparison
- Email Governance and Email Queue Metrics
- HER Governance and HER Queue Metrics
- NBI Governance and NBI EMR Metrics

The portal labels and embedded dashboard titles omit source-document numbering
such as 1a/1b. CA retains five dashboards and EU retains three. The dashboard tab
row scrolls horizontally to reach every dashboard on smaller screens.

Within a region, Time Period, Period, Pilot ID, and Pilot Name follow navigation
where the destination dashboard supports them. Queue dashboards receive only
the shared date range; Ingestion Queue Metrics maps it to Queue Time Period.
Dashboard-specific controls, including module, queue, and failure metric, use
the destination dashboard's defaults. Switching regions resets filters to that
region's defaults: NA PSEG (10037), CA HONI (40001), EU Repsol (20006).

## Build and validate

From `frontend/`:

```sh
npm ci
npx tsc --noEmit
npm run build
```

Commit the generated root `bundle.js` with source changes: `manifest.lkml` loads
this file. Local development can use the commented localhost URL in the
manifest with `npm start`.

After pulling the branch into Looker, validate LookML and open the extension in
development mode. Check NA → CA → EU ordering, all dashboard tabs, pilot/date
handoffs, and queue controls. Production visibility follows the project's usual
Looker deployment process; pushing a branch alone does not deploy production.

The NA integration was checked locally on 2026-10-04 with TypeScript, a production
build, and headless Chromium using the real portal components with a mocked
Looker Embed SDK. All 21 dashboard routes matched repository IDs and supported
filter names. Checks covered NA-first startup, region resets, date/pilot
handoffs, the queue date alias, ignored events from removed iframes, and tab
access at 1440, 1024, and 390 pixels. No browser errors were recorded. Authenticated
Looker embeds and native LookML validation still require the web UI check above.
