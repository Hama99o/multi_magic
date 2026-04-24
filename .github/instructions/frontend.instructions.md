---
description: 'Use when writing, editing, or reviewing any frontend React/TypeScript code: components, pages, routes, APIs, i18n, forms, drawers, lists, layouts. Covers HeroUI v3, Tailwind v4, React Query, react-hook-form, i18n, routing, mobile-first design, dark/light mode safety.'
applyTo: 'app/javascript/**'
---

# Frontend Conventions — MultiMagic React App

## 1. TypeScript — Always Strict

- Every file must be `.tsx` or `.ts`. No `.js`/`.jsx`.
- All props, state, and API return types must be explicitly typed.
- Types for a domain live in `app/javascript/types/<domain>.ts`.
- `FormData` types are `Omit<Entity, 'id' | 'createdAt' | 'updatedAt'>`.
- Never use `any`. Prefer `unknown` + narrowing if necessary.

```ts
// ✅ Correct
interface PasswordDrawerProps {
  state: ReturnType<typeof useOverlayState>
  password?: Password | null
  onClose: () => void
}

// ❌ Wrong
const handleClose = (e: any) => { ... }
```

---

## 2. i18n — Translation Is Mandatory

**Rule: Zero hardcoded English strings in JSX.** Every visible string must come from `useTranslation()`.

### How to use

```tsx
const { t } = useTranslation();
// Then in JSX:
{
  t('safezone.addPassword');
}
```

### Adding a new key

1. Add to `app/javascript/i18n/locales/en.ts`
2. Add the **French equivalent** to `app/javascript/i18n/locales/fr.ts` at the same time.
3. Never leave one locale ahead of the other.

### Key naming convention

```
<domain>.<camelCaseKey>
```

Examples: `safezone.searchPasswords`, `common.cancel`, `nav.comingSoon`

Nested objects are allowed for enums:

```ts
safezone: {
  identityTypes: {
    passport: 'Passport',
    national_id: 'National ID',
  }
}
```

Used as: `t('safezone.identityTypes.passport')`

### Shared keys

Put truly generic labels in `common.*`:

- `common.save`, `common.cancel`, `common.delete`, `common.edit`, `common.loading`, `common.required`, `common.noResults`

---

## 3. Folder Structure

```
app/javascript/
├── apis/               # Cross-domain or global APIs
├── components/         # Global/shared UI components
│   ├── layout/         # TopNav, MainLayout, NotFound, etc.
│   ├── routing/        # ProtectedRoute, etc.
│   └── ui/             # FormField, Spinner, etc.
├── contexts/           # React contexts (AuthContext, etc.)
├── i18n/locales/       # en.ts, fr.ts
├── pages/              # Route-level views, grouped by domain
│   └── <domain>/
│       ├── Layout.tsx          # Optional layout wrapper
│       ├── Index.tsx           # List/main page
│       ├── api/                # Domain API (http calls)
│       │   └── <domain>.api.ts
│       └── components/         # Domain-scoped components
│           └── <Domain>Drawer.tsx
├── routes/             # AppRoutes.tsx
├── services/           # http.service.ts
├── types/              # TypeScript interfaces per domain
└── entrypoints/        # Vite entry points
```

**Rules:**

- Folders are **singular**: `pages/safezone/`, `types/`, `components/`
- Domain components are **prefixed**: `PasswordCard.tsx`, `IdentityDrawer.tsx`
- Reusable logic goes in `components/` or `composables/`; domain-only logic stays inside `pages/<domain>/`

---

## 4. API Layer

Every domain has its own `api/<domain>.api.ts`. It imports `http` from `@/services/http.service` and returns typed data.

```ts
// app/javascript/pages/safezone/passwords/api/passwords.api.ts
import { http } from '@/services/http.service'
import type { Password, PasswordFormData, PaginatedSafezoneResponse } from '@/types/safezone'

export const passwordsApi = {
  list: async (params: { search?: string; page?: number } = {}): Promise<PaginatedSafezoneResponse<Password>> => {
    const res = await http.get<{ passwords: Password[]; meta: { pagy: { page: number; pages: number }; total_count: number } }>(
      '/api/v1/safezone_app/passwords', { params }
    )
    return {
      data: res.data.passwords,
      meta: { page: res.data.meta.pagy.page, pages: res.data.meta.pagy.pages, totalCount: res.data.meta.total_count },
    }
  },
  create: async (data: PasswordFormData): Promise<Password> => {
    const res = await http.post<{ password: Password }>('/api/v1/safezone_app/passwords', { password: data })
    return res.data.password
  },
  update: async (id: number, data: PasswordFormData): Promise<Password> => {
    const res = await http.put<{ password: Password }>(`/api/v1/safezone_app/passwords/${id}`, { password: data })
    return res.data.password
  },
  destroy: async (id: number): Promise<void> => {
    await http.delete(`/api/v1/safezone_app/passwords/${id}`)
  },
}
```

