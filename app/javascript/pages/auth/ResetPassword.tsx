import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Button, Card, CardContent, Spinner } from '@heroui/react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { Eye, EyeOff } from 'lucide-react'
import { resetPasswordApi } from '@/apis/auth.api'
import { FormField } from '@/components/ui/FormField'

const schema = z
  .object({
    password: z
      .string()
      .min(8, 'auth.passwordMin')
      .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])/, 'auth.passwordWeak'),
    password_confirmation: z.string().min(1, 'auth.passwordRequired'),
  })
  .refine((d) => d.password === d.password_confirmation, {
    message: 'auth.passwordMismatch',
    path: ['password_confirmation'],
  })

type FormValues = z.infer<typeof schema>

export default function ResetPassword() {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const token = searchParams.get('reset_password_token') || ''
  const [showPass, setShowPass] = useState(false)
  const [loading, setLoading] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({ resolver: zodResolver(schema) })

  const onSubmit = async (data: FormValues) => {
    if (!token) {
      toast.error(t('common.error'))
      return
    }
    setLoading(true)
    try {
      await resetPasswordApi({ password: data.password, token })
      toast.success(t('auth.passwordResetSuccess'))
      navigate('/login')
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
            <h1 className="text-2xl font-bold">{t('auth.resetPassword')}</h1>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
            <FormField
              label={t('auth.password')}
              type={showPass ? 'text' : 'password'}
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
            <FormField
              label={t('auth.confirmPassword')}
              type={showPass ? 'text' : 'password'}
              errorMessage={errors.password_confirmation && t(errors.password_confirmation.message as string)}
              isInvalid={!!errors.password_confirmation}
              fullWidth
              inputProps={register('password_confirmation')}
            />
            <Button type="submit" variant="primary" fullWidth isDisabled={loading}>
              {loading ? <span className="flex items-center gap-2"><Spinner size="sm" />{t('auth.resetPassword')}</span> : t('auth.resetPassword')}
            </Button>
          </form>

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
