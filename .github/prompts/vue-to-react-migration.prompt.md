---
name: vue-to-react-migration
description: >
  Step-by-step implementation guide for migrating multi_magic from Vue 3 + Vuetify to
  React 19 + HeroUI v3 + TailwindCSS v4. Use this prompt when implementing any migration
  phase. Always read this file first before touching any migration-related code.
---

# Vue → React Migration — multi_magic

## Stack Decision Summary

| Concern          | Old (Vue)                                   | New (React)                                                |
| ---------------- | ------------------------------------------- | ---------------------------------------------------------- |
| Framework        | Vue 3 + Composition API                     | React 19                                                   |
| UI Library       | Vuetify 3                                   | HeroUI v3 (`@heroui/react`)                                |
| CSS              | Tailwind v3 + Vuetify styles                | Tailwind v4 (CSS-first, no config file) + `@heroui/styles` |
| State (API data) | Pinia stores per domain                     | TanStack Query v5 (`useInfiniteQuery`, `useMutation`)      |
| State (auth)     | Pinia `auth.store.ts`                       | React Context (`AuthContext.tsx`)                          |
| Routing          | vue-router v4                               | react-router-dom v7                                        |
| Forms            | Manual reactive + validation                | react-hook-form v7 + zod                                   |
| i18n             | vue-i18n v9                                 | i18next + react-i18next + i18next-browser-languagedetector |
| Rich text editor | Custom Tiptap v2 setup                      | `tiptop-editor` (npm package, HeroUI v3-based)             |
| HTTP             | axios + manual header management            | axios (same pattern, same interceptors)                    |
| WebSocket        | ActionCable via Pinia store                 | ActionCable via React Context / hooks                      |
| Toast            | Custom Vuetify-based                        | sonner + HeroUI Toast.Provider                             |
| Theme            | Vuetify themes (light/dark/blackguard)      | next-themes (light/dark/system)                            |
| Icons            | MDI + Iconify                               | lucide-react                                               |
| Build            | Vite + vite-plugin-ruby + plugin-vue        | Vite + vite-plugin-ruby + plugin-react                     |
| Entry point      | `app/javascript/entrypoints/multi_magic.ts` | `app/javascript/entrypoints/multi_magic.tsx`               |
| DOM mount ID     | `#app`                                      | `#app` (same, in `app/views/layouts/multi_magic.erb`)      |

---

## Preserved Files

**All Vue source lives in `app/javascript_vue/`** — never delete until 100% migrated.
React source lives in `app/javascript/`.
Reference Vue files for: API endpoint URLs, pagination patterns, field names, business logic.

---

## Implementation Rules

1. **No Pinia / No Zustand** for API data. Every API query = TanStack Query hook.
2. **No `axios` calls inside components**. All HTTP goes through `apis/` files, consumed by hooks.
3. **Auth state only in `AuthContext`**. Never duplicate auth logic.
4. **Tailwind v4 CSS-first**. No `tailwind.config.js`. All customization via CSS variables in `index.css`.
5. **All text must use `useTranslation()`**. No hardcoded English strings in components.
6. **HeroUI v3** — `HeroUIProvider` is required at app root for all HeroUI components to work.
7. **tiptop-editor** requires `@import "@heroui/styles"` in CSS and `Toast.Provider` at app root.
8. **TypeScript everywhere**. No `.js` or `.jsx` files in new React code.
9. **CLAUDE.md conventions** apply: no `render json:` in controllers, `authorize(record)` in policies, etc.
10. **Never delete Vue files** until the phase 8 cleanup step.

---

## Directory Structure

