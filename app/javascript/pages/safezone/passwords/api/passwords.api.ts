import { http } from '@/services/http.service'
import type { Password, PasswordFormData, PaginatedSafezoneResponse } from '@/types/safezone'

interface FetchParams {
  search?: string
  page?: number
}

interface PasswordsResponse {
  passwords: Password[]
  meta: {
    pagy: { page: number; pages: number }
    total_count: number
  }
}

export const passwordsApi = {
  list: async (params: FetchParams = {}): Promise<PaginatedSafezoneResponse<Password>> => {
    const res = await http.get<PasswordsResponse>('/api/v1/safezone_app/passwords', { params })
    return {
      data: res.data.passwords,
      meta: {
        page: res.data.meta.pagy.page,
        pages: res.data.meta.pagy.pages,
        totalCount: (res.data.meta as any).totalCount,
      },
    }
  },

  create: async (data: PasswordFormData): Promise<Password> => {
    const res = await http.post<Password>('/api/v1/safezone_app/passwords', { password: data })
    return res.data
  },

  update: async (id: number, data: Partial<PasswordFormData>): Promise<Password> => {
    const res = await http.put<Password>(`/api/v1/safezone_app/passwords/${id}`, { password: data })
    return res.data
  },

  destroy: async (id: number): Promise<void> => {
    await http.delete(`/api/v1/safezone_app/passwords/${id}`)
  },
}
