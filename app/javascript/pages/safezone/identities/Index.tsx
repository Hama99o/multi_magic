import { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { SearchField, SearchFieldGroup, SearchFieldInput, SearchFieldClearButton, SearchFieldSearchIcon, Button } from '@heroui/react'
import { Plus, IdCard } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { identitiesApi } from './api/identities.api'
import { IdentityItem } from './components/IdentityItem'
import { IdentityDrawer } from './components/IdentityDrawer'
import type { Identity } from '@/types/safezone'

export default function IdentitiesIndex() {
  const { t } = useTranslation()
  const [isDrawerOpen, setIsDrawerOpen] = useState(false)
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [selectedIdentity, setSelectedIdentity] = useState<Identity | null>(null)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(search), 400)
    return () => clearTimeout(timer)
  }, [search])

  const { data, isLoading } = useQuery({
    queryKey: ['safezone', 'identities', debouncedSearch],
    queryFn: () => identitiesApi.list({ search: debouncedSearch }),
  })

  const openCreate = () => {
    setSelectedIdentity(null)
    setIsDrawerOpen(true)
  }

  const openView = (identity: Identity) => {
    setSelectedIdentity(identity)
    setIsDrawerOpen(true)
  }

  const handleClose = () => {
    setIsDrawerOpen(false)
    setSelectedIdentity(null)
  }

  const identities = data?.data ?? []

  return (
    <div className="flex flex-col gap-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <IdCard size={20} className="text-primary" />
          <h1 className="text-xl font-semibold">{t('safezone.identities')}</h1>
        </div>
        <Button color="primary" size="sm" onPress={openCreate}>
          <Plus size={16} />
          {t('safezone.addIdentity')}
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
          <SearchFieldInput placeholder={t('safezone.searchIdentities')} />
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
      ) : identities.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-muted-foreground gap-3">
          <IdCard size={40} className="opacity-30" />
          <p className="text-sm">{t('safezone.noItems')}</p>
        </div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {identities.map((identity) => (
            <IdentityItem
              key={identity.id}
              identity={identity}
              onClick={() => openView(identity)}
            />
          ))}
        </div>
      )}

      <IdentityDrawer
        isOpen={isDrawerOpen}
        identity={selectedIdentity}
        onClose={handleClose}
      />
    </div>
  )
}
