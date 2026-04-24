import axios from 'axios'
import { API_URL } from '@/configs'
import { camelizeKeys, decamelizeKeys } from '@/lib/utils'

const http = axios.create({ baseURL: API_URL })

const setHTTPHeader = (headers: Record<string, string>) => {
  http.defaults.headers.common = { ...http.defaults.headers.common, ...headers }
}

const initHTTPHeader = () => {
  const token = localStorage.getItem('token')
  if (token) setHTTPHeader({ Authorization: token })
}

http.interceptors.request.use((config) => {
  if (config.data && typeof config.data === 'object') {
    config.data = decamelizeKeys(config.data)
  }
  return config
})

http.interceptors.response.use(
  (response) => {
    if (response.data && typeof response.data === 'object') {
      response.data = camelizeKeys(response.data)
    }
    return response
  },
  async (error) => {
    if (error?.response?.status === 401) {
      // Avoid redirect loop if already on auth pages
      if (!window.location.pathname.startsWith('/login')) {
        localStorage.removeItem('user')
        localStorage.removeItem('token')
        delete http.defaults.headers.common['Authorization']
        window.location.href = '/login'
      }
      return error
    }
    return Promise.reject(error?.response?.data || 'Unknown Error')
  }
)

export { http, setHTTPHeader, initHTTPHeader }
