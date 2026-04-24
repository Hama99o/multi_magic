import { IdCard, Calendar } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import type { Identity } from '@/types/safezone'

const typeColors: Record<string, string> = {
  passport: 'bg-primary/10 text-primary',
  national_id: 'bg-warning/10 text-warning',
  drivers_license: 'bg-success/10 text-success',
  residence_permit: 'bg-secondary/10 text-secondary',
}

interface IdentityItemProps {
  identity: Identity
  onClick: () => void
}

export function IdentityItem({ identity, onClick }: IdentityItemProps) {
  const { t } = useTranslation()
  const colorClass = typeColors[identity.type] ?? 'bg-muted text-muted-foreground'
  const typeLabel = t(`safezone.identityTypes.${identity.type}`, { defaultValue: identity.type })

  return (
    <button
      onClick={onClick}
      className="w-full text-left rounded-xl border border-border bg-card p-4 hover:border-primary/50 hover:shadow-sm transition-all cursor-pointer group"
    >
      <div className="flex items-center gap-3">
        {/* Type icon */}
        <div className={`shrink-0 w-10 h-10 rounded-lg flex items-center justify-center ${colorClass}`}>
          <IdCard size={18} />
        </div>

        <div className="flex-1 min-w-0">
          <p className="font-medium text-sm text-foreground truncate group-hover:text-primary transition-colors">
            {identity.documentNumber}
          </p>
          <p className="text-xs text-muted-foreground mt-0.5">{typeLabel}</p>
        </div>

        {identity.expiresAt && (
          <div className="shrink-0 flex flex-col items-end gap-0.5">
            <div className="flex items-center gap-1 text-xs text-muted-foreground">
              <Calendar size={11} />
              <span>
                {new Date(identity.expiresAt).toLocaleDateString(undefined, {
                  month: 'short',
                  year: 'numeric',
                })}
              </span>
            </div>
          </div>
        )}
      </div>
    </button>
  )
}