```
app/javascript/
├── entrypoints/
│   └── multi_magic.tsx          ← createRoot('#app')
├── App.tsx                       ← full provider tree
├── index.css                     ← @import tailwindcss, @heroui/styles, tiptop-editor css
├── configs.ts                    ← API_URL, GOOGLE_CLIENT_ID from import.meta.env
├── routes/
│   └── AppRoutes.tsx             ← all routes
├── contexts/
│   └── AuthContext.tsx           ← AuthProvider + useAuth hook
├── providers/
│   └── QueryProvider.tsx         ← TanStack QueryClient
├── services/
│   ├── http.service.ts           ← axios instance + interceptors + setHTTPHeader
│   └── auth.service.ts           ← AuthService class singleton
├── i18n/
│   ├── index.ts                  ← i18next init
│   └── locales/
│       ├── en.ts
│       └── fr.ts
├── components/
│   ├── routing/
│   │   └── ProtectedRoute.tsx
│   └── layouts/
│       ├── MainLayout.tsx        ← top nav + <Outlet />
│       ├── TopNav.tsx            ← logo, app grid, user dropdown, theme, lang
│       ├── AppGridMenu.tsx       ← app switcher dropdown
│       └── NotFound.tsx
├── pages/
│   ├── Home.tsx
│   ├── auth/
│   │   ├── Login.tsx
│   │   ├── Signup.tsx
│   │   ├── ForgotPassword.tsx
│   │   ├── ResetPassword.tsx
│   │   └── Logout.tsx
│   └── safezone_app/
│       ├── SafezoneLayout.tsx    ← sidebar + <Outlet />
│       ├── password/
│       │   ├── Index.tsx
│       │   └── components/
│       │       ├── PasswordCard.tsx
│       │       └── PasswordForm.tsx
│       ├── identity/
│       │   ├── Index.tsx
│       │   └── components/
│       │       ├── IdentityCard.tsx
│       │       └── IdentityForm.tsx
│       └── payment_card/
│           ├── Index.tsx
│           └── components/
│               ├── PaymentCardCard.tsx
│               └── PaymentCardForm.tsx
├── apis/
│   └── safezone_app/
│       ├── password.api.ts
│       ├── identity.api.ts
│       └── payment_card.api.ts
└── hooks/
    └── safezone_app/
        ├── usePasswords.ts
        ├── useIdentities.ts
        └── usePaymentCards.ts
```

---

## Phase 0 — Preserve Vue Files

```bash
git mv app/javascript app/javascript_vue
mkdir -p app/javascript
```

Commit: `chore(arch:web): move vue source to javascript_vue for react migration`

---

## Phase 1 — Build Configuration

### 1a. Install new dependencies

```bash
npm install react@19 react-dom@19 @heroui/react react-router-dom@7 \
  @tanstack/react-query@5 i18next react-i18next i18next-browser-languagedetector \
  react-hook-form @hookform/resolvers zod next-themes sonner tiptop-editor \
  lucide-react @vitejs/plugin-react

npm install --save-dev @types/react@19 @types/react-dom@19
```

Keep: `axios`, `@rails/actioncable`, `vite-plugin-ruby`

### 1b. `vite.config.mts`

Replace `@vitejs/plugin-vue` and `vue()` with `@vitejs/plugin-react` and `react()`.
Remove `dedupe: ['vuetify']` and scss preprocessor options.

```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import RubyPlugin from 'vite-plugin-ruby';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react(), RubyPlugin()],
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json'],
    alias: { '@': resolve(__dirname, 'app/javascript') },
  },
});
```

### 1c. `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "allowSyntheticDefaultImports": true,
    "isolatedModules": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": { "@/*": ["app/javascript/*"] },
    "typeRoots": ["node_modules/@types"],
    "types": ["vite/client"]
  },
  "include": ["app/javascript/**/*"]
}
```

### 1d. `app/javascript/index.css`

```css
@import 'tailwindcss';
@import '@heroui/styles';
@import 'tiptop-editor/dist/tiptop-editor.css';

/* Dark mode class strategy for next-themes */
@custom-variant dark (&:where(.dark, .dark *));
```

---

## Phase 2 — Core Infrastructure

### 2a. `app/javascript/configs.ts`

```ts
export const API_URL = import.meta.env.VITE_APP_DOMAIN as string;
export const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID as string;
```

> **Note**: The Vue app used `APP_DOMAIN` (no VITE* prefix via vite-plugin-ruby).
> Check `.env` files — if they use `APP_DOMAIN` keep it, otherwise add `VITE*`prefix.
Reference:`app/javascript_vue/configs.ts`and`app/javascript_vue/utils/configs.ts`

### 2b. `app/javascript/services/http.service.ts`

```ts
import axios from 'axios';
import { API_URL } from '@/configs';

const http = axios.create({ baseURL: API_URL });

// Called on app init and after login
const setHTTPHeader = (headers: Record<string, string>) => {
  http.defaults.headers.common = { ...http.defaults.headers.common, ...headers };
};

// Called on app init to restore token from localStorage
const initHTTPHeader = () => {
  const token = localStorage.getItem('token');
  if (token) setHTTPHeader({ Authorization: token });
};

http.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error?.response?.status === 401) {
      const { default: AuthService } = await import('@/services/auth.service');
      AuthService.clearCacheAndRedirect();
      return error;
    }
    return Promise.reject(error?.response?.data || 'Unknown Error');
  },
);

export { http, setHTTPHeader, initHTTPHeader };
```

### 2c. `app/javascript/services/auth.service.ts`

```ts
import { http, setHTTPHeader } from '@/services/http.service';
import { login, logout, register } from '@/apis/auth.api';
import type { IUserLogin, IRegisterUser } from '@/types/auth';

