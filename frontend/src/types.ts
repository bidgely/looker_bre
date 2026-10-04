export type Region = 'NA' | 'CA' | 'EU'

export const REGIONS: { id: Region; label: string; icon: string }[] = [
  { id: 'NA', label: 'North America (NA)', icon: '🌎' },
  { id: 'CA', label: 'Canada (CA)', icon: '🇨🇦' },
  { id: 'EU', label: 'Europe (EU)', icon: '🇪🇺' },
]

// Map shared portal filters to the controls available on each dashboard.
export const COMMON_FILTERS: Record<string, string> = {
  'Time Period': 'Time Period',
  Period: 'Period',
  'Pilot ID': 'Pilot ID',
  'Pilot Name': 'Pilot Name',
}

export const NA_DASHBOARD_GROUPS = [
  { id: 'ingestion', label: 'Ingestion' },
  { id: 'aggregation', label: 'Aggregation' },
  { id: 'disaggregation', label: 'Disaggregation' },
  { id: 'tou', label: 'TOU' },
  { id: 'rate-comparison', label: 'Rate Comparison' },
  { id: 'email', label: 'Email' },
  { id: 'her', label: 'HER' },
  { id: 'nbi', label: 'NBI' },
] as const

type NADashboardGroup = typeof NA_DASHBOARD_GROUPS[number]['id']

export interface DashboardDefinition {
  id: string // Model-qualified LookML dashboard ID (e.g. 'bre_ca::bre_ca_disagg')
  slug: string
  label: string
  description: string
  region: Region
  group?: NADashboardGroup
  subTabLabel?: string
  sharedFilterMapping?: Record<string, string>
}

export const NA_DASHBOARDS: DashboardDefinition[] = [
  {
    id: 'bre_na::bre_na_ingestion_governance',
    slug: 'ingestion-governance',
    group: 'ingestion',
    subTabLabel: 'Governance',
    label: 'Ingestion Governance',
    description: 'NA Ingestion Governance',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_ingestion_queue_metrics',
    slug: 'ingestion-queue-metrics',
    group: 'ingestion',
    subTabLabel: 'Queue Metrics',
    label: 'Ingestion Queue Metrics',
    description: 'NA Ingestion Queue Metrics',
    region: 'NA',
    sharedFilterMapping: { 'Time Period': 'Queue Time Period' },
  },
  {
    id: 'bre_na::bre_na_aggregation',
    slug: 'aggregation',
    group: 'aggregation',
    label: 'Aggregation',
    description: 'NA Aggregation',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_disaggregation_governance',
    slug: 'disaggregation-governance',
    group: 'disaggregation',
    subTabLabel: 'Governance',
    label: 'Disaggregation Governance',
    description: 'NA Disaggregation Governance',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_disaggregation_queue_metrics',
    slug: 'disaggregation-queue-metrics',
    group: 'disaggregation',
    subTabLabel: 'Queue Metrics',
    label: 'Disaggregation Queue Metrics',
    description: 'NA Disaggregation Queue Metrics',
    region: 'NA',
    sharedFilterMapping: { 'Time Period': 'Time Period' },
  },
  {
    id: 'bre_na::bre_na_tou',
    slug: 'tou',
    group: 'tou',
    label: 'TOU',
    description: 'NA TOU',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_rate_comparison',
    slug: 'rate-comparison',
    group: 'rate-comparison',
    label: 'Rate Comparison',
    description: 'NA Rate Comparison',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_email_governance',
    slug: 'email-governance',
    group: 'email',
    subTabLabel: 'Governance',
    label: 'Email Governance',
    description: 'NA Email Governance',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_email_queue_metrics',
    slug: 'email-queue-metrics',
    group: 'email',
    subTabLabel: 'Queue Metrics',
    label: 'Email Queue Metrics',
    description: 'NA Email Queue Metrics',
    region: 'NA',
    sharedFilterMapping: { 'Time Period': 'Time Period' },
  },
  {
    id: 'bre_na::bre_na_her_governance',
    slug: 'her-governance',
    group: 'her',
    subTabLabel: 'Governance',
    label: 'HER Governance',
    description: 'NA HER Governance',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_her_queue_metrics',
    slug: 'her-queue-metrics',
    group: 'her',
    subTabLabel: 'Queue Metrics',
    label: 'HER Queue Metrics',
    description: 'NA HER Queue Metrics',
    region: 'NA',
    sharedFilterMapping: { 'Time Period': 'Time Period' },
  },
  {
    id: 'bre_na::bre_na_nbi_governance',
    slug: 'nbi-governance',
    group: 'nbi',
    subTabLabel: 'Governance',
    label: 'NBI Governance',
    description: 'NA NBI Governance',
    region: 'NA',
  },
  {
    id: 'bre_na::bre_na_nbi_emr_metrics',
    slug: 'nbi-emr-metrics',
    group: 'nbi',
    subTabLabel: 'EMR Metrics',
    label: 'NBI EMR Metrics',
    description: 'NA NBI EMR Metrics',
    region: 'NA',
  },
]

export const CA_DASHBOARDS: DashboardDefinition[] = [
  {
    id: 'bre_ca::bre_ca_disagg',
    slug: 'disagg',
    label: 'Disaggregation',
    description: 'CA disaggregation monitoring',
    region: 'CA',
  },
  {
    id: 'bre_ca::bre_ca_email',
    slug: 'email',
    label: 'Email Delivery',
    description: 'CA email delivery & statistics monitoring',
    region: 'CA',
  },
  {
    id: 'bre_ca::bre_ca_her',
    slug: 'her',
    label: 'HER',
    description: 'CA Home Energy Report generation & schedules',
    region: 'CA',
  },
  {
    id: 'bre_ca::bre_ca_ingestion',
    slug: 'ingestion',
    label: 'Ingestion',
    description: 'CA ingestion audit & failure tracking',
    region: 'CA',
  },
  {
    id: 'bre_ca::bre_ca_nbi',
    slug: 'nbi',
    label: 'NBI',
    description: 'CA Next Best Action & generic tags',
    region: 'CA',
  },
]

export const EU_DASHBOARDS: DashboardDefinition[] = [
  {
    id: 'bre_eu::bre_eu_disagg',
    slug: 'disagg',
    label: 'Disaggregation',
    description: 'EU disaggregation monitoring',
    region: 'EU',
  },
  {
    id: 'bre_eu::bre_eu_email',
    slug: 'email',
    label: 'Email Delivery',
    description: 'EU email delivery & statistics monitoring',
    region: 'EU',
  },
  {
    id: 'bre_eu::bre_eu_ingestion',
    slug: 'ingestion',
    label: 'Ingestion',
    description: 'EU ingestion audit & failure tracking',
    region: 'EU',
  },
]

export const REGION_DASHBOARDS: Record<Region, DashboardDefinition[]> = {
  NA: NA_DASHBOARDS,
  CA: CA_DASHBOARDS,
  EU: EU_DASHBOARDS,
}
