// APP_DOMAIN is exposed via vite-plugin-ruby from .env (no VITE_ prefix needed)
export const API_URL = (import.meta.env.APP_DOMAIN as string) || ''
export const GOOGLE_CLIENT_ID = (import.meta.env.GOOGLE_CLIENT_ID as string) || ''