class AuthService {
  async login(user: IUserLogin) {
    const response = await login(user);
    if (response.headers.authorization) {
      const token = response.headers.authorization as string;
      localStorage.setItem('user', JSON.stringify(response.data));
      localStorage.setItem('token', token);
      setHTTPHeader({ Authorization: token });
    }
    return response.data;
  }

  async logout() {
    try {
      await logout();
    } finally {
      this.clearCache();
      delete http.defaults.headers.common['Authorization'];
    }
  }

  async register(user: IRegisterUser) {
    return register(user);
  }

  getUser() {
    const raw = localStorage.getItem('user');
    if (!raw) return null;
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  getToken() {
    return localStorage.getItem('token');
  }

  clearCache() {
    localStorage.removeItem('user');
    localStorage.removeItem('token');
  }

  clearCacheAndRedirect() {
    this.clearCache();
    window.location.href = '/login';
  }
}

export default new AuthService();
```

### 2d. `app/javascript/apis/auth.api.ts`

```ts
import { http } from '@/services/http.service';
import type { IUserLogin, IRegisterUser } from '@/types/auth';

export const login = (user: IUserLogin) => http.post('users/login', { user });

export const logout = () => http.delete('users/logout');

export const register = (user: IRegisterUser) => http.post('users/signup', { user });
```

### 2e. `app/javascript/apis/user.api.ts`

Reference: `app/javascript_vue/apis/user.api.ts`

```ts
import { http } from '@/services/http.service';

export const fetchCurrentUser = () => http.get('/api/v1/users/current_user');
export const forgotPassword = (data: { email: string }) =>
  http.post('/api/v1/users/forgot_password', data);
export const resetPassword = (data: { password: string; token: string }) =>
  http.put('/api/v1/users/reset_password', data);
export const updateUser = (id: number, data: FormData | Record<string, unknown>) =>
  http.patch(`/api/v1/users/${id}`, data);
```

### 2f. `app/javascript/types/auth.ts`

```ts
export interface IUserLogin {
  email: string;
  password: string;
}

export interface IRegisterUser {
  email: string;
  password: string;
  password_confirmation: string;
  firstname: string;
  lastname: string;
  birth_date?: string;
  agreed_to_terms: boolean;
}

export interface ICurrentUser {
  id: number;
  email: string;
  firstname: string;
  lastname: string;
  theme: string;
  applications: string[];
  access_level: string;
  avatar_url?: string;
}
```

### 2g. `app/javascript/contexts/AuthContext.tsx`

```tsx
import { createContext, useContext, useEffect, useState, useCallback, ReactNode } from 'react';
import AuthService from '@/services/auth.service';
import { initHTTPHeader } from '@/services/http.service';
import { fetchCurrentUser, updateUser as updateUserApi } from '@/apis/user.api';
import type { ICurrentUser, IUserLogin, IRegisterUser } from '@/types/auth';

interface AuthContextValue {
  user: ReturnType<typeof AuthService.getUser>;
  currentUser: ICurrentUser | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (user: IUserLogin) => Promise<void>;
  logout: () => Promise<void>;
  register: (user: IRegisterUser) => Promise<void>;
  fetchCurrentUser: () => Promise<void>;
  updateUser: (id: number, data: Record<string, unknown>) => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState(AuthService.getUser());
  const [currentUser, setCurrentUser] = useState<ICurrentUser | null>(null);
  const [isLoading, setIsLoading] = useState(!!AuthService.getToken());

  const loadCurrentUser = useCallback(async () => {
    try {
      const res = await fetchCurrentUser();
      setCurrentUser(res.data);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    initHTTPHeader();
    if (AuthService.getToken()) {
      loadCurrentUser();
    } else {
      setIsLoading(false);
    }
  }, [loadCurrentUser]);

  const login = async (credentials: IUserLogin) => {
    const data = await AuthService.login(credentials);
    setUser(data);
    await loadCurrentUser();
  };

  const logout = async () => {
    await AuthService.logout();
    setUser(null);
    setCurrentUser(null);
  };

  const register = async (data: IRegisterUser) => {
    await AuthService.register(data);
  };

  const updateUser = async (id: number, data: Record<string, unknown>) => {
    const res = await updateUserApi(id, data);
    setCurrentUser(res.data);
    localStorage.setItem('user', JSON.stringify(res.data));
  };

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
        fetchCurrentUser: loadCurrentUser,
        updateUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
```

### 2h. `app/javascript/i18n/index.ts`

```ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import { en } from './locales/en';
import { fr } from './locales/fr';

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: { en: { translation: en }, fr: { translation: fr } },
    fallbackLng: 'en',
    supportedLngs: ['en', 'fr'],
    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage'],
      lookupLocalStorage: 'i18n_lang',
    },
    interpolation: { escapeValue: false },
  });

