import React, { useEffect, useRef, useState, useContext } from 'react'
import styled from 'styled-components'
import { LookerEmbedSDK, LookerEmbedDashboard } from '@looker/embed-sdk'
import { ExtensionContext40 } from '@looker/extension-sdk-react'

interface DashboardEmbedProps {
  dashboardId: string
  sharedFilters: Record<string, string>
  onFiltersChanged: (filters: Record<string, string>) => void
}

const EmbedContainer = styled.div`
  position: relative;
  width: 100%;
  height: calc(100vh - 125px);
  background: #f8f9fa;
  overflow: hidden;

  iframe {
    width: 100%;
    height: 100%;
    border: none;
  }
`

const LoadingOverlay = styled.div<{ $visible: boolean }>`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.75);
  display: ${(props) => (props.$visible ? 'flex' : 'none')};
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 10;
  gap: 12px;
`

const Spinner = styled.div`
  width: 36px;
  height: 36px;
  border: 3px solid #e0e0e0;
  border-top: 3px solid #1a73e8;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;

  @keyframes spin {
    0% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(360deg);
    }
  }
`

const LoadingText = styled.span`
  font-size: 13px;
  color: #5f6368;
  font-weight: 500;
`

let isSdkInitialized = false

export const DashboardEmbed: React.FC<DashboardEmbedProps> = ({
  dashboardId,
  sharedFilters,
  onFiltersChanged,
}) => {
  const containerRef = useRef<HTMLDivElement>(null)
  const dashboardInstanceRef = useRef<LookerEmbedDashboard | null>(null)
  const extensionContext = useContext(ExtensionContext40)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const hostUrl = extensionContext?.extensionSDK?.lookerHostData?.hostUrl

    if (!isSdkInitialized && hostUrl) {
      LookerEmbedSDK.init(hostUrl)
      isSdkInitialized = true
    }

    if (!containerRef.current) return

    setIsLoading(true)
    containerRef.current.innerHTML = '' // Clear existing iframe container

    let activeDashboard: LookerEmbedDashboard | null = null

    try {
      const builder = LookerEmbedSDK.createDashboardWithId(dashboardId)
        .appendTo(containerRef.current)
        .withClassName('looker-embedded-dashboard')

      // Apply any accumulated shared filters
      if (sharedFilters && Object.keys(sharedFilters).length > 0) {
        builder.withFilters(sharedFilters)
      }

      builder
        .on('dashboard:loaded', () => {
          setIsLoading(false)
        })
        .on('dashboard:filters:changed', (event: any) => {
          if (event && event.dashboard && event.dashboard.dashboard_filters) {
            const newFilters: Record<string, string> = {}
            for (const [key, val] of Object.entries(event.dashboard.dashboard_filters)) {
              if (val !== undefined && val !== null) {
                newFilters[key] = String(val)
              }
            }
            onFiltersChanged(newFilters)
          }
        })
        .build()
        .connect()
        .then((dashboard) => {
          activeDashboard = dashboard
          dashboardInstanceRef.current = dashboard
        })
        .catch((error) => {
          console.error('[BRE Portal] Failed to connect embedded dashboard:', error)
          setIsLoading(false)
        })
    } catch (err) {
      console.error('[BRE Portal] Embed creation error:', err)
      setIsLoading(false)
    }

    return () => {
      activeDashboard = null
    }
  }, [dashboardId, extensionContext])

  return (
    <EmbedContainer ref={containerRef}>
      <LoadingOverlay $visible={isLoading}>
        <Spinner />
        <LoadingText>Loading dashboard...</LoadingText>
      </LoadingOverlay>
    </EmbedContainer>
  )
}
