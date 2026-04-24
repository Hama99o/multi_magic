# SafeZone — Migration from Vue to React

## Overview

SafeZone is the secure credential vault application within MultiMagic. It stores passwords, payment cards, and identity documents.

The original implementation lives in `app/javascript_vue/views/safezone_app/`. It was built with **Vuetify 3** and has a functional but visually outdated design.

---

## What we are migrating

The **new implementation** lives in `app/javascript/pages/safezone/`.

We are migrating the **features and data model**, not the UI design.

---

## What we are NOT doing

> ❌ We will **not** copy the Vuetify-based design. It was ugly and tightly coupled to a design system we are no longer using.

The old Vue design used:

- Vuetify `v-navigation-drawer` and `v-list`
- Vuetify `v-card`, `v-chip`, `v-dialog`
- Raw Vuetify grids (`v-row`, `v-col`)
- Inline styles and repeated layout patterns
- No consistent component abstraction

---

## New design approach

The React implementation uses **HeroUI v3** with **Tailwind v4** and follows the project's established patterns:

| Old (Vue + Vuetify)           | New (React + HeroUI v3)                          |
| ----------------------------- | ------------------------------------------------ |
| `v-navigation-drawer`         | Sticky sidebar with responsive mobile collapse   |
| `v-dialog` / `v-bottom-sheet` | `DrawerRoot` (slide-in panel from right)         |
| `v-text-field`                | `FormField` component (wraps HeroUI `TextField`) |
| `v-select`                    | `SelectRoot` / `SelectTrigger` / `SelectPopover` |
| `v-chip` for type labels      | HeroUI `Badge`                                   |
| Custom CSS grid               | Tailwind responsive grid                         |
| Vuetify icon fonts            | `lucide-react` icons                             |

---

## Features to migrate (per section)

### Passwords

- [ ] List with title, username, website favicon, last updated
- [ ] Search by title/username
- [ ] Pagination (cursor-based via `meta.pagy`)
- [ ] Create / Edit drawer with fields: title, username, email, password (toggle visibility), link, note
- [ ] Delete with confirmation

### Payment Cards

- [ ] List with card name, type (credit/debit), masked number (last 4 digits), expiry date
- [ ] Search by name
- [ ] Create / Edit drawer with fields: name, card type, card number, CVV, expiry date, billing code, note
- [ ] Delete with confirmation

### Identity Documents

- [ ] List with document type, document number, expiry date
- [ ] Search by document number
- [ ] Create / Edit drawer with fields: type (passport, national ID, driver's license, etc.), document number, issued date, expiry date, note
- [ ] Delete with confirmation

---

## API reference

All endpoints are under `/api/v1/safezone_app/`:

| Resource      | Endpoints                                                  |
| ------------- | ---------------------------------------------------------- |
| Passwords     | `GET/POST /passwords`, `PUT/DELETE /passwords/:id`         |
| Payment Cards | `GET/POST /payment_cards`, `PUT/DELETE /payment_cards/:id` |
| Identities    | `GET/POST /identities`, `PUT/DELETE /identities/:id`       |

Query params: `?search=<term>&page=<n>`

Response format:

```json
{
  "passwords": [...],
  "meta": {
    "pagy": { "page": 1, "pages": 3 },
    "total_count": 25
  }
}
```

---

## Design decisions

### Why Drawers instead of modals?

Drawers provide better UX for forms with many fields. They slide in from the right, keeping the list visible behind them for context.

### Why Google Favicons for passwords?

Using `https://www.google.com/s2/favicons?domain=<link>&sz=50` gives visual identity to each credential without storing icons ourselves.

### Why `useOverlayState` + `DrawerRoot`?

HeroUI v3's `DrawerRoot` accepts a `state` prop from `useOverlayState()`. This avoids boolean state duplication and gives clean open/close/toggle methods.

---

## Reference files (Vue)

These are the original Vue files for feature reference only:

```
app/javascript_vue/views/safezone_app/
├── Dashboard.vue                         ← Sidebar layout
├── password/
│   ├── Index.vue
│   ├── Create.vue / Edit.vue
│   └── api/password.api.ts
├── payment_card/
│   ├── Index.vue
│   └── api/payment_card.api.ts
└── identity/
    ├── Index.vue
    └── api/identity.api.ts
```

---

## Status

| Section             | Status                     |
| ------------------- | -------------------------- |
| Passwords           | ✅ Implemented             |
| Payment Cards       | ✅ Implemented             |
| Identities          | ✅ Implemented             |
| Search              | ✅ All sections            |
| Pagination          | 🔜 Infinite scroll planned |
| Delete confirmation | ✅ All sections            |
