import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

function camelizeKey(key: string): string {
  return key.replace(/_([a-z])/g, (_, c: string) => c.toUpperCase())
}

function decamelizeKey(key: string): string {
  return key.replace(/([A-Z])/g, (c) => `_${c.toLowerCase()}`)
}

export function camelizeKeys(obj: unknown): unknown {
  if (Array.isArray(obj)) return obj.map(camelizeKeys)
  if (obj !== null && typeof obj === 'object') {
    return Object.fromEntries(
      Object.entries(obj as Record<string, unknown>).map(([k, v]) => [camelizeKey(k), camelizeKeys(v)]),
    )
  }
  return obj
}

export function decamelizeKeys(obj: unknown): unknown {
  if (Array.isArray(obj)) return obj.map(decamelizeKeys)
  if (obj !== null && typeof obj === 'object') {
    return Object.fromEntries(
      Object.entries(obj as Record<string, unknown>).map(([k, v]) => [decamelizeKey(k), decamelizeKeys(v)]),
    )
  }
  return obj
}
