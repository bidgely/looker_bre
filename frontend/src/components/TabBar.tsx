import React from 'react'
import styled from 'styled-components'
import { Region, DashboardDefinition, REGION_DASHBOARDS, REGIONS, NA_DASHBOARD_GROUPS } from '../types'

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
  overflow-x: auto;
  border-bottom: 1px solid #f1f3f4;
`

const RegionTab = styled.button<{ $active: boolean }>`
  flex-shrink: 0;
  white-space: nowrap;
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

const DetailNavRow = styled(SubNavRow)`
  border-top: 1px solid #f1f3f4;
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
  flex-shrink: 0;

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

  const activeGroup = dashboards.find((dash) => dash.id === currentDashboardId)?.group
  const groupDashboards = dashboards.filter((dash) => dash.group === activeGroup)

  const handleRegionClick = (region: Region) => {
    if (region !== currentRegion) {
      onSelectRegion(region)
    }
  }

  return (
    <NavigationContainer aria-label="Dashboard navigation">
      {/* Tier 1: Region Selection */}
      <RegionRow role="group" aria-label="Regions">
        {REGIONS.map((region) => (
          <RegionTab
            key={region.id}
            $active={currentRegion === region.id}
            aria-pressed={currentRegion === region.id}
            onClick={() => handleRegionClick(region.id)}
          >
            <span aria-hidden="true">{region.icon}</span>
            <span>{region.label}</span>
          </RegionTab>
        ))}
      </RegionRow>

      {currentRegion === 'NA' ? (
        <>
          <SubNavRow role="group" aria-label="Dashboard categories">
            {NA_DASHBOARD_GROUPS.map((group) => (
              <DashboardSubTab
                key={group.id}
                $active={activeGroup === group.id}
                aria-pressed={activeGroup === group.id}
                onClick={() => {
                  if (activeGroup !== group.id) {
                    const firstDashboard = dashboards.find((dash) => dash.group === group.id)
                    if (firstDashboard) onSelectDashboard(firstDashboard.id)
                  }
                }}
              >
                {group.label}
              </DashboardSubTab>
            ))}
          </SubNavRow>
          {groupDashboards.length > 1 && (
            <DetailNavRow role="group" aria-label="Dashboards">
              {groupDashboards.map((dash) => (
                <DashboardSubTab
                  key={dash.id}
                  $active={currentDashboardId === dash.id}
                  aria-pressed={currentDashboardId === dash.id}
                  onClick={() => onSelectDashboard(dash.id)}
                  title={dash.description}
                >
                  {dash.subTabLabel}
                </DashboardSubTab>
              ))}
            </DetailNavRow>
          )}
        </>
      ) : (
        <SubNavRow role="group" aria-label="Dashboards">
          {dashboards.map((dash) => (
            <DashboardSubTab
              key={dash.id}
              $active={currentDashboardId === dash.id}
              aria-pressed={currentDashboardId === dash.id}
              onClick={() => onSelectDashboard(dash.id)}
              title={dash.description}
            >
              {dash.label}
            </DashboardSubTab>
          ))}
        </SubNavRow>
      )}
    </NavigationContainer>
  )
}
