import {
  createContext,
  useContext,
  useEffect,
  useState,
  useCallback,
  type ReactNode,
} from 'react'
import AuthService from '@/services/auth.service'
import { initHTTPHeader } from '@/services/http.service'
import { fetchCurrentUserApi, updateUserApi } from '@/apis/auth.api'
import type { ICurrentUser, IUserLogin, IRegisterUser } from '@/types/auth'

interface AuthContextValue {
  user: ReturnType<typeof AuthService.getUser>
  currentUser: ICurrentUser | null
  isAuthenticated: boolean
  isLoading: boolean
  login: (user: IUserLogin) => Promise<void>
  logout: () => Promise<void>
  register: (user: IRegisterUser) => Promise<void>
  refreshCurrentUser: () => Promise<void>
  updateUser: (id: number, data: Record<string, unknown>) => Promise<void>
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState(AuthService.getUser())
  const [currentUser, setCurrentUser] = useState<ICurrentUser | null>(null)
  const [isLoading, setIsLoading] = useState(!!AuthService.getToken())

  const loadCurrentUser = useCallback(async () => {
    try {
      const res = await fetchCurrentUserApi()
      setCurrentUser(res.data.user ?? res.data)
    } catch {
      // token invalid — auth service interceptor handles redirect
    } finally {
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    initHTTPHeader()
    if (AuthService.getToken()) {
      loadCurrentUser()
    } else {
      setIsLoading(false)
    }
  }, [loadCurrentUser])

  const login = async (credentials: IUserLogin) => {
    const data = await AuthService.login(credentials)
    setUser(data)
    await loadCurrentUser()
  }

  const logout = async () => {
    await AuthService.logout()
    setUser(null)
    setCurrentUser(null)
  }

  const register = async (data: IRegisterUser) => {
    await AuthService.register(data)
  }

  const updateUser = async (id: number, data: Record<string, unknown>) => {
    const res = await updateUserApi(id, data)
    setCurrentUser(res.data)
    localStorage.setItem('user', JSON.stringify(res.data))
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        currentUser,
        isAuthenticated: !!user,
        isLoading,
        login,
        logout,
        register,
        refreshCurrentUser: loadCurrentUser,
        updateUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider')
  return ctx
}
