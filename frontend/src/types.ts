export type Region = 'CA' | 'EU'

export interface DashboardDefinition {
  id: string // Model-qualified LookML dashboard ID (e.g. 'bre_ca::bre_ca_disagg')
  slug: string
  label: string
  description: string
  region: Region
}

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
  CA: CA_DASHBOARDS,
  EU: EU_DASHBOARDS,
}
