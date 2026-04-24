import { http } from '@/services/http.service'
import type { Identity, IdentityFormData, PaginatedSafezoneResponse } from '@/types/safezone'

interface FetchParams {
  search?: string
  page?: number
}

interface IdentitiesResponse {
  identities: Identity[]
  meta: {
    pagy: { page: number; pages: number }
    total_count: number
  }
}

export const identitiesApi = {
  list: async (params: FetchParams = {}): Promise<PaginatedSafezoneResponse<Identity>> => {
    const res = await http.get<IdentitiesResponse>('/api/v1/safezone_app/identities', { params })
    return {
      data: res.data.identities,
      meta: {
        page: res.data.meta.pagy.page,
        pages: res.data.meta.pagy.pages,
        totalCount: (res.data.meta as any).totalCount,
      },
    }
  },

  create: async (data: IdentityFormData): Promise<Identity> => {
    const res = await http.post<Identity>('/api/v1/safezone_app/identities', { identity: data })
    return res.data
  },

  update: async (id: number, data: Partial<IdentityFormData>): Promise<Identity> => {
    const res = await http.put<Identity>(`/api/v1/safezone_app/identities/${id}`, { identity: data })
    return res.data
  },

  destroy: async (id: number): Promise<void> => {
    await http.delete(`/api/v1/safezone_app/identities/${id}`)
  },
}
