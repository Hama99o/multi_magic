import { createRoot } from 'react-dom/client'
import App from '@/App'
import '@heroui/styles/css'
import '@/index.css'

const container = document.getElementById('app')
if (!container) throw new Error('#app root element not found')

const root = createRoot(container)
root.render(<App />)

// Hide the Rails-rendered loader once React has mounted
const loader = document.getElementById('mainLoader')
if (loader) loader.style.display = 'none'
