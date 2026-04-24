import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { Button } from '@heroui/react'
import { Eye, EyeOff, Trash2, Pencil, Globe, Copy, Check, Key } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { SafePanel } from '@/components/ui/SafePanel'
import { passwordsApi } from '../api/passwords.api'
import type { Password, PasswordFormData } from '@/types/safezone'

type PanelMode = 'view' | 'edit' | 'create'

interface PasswordDrawerProps {
  isOpen: boolean
  password?: Password | null
  onClose: () => void
}

interface ViewRowProps {
  label: string
  value: string
  onCopy?: () => void
  copied?: boolean
  children?: React.ReactNode
}

function ViewRow({ label, value, onCopy, copied, children }: ViewRowProps) {
  return (
    <div className="flex items-end justify-between gap-3 py-3 border-b border-border last:border-0">
      <div className="flex-1 min-w-0">
        <p className="text-xs text-muted-foreground mb-1">{label}</p>
        {children ?? <p className="text-sm text-foreground break-all">{value}</p>}
      </div>
      {onCopy && (
        <button
          type="button"
          onClick={onCopy}
          className="shrink-0 text-muted-foreground hover:text-foreground transition-colors"
        >
          {copied ? <Check size={14} className="text-success" /> : <Copy size={14} />}
        </button>
      )}
    </div>
  )
}

