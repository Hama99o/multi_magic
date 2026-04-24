import { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { SearchField, SearchFieldGroup, SearchFieldInput, SearchFieldClearButton, SearchFieldSearchIcon, Button } from '@heroui/react'
import { Plus, Key } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { passwordsApi } from './api/passwords.api'
import { PasswordCard } from './components/PasswordCard'
import { PasswordDrawer } from './components/PasswordDrawer'
import type { Password } from '@/types/safezone'

export default function PasswordsIndex() {
  const { t } = useTranslation()
  const [isDrawerOpen, setIsDrawerOpen] = useState(false)
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [selectedPassword, setSelectedPassword] = useState<Password | null>(null)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(search), 400)
    return () => clearTimeout(timer)
  }, [search])

  const { data, isLoading } = useQuery({
    queryKey: ['safezone', 'passwords', debouncedSearch],
    queryFn: () => passwordsApi.list({ search: debouncedSearch }),
  })

  const openCreate = () => {
    setSelectedPassword(null)
    setIsDrawerOpen(true)
  }

  const openView = (password: Password) => {
    setSelectedPassword(password)
    setIsDrawerOpen(true)
  }

  const handleClose = () => {
    setIsDrawerOpen(false)
    setSelectedPassword(null)
  }

  const passwords = data?.data ?? []

  return (
    <div className="flex flex-col gap-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Key size={20} className="text-primary" />
          <h1 className="text-xl font-semibold">{t('safezone.passwords')}</h1>
        </div>
        <Button color="primary" size="sm" onPress={openCreate}>
          <Plus size={16} />
          {t('safezone.addPassword')}
        </Button>
      </div>

      {/* Search */}
      <SearchField
        value={search}
        onChange={setSearch}
        className="w-full max-w-sm"
      >
        <SearchFieldGroup>
          <SearchFieldSearchIcon />
          <SearchFieldInput placeholder={t('safezone.searchPasswords')} />
          <SearchFieldClearButton />
        </SearchFieldGroup>
      </SearchField>

      {/* List */}
      {isLoading ? (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-20 rounded-xl bg-muted animate-pulse" />
          ))}
        </div>
      ) : passwords.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-muted-foreground gap-3">
          <Key size={40} className="opacity-30" />
          <p className="text-sm">{t('safezone.noItems')}</p>
        </div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {passwords.map((password) => (
            <PasswordCard
              key={password.id}
              password={password}
              onClick={() => openView(password)}
            />
          ))}
        </div>
      )}

      <PasswordDrawer
        isOpen={isDrawerOpen}
        password={selectedPassword}
        onClose={handleClose}
      />
    </div>
  )
}
