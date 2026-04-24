import { useTranslation } from 'react-i18next'
import { Button } from '@heroui/react'
import { Link } from 'react-router-dom'
import { Home } from 'lucide-react'

export default function NotFound() {
  const { t } = useTranslation()

  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
      <h1 className="text-6xl font-bold text-primary">404</h1>
      <p className="text-xl text-foreground-500">{t('common.noResults')}</p>
      <Link to="/">
        <Button variant="primary">
          <span className="flex items-center gap-2">
            <Home size={18} />{t('nav.home')}
          </span>
        </Button>
      </Link>
    </div>
  )
}
