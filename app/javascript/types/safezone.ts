export interface Password {
  id: number
  title: string
  username: string
  email: string
  password: string
  link: string
  note: string
  updatedAt: string
  createdAt: string
}

export interface PaymentCard {
  id: number
  name: string
  cardType: string
  cardNumber: string
  cvv: string
  expiryDate: string
  status: string
  note: string
  code: string
  createdAt: string
  updatedAt: string
}

export interface Identity {
  id: number
  type: string
  documentNumber: string
  issuedAt: string
  expiresAt: string
  note: string
  createdAt: string
  updatedAt: string
}

export interface SafezoneMeta {
  page: number
  pages: number
  totalCount: number
}

export interface PaginatedSafezoneResponse<T> {
  data: T[]
  meta: SafezoneMeta
}

export type PasswordFormData = Omit<Password, 'id' | 'createdAt' | 'updatedAt'>
export type PaymentCardFormData = Omit<PaymentCard, 'id' | 'createdAt' | 'updatedAt'>
export type IdentityFormData = Omit<Identity, 'id' | 'createdAt' | 'updatedAt'>
