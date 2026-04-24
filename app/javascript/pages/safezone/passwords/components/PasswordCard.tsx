import { Key, Globe, Clock } from 'lucide-react'
import type { Password } from '@/types/safezone'

interface PasswordCardProps {
  password: Password
  onClick: () => void
}

export function PasswordCard({ password, onClick }: PasswordCardProps) {
  const lastUpdated = new Date(password.updatedAt).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })

  return (
    <button
      onClick={onClick}
      className="w-full text-left rounded-xl border border-border bg-card p-4 hover:border-primary/50 hover:shadow-sm transition-all cursor-pointer group"
    >
      <div className="flex items-center gap-3">
        {/* Favicon or fallback icon */}
        <div className="shrink-0 w-10 h-10 rounded-lg bg-muted flex items-center justify-center overflow-hidden">
          {password.link ? (
            <img
              src={`https://www.google.com/s2/favicons?domain=${password.link}&sz=50`}
              alt=""
              className="w-7 h-7 object-contain"
              onError={(e) => {
                const target = e.currentTarget
                target.style.display = 'none'
                target.nextElementSibling?.classList.remove('hidden')
              }}
            />
          ) : null}
          <Key
            size={18}
            className={`text-muted-foreground ${password.link ? 'hidden' : ''}`}
          />
        </div>

        <div className="flex-1 min-w-0">
          <p className="font-medium text-sm text-foreground truncate group-hover:text-primary transition-colors">
            {password.title}
          </p>
          {password.username && (
            <p className="text-xs text-muted-foreground truncate mt-0.5">{password.username}</p>
          )}
          {password.link && (
            <div className="flex items-center gap-1 mt-0.5">
              <Globe size={10} className="text-muted-foreground shrink-0" />
              <p className="text-xs text-muted-foreground truncate">{password.link}</p>
            </div>
          )}
        </div>

        <div className="shrink-0 flex items-center gap-1 text-xs text-muted-foreground">
          <Clock size={11} />
          <span>{lastUpdated}</span>
        </div>
      </div>
    </button>
  )
}
