import { CreditCard, Banknote, Clock } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import type { PaymentCard } from '@/types/safezone'

interface PaymentCardItemProps {
  card: PaymentCard
  onClick: () => void
}

export function PaymentCardItem({ card, onClick }: PaymentCardItemProps) {
  const { t } = useTranslation()
  const isCredit = card.cardType === 'credit_card'
  const maskedNumber = card.cardNumber ? `•••• •••• •••• ${card.cardNumber.slice(-4)}` : '•••• •••• •••• ••••'

  return (
    <button
      onClick={onClick}
      className="w-full text-left rounded-xl border border-border bg-card p-4 hover:border-primary/50 hover:shadow-sm transition-all cursor-pointer group"
    >
      <div className="flex items-center gap-3">
        {/* Card type icon */}
        <div
          className={`shrink-0 w-10 h-10 rounded-lg flex items-center justify-center ${
            isCredit ? 'bg-danger/10 text-danger' : 'bg-success/10 text-success'
          }`}
        >
          {isCredit ? <CreditCard size={18} /> : <Banknote size={18} />}
        </div>

        <div className="flex-1 min-w-0">
          <p className="font-medium text-sm text-foreground truncate group-hover:text-primary transition-colors">
            {card.name}
          </p>
          <p className="text-xs text-muted-foreground font-mono mt-0.5">{maskedNumber}</p>
          <p className="text-xs text-muted-foreground mt-0.5">
            {isCredit ? t('safezone.creditCard') : t('safezone.debitCard')}
            {card.expiryDate && ` · ${t('safezone.expiresAt')}: ${card.expiryDate}`}
          </p>
        </div>

        {card.updatedAt && (
          <div className="shrink-0 flex items-center gap-1 text-xs text-muted-foreground">
            <Clock size={11} />
            <span>{new Date(card.updatedAt).toLocaleDateString(undefined, { month: 'short', year: '2-digit' })}</span>
          </div>
        )}
      </div>
    </button>
  )
}
