import { http, setHTTPHeader } from '@/services/http.service'
import type { IUserLogin, IRegisterUser } from '@/types/auth'

export const loginApi = (user: IUserLogin) =>
  http.post('users/login', { user })

export const logoutApi = () =>
  http.delete('users/logout')

export const registerApi = (user: IRegisterUser) =>
  http.post('users/signup', { user })

export const forgotPasswordApi = (data: { email: string }) =>
  http.post('/api/v1/users/forgot_password', data)

export const resetPasswordApi = (data: { password: string; token: string }) =>
  http.put('/api/v1/users/reset_password', data)

export const fetchCurrentUserApi = () =>
  http.get('/api/v1/users/connected_user')

export const updateUserApi = (id: number, data: FormData | Record<string, unknown>) =>
  http.patch(`/api/v1/users/${id}`, data)

// Call after login to persist token
export const setAuthHeader = (token: string) => {
  setHTTPHeader({ Authorization: token })
}
