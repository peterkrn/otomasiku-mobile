# Phase 3 — Backend Integration Specs
# Otomasiku Marketplace Mobile App

> **Status:** 🔄 In Progress — Milestone 3
> **Source of truth:** `docs/PROMPT_FLUTTER_BACKEND_INTEGRATION.md`
> **Architecture:** `docs/ARCHITECTURE.md`
> **Rules:** `docs/AI_RULES.md`

---

## Overview

Phase 3 replaces all dummy data providers with real API calls to the Express backend (Railway) and Supabase Auth. Each spec below is independently implementable and must be completed in order (later specs depend on earlier ones).

```
Flutter App
  ├── Supabase SDK ──→ Supabase Auth (login, register, token refresh)
  └── Dio ──→ Express API (Railway)
               └── Prisma ──→ Supabase PostgreSQL
```

---

## Spec Index

| # | File | Scope | Depends On | Status |
|---|------|-------|------------|--------|
| 01 | [01-infrastructure.md](./01-infrastructure.md) | Dio client, interceptors, env config, connectivity | — | ✅ |
| 02 | [02-models-repositories.md](./02-models-repositories.md) | Typed models + repository layer | 01 | ✅ |
| 03 | [03-auth-flow.md](./03-auth-flow.md) | Supabase auth, token storage, GoRouter guards, bootstrap | 01, 02 | ✅ |
| 04 | [04-product-catalog.md](./04-product-catalog.md) | Product list, search, filter, pagination | 01, 02, 03 | ⬜ |
| 05 | [05-cart.md](./05-cart.md) | Cart CRUD, optimistic UI, idempotency | 01, 02, 03 | ⬜ |
| 06 | [06-checkout-orders.md](./06-checkout-orders.md) | Checkout flow, order creation, order history | 01, 02, 03, 05 | ⬜ |
| 07 | [07-payment-bca.md](./07-payment-bca.md) | BCA VA display, countdown timer, payment polling | 01, 02, 03, 06 | ⬜ |
| 08 | [08-profile-addresses.md](./08-profile-addresses.md) | Profile view/edit, address CRUD | 01, 02, 03 | ⬜ |
| 09 | [09-push-notifications.md](./09-push-notifications.md) | FCM setup, device token registration, notification routing | 03 | ⬜ |

---

## Global Conventions (apply to all specs)

### Money
- All prices are `int` in Rupiah. `Rp 19.800.000` = `19800000`
- API returns prices as `String` (BigInt serialization) → parse to `int` in Dart
- Always display with `CurrencyFormatter.format(price)`

### Error Handling
- Express returns `{ "success": false, "error": { "code": "MACHINE_CODE", "correlationId": "uuid" } }`
- Flutter maps `error.code` → `AppLocalizations` key via `error_handler.dart`
- Never display raw server error strings in UI

### Auth
- Every authenticated Dio request: `Authorization: Bearer <supabase_jwt>`
- Tokens stored in `flutter_secure_storage` only (Android Keystore)
- On 401: attempt token refresh → if fails, redirect to login

### Idempotency
- `POST /api/orders` and `POST /api/cart` require `X-Idempotency-Key: <uuid_v4>` header
- Generate fresh UUID per request attempt

### i18n
- All user-facing strings via `AppLocalizations.of(context)!`
- No hardcoded strings in widgets

### State
- Always handle 3 states: loading, error, data (`.when()`)
- Use `FutureProvider.autoDispose` for screen-scoped data
- Use `StateNotifierProvider` for mutable state (cart, auth)

---

## File Naming Convention

```
docs/specs/phase_3_integrations/
├── 00-index.md                  ← This file
├── 01-infrastructure.md
├── 02-models-repositories.md
├── 03-auth-flow.md
├── 04-product-catalog.md
├── 05-cart.md
├── 06-checkout-orders.md
├── 07-payment-bca.md
├── 08-profile-addresses.md
└── 09-push-notifications.md
```

---

## Definition of Done (per spec)

- [ ] All acceptance criteria pass
- [ ] `flutter analyze` clean
- [ ] No `dynamic` types in new code
- [ ] No hardcoded strings in widgets
- [ ] All money values use `CurrencyFormatter`
- [ ] Dummy data file for this feature is no longer imported anywhere
- [ ] Error states handled and localized
- [ ] Loading states shown
