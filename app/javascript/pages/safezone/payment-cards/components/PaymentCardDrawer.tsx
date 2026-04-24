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
import { CreditCard, Banknote, Trash2, Pencil, Copy, Check, Eye, EyeOff } from 'lucide-react'
import { useTranslation } from 'react-i18next'
import { toast } from 'sonner'
import { SafePanel } from '@/components/ui/SafePanel'
import { paymentCardsApi } from '../api/payment-cards.api'
import type { PaymentCard, PaymentCardFormData } from '@/types/safezone'

type PanelMode = 'view' | 'edit' | 'create'

interface PaymentCardDrawerProps {
  isOpen: boolean
  card?: PaymentCard | null
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

export function PaymentCardDrawer({ isOpen, card, onClose }: PaymentCardDrawerProps) {
  const { t } = useTranslation()
  const queryClient = useQueryClient()
  const [mode, setMode] = useState<PanelMode>('view')
  const [confirmDelete, setConfirmDelete] = useState(false)
  const [showCvv, setShowCvv] = useState(false)
  const [copiedKey, setCopiedKey] = useState<string | null>(null)

  const { register, handleSubmit, reset, control, formState: { errors } } = useForm<PaymentCardFormData>()

  const buildValues = () =>
    card
      ? { name: card.name, cardType: card.cardType, cardNumber: card.cardNumber, cvv: card.cvv, expiryDate: card.expiryDate, code: card.code, status: card.status, note: card.note }
      : { name: '', cardType: 'credit_card', cardNumber: '', cvv: '', expiryDate: '', code: '', status: '', note: '' }

  useEffect(() => {
    if (isOpen) {
      setMode(card ? 'view' : 'create')
      setConfirmDelete(false)
      setShowCvv(false)
      setCopiedKey(null)
      reset(buildValues())
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen, card])

  const copy = (text: string, key: string) => {
    navigator.clipboard.writeText(text).catch(() => {})
    setCopiedKey(key)
    setTimeout(() => setCopiedKey(null), 2000)
  }

  const createMutation = useMutation({
    mutationFn: paymentCardsApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'payment-cards'] })
      toast.success(t('common.saved'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const updateMutation = useMutation({
    mutationFn: (data: PaymentCardFormData) => paymentCardsApi.update(card!.id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'payment-cards'] })
      toast.success(t('common.saved'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const deleteMutation = useMutation({
    mutationFn: () => paymentCardsApi.destroy(card!.id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['safezone', 'payment-cards'] })
      toast.success(t('common.deleted'))
      onClose()
    },
    onError: () => toast.error(t('common.error')),
  })

  const onSubmit = (data: PaymentCardFormData) => {
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

  const isCredit = card?.cardType === 'credit_card'
  const last4 = card?.cardNumber?.slice(-4) ?? ''
  const maskedNumber = card?.cardNumber ? `•••• •••• •••• ${last4}` : ''

  const panelTitle =
    mode === 'view'
      ? (card?.name ?? '')
      : mode === 'edit'
        ? t('safezone.editCard')
        : t('safezone.addCard')

  const footer =
    mode === 'view' ? (
      <div className="flex w-full items-center gap-2">
        {card && (
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
        <Button variant="primary" size="sm" type="submit" form="card-form" isDisabled={isPending}>
          {t('common.save')}
        </Button>
      </div>
    )

  return (
    <SafePanel isOpen={isOpen} onClose={onClose} title={panelTitle} footer={footer}>
      {/* ── VIEW MODE ── */}
      {mode === 'view' && card && (
        <div className="flex flex-col">
          <div className="flex items-center gap-3 pb-4 mb-1 border-b border-border">
            <div className={`shrink-0 w-11 h-11 rounded-xl flex items-center justify-center ${isCredit ? 'bg-danger/10' : 'bg-success/10'}`}>
              {isCredit
                ? <CreditCard size={20} className="text-danger" />
                : <Banknote size={20} className="text-success" />
              }
            </div>
            <div>
              <h3 className="font-semibold text-foreground">{card.name}</h3>
              <p className="text-xs text-muted-foreground">
                {isCredit ? t('safezone.creditCard') : t('safezone.debitCard')}
              </p>
            </div>
          </div>

          {!!card.cardNumber && (
            <ViewRow
              label={t('safezone.cardNumber')}
              value=""
              onCopy={() => copy(card.cardNumber, 'cardNumber')}
              copied={copiedKey === 'cardNumber'}
            >
              <p className="text-sm font-mono text-foreground">{maskedNumber}</p>
            </ViewRow>
          )}

          {!!card.cvv && (
            <ViewRow
              label={t('safezone.cvv')}
              value=""
              onCopy={() => copy(card.cvv, 'cvv')}
              copied={copiedKey === 'cvv'}
            >
              <div className="flex items-center gap-2">
                <span className="text-sm font-mono text-foreground">
                  {showCvv ? card.cvv : '•••'}
                </span>
                <button
                  type="button"
                  onClick={() => setShowCvv((v) => !v)}
                  className="text-muted-foreground hover:text-foreground transition-colors"
                >
                  {showCvv ? <EyeOff size={13} /> : <Eye size={13} />}
                </button>
              </div>
            </ViewRow>
          )}

          {!!card.expiryDate && (
            <ViewRow label={t('safezone.expiryDate')} value={card.expiryDate} />
          )}
          {!!card.code && (
            <ViewRow
              label={t('safezone.billingCode')}
              value={card.code}
              onCopy={() => copy(card.code, 'code')}
              copied={copiedKey === 'code'}
            />
          )}
          {!!card.note && <ViewRow label={t('common.note')} value={card.note} />}

          <p className="text-xs text-muted-foreground pt-4">
            {t('common.updated')}: {new Date(card.updatedAt).toLocaleDateString()}
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
      <form id="card-form" autoComplete="off" onSubmit={handleSubmit(onSubmit)} className={`flex-col gap-4 ${mode === 'view' ? 'hidden' : 'flex'}`}>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('common.name')} <span className="text-danger">*</span></label>
            <input
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              autoComplete="off"
              {...register('name', { required: t('common.required') })}
            />
            {errors.name && <span className="text-xs text-danger">{errors.name.message}</span>}
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('safezone.cardType')}</label>
            <Controller
              name="cardType"
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
                      <ListBoxItem id="credit_card">{t('safezone.creditCard')}</ListBoxItem>
                      <ListBoxItem id="debit_card">{t('safezone.debitCard')}</ListBoxItem>
                    </ListBox>
                  </SelectPopover>
                </SelectRoot>
              )}
            />
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('safezone.cardNumber')}</label>
            <input
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition font-mono placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              autoComplete="cc-number"
              maxLength={19}
              {...register('cardNumber')}
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div className="flex flex-col gap-1">
              <label className="text-sm font-medium text-foreground">{t('safezone.cvv')}</label>
              <input
                className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition font-mono placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
                autoComplete="off"
                maxLength={4}
                {...register('cvv')}
              />
            </div>
            <div className="flex flex-col gap-1">
              <label className="text-sm font-medium text-foreground">{t('safezone.expiryDate')}</label>
              <input
                placeholder="MM/YY"
                className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
                autoComplete="off"
                {...register('expiryDate')}
              />
            </div>
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-sm font-medium text-foreground">{t('safezone.billingCode')}</label>
            <input
              className="w-full rounded-lg border border-border bg-background px-3 py-2 text-sm outline-none transition placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/20"
              autoComplete="off"
              {...register('code')}
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
