import React, { useState, useMemo } from 'react'
import styled from 'styled-components'
import { Region, CA_DASHBOARDS, REGION_DASHBOARDS } from './types'
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

export const App: React.FC = () => {
  const [currentRegion, setCurrentRegion] = useState<Region>('CA')
  const [currentDashboardId, setCurrentDashboardId] = useState<string>(CA_DASHBOARDS[0].id)
  const [sharedFilters, setSharedFilters] = useState<Record<string, string>>({})

  // Find the current dashboard metadata
  const activeDashboard = useMemo(() => {
    const list = REGION_DASHBOARDS[currentRegion]
    return list.find((d) => d.id === currentDashboardId) || list[0]
  }, [currentRegion, currentDashboardId])

  const handleFiltersChanged = (newFilters: Record<string, string>) => {
    setSharedFilters((prev) => ({
      ...prev,
      ...newFilters,
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
        onSelectRegion={setCurrentRegion}
        onSelectDashboard={setCurrentDashboardId}
      />
      <DashboardEmbed
        dashboardId={currentDashboardId}
        sharedFilters={sharedFilters}
        onFiltersChanged={handleFiltersChanged}
      />
    </AppWrapper>
  )
}