export default i18n;
```

### 2i. i18n locale keys (minimum required)

`app/javascript/i18n/locales/en.ts` — must include at minimum:

```ts
export const en = {
  // Auth
  auth: {
    login: 'Login',
    signup: 'Sign up',
    logout: 'Logout',
    email: 'Email',
    password: 'Password',
    confirmPassword: 'Confirm password',
    forgotPassword: 'Forgot password?',
    resetPassword: 'Reset password',
    firstname: 'First name',
    lastname: 'Last name',
    birthDate: 'Birth date',
    agreedToTerms: 'I agree to the terms',
    signInWithGoogle: 'Sign in with Google',
    invalidCredentials: 'Invalid email or password',
    emailRequired: 'Email is required',
    passwordRequired: 'Password is required',
    passwordResetSent: 'Password reset email sent!',
    passwordReset: 'Password successfully reset!',
    noAccount: "Don't have an account?",
    haveAccount: 'Already have an account?',
  },
  // Layout
  nav: {
    home: 'Home',
    profile: 'Profile',
    settings: 'Settings',
    language: 'Language',
    theme: 'Theme',
    light: 'Light',
    dark: 'Dark',
    system: 'System',
    apps: 'Apps',
  },
  // App names (for AppGridMenu)
  apps: {
    safezone: 'SafeZone',
    notes: 'My Notes',
    finance: 'My Finance',
    contacts: 'My Contacts',
    blog: 'My Blog',
    todos: 'My Tasks',
  },
  // SafeZone
  safezone: {
    title: 'SafeZone',
    passwords: 'Passwords',
    paymentCards: 'Payment Cards',
    identities: 'Identities',
    addNew: 'Add New',
    search: 'Search',
    save: 'Save',
    edit: 'Edit',
    delete: 'Delete',
    cancel: 'Cancel',
    lastUpdated: 'Last updated',
    // Password fields
    password: {
      title: 'Title',
      email: 'Email',
      username: 'Username',
      password: 'Password',
      link: 'Website URL',
      note: 'Note',
      createTitle: 'Create Password',
      editTitle: 'Edit Password',
    },
    // Identity fields
    identity: {
      type: 'Document type',
      documentNumber: 'Document number',
      expiresAt: 'Expiry date',
      passport: 'Passport',
      idCard: 'ID Card',
      drivingLicense: 'Driving License',
      createTitle: 'Create Identity',
      editTitle: 'Edit Identity',
    },
    // Payment card fields
    paymentCard: {
      cardNumber: 'Card number',
      cardHolder: 'Card holder',
      expiryDate: 'Expiry date',
      cvv: 'CVV',
      bankName: 'Bank name',
      cardType: 'Card type',
      createTitle: 'Create Payment Card',
      editTitle: 'Edit Payment Card',
    },
  },
};
```

`app/javascript/i18n/locales/fr.ts` — same keys in French.

### 2j. `app/javascript/providers/QueryProvider.tsx`

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactNode } from 'react';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

export function QueryProvider({ children }: { children: ReactNode }) {
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}
```

### 2k. `app/javascript/App.tsx`

```tsx
import { BrowserRouter } from 'react-router-dom';
import { HeroUIProvider } from '@heroui/react';
import { ThemeProvider } from 'next-themes';
import { Toaster } from 'sonner';
import { Toast } from '@heroui/react';
import { QueryProvider } from '@/providers/QueryProvider';
import { AuthProvider } from '@/contexts/AuthContext';
import { AppRoutes } from '@/routes/AppRoutes';
import '@/i18n';

export default function App() {
  return (
    <QueryProvider>
      <HeroUIProvider>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          <AuthProvider>
            <Toaster richColors position="top-right" />
            <Toast.Provider placement="top-end" />
            <BrowserRouter>
              <AppRoutes />
            </BrowserRouter>
          </AuthProvider>
        </ThemeProvider>
      </HeroUIProvider>
    </QueryProvider>
  );
}
```

### 2l. `app/javascript/entrypoints/multi_magic.tsx`

```tsx
import { createRoot } from 'react-dom/client';
import App from '@/App';
import '@/index.css';

function mount() {
  const el = document.getElementById('app');
  if (!el) throw new Error('#app mount point not found');
  createRoot(el).render(<App />);
}

document.readyState === 'loading' ? document.addEventListener('DOMContentLoaded', mount) : mount();
```

---

## Phase 3 — Routing

### 3a. `app/javascript/components/routing/ProtectedRoute.tsx`

```tsx
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
      </div>
    );
  }

  if (!isAuthenticated) {
    sessionStorage.setItem('redirectAfterLogin', location.pathname + location.search);
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
}
```

