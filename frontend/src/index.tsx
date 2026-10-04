import React from 'react'
import ReactDOM from 'react-dom'
import { ExtensionProvider40 } from '@looker/extension-sdk-react'
import { ComponentsProvider } from '@looker/components'
import { App } from './App'

const renderApp = () => {
  let root = document.getElementById('root')
  if (!root) {
    root = document.createElement('div')
    root.id = 'root'
    document.body.appendChild(root)
  }

  // Ensure body and html take 100% height without default margins
  document.documentElement.style.height = '100%'
  document.body.style.height = '100%'
  document.body.style.margin = '0'
  document.body.style.padding = '0'

  ReactDOM.render(
    <ExtensionProvider40>
      <ComponentsProvider>
        <App />
      </ComponentsProvider>
    </ExtensionProvider40>,
    root
  )
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', renderApp)
} else {
  renderApp()
}