**Rules:**

- Never call `http` directly from a component. Always go through a `*.api.ts` file.
- Wrap the Rails JSON body key: `{ password: data }`, `{ identity: data }`, etc.
- Paginated responses return `{ data: T[], meta: { page, pages, totalCount } }`.

---

## 5. React Query — Data Fetching & Mutations

```tsx
// Fetching
const { data, isLoading } = useQuery({
  queryKey: ['safezone', 'passwords', debouncedSearch],
  queryFn: () => passwordsApi.list({ search: debouncedSearch }),
});

// Mutating
const queryClient = useQueryClient();
const createMutation = useMutation({
  mutationFn: passwordsApi.create,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['safezone', 'passwords'] });
    onClose();
  },
});
```

**Query key convention:** `['<domain>', '<resource>', ...params]`
Examples: `['safezone', 'passwords', search]`, `['safezone', 'payment-cards']`

---

## 6. HeroUI v3 — Component Rules

### DrawerRoot

`DrawerRoot` requires a `state` prop from `useOverlayState()`. Do **not** use `isOpen`/`onOpenChange` directly on it.

```tsx
// In the parent (Index page):
const drawerState = useOverlayState()
<PasswordDrawer state={drawerState} ... />

// In the drawer component:
import { DrawerRoot, DrawerBackdrop, DrawerContent, DrawerDialog,
         DrawerHeader, DrawerHeading, DrawerBody, DrawerFooter,
         DrawerCloseTrigger, useOverlayState } from '@heroui/react'

interface Props {
  state: ReturnType<typeof useOverlayState>
}

<DrawerRoot state={state}>
  <DrawerBackdrop />
  <DrawerContent placement="right">
    <DrawerDialog>
      <DrawerHeader>
        <DrawerHeading>{title}</DrawerHeading>
        <DrawerCloseTrigger />
      </DrawerHeader>
      <DrawerBody>...</DrawerBody>
      <DrawerFooter>...</DrawerFooter>
    </DrawerDialog>
  </DrawerContent>
</DrawerRoot>
```

### SearchField — Compound Component

`SearchField` IS `SearchFieldRoot`. Do **not** nest `<SearchField>` inside `<SearchFieldRoot>`.

```tsx
import {
  SearchField,
  SearchFieldGroup,
  SearchFieldInput,
  SearchFieldClearButton,
  SearchFieldSearchIcon,
} from '@heroui/react';

<SearchField value={search} onChange={setSearch} className="w-full max-w-sm">
  <SearchFieldGroup>
    <SearchFieldSearchIcon />
    <SearchFieldInput placeholder={t('safezone.searchPasswords')} />
    <SearchFieldClearButton />
  </SearchFieldGroup>
</SearchField>;
```

### SelectRoot — Controlled with react-hook-form

`SelectRoot` uses React Aria props: `selectedKey` + `onSelectionChange`. Always wrap with `Controller`.

```tsx
import {
  SelectRoot,
  SelectTrigger,
  SelectValue,
  SelectIndicator,
  SelectPopover,
  ListBox,
  ListBoxItem,
} from '@heroui/react';
import { Controller } from 'react-hook-form';

<Controller
  name="cardType"
  control={control}
  rules={{ required: t('common.required') }}
  render={({ field }) => (
    <SelectRoot
      selectedKey={field.value}
      onSelectionChange={(key) => field.onChange(key)}
      isInvalid={!!errors.cardType}
    >
      <SelectTrigger>
        <SelectValue />
        <SelectIndicator />
      </SelectTrigger>
      <SelectPopover>
        <ListBox>
          <ListBoxItem id="credit_card">{t('safezone.creditCard')}</ListBoxItem>
          <ListBoxItem id="debit_card">{t('safezone.debitCard')}</ListBoxItem>
        </ListBox>
      </SelectPopover>
    </SelectRoot>
  )}
/>;
```

### FormField — Shared Text Input

Always use `<FormField>` from `@/components/ui/FormField` for text/email/password inputs inside forms.

```tsx
<FormField
  label={t('common.title')}
  errorMessage={errors.title?.message}
  fullWidth
  {...register('title', { required: t('common.required') })}
/>
```

---

## 7. Forms — react-hook-form

- Use `useForm<FormData>()` with explicit generic.
- Use `register()` for native inputs (through `FormField`).
- Use `Controller` for HeroUI Select, DatePicker, or any non-native input.
- Reset the form inside a `useEffect` that watches `state.isOpen`:

```tsx
useEffect(() => {
  if (state.isOpen) {
    reset(entity ? { ...entityFields } : defaultValues);
    setLocalUIState(false);
  }
}, [state.isOpen, entity, reset]);
```