### 3b. `app/javascript/routes/AppRoutes.tsx`

```tsx
import { Routes, Route, Navigate } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import { ProtectedRoute } from '@/components/routing/ProtectedRoute';
import { MainLayout } from '@/components/layouts/MainLayout';
import { SafezoneLayout } from '@/pages/safezone_app/SafezoneLayout';
import { NotFound } from '@/components/layouts/NotFound';

// Auth pages (eager — small, always needed)
import Login from '@/pages/auth/Login';
import Signup from '@/pages/auth/Signup';
import ForgotPassword from '@/pages/auth/ForgotPassword';
import ResetPassword from '@/pages/auth/ResetPassword';
import Logout from '@/pages/auth/Logout';

// Lazy-loaded pages
const Home = lazy(() => import('@/pages/Home'));
const PasswordIndex = lazy(() => import('@/pages/safezone_app/password/Index'));
const IdentityIndex = lazy(() => import('@/pages/safezone_app/identity/Index'));
const PaymentCardIndex = lazy(() => import('@/pages/safezone_app/payment_card/Index'));

const PageLoader = () => (
  <div className="flex h-64 items-center justify-center">
    <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
  </div>
);

export function AppRoutes() {
  return (
    <Routes>
      {/* Public */}
      <Route path="/login" element={<Login />} />
      <Route path="/signup" element={<Signup />} />
      <Route path="/forgot-password" element={<ForgotPassword />} />
      <Route path="/reset-password" element={<ResetPassword />} />
      <Route path="/logout" element={<Logout />} />

      {/* Protected */}
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <MainLayout />
          </ProtectedRoute>
        }
      >
        <Route
          index
          element={
            <Suspense fallback={<PageLoader />}>
              <Home />
            </Suspense>
          }
        />

        {/* SafeZone */}
        <Route path="safezone_app" element={<SafezoneLayout />}>
          <Route index element={<Navigate to="passwords" replace />} />
          <Route
            path="passwords"
            element={
              <Suspense fallback={<PageLoader />}>
                <PasswordIndex />
              </Suspense>
            }
          />
          <Route
            path="payment_cards"
            element={
              <Suspense fallback={<PageLoader />}>
                <PaymentCardIndex />
              </Suspense>
            }
          />
          <Route
            path="identities"
            element={
              <Suspense fallback={<PageLoader />}>
                <IdentityIndex />
              </Suspense>
            }
          />
        </Route>
      </Route>

      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}
```

---

## Phase 4 — Layout

### 4a. `app/javascript/components/layouts/MainLayout.tsx`

```tsx
import { Outlet } from 'react-router-dom';
import { TopNav } from './TopNav';

export function MainLayout() {
  return (
    <div className="min-h-screen bg-background">
      <TopNav />
      <main>
        <Outlet />
      </main>
    </div>
  );
}
```

### 4b. `app/javascript/components/layouts/TopNav.tsx`

Key features:

- Left: Logo (shield icon) + "MultiMagic" text → navigates to `/`
- Center (desktop): app name breadcrumb
- Right: `AppGridMenu`, theme toggle, language switcher (EN/FR), user avatar dropdown (profile + logout), login/signup buttons when unauthenticated

Use HeroUI `Navbar`, `NavbarBrand`, `NavbarContent`, `NavbarItem`, `Dropdown`, `DropdownTrigger`, `DropdownMenu`, `DropdownItem`, `Avatar`.
Use `useTheme()` from `next-themes` for theme toggle.
Use `useTranslation()` from `react-i18next` for all labels.
Use `useAuth()` for user state.

```tsx
import {
  Navbar,
  NavbarBrand,
  NavbarContent,
  NavbarItem,
  Button,
  Dropdown,
  DropdownTrigger,
  DropdownMenu,
  DropdownItem,
  Avatar,
} from '@heroui/react';
import { useTheme } from 'next-themes';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { AppGridMenu } from './AppGridMenu';
import { Sun, Moon, Monitor, Shield } from 'lucide-react';

export function TopNav() {
  const { theme, setTheme } = useTheme();
  const { t, i18n } = useTranslation();
  const { isAuthenticated, currentUser, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  // ... render Navbar
}
```

### 4c. `app/javascript/components/layouts/AppGridMenu.tsx`

Apps list (reference `app/javascript_vue/components/layouts/AppGridMenu.vue` for app names + route mapping):

