import { loginApi, logoutApi, registerApi, setAuthHeader } from '@/apis/auth.api'
import { http } from '@/services/http.service'
import type { IUserLogin, IRegisterUser } from '@/types/auth'

class AuthService {
  async login(user: IUserLogin) {
    const response = await loginApi(user)
    if (response.headers.authorization) {
      const token = response.headers.authorization as string
      localStorage.setItem('user', JSON.stringify(response.data))
      localStorage.setItem('token', token)
      setAuthHeader(token)
    }
    return response.data
  }

  async logout() {
    try {
      await logoutApi()
    } finally {
      this.clearCache()
      delete http.defaults.headers.common['Authorization']
    }
  }

  async register(user: IRegisterUser) {
    return registerApi(user)
  }

  getUser() {
    const raw = localStorage.getItem('user')
    if (!raw) return null
    try {
      return JSON.parse(raw)
    } catch {
      return null
    }
  }

  getToken() {
    return localStorage.getItem('token')
  }

  clearCache() {
    localStorage.removeItem('user')
    localStorage.removeItem('token')
  }

  clearCacheAndRedirect() {
    this.clearCache()
    if (!window.location.pathname.startsWith('/login')) {
      window.location.href = '/login'
    }
  }
}

export default new AuthService()