---

## 8. Debounce — No External Package

`use-debounce` is **not** installed. Use the `useEffect` + `setTimeout` pattern:

```tsx
const [search, setSearch] = useState('');
const [debouncedSearch, setDebouncedSearch] = useState('');

useEffect(() => {
  const timer = setTimeout(() => setDebouncedSearch(search), 400);
  return () => clearTimeout(timer);
}, [search]);
```

---

## 9. Routing

All routes live in `app/javascript/routes/AppRoutes.tsx`. Use `lazy()` for every page.

```tsx
// Lazy import
const SafezoneLayout = lazy(() => import('@/pages/safezone/Layout'))
const SafezonePasswords = lazy(() => import('@/pages/safezone/passwords/Index'))

// Nested routes
<Route path="safezone" element={<SafezoneLayout />}>
  <Route index element={<Navigate to="passwords" replace />} />
  <Route path="passwords" element={<SafezonePasswords />} />
</Route>
```

**Rules:**

- New domain = new nested group under `<Route element={<MainLayout />}>`.
- Domain layout uses `<Outlet />` to render children.
- Route paths are **plural kebab-case**: `safezone`, `payment-cards`, `identities`.

---

## 10. Colors & Dark/Light Mode Safety

**Never use raw color values** (`text-gray-500`, `bg-white`, `text-black`). Always use semantic Tailwind tokens that adapt to the current theme.

| Need            | Use                                                             |
| --------------- | --------------------------------------------------------------- |
| Background      | `bg-background`, `bg-muted`, `bg-card`                          |
| Text            | `text-foreground`, `text-muted-foreground`                      |
| Border          | `border-border`                                                 |
| Brand primary   | `text-primary`, `bg-primary`, `text-primary-foreground`         |
| Semantic colors | `text-success`, `text-warning`, `text-danger`, `text-secondary` |
| Hover           | `hover:bg-accent hover:text-accent-foreground`                  |
| Subtle tint     | `bg-primary/10`, `bg-success/10`                                |

```tsx
// ✅ Safe for dark AND light mode
<div className="bg-card border border-border rounded-xl p-4">
  <p className="text-muted-foreground text-sm">Last updated</p>
  <span className="text-primary font-medium">SafeZone</span>
</div>

// ❌ Breaks dark mode
<div className="bg-white text-gray-600 border-gray-200">
```

---

## 11. Mobile-First Responsive Layout

Every new page/component **must work on mobile**. Use Tailwind's mobile-first breakpoints.

```tsx
// Grids
<div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">

// Flex stacking
<div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">

// Width
<div className="w-full max-w-sm">       // full on mobile, constrained on desktop
<div className="px-4 sm:px-6 lg:px-8"> // edge padding

// Drawers
placement="right"  // full-screen on mobile, side panel on desktop (HeroUI default)
```

**Rules:**

- Minimum tap target: `h-10 w-10` (`min-h-[44px]` for accessibility).
- Bottom navigation for mobile (sticky bottom bar in domain layouts).
- Sticky desktop sidebar + bottom mobile nav for multi-section apps (see `SafezoneLayout`).
- `text-sm` on mobile, `text-base` on desktop when needed.
- `truncate` or `line-clamp-2` to prevent overflow on small screens.

---

## 12. Loading & Empty States

Every list page needs all three states:

```tsx
{
  isLoading ? (
    // Skeleton: same grid/layout as loaded state
    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="bg-muted h-20 animate-pulse rounded-xl" />
      ))}
    </div>
  ) : items.length === 0 ? (
    // Empty state: centered, with icon + message
    <div className="text-muted-foreground flex flex-col items-center justify-center gap-3 py-16">
      <IconComponent size={40} className="opacity-30" />
      <p className="text-sm">{t('safezone.noItems')}</p>
    </div>
  ) : (
    // Actual list
    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {items.map((item) => (
        <ItemCard key={item.id} item={item} onEdit={openEdit} />
      ))}
    </div>
  );
}
```

---

## 13. Adding a New Domain / App Section

Checklist when creating a new section (e.g., `notes`):

1. **Types** → `app/javascript/types/notes.ts`
2. **API** → `app/javascript/pages/notes/api/notes.api.ts`
3. **Layout** → `app/javascript/pages/notes/Layout.tsx` (if multi-tab)
4. **Pages** → `app/javascript/pages/notes/Index.tsx`, etc.
5. **Components** → `app/javascript/pages/notes/components/NoteCard.tsx`, `NoteDrawer.tsx`
6. **Routes** → Add lazy imports + nested routes to `AppRoutes.tsx`
7. **i18n** → Add `notes.*` keys to both `en.ts` **and** `fr.ts`
8. **Apps menu** → Update `APPS` array in `TopNav.tsx` (set `available: true`)
