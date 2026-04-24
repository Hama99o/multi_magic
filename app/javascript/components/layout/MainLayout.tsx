import { Outlet } from 'react-router-dom'
import { TopNav } from './TopNav'

export function MainLayout() {
  return (
    <div className="min-h-screen flex flex-col bg-background text-foreground">
      <TopNav />
      <main className="flex-1 container mx-auto px-4 py-6">
        <Outlet />
      </main>
    </div>
  )
}