```tsx
const apps = [
  { name: 'safezone', icon: Shield, route: '/safezone_app/passwords', appKey: 'safezone_app' },
  { name: 'notes', icon: FileText, route: '/note_app/notes', appKey: 'note_app' },
  {
    name: 'finance',
    icon: DollarSign,
    route: '/my_finance_app/expenses',
    appKey: 'my_finance_app',
  },
  { name: 'contacts', icon: Users, route: '/contact_app/contacts', appKey: 'contact_app' },
  { name: 'blog', icon: BookOpen, route: '/blog_app/articles', appKey: 'blog_app' },
  { name: 'todos', icon: CheckSquare, route: '/todo_app/todos', appKey: 'todo_app' },
];
// Filter by: apps.filter(a => currentUser?.applications?.includes(a.appKey))
```

### 4d. `app/javascript/components/layouts/NotFound.tsx`

Simple centered 404 page with "Go Home" button.

---

## Phase 5 — Auth Pages

### 5a. `app/javascript/pages/auth/Login.tsx`

- `useForm<{ email: string; password: string }>()` with zod schema
- On submit: `useAuth().login(data)` → on success read `sessionStorage.getItem('redirectAfterLogin')`, navigate there or `/`
- On mount: check `?creds` and `?user` query params (Google OAuth return) → if present: `localStorage.setItem('user', user)`, `localStorage.setItem('token', creds)`, `setHTTPHeader({ Authorization: creds })`, `window.location.href = '/'`
- Google button: `googleSdkLoaded` from `vue3-google-login` **is Vue-only**. Instead, dynamically load `https://accounts.google.com/gsi/client` via script tag, then call `google.accounts.oauth2.initCodeClient({ client_id: GOOGLE_CLIENT_ID, scope: 'email profile openid', redirect_uri: \`${API_URL}/google/callback\`, ux_mode: 'redirect' }).requestCode()`
- If already `isAuthenticated`: redirect to `/`

### 5b. `app/javascript/pages/auth/Signup.tsx`

- Zod schema: email, password (8+ chars, uppercase, lowercase, digit, special char), password_confirmation, firstname, lastname, birth_date, agreed_to_terms (must be true)
- On success: navigate to `/login`
- If already authenticated: redirect to `/`

### 5c. `app/javascript/pages/auth/ForgotPassword.tsx`

```tsx
const onSubmit = async (data: { email: string }) => {
  await forgotPassword(data); // from apis/user.api.ts
  toast.success(t('auth.passwordResetSent'));
};
```

### 5d. `app/javascript/pages/auth/ResetPassword.tsx`

```tsx
const [searchParams] = useSearchParams();
const token = searchParams.get('reset_password_token');

const onSubmit = async (data: { password: string; confirmPassword: string }) => {
  await resetPassword({ password: data.password, token });
  navigate('/login');
  toast.success(t('auth.passwordReset'));
};
```

### 5e. `app/javascript/pages/auth/Logout.tsx`

```tsx
export default function Logout() {
  const { logout } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    logout().then(() => navigate('/login', { replace: true }));
  }, []);

  return null;
}
```

### 5f. `app/javascript/pages/Home.tsx`

Reference: `app/javascript_vue/views/Home.vue`

- Hero section with headline + CTA buttons (Login / Sign Up when unauthenticated, or app grid when authenticated)
- Feature cards: Secure Vault, Fast & Simple, All-in-One
- App cards grid using same `apps` array as AppGridMenu, filtered by `currentUser?.applications`
- Footer with author info

---

## ✅ GATE — All must pass before Phase 6 (SafeZone)

Run through this checklist manually after Phase 5:

- [ ] `npm run dev` boots, zero console errors
- [ ] Login with email/password → JWT in localStorage → `currentUser` loaded → redirect to `/`
- [ ] Logout → localStorage cleared → redirect to `/login`
- [ ] Register → redirect to `/login`
- [ ] Forgot password → success toast
- [ ] Reset password with token from email → redirect to `/login`
- [ ] Visit `/safezone_app/passwords` while logged out → redirect to `/login` → login → redirect back to `/safezone_app/passwords`
- [ ] Google OAuth redirect flow works end-to-end
- [ ] TopNav shows login/signup when logged out; shows user avatar + app grid when logged in
- [ ] AppGridMenu opens, shows correct apps per `currentUser.applications`, navigates correctly
- [ ] Theme toggle works (light ↔ dark ↔ system), persists on page refresh (class on `<html>`)
- [ ] Language switcher EN ↔ FR, all visible strings update immediately
- [ ] `useAuth().currentUser` has full user object with `id`, `applications`, `theme`, etc.

---

## Phase 6 — SafeZone App

### 6a. API endpoints

Reference: `app/javascript_vue/apis/safezone_app/`

`app/javascript/apis/safezone_app/password.api.ts`:

