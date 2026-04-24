import { useEffect, useState } from 'react'
import { useForm, Controller } from 'react-hook-form'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Button,
  SelectRoot,
  SelectTrigger,
  SelectValue,
  SelectIndicator,
  SelectPopover,
  ListBox,
  ListBoxItem,
} from '@heroui/react'
import { IdCard, Trash2, Pencil, Copy, Check, Calendar } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { SafePanel } from '@/components/ui/SafePanel'
import { identitiesApi } from '../api/identities.api'
import type { Identity, IdentityFormData } from '@/types/safezone'

type PanelMode = 'view' | 'edit' | 'create'

const IDENTITY_TYPES = ['passport', 'national_id', 'drivers_license', 'residence_permit', 'other']

const TYPE_COLORS: Record<string, string> = {
  passport: 'bg-primary/10 text-primary',
  national_id: 'bg-warning/10 text-warning',
  drivers_license: 'bg-success/10 text-success',
  residence_permit: 'bg-secondary/10 text-secondary',
  other: 'bg-muted text-muted-foreground',
}

interface IdentityDrawerProps {
  isOpen: boolean
  identity?: Identity | null
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

export function IdentityDrawer({ isOpen, identity, onClose }: IdentityDrawerProps) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()
  const [mode, setMode] = useState<PanelMode>('view')
  const [confirmDelete, setConfirmDelete] = useState(false)
  const [copiedKey, setCopiedKey] = useState<string | null>(null)

  const { register, handleSubmit, reset, control, formState: { errors } } = useForm<IdentityFormData>()

  const buildValues = () =>
    identity
      ? { type: identity.type, documentNumber: identity.documentNumber, issuedAt: identity.issuedAt, expiresAt: identity.expiresAt, note: identity.note }
      : { type: 'passport', documentNumber: '', issuedAt: '', expiresAt: '', note: '' }

  useEffect(() => {
    if (isOpen) {
      setMode(identity ? 'view' : 'create')
      setConfirmDelete(false)
      setCopiedKey(null)
      reset(buildValues())
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen, identity])

  const copy = (text: string, key: string) => {
    navigator.clipboard.writeText(text).catch(() => {})
    setCopiedKey(key)
    setTimeout(() => setCopiedKey(null), 2000)
  }

  const createMutation = useMutation({
    mutationFn: identitiesApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'identities'] })
      toast.success(t('common.saved'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const updateMutation = useMutation({
    mutationFn: (data: IdentityFormData) => identitiesApi.update(identity!.id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'identities'] })
      toast.success(t('common.saved'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const deleteMutation = useMutation({
    mutationFn: () => identitiesApi.destroy(identity!.id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'identities'] })
      toast.success(t('common.deleted'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const onSubmit = (data: IdentityFormData) => {
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
  const typeColorClass = TYPE_COLORS[identity?.type ?? 'other'] ?? TYPE_COLORS['other']

  const panelTitle =
    mode === 'view'
      ? (identity ? t(`safezone.identityTypes.${identity.type}`, { defaultValue: identity.type }) : '')
      : mode === 'edit'
        ? t('safezone.editIdentity')
        : t('safezone.addIdentity')

  const footer =
    mode === 'view' ? (
      <div className="flex w-full items-center gap-2">
        {identity && (
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
        <Button variant="primary" size="sm" type="submit" form="identity-form" isDisabled={isPending}>
          {t('common.save')}
        </Button>
      </div>
    )

  return (
    <SafePanel isOpen={isOpen} onClose={onClose} title={panelTitle} footer={footer}>
      {/* ── VIEW MODE ── */}
      {mode === 'view' && identity && (
        <div className="flex flex-col">
          <div className="flex items-center gap-3 pb-4 mb-1 border-b border-border">
            <div className={`shrink-0 w-11 h-11 rounded-xl flex items-center justify-center ${typeColorClass}`}>
              <IdCard size={20} />
            </div>
            <div>
              <h3 className="font-semibold text-foreground">
                {t(`safezone.identityTypes.${identity.type}`, { defaultValue: identity.type })}
              </h3>
              <p className="text-xs text-muted-foreground">{t('safezone.identities')}</p>
            </div>
          </div>

          {!!identity.documentNumber && (
            <ViewRow
              label={t('safezone.documentNumber')}
              value={identity.documentNumber}
              onCopy={() => copy(identity.documentNumber, 'documentNumber')}
              copied={copiedKey === 'documentNumber'}
            />
          )}

          {!!identity.issuedAt && (
            <ViewRow label={t('safezone.issuedAt')} value="">
              <div className="flex items-center gap-2">
                <Calendar size={13} className="text-muted-foreground shrink-0" />
                <span className="text-sm text-foreground">
                  {new Date(identity.issuedAt).toLocaleDateString()}
                </span>
              </div>
            </ViewRow>
          )}

          {!!identity.expiresAt && (
            <ViewRow label={t('safezone.expiresAt')} value="">
              <div className="flex items-center gap-2">
                <Calendar size={13} className="text-muted-foreground shrink-0" />
                <span className="text-sm text-foreground">
                  {new Date(identity.expiresAt).toLocaleDateString()}
                </span>
              </div>
            </ViewRow>
          )}

          {!!identity.note && <ViewRow label={t('common.note')} value={identity.note} />}

          <p className="text-xs text-muted-foreground pt-4">
            {t('common.updated')}: {new Date(identity.updatedAt).toLocaleDateString()}
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
      <form id="identity-form" autoComplete="off" onSubmit={handleSubmit(onSubmit)} className={`flex-col gap-4 ${mode === 'view' ? 'hidden' : 'flex'}`}>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('safezone.identityType')}</label>
            <Controller
              name="type"
              control={control}
              render={({ field }) => (
                <SelectRoot
                  selectedKey={field.value}
                  onSelectionChange={(key) => field.onChange(key)}
                >
                  <SelectTrigger className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none focus:border-primary focus:ring-2 focus:ring-primary/20">
                    <SelectValue />
                    <SelectIndicator />
                  </SelectTrigger>
                  <SelectPopover>
                    <ListBox>
                      {IDENTITY_TYPES.map((type) => (
                        <ListBoxItem key={type} id={type}>
                          {t(`safezone.identityTypes.${type}`, { defaultValue: type })}
                        </ListBoxItem>
                      ))}
                    </ListBox>
                  </SelectPopover>
                </SelectRoot>
              )}
            />
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('safezone.documentNumber')} <span className="text-danger">*</span></label>
            <input
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              autoComplete="off"
              {...register('documentNumber', { required: t('common.required') })}
            />
            {errors.documentNumber && <span className="text-xs text-danger">{errors.documentNumber.message}</span>}
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="flex flex-col gap-1">
              <label className="text-sm font-medium text-foreground">{t('safezone.issuedAt')}</label>
              <input
                type="date"
                className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
                {...register('issuedAt')}
              />
            </div>
            <div className="flex flex-col gap-1">
              <label className="text-sm font-medium text-foreground">{t('safezone.expiresAt')}</label>
              <input
                type="date"
                className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
                {...register('expiresAt')}
              />
            </div>
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
