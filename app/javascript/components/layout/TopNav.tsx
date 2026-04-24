import {
  Button,
  Dropdown,
  DropdownTrigger,
  DropdownPopover,
  DropdownMenu,
  DropdownItem,
  Avatar,
  AvatarImage,
  AvatarFallback,
  AvatarRoot,
} from '@heroui/react'
import { useTheme } from 'next-themes'
import { useTranslation } from 'react-i18next'
import { Link, useNavigate } from 'react-router-dom'
import { Sun, Moon, Monitor, Languages, LogOut, User } from 'lucide-react'
import { useAuth } from '@/contexts/AuthContext'

const LANGS = [
  { key: 'en', label: 'English' },
  { key: 'fr', label: 'Français' },
]

export function TopNav() {
  const { t, i18n } = useTranslation()
  const { theme, setTheme } = useTheme()
  const { isAuthenticated, currentUser, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = async () => {
    await logout()
    navigate('/login')
  }

  const ThemeIcon = theme === 'dark' ? Moon : theme === 'light' ? Sun : Monitor

  const initials = currentUser
    ? `${currentUser.firstname[0]}${currentUser.lastname[0]}`.toUpperCase()
    : '?'

  return (
    <nav className="sticky top-0 z-50 w-full border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-14 max-w-7xl items-center justify-between px-4">
        {/* Logo */}
        <Link to="/" className="font-bold text-xl text-primary hover:opacity-80 transition-opacity">
          MultiMagic
        </Link>

        {/* Right actions */}
        <div className="flex items-center gap-1">
          {/* Language switcher */}
          <Dropdown>
            <DropdownTrigger
              aria-label={t('nav.language')}
              className="inline-flex h-8 w-8 items-center justify-center rounded-md hover:bg-accent hover:text-accent-foreground"
            >
              <Languages size={18} />
            </DropdownTrigger>
            <DropdownPopover>
              <DropdownMenu
                onAction={(key) => {
                  i18n.changeLanguage(key as string)
                  localStorage.setItem('i18n_lang', key as string)
                }}
              >
                {LANGS.map((lang) => (
                  <DropdownItem id={lang.key} key={lang.key}>
                    {lang.label}
                  </DropdownItem>
                ))}
              </DropdownMenu>
            </DropdownPopover>
          </Dropdown>

          {/* Theme switcher */}
          <Dropdown>
            <DropdownTrigger
              aria-label={t('nav.theme')}
              className="inline-flex h-8 w-8 items-center justify-center rounded-md hover:bg-accent hover:text-accent-foreground"
            >
              <ThemeIcon size={18} />
            </DropdownTrigger>
            <DropdownPopover>
              <DropdownMenu onAction={(key) => setTheme(key as string)}>
                <DropdownItem id="light" key="light">
                  <span className="flex items-center gap-2"><Sun size={14} />{t('nav.light')}</span>
                </DropdownItem>
                <DropdownItem id="dark" key="dark">
                  <span className="flex items-center gap-2"><Moon size={14} />{t('nav.dark')}</span>
                </DropdownItem>
                <DropdownItem id="system" key="system">
                  <span className="flex items-center gap-2"><Monitor size={14} />{t('nav.system')}</span>
                </DropdownItem>
              </DropdownMenu>
            </DropdownPopover>
          </Dropdown>

          {/* Auth */}
          {isAuthenticated ? (
            <Dropdown>
              <DropdownTrigger className="ml-1 rounded-full focus:outline-none focus-visible:ring-2 focus-visible:ring-primary">
                <AvatarRoot className="h-8 w-8 cursor-pointer">
                  {currentUser?.avatar_url ? (
                    <AvatarImage src={currentUser.avatar_url} alt={initials} />
                  ) : null}
                  <AvatarFallback className="text-xs font-medium bg-primary text-primary-foreground">
                    {initials}
                  </AvatarFallback>
                </AvatarRoot>
              </DropdownTrigger>
              <DropdownPopover>
                <DropdownMenu>
                  <DropdownItem id="profile" key="profile" onAction={() => navigate('/profile')}>
                    <span className="flex items-center gap-2"><User size={14} />{t('nav.profile')}</span>
                  </DropdownItem>
                  <DropdownItem id="logout" key="logout" onAction={handleLogout} className="text-danger">
                    <span className="flex items-center gap-2"><LogOut size={14} />{t('auth.logout')}</span>
                  </DropdownItem>
                </DropdownMenu>
              </DropdownPopover>
            </Dropdown>
          ) : (
            <div className="flex items-center gap-2 ml-2">
              <Link to="/login">
                <Button variant="ghost" size="sm">{t('auth.login')}</Button>
              </Link>
              <Link to="/signup">
                <Button variant="primary" size="sm">{t('auth.signup')}</Button>
              </Link>
            </div>
          )}
        </div>
      </div>
    </nav>
  )
}
