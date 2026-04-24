import { useTranslation } from 'react-i18next'
import { Button, Card, CardContent } from '@heroui/react'
import { Link } from 'react-router-dom'
import { ShieldCheck, Zap, LayoutGrid } from 'lucide-react'
import { useAuth } from '@/contexts/AuthContext'

export default function Home() {
  const { t } = useTranslation()
  const { isAuthenticated } = useAuth()

  return (
    <div className="flex flex-col items-center gap-16 py-12">
      {/* Hero */}
      <section className="text-center flex flex-col items-center gap-4 max-w-2xl">
        <h1 className="text-5xl font-extrabold text-primary">{t('home.hero')}</h1>
        <p className="text-xl text-foreground-500">{t('home.heroSub')}</p>
        <div className="flex gap-3 mt-4">
          {!isAuthenticated && (
            <>
              <Link to="/signup">
                <Button variant="primary" size="lg">{t('home.getStarted')}</Button>
              </Link>
              <Link to="/login">
                <Button variant="outline" size="lg">{t('home.learnMore')}</Button>
              </Link>
            </>
          )}
        </div>
      </section>

      {/* Features */}
      <section className="w-full max-w-4xl">
        <h2 className="text-2xl font-bold text-center mb-8">{t('home.features')}</h2>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
          <Card>
            <CardContent className="flex flex-col items-center gap-3 p-6 text-center">
              <ShieldCheck size={36} className="text-primary" />
              <h3 className="font-semibold text-lg">{t('home.featSecure')}</h3>
              <p className="text-foreground-500 text-sm">{t('home.featSecureSub')}</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="flex flex-col items-center gap-3 p-6 text-center">
              <Zap size={36} className="text-warning" />
              <h3 className="font-semibold text-lg">{t('home.featSimple')}</h3>
              <p className="text-foreground-500 text-sm">{t('home.featSimpleSub')}</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="flex flex-col items-center gap-3 p-6 text-center">
              <LayoutGrid size={36} className="text-success" />
              <h3 className="font-semibold text-lg">{t('home.featAll')}</h3>
              <p className="text-foreground-500 text-sm">{t('home.featAllSub')}</p>
            </CardContent>
          </Card>
        </div>
      </section>
    </div>
  )
}