```ts
import { http } from '@/services/http.service';

const BASE = '/api/v1/safezone_app/passwords';

export const passwordApi = {
  fetch: (params: { page?: number; search?: string }) => http.get(BASE, { params }),
  create: (data: Record<string, unknown>) => http.post(BASE, { password: data }),
  update: (id: number, data: Record<string, unknown>) =>
    http.patch(`${BASE}/${id}`, { password: data }),
  delete: (id: number) => http.delete(`${BASE}/${id}`),
};
```

Same pattern for `identity.api.ts` (BASE = `/api/v1/safezone_app/identities`) and `payment_card.api.ts` (BASE = `/api/v1/safezone_app/payment_cards`).

> Verify exact paths against the Rails router: `config/routes.rb` and Vue store base paths in `app/javascript_vue/stores/safezone_app/`

### 6b. TanStack Query hooks

`app/javascript/hooks/safezone_app/usePasswords.ts`:

```ts
import { useInfiniteQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { passwordApi } from '@/apis/safezone_app/password.api';
import { toast } from 'sonner';

const QUERY_KEY = ['safezone', 'passwords'];

export function usePasswords(search: string) {
  return useInfiniteQuery({
    queryKey: [...QUERY_KEY, search],
    queryFn: ({ pageParam = 1 }) =>
      passwordApi.fetch({ page: pageParam as number, search }).then((r) => r.data),
    getNextPageParam: (lastPage) =>
      lastPage.pagination?.current_page < lastPage.pagination?.total_pages
        ? lastPage.pagination.current_page + 1
        : undefined,
    initialPageParam: 1,
  });
}

export function useCreatePassword() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: passwordApi.create,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: QUERY_KEY });
      toast.success('Password saved');
    },
    onError: () => toast.error('Failed to save password'),
  });
}

export function useUpdatePassword() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: Record<string, unknown> }) =>
      passwordApi.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: QUERY_KEY });
      toast.success('Password updated');
    },
  });
}

export function useDeletePassword() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: passwordApi.delete,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: QUERY_KEY });
      toast.success('Password deleted');
    },
  });
}
```

Same pattern for `useIdentities.ts` and `usePaymentCards.ts`.

### 6c. SafeZone Layout

`app/javascript/pages/safezone_app/SafezoneLayout.tsx`:

```tsx
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Lock, CreditCard, IdCard } from 'lucide-react';
// HeroUI layout primitives

const navItems = [
  { key: 'passwords', icon: Lock, path: '/safezone_app/passwords' },
  { key: 'paymentCards', icon: CreditCard, path: '/safezone_app/payment_cards' },
  { key: 'identities', icon: IdCard, path: '/safezone_app/identities' },
];
// Collapsible sidebar on mobile (same pattern as Vue Dashboard.vue)
// Active item highlighted when location.pathname matches item.path
```

### 6d. Passwords Index

Reference: `app/javascript_vue/views/safezone_app/password/Index.vue`

`app/javascript/pages/safezone_app/password/Index.tsx`:

```tsx
import { useState, useEffect, useRef, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import {
  usePasswords,
  useCreatePassword,
  useUpdatePassword,
  useDeletePassword,
} from '@/hooks/safezone_app/usePasswords';
import PasswordCard from './components/PasswordCard';
import PasswordForm from './components/PasswordForm';
import { Input, Button } from '@heroui/react';
import { Plus } from 'lucide-react';

// Infinite scroll: use IntersectionObserver on a sentinel div
// When sentinel enters viewport and hasNextPage → fetchNextPage()
// Flatten pages: data?.pages.flatMap(p => p.passwords) ?? []
// Show total: data?.pages[0]?.pagination?.total_items
// Search: debounced input → re-runs query with new search term
// "Add New" button → opens PasswordForm modal in create mode
// Click card → opens PasswordForm modal in edit mode with selected password
```

### 6e. Password Card

`app/javascript/pages/safezone_app/password/components/PasswordCard.tsx`:

```tsx
// HeroUI Card, variant="bordered", hover effect
// Favicon: <img src={`https://www.google.com/s2/favicons?domain=${password.link}&sz=50`} />
// Shows: title, username, last updated (formatted date)
// onClick → open edit form
```

### 6f. Password Form

`app/javascript/pages/safezone_app/password/components/PasswordForm.tsx`:

```tsx
// HeroUI Modal (isOpen, onClose props)
// react-hook-form with zod schema
// Fields: title (required), email, username, password (show/hide toggle), link, note (textarea)
// If password.link present → show favicon + title as header preview
// On submit → calls createPassword or updatePassword depending on mode
// On success → modal closes, query invalidated via hook
```

### 6g. Identity types

Reference `app/javascript_vue/views/safezone_app/identity/Index.vue`:

```ts
const identityTypes = {
  'SafezoneApp::Identities::Passport': { icon: 'Passport', color: 'primary', label: 'passport' },
  'SafezoneApp::Identities::IdCard': { icon: 'IdCard', color: 'success', label: 'idCard' },
  'SafezoneApp::Identities::DrivingLicense': {
    icon: 'Car',
    color: 'warning',
    label: 'drivingLicense',
  },
};
```

---

## Phase 7 — Prompt File Update

After completing SafeZone, update this file's migration tracker:

```
## Migration Tracker

