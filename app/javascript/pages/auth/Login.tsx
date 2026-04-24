import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Button, Card, CardContent, Spinner, Separator } from '@heroui/react'
import { Link, useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { Eye, EyeOff } from 'lucide-react'
import { useAuth } from '@/contexts/AuthContext'
import { FormField } from '@/components/ui/FormField'

const schema = z.object({
  email: z.string().min(1, 'auth.emailRequired').email('auth.emailInvalid'),
  password: z.string().min(1, 'auth.passwordRequired'),
})

type FormValues = z.infer<typeof schema>

export default function Login() {
  const { t } = useTranslation()
  const { login } = useAuth()
  const navigate = useNavigate()
  const [showPass, setShowPass] = useState(false)
  const [loading, setLoading] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({ resolver: zodResolver(schema) })

  const onSubmit = async (data: FormValues) => {
    setLoading(true)
    try {
      await login(data)
      const redirect = sessionStorage.getItem('redirectAfterLogin') || '/'
      sessionStorage.removeItem('redirectAfterLogin')
      navigate(redirect, { replace: true })
    } catch {
      toast.error(t('auth.invalidCredentials'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background px-4">
      <Card className="w-full max-w-sm">
        <CardContent className="flex flex-col gap-6 p-8">
          <div className="text-center">
            <h1 className="text-2xl font-bold">{t('auth.welcomeBack')}</h1>
            <p className="text-foreground-500 text-sm mt-1">MultiMagic</p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
            <FormField
              label={t('auth.email')}
              type="email"
              autoComplete="email"
              errorMessage={errors.email && t(errors.email.message as string)}
              isInvalid={!!errors.email}
              fullWidth
              inputProps={register('email')}
            />
            <FormField
              label={t('auth.password')}
              type={showPass ? 'text' : 'password'}
              autoComplete="current-password"
              errorMessage={errors.password && t(errors.password.message as string)}
              isInvalid={!!errors.password}
              fullWidth
              inputProps={register('password')}
              endContent={
                <button type="button" onClick={() => setShowPass((p) => !p)} className="text-foreground-400 hover:text-foreground transition-colors">
                  {showPass ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              }
            />

            <div className="text-right">
              <Link to="/forgot-password" className="text-sm text-primary hover:underline">
                {t('auth.forgotPassword')}
              </Link>
            </div>

            <Button type="submit" variant="primary" fullWidth isDisabled={loading}>
              {loading ? <span className="flex items-center gap-2"><Spinner size="sm" />{t('auth.login')}</span> : t('auth.login')}
            </Button>
          </form>

          <Separator />

          <p className="text-center text-sm text-foreground-500">
            {t('auth.noAccount')}{' '}
            <Link to="/signup" className="text-primary font-medium hover:underline">
              {t('auth.signup')}
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
