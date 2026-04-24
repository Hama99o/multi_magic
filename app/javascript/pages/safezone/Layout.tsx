import { NavLink, Outlet } from 'react-router-dom'
import { Shield, Key, CreditCard, IdCard } from 'lucide-react'
import { useTranslation } from 'react-i18next'

const navItems = [
  { path: 'passwords', labelKey: 'safezone.passwords', icon: Key },
  { path: 'payment-cards', labelKey: 'safezone.paymentCards', icon: CreditCard },
  { path: 'identities', labelKey: 'safezone.identities', icon: IdCard },
]

export default function SafezoneLayout() {
  const { t } = useTranslation()

  return (
    <div className="flex min-h-[calc(100vh-4rem)]">
      {/* Sidebar */}
      <aside className="w-56 shrink-0 border-r border-border bg-card hidden md:flex flex-col p-3 gap-1">
        <div className="flex items-center gap-2 px-3 py-2 mb-2">
          <Shield size={18} className="text-primary" />
          <span className="font-semibold text-sm">{t('safezone.title')}</span>
        </div>
        {navItems.map(({ path, labelKey, icon: Icon }) => (
          <NavLink
            key={path}
            to={path}
            className={({ isActive }) =>
              `flex items-center gap-2.5 px-3 py-2 rounded-md text-sm transition-colors ${
                isActive
                  ? 'bg-primary/10 text-primary font-medium'
                  : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
              }`
            }
          >
            <Icon size={16} />
            {t(labelKey)}
          </NavLink>
        ))}
      </aside>

      {/* Mobile bottom nav */}
      <nav className="fixed bottom-0 inset-x-0 z-40 border-t border-border bg-card flex md:hidden">
        {navItems.map(({ path, labelKey, icon: Icon }) => (
          <NavLink
            key={path}
            to={path}
            className={({ isActive }) =>
              `flex flex-1 flex-col items-center gap-0.5 py-2.5 text-xs transition-colors ${
                isActive ? 'text-primary' : 'text-muted-foreground'
              }`
            }
          >
            <Icon size={20} />
            <span>{t(labelKey)}</span>
          </NavLink>
        ))}
      </nav>

      {/* Main content */}
      <main className="flex-1 overflow-auto p-4 md:p-6 pb-20 md:pb-6">
        <Outlet />
      </main>
    </div>
  )
}
