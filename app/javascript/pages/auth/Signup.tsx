import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import {
  Button,
  Card,
  CardContent,
  Spinner,
  Separator,
  Checkbox,
  CheckboxControl,
  CheckboxContent,
} from '@heroui/react'
import { Link, useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { Eye, EyeOff } from 'lucide-react'
import { useAuth } from '@/contexts/AuthContext'
import { FormField } from '@/components/ui/FormField'

const schema = z
  .object({
    firstname: z.string().min(1, 'auth.firstnameRequired'),
    lastname: z.string().min(1, 'auth.lastnameRequired'),
    email: z.string().min(1, 'auth.emailRequired').email('auth.emailInvalid'),
    password: z
      .string()
      .min(8, 'auth.passwordMin')
      .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])/, 'auth.passwordWeak'),
    password_confirmation: z.string().min(1, 'auth.passwordRequired'),
    agreed_to_terms: z.literal(true, {
      error: () => ({ message: 'auth.termsRequired' }),
    }),
  })
  .refine((d) => d.password === d.password_confirmation, {
    message: 'auth.passwordMismatch',
    path: ['password_confirmation'],
  })

type FormValues = z.infer<typeof schema>

export default function Signup() {
  const { t } = useTranslation()
  const { register: registerAuth } = useAuth()
  const navigate = useNavigate()
  const [showPass, setShowPass] = useState(false)
  const [loading, setLoading] = useState(false)

  const {
    register,
    handleSubmit,
    setValue,
    formState: { errors },
  } = useForm<FormValues>({ resolver: zodResolver(schema) })

  const onSubmit = async (data: FormValues) => {
    setLoading(true)
    try {
      await registerAuth(data)
      toast.success(t('auth.welcomeBack'))
      navigate('/login')
    } catch (err: unknown) {
      const msg =
        (err as { message?: string })?.message || t('common.error')
      toast.error(msg)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background px-4 py-8">
      <Card className="w-full max-w-sm">
        <CardContent className="flex flex-col gap-6 p-8">
          <div className="text-center">
            <h1 className="text-2xl font-bold">{t('auth.joinUs')}</h1>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
            <div className="grid grid-cols-2 gap-3">
              <FormField
                label={t('auth.firstname')}
                errorMessage={errors.firstname && t(errors.firstname.message as string)}
                isInvalid={!!errors.firstname}
                fullWidth
                inputProps={register('firstname')}
              />
              <FormField
                label={t('auth.lastname')}
                errorMessage={errors.lastname && t(errors.lastname.message as string)}
                isInvalid={!!errors.lastname}
                fullWidth
                inputProps={register('lastname')}
              />
            </div>

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

            <div className="flex flex-col gap-1">
              <Checkbox
                onChange={(isSelected) =>
                  setValue('agreed_to_terms', isSelected as true, { shouldValidate: true })
                }
                isInvalid={!!errors.agreed_to_terms}
              >
                <CheckboxControl />
                <CheckboxContent>
                  <span className="text-sm">{t('auth.agreedToTerms')}</span>
                </CheckboxContent>
              </Checkbox>
              {errors.agreed_to_terms && (
                <p className="text-danger text-xs">
                  {t(errors.agreed_to_terms.message as string)}
                </p>
              )}
            </div>

            <Button type="submit" variant="primary" fullWidth isDisabled={loading}>
              {loading ? <span className="flex items-center gap-2"><Spinner size="sm" />{t('auth.createAccount')}</span> : t('auth.createAccount')}
            </Button>
          </form>

          <Separator />

          <p className="text-center text-sm text-foreground-500">
            {t('auth.haveAccount')}{' '}
            <Link to="/login" className="text-primary font-medium hover:underline">
              {t('auth.login')}
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
