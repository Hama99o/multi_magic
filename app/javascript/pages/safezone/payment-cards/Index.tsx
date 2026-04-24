import { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { SearchField, SearchFieldGroup, SearchFieldInput, SearchFieldClearButton, SearchFieldSearchIcon, Button } from '@heroui/react'
import { Plus, CreditCard } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { paymentCardsApi } from './api/payment-cards.api'
import { PaymentCardItem } from './components/PaymentCardItem'
import { PaymentCardDrawer } from './components/PaymentCardDrawer'
import type { PaymentCard } from '@/types/safezone'

export default function PaymentCardsIndex() {
  const { t } = useTranslation()
  const [isDrawerOpen, setIsDrawerOpen] = useState(false)
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [selectedCard, setSelectedCard] = useState<PaymentCard | null>(null)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(search), 400)
    return () => clearTimeout(timer)
  }, [search])

  const { data, isLoading } = useQuery({
    queryKey: ['safezone', 'payment-cards', debouncedSearch],
    queryFn: () => paymentCardsApi.list({ search: debouncedSearch }),
  })

  const openCreate = () => {
    setSelectedCard(null)
    setIsDrawerOpen(true)
  }

  const openView = (card: PaymentCard) => {
    setSelectedCard(card)
    setIsDrawerOpen(true)
  }

  const handleClose = () => {
    setIsDrawerOpen(false)
    setSelectedCard(null)
  }

  const cards = data?.data ?? []

  return (
    <div className="flex flex-col gap-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <CreditCard size={20} className="text-primary" />
          <h1 className="text-xl font-semibold">{t('safezone.paymentCards')}</h1>
        </div>
        <Button color="primary" size="sm" onPress={openCreate}>
          <Plus size={16} />
          {t('safezone.addCard')}
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
          <SearchFieldInput placeholder={t('safezone.searchCards')} />
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
      ) : cards.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-muted-foreground gap-3">
          <CreditCard size={40} className="opacity-30" />
          <p className="text-sm">{t('safezone.noItems')}</p>
        </div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {cards.map((card) => (
            <PaymentCardItem
              key={card.id}
              card={card}
              onClick={() => openView(card)}
            />
          ))}
        </div>
      )}

      <PaymentCardDrawer
        isOpen={isDrawerOpen}
        card={selectedCard}
        onClose={handleClose}
      />
    </div>
  )
}