export function PasswordDrawer({ isOpen, password, onClose }: PasswordDrawerProps) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()
  const [mode, setMode] = useState<PanelMode>('view')
  const [showPassword, setShowPassword] = useState(false)
  const [confirmDelete, setConfirmDelete] = useState(false)
  const [copiedKey, setCopiedKey] = useState<string | null>(null)

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<PasswordFormData>()

  const buildValues = () =>
    password
      ? { title: password.title, username: password.username, email: password.email, password: password.password, link: password.link, note: password.note }
      : { title: '', username: '', email: '', password: '', link: '', note: '' }

  useEffect(() => {
    if (isOpen) {
      setMode(password ? 'view' : 'create')
      setConfirmDelete(false)
      setShowPassword(false)
      setCopiedKey(null)
      reset(buildValues())
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen, password])

  const copy = (text: string, key: string) => {
    navigator.clipboard.writeText(text).catch(() => {})
    setCopiedKey(key)
    setTimeout(() => setCopiedKey(null), 2000)
  }

  const createMutation = useMutation({
    mutationFn: passwordsApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'passwords'] })
      toast.success(t('common.saved'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const updateMutation = useMutation({
    mutationFn: (data: PasswordFormData) => passwordsApi.update(password!.id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'passwords'] })
      toast.success(t('common.saved'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const deleteMutation = useMutation({
    mutationFn: () => passwordsApi.destroy(password!.id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'passwords'] })
      toast.success(t('common.deleted'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const onSubmit = (data: PasswordFormData) => {
    if (mode === 'edit') {
      updateMutation.mutate(data)
    } else {
      createMutation.mutate(data)
    }
  }

  const switchToEdit = () => {
    reset(buildValues())
    setMode('edit')
  }

  const isPending = createMutation.isPending || updateMutation.isPending

  const panelTitle =
    mode === 'view'
      ? (password?.title ?? '')
      : mode === 'edit'
        ? t('safezone.editPassword')
        : t('safezone.addPassword')

  const footer =
    mode === 'view' ? (
      <div className="flex w-full items-center gap-2">
        {password && (
          <Button variant="danger-soft" size="sm" onPress={() => setConfirmDelete(true)}>
            <Trash2 size={14} />
            {t('common.delete')}
          </Button>
        )}
        <div className="flex gap-2 ml-auto">
          <Button variant="outline" size="sm" onPress={onClose}>
            {t('common.close')}
          </Button>
          <Button variant="primary" size="sm" onPress={switchToEdit}>
            <Pencil size={14} />
            {t('common.edit')}
          </Button>
        </div>
      </div>
    ) : (
      <div className="flex w-full justify-end gap-2">
        <Button
          variant="outline"
          size="sm"
          onPress={mode === 'edit' ? () => setMode('view') : onClose}
        >
          {t('common.cancel')}
        </Button>
        <Button variant="primary" size="sm" type="submit" form="password-form" isDisabled={isPending}>
          {t('common.save')}
        </Button>
      </div>
    )

  return (
    <SafePanel isOpen={isOpen} onClose={onClose} title={panelTitle} footer={footer}>
      {/* ── VIEW MODE ── */}
      {mode === 'view' && password && (
        <div className="flex flex-col">
          <div className="flex items-center gap-3 pb-4 mb-1 border-b border-border">
            <div className="shrink-0 w-11 h-11 rounded-xl bg-primary/10 flex items-center justify-center overflow-hidden">
              {password.link ? (
                <img
                  src={`https://www.google.com/s2/favicons?domain=${password.link}&sz=64`}
                  alt=""
                  className="w-8 h-8 object-contain"
                  onError={(e) => {
                    e.currentTarget.style.display = 'none'
                    const s = e.currentTarget.nextElementSibling
                    if (s instanceof HTMLElement) s.classList.remove('hidden')
                  }}
                />
              ) : null}
              <Key size={20} className={`text-primary ${password.link ? 'hidden' : ''}`} />
            </div>
            <div>
              <h3 className="font-semibold text-foreground">{password.title}</h3>
              <p className="text-xs text-muted-foreground">{t('safezone.passwords')}</p>
            </div>
          </div>

          {!!password.username && (
            <ViewRow
              label={t('safezone.username')}
              value={password.username}
              onCopy={() => copy(password.username, 'username')}
              copied={copiedKey === 'username'}
            />
          )}
          {!!password.email && (
            <ViewRow
              label={t('auth.email')}
              value={password.email}
              onCopy={() => copy(password.email, 'email')}
              copied={copiedKey === 'email'}
            />
          )}
          {!!password.password && (
            <ViewRow
              label={t('auth.password')}
              value=""
              onCopy={() => copy(password.password, 'password')}
              copied={copiedKey === 'password'}
            >
              <div className="flex items-center gap-2">
                <span className="text-sm font-mono text-foreground">
                  {showPassword ? password.password : '••••••••••••'}
                </span>
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="text-muted-foreground hover:text-foreground transition-colors"
                >
                  {showPassword ? <EyeOff size={13} /> : <Eye size={13} />}
                </button>
              </div>
            </ViewRow>
          )}
          {!!password.link && (
            <ViewRow label={t('safezone.link')} value="">
              <div className="flex items-center gap-2">
                <Globe size={12} className="shrink-0 text-muted-foreground" />
                <a
                  href={password.link}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-primary hover:underline break-all"
                >
                  {password.link}
                </a>
              </div>
            </ViewRow>
          )}
          {!!password.note && <ViewRow label={t('common.note')} value={password.note} />}

          <p className="text-xs text-muted-foreground pt-4">
            {t('common.updated')}: {new Date(password.updatedAt).toLocaleDateString()}
          </p>

          {confirmDelete && (
            <div className="mt-4 rounded-lg border border-danger/30 bg-danger/5 p-3">
              <p className="text-sm text-danger mb-3">{t('safezone.deleteConfirm')}</p>
              <div className="flex gap-2">
                <Button
                  size="sm"
                  variant="danger"
                  onPress={() => deleteMutation.mutate()}
                  isDisabled={deleteMutation.isPending}
                >
                  {t('common.delete')}
                </Button>
                <Button size="sm" variant="outline" onPress={() => setConfirmDelete(false)}>
                  {t('common.cancel')}
                </Button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ── EDIT / CREATE MODE ── always mounted so reset() works ── */}
      <form id="password-form" autoComplete="off" onSubmit={handleSubmit(onSubmit)} className={`flex-col gap-4 ${mode === 'view' ? 'hidden' : 'flex'}`}>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('common.title')} <span className="text-danger">*</span></label>
            <input
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              {...register('title', { required: t('common.required') })}
            />
            {errors.title && <span className="text-xs text-danger">{errors.title.message}</span>}
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('safezone.username')}</label>
            <input
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              autoComplete="off"
              {...register('username')}
            />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('auth.email')}</label>
            <input
              type="email"
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              autoComplete="off"
              {...register('email')}
            />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('auth.password')}</label>
            <div className="relative flex items-center">
              <input
                type={showPassword ? 'text' : 'password'}
                className="w-full rounded-lg border border-border bg-background px-3 py-2 pr-10 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
                autoComplete="new-password"
                {...register('password')}
              />
              <button
                type="button"
                onClick={() => setShowPassword((v) => !v)}
                className="absolute right-3 text-muted-foreground hover:text-foreground transition-colors"
              >
                {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('safezone.link')}</label>
            <input
              type="url"
              placeholder="https://"
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              autoComplete="off"
              {...register('link')}
            />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('common.note')}</label>
            <textarea
              rows={3}
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20 resize-none"
              {...register('note')}
            />
          </div>
        </form>
    </SafePanel>
  )
}

