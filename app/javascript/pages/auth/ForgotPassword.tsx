import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Button, Card, CardContent, Spinner } from '@heroui/react'
import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { forgotPasswordApi } from '@/apis/auth.api'
import { FormField } from '@/components/ui/FormField'

const schema = z.object({
  email: z.string().min(1, 'auth.emailRequired').email('auth.emailInvalid'),
})

type FormValues = z.infer<typeof schema>

export default function ForgotPassword() {
  const { t } = useTranslation()
  const [loading, setLoading] = useState(false)
  const [sent, setSent] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({ resolver: zodResolver(schema) })

  const onSubmit = async (data: FormValues) => {
    setLoading(true)
    try {
      await forgotPasswordApi(data)
      setSent(true)
      toast.success(t('auth.passwordResetSent'))
    } catch {
      toast.error(t('common.error'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background px-4">
      <Card className="w-full max-w-sm">
        <CardContent className="flex flex-col gap-6 p-8">
          <div className="text-center">
            <h1 className="text-2xl font-bold">{t('auth.forgotPassword')}</h1>
          </div>

          {sent ? (
            <p className="text-center text-success">{t('auth.passwordResetSent')}</p>
          ) : (
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
              <Button type="submit" variant="primary" fullWidth isDisabled={loading}>
                {loading ? <span className="flex items-center gap-2"><Spinner size="sm" />{t('auth.sendResetLink')}</span> : t('auth.sendResetLink')}
              </Button>
            </form>
          )}

          <div className="text-center">
            <Link to="/login" className="text-sm text-primary hover:underline">
              {t('auth.backToLogin')}
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
