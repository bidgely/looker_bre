import React from 'react'
import styled from 'styled-components'
import { Region } from '../types'

interface HeaderProps {
  currentRegion: Region
  activeDashboardTitle: string
}

const HeaderContainer = styled.header`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 24px;
  background: #ffffff;
  border-bottom: 1px solid #e0e6ed;
`

const TitleGroup = styled.div`
  display: flex;
  align-items: center;
  gap: 12px;
`

const LogoIcon = styled.div`
  width: 32px;
  height: 32px;
  border-radius: 6px;
  background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  font-weight: 700;
  font-size: 15px;
  box-shadow: 0 2px 4px rgba(26, 115, 232, 0.25);
`

const MainTitle = styled.h1`
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #202124;
  letter-spacing: -0.2px;
`

const SubTitle = styled.span`
  font-size: 13px;
  color: #5f6368;
  margin-left: 8px;
  padding-left: 8px;
  border-left: 1px solid #dadce0;
`

const Badge = styled.span<{ region: Region }>`
  font-size: 12px;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 12px;
  background-color: ${(props) => (props.region === 'CA' ? '#e8f0fe' : '#e6f4ea')};
  color: ${(props) => (props.region === 'CA' ? '#1a73e8' : '#137333')};
  border: 1px solid ${(props) => (props.region === 'CA' ? '#d2e3fc' : '#ceead6')};
`

export const Header: React.FC<HeaderProps> = ({ currentRegion, activeDashboardTitle }) => {
  return (
    <HeaderContainer>
      <TitleGroup>
        <LogoIcon>B</LogoIcon>
        <div>
          <MainTitle>
            BRE Operations Portal
            <SubTitle>{activeDashboardTitle}</SubTitle>
          </MainTitle>
        </div>
      </TitleGroup>
      <Badge region={currentRegion}>
        {currentRegion === 'CA' ? '🇨🇦 Canada Cluster (CA)' : '🇪🇺 Europe Cluster (EU)'}
      </Badge>
    </HeaderContainer>
  )
}
