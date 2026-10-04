import React, { useState, useMemo } from 'react'
import styled from 'styled-components'
import { Region, NA_DASHBOARDS, REGION_DASHBOARDS, COMMON_FILTERS } from './types'
import { Header } from './components/Header'
import { TabBar } from './components/TabBar'
import { DashboardEmbed } from './components/DashboardEmbed'

const AppWrapper = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100vh;
  background-color: #f8f9fa;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  margin: 0;
  padding: 0;
  overflow: hidden;
`

const REGION_DEFAULT_FILTERS: Record<Region, Record<string, string>> = {
  NA: { 'Pilot ID': '10037', 'Pilot Name': 'PSEG' },
  CA: { 'Pilot ID': '40001', 'Pilot Name': 'HONI' },
  EU: { 'Pilot ID': '20006', 'Pilot Name': 'Repsol' },
}

export const App: React.FC = () => {
  const [currentRegion, setCurrentRegion] = useState<Region>('NA')
  const [currentDashboardId, setCurrentDashboardId] = useState<string>(NA_DASHBOARDS[0].id)
  const [sharedFilters, setSharedFilters] = useState<Record<string, string>>(REGION_DEFAULT_FILTERS.NA)

  // Find the current dashboard metadata
  const activeDashboard = useMemo(() => {
    const list = REGION_DASHBOARDS[currentRegion]
    return list.find((d) => d.id === currentDashboardId) || list[0]
  }, [currentRegion, currentDashboardId])

  const handleRegionChange = (newRegion: Region) => {
    if (newRegion !== currentRegion) {
      setCurrentRegion(newRegion)
      setCurrentDashboardId(REGION_DASHBOARDS[newRegion][0].id)
      setSharedFilters(REGION_DEFAULT_FILTERS[newRegion])
    }
  }

  const filterMapping = activeDashboard.sharedFilterMapping || COMMON_FILTERS
  const dashboardFilters = Object.fromEntries(
    Object.entries(filterMapping)
      .filter(([sharedName]) => sharedFilters[sharedName] !== undefined)
      .map(([sharedName, dashboardName]) => [dashboardName, sharedFilters[sharedName]])
  )

  const handleFiltersChanged = (newFilters: Record<string, string>) => {
    setSharedFilters((prev) => ({
      ...prev,
      ...Object.fromEntries(
        Object.entries(filterMapping)
          .filter(([, dashboardName]) => newFilters[dashboardName] !== undefined)
          .map(([sharedName, dashboardName]) => [sharedName, newFilters[dashboardName]])
      ),
    }))
  }

  return (
    <AppWrapper>
      <Header
        currentRegion={currentRegion}
        activeDashboardTitle={activeDashboard?.label || ''}
      />
      <TabBar
        currentRegion={currentRegion}
        currentDashboardId={currentDashboardId}
        onSelectRegion={handleRegionChange}
        onSelectDashboard={setCurrentDashboardId}
      />
      <DashboardEmbed
        dashboardId={currentDashboardId}
        sharedFilters={dashboardFilters}
        onFiltersChanged={handleFiltersChanged}
      />
    </AppWrapper>
  )
}
