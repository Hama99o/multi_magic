import { http } from '@/services/http.service'
import type { PaymentCard, PaymentCardFormData, PaginatedSafezoneResponse } from '@/types/safezone'

interface FetchParams {
  search?: string
  page?: number
}

interface PaymentCardsResponse {
  payment_cards: PaymentCard[]
  meta: {
    pagy: { page: number; pages: number }
    total_count: number
  }
}

export const paymentCardsApi = {
  list: async (params: FetchParams = {}): Promise<PaginatedSafezoneResponse<PaymentCard>> => {
    const res = await http.get<PaymentCardsResponse>('/api/v1/safezone_app/payment_cards', { params })
    return {
      data: (res.data as any).paymentCards,
      meta: {
        page: (res.data as any).meta.pagy.page,
        pages: (res.data as any).meta.pagy.pages,
        totalCount: (res.data as any).meta.totalCount,
      },
    }
  },

  create: async (data: PaymentCardFormData): Promise<PaymentCard> => {
    const res = await http.post<PaymentCard>('/api/v1/safezone_app/payment_cards', { payment_card: data })
    return res.data
  },

  update: async (id: number, data: Partial<PaymentCardFormData>): Promise<PaymentCard> => {
    const res = await http.put<PaymentCard>(`/api/v1/safezone_app/payment_cards/${id}`, { payment_card: data })
    return res.data
  },

  destroy: async (id: number): Promise<void> => {
    await http.delete(`/api/v1/safezone_app/payment_cards/${id}`)
  },
}
