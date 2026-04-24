declare module 'lodash' {
  export function debounce<T extends (...args: unknown[]) => unknown>(
    func: T,
    wait?: number,
    options?: { leading?: boolean; maxWait?: number; trailing?: boolean }
  ): T & { cancel: () => void; flush: () => void };
}