| App | Status |
|---|---|
| Foundation (Auth + Layout + Routing) | ✅ Done |
| SafeZone | ✅ Done |
| Note App | ⬜ Not started |
| My Finance | ⬜ Not started |
| Contact App | ⬜ Not started |
| Blog App | ⬜ Not started |
| Todo App | ⬜ Not started |
| Conversations | ⬜ Not started |
| AI Page | ⬜ Not started |
| Users (Profile / List) | ⬜ Not started |
```

---

## Phase 8 — Per-App Migration Pattern

When migrating each additional app, follow this exact pattern:

1. **API file**: `apis/<app>/[resource].api.ts` — copy endpoint paths from Vue `apis/<app>/` and Vue store `baseUrl`
2. **Query hook**: `hooks/<app>/use[Resource].ts` — `useInfiniteQuery` for lists, `useMutation` for writes
3. **Layout** (if app needs own sidebar): `pages/<app>/[App]Layout.tsx` — add to `AppRoutes.tsx`
4. **Index page**: `pages/<app>/[resource]/Index.tsx` — infinite scroll + search + add button
5. **Card component**: `pages/<app>/[resource]/components/[Resource]Card.tsx`
6. **Form component**: `pages/<app>/[resource]/components/[Resource]Form.tsx` — HeroUI Modal + react-hook-form + zod
7. **i18n keys**: add to `i18n/locales/en.ts` and `fr.ts`
8. **Route**: add to `AppRoutes.tsx`
9. **AppGridMenu**: add route mapping if not already there

---

## Phase 9 — Cleanup (only after all apps verified)

```bash
rm -rf app/javascript_vue
# Remove from package.json: vue, vuetify, pinia, vue-router, vue-i18n, @vitejs/plugin-vue,
# vue3-google-login, lucide-vue-next, @iconify/vue, @mdi/font, vue-chartjs,
# vue-advanced-cropper, vue3-dropzone, yjs, y-webrtc, y-websocket (if not used)
npm install
```

Commit: `chore(arch:web): remove vue source and dependencies after full react migration`

---

## Migration Tracker

| App                                             | Status         |
| ----------------------------------------------- | -------------- |
| Foundation (Auth + Layout + Routing)            | ⬜ Not started |
| SafeZone (Passwords, Identities, Payment Cards) | ⬜ Not started |
| Note App                                        | ⬜ Not started |
| My Finance (Expenses + Loans)                   | ⬜ Not started |
| Contact App                                     | ⬜ Not started |
| Blog App                                        | ⬜ Not started |
| Todo App                                        | ⬜ Not started |
| Conversations / Chat                            | ⬜ Not started |
| AI Page                                         | ⬜ Not started |
| Users (Profile / List)                          | ⬜ Not started |

---

## Common Pitfalls

| Pitfall                                  | Fix                                                                                                               |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| HeroUI components not styled             | Ensure `@import "@heroui/styles"` is in `index.css` AND `HeroUIProvider` wraps the app                            |
| `useTheme()` returns `undefined`         | `ThemeProvider` must be ancestor; use `attribute="class"` so it sets class on `<html>`                            |
| Tailwind classes not applied             | Tailwind v4: no `content` array needed, it scans automatically. Ensure `@import "tailwindcss"` is first in CSS    |
| Auth context `null`                      | Any component using `useAuth()` must be inside `AuthProvider`                                                     |
| TanStack Query stale data after mutation | Always call `queryClient.invalidateQueries({ queryKey: ... })` in `onSuccess`                                     |
| Infinite scroll not triggering           | Check IntersectionObserver threshold; ensure sentinel div is in DOM; `hasNextPage` must be true                   |
| `?creds&user` OAuth params not handled   | Must be in `useEffect` on mount in `Login.tsx`, before any auth checks                                            |
| 401 redirect loop                        | `clearCacheAndRedirect` must check if already on `/login` before redirecting                                      |
| i18n keys missing in FR                  | Always add both `en` and `fr` keys simultaneously                                                                 |
| Vue-only package imported                | `vue3-google-login`, `storeToRefs`, `pinia`, etc. — none of these exist in React. Replace with native equivalents |
