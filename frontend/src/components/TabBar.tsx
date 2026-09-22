import React from 'react'
import styled from 'styled-components'
import { Region, DashboardDefinition, REGION_DASHBOARDS } from '../types'

interface TabBarProps {
  currentRegion: Region
  currentDashboardId: string
  onSelectRegion: (region: Region) => void
  onSelectDashboard: (dashboardId: string) => void
}

const NavigationContainer = styled.nav`
  background: #ffffff;
  border-bottom: 1px solid #dadce0;
  padding: 0 24px;
`

const RegionRow = styled.div`
  display: flex;
  gap: 16px;
  padding-top: 8px;
  border-bottom: 1px solid #f1f3f4;
`

const RegionTab = styled.button<{ $active: boolean }>`
  background: none;
  border: none;
  padding: 10px 16px;
  font-size: 14px;
  font-weight: ${(props) => (props.$active ? '600' : '500')};
  color: ${(props) => (props.$active ? '#1a73e8' : '#5f6368')};
  border-bottom: 3px solid ${(props) => (props.$active ? '#1a73e8' : 'transparent')};
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.15s ease-in-out;

  &:hover {
    color: #1a73e8;
  }
`

const SubNavRow = styled.div`
  display: flex;
  gap: 8px;
  padding: 8px 0;
  overflow-x: auto;
`

const DashboardSubTab = styled.button<{ $active: boolean }>`
  background: ${(props) => (props.$active ? '#e8f0fe' : 'transparent')};
  border: 1px solid ${(props) => (props.$active ? '#d2e3fc' : 'transparent')};
  color: ${(props) => (props.$active ? '#1967d2' : '#3c4043')};
  font-weight: ${(props) => (props.$active ? '600' : '400')};
  font-size: 13px;
  padding: 6px 14px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.12s ease-in-out;
  white-space: nowrap;

  &:hover {
    background-color: ${(props) => (props.$active ? '#e8f0fe' : '#f1f3f4')};
  }
`

export const TabBar: React.FC<TabBarProps> = ({
  currentRegion,
  currentDashboardId,
  onSelectRegion,
  onSelectDashboard,
}) => {
  const dashboards: DashboardDefinition[] = REGION_DASHBOARDS[currentRegion]

  const handleRegionClick = (region: Region) => {
    if (region !== currentRegion) {
      onSelectRegion(region)
      // Switch to the first dashboard in the newly selected region
      const targetDashboards = REGION_DASHBOARDS[region]
      if (targetDashboards.length > 0) {
        onSelectDashboard(targetDashboards[0].id)
      }
    }
  }

  return (
    <NavigationContainer>
      {/* Tier 1: Region Selection */}
      <RegionRow>
        <RegionTab
          $active={currentRegion === 'CA'}
          onClick={() => handleRegionClick('CA')}
        >
          <span>🇨🇦</span>
          <span>Canada (CA)</span>
        </RegionTab>
        <RegionTab
          $active={currentRegion === 'EU'}
          onClick={() => handleRegionClick('EU')}
        >
          <span>🇪🇺</span>
          <span>Europe (EU)</span>
        </RegionTab>
      </RegionRow>

      {/* Tier 2: Dashboard Sub-tabs */}
      <SubNavRow>
        {dashboards.map((dash) => (
          <DashboardSubTab
            key={dash.id}
            $active={currentDashboardId === dash.id}
            onClick={() => onSelectDashboard(dash.id)}
            title={dash.description}
          >
            {dash.label}
          </DashboardSubTab>
        ))}
      </SubNavRow>
    </NavigationContainer>
  )
}
