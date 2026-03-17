# Skill: Project Onboarding & Session Context
# Otomasiku Marketplace Mobile App

> **When to use:** Run `/read docs/skills/SKILL-onboarding.md` at the START of every Claude Code session — before any code is written. This file gives the AI the minimum viable context to work correctly without dumping all MD files into the window.

---

## What This Project Is

B2B industrial automation marketplace (Android). Customers buy Mitsubishi + Danfoss products (inverters, PLCs, servos, HMIs). B2B context: buyers are companies, orders are large, payment via BCA Virtual Account.

**Two separate projects on this machine:**

| Project | Path | Purpose |
|---------|------|---------|
| Flutter app | `C:\dev\projects\otomasiku-mobile` | Android app — current working directory |
| Express backend | `C:\dev\projects\otomasiku-api` | API + BCA Sandbox backend |

**Never run Node.js/pnpm commands inside `otomasiku-mobile`. Never run Flutter commands inside `otomasiku-api`.**

---

## Tech Stack — Quick Reference

| Layer | Technology | Notes |
|-------|-----------|-------|
| Mobile | Flutter (Dart) | Android only for v1 |
| State | Riverpod | No setState for business logic |
| Navigation | GoRouter | Named routes only |
| i18n | flutter_localizations + ARB | `app_id.arb` primary, `app_en.arb` mirror |
| Backend | Express.js + TypeScript | `C:\dev\projects\otomasiku-api` |
| ORM | Prisma | No raw SQL ever |
| Validation | Zod | Every POST/PUT/PATCH endpoint |
| DB | Supabase PostgreSQL | via Prisma |
| Payment | BCA Virtual Account | BCA Developer API |
| Package manager (BE) | `pnpm` | NEVER npm or yarn |
| Logging (BE) | Pino | Structured JSON, always include correlationId |

---

## Current Milestone & Sprint

**Milestone 2 — Flutter UI with Dummy Data + BCA Sandbox**
**Sprint 1 — OMA-11 through OMA-14**

| JIRA | Task | Status |
|------|------|--------|
| OMA-11 | Product Catalog Page | ⬜ |
| OMA-12 | Product Detail Page | ⬜ |
| OMA-13 | Shopping Cart Page | ⬜ |
| OMA-14 | Checkout Page | ⬜ |

**Milestone 2 ground rules (non-negotiable):**
- NO backend calls except BCA Sandbox payment flow
- NO Supabase SDK — auth is a fake `isLoggedIn` bool in Riverpod
- ALL data from `lib/data/dummy/` — 10 products, 1 user, 2 addresses, 3 orders
- ALL screens must pixel-match HTML mockups in `ui-otomasiku-marketplace/`

---

## 10 Rules You Must Never Break

These are the highest-stakes rules from `docs/AI_RULES.md`. Read the full file for the complete list.

1. **Money = `int`/`BigInt` only.** `Rp 19.800.000` = `19800000`. Never float, never double.
2. **No hardcoded strings in widgets.** Always `AppLocalizations.of(context)!`. Define in `lib/l10n/app_id.arb` + `app_en.arb` first.
3. **No hardcoded error text from Express.** Send `error.code` only. Flutter translates it.
4. **Product images = `Image.asset()` only.** Never `Image.network()`, never placeholder URLs. Always include `errorBuilder`.
5. **Navigation = `context.goNamed()` only.** Never `Navigator.push()`.
6. **Prices = `CurrencyFormatter.format(int)` only.** Never format manually.
7. **No `setState` for business logic.** Riverpod providers only.
8. **No raw SQL.** Prisma for everything on the backend.
9. **Backend package manager = `pnpm`.** Never `npm install` or `yarn`.
10. **All Express routes = `/api/` prefix.** e.g. `/api/orders`, `/api/products`. No version segment.

---

## Key File Locations

### Flutter (`otomasiku-mobile`)
```
lib/
├── l10n/
│   ├── app_id.arb           ← ALL Indonesian strings — define here first
│   └── app_en.arb           ← English mirror — must have every key from app_id.arb
├── core/
│   ├── constants/
│   │   ├── app_colors.dart  ← mitsubishiRed = #E7192D, bcaBlue = #0066AE
│   │   └── bca_config.dart  ← ONLY place BCA mini backend URL is set
│   ├── router/
│   │   └── app_router.dart  ← all GoRouter routes
│   └── utils/
│       └── currency_formatter.dart
├── data/dummy/              ← ALL dummy data for M2 (10 products, user, cart, orders)
├── models/                  ← typed Dart models
├── providers/               ← all Riverpod providers
└── features/                ← one folder per screen/feature
```

### Express (`otomasiku-api`)
```
src/
├── index.ts                 ← entry point
├── config/env.ts            ← typed env — never raw process.env
├── routes/payment.ts        ← BCA: /payment/create-va, /payment/callback, /payment/status/:va
├── routes/health.ts         ← GET /health (liveness)
├── middleware/
│   ├── bca_signature.ts     ← HMAC-SHA256 validation on BCA callbacks
│   └── error-handler.ts     ← centralized error response
├── services/bca_auth.ts     ← BCA OAuth token with caching (never request per-call)
└── store/va_store.ts        ← in-memory VA map (no DB for M2)
```

---

## Skill Files — Read These for Specific Tasks

| Task | Skill File |
|------|-----------|
| Building any Flutter screen | `docs/skills/SKILL-flutter-screens.md` |
| Express API endpoints | `docs/skills/SKILL-express-api.md` |
| Database / Prisma | `docs/skills/SKILL-database.md` |
| BCA payment integration | `docs/skills/SKILL-bca-payment.md` |
| Writing tests | `docs/skills/SKILL-testing.md` |
| Spec-driven development workflow | `docs/skills/SKILL-sdd-workflow.md` |

**Do NOT read all skill files at once.** Only read the one relevant to the current task.

---

## Before Writing ANY Code — Checklist

```
[ ] Read the relevant spec in docs/specs/{oma-id}-{description}.md
[ ] Read the HTML mockup in ui-otomasiku-marketplace/{file}.html
[ ] Confirm the task is in scope for Milestone 2 (dummy data, no backend except BCA)
[ ] Show a component tree / implementation plan FIRST — wait for approval
[ ] Then implement ONE file at a time
```

---

## Color & Design Constants

| Token | Value | Used For |
|-------|-------|---------|
| Mitsubishi Red | `#E7192D` | Primary CTA, active states, brand |
| Background | `#F9FAFB` | All scaffold backgrounds |
| BCA Blue | `#0066AE` | Payment screen accents |
| Danfoss Blue | `#005A8C` | Danfoss brand elements |
| Font | Inter | All weights 300–700 |
| Card radius | 16px | `rounded-2xl` |
| Button radius | 12px | `rounded-xl` |
| Min touch target | 44×44dp | All interactive elements |
| Bottom padding | 96px | All scrollable screens (clears bottom nav) |

---

## Error Response Contract (Express → Flutter)

```
Express sends:  { error: { code: "INSUFFICIENT_STOCK", details: { available: 2 } } }
Flutter reads:  error.code → translateErrorCode(code, l10n, details) → localized string
```

**Never put human-readable text in Express error responses.** Always `code` only.

---

## Dummy Data Quick Reference

| File | Contents |
|------|---------|
| `dummy_products.dart` | 10 products (5 Inverter, 2 PLC, 2 Servo, 1 HMI) |
| `dummy_user.dart` | John Doe — Otomasi Indonesia |
| `dummy_addresses.dart` | 2 addresses: Sudirman Jakarta (Utama) + Bekasi (Gudang) |
| `dummy_cart.dart` | FR-A820-0.4K × 2, FX5U-32MT × 1 |
| `dummy_orders.dart` | 3 orders: Sedang Diproses, Dikirim, Selesai |
| `dummy_projects.dart` | 2 projects: Maintenance Conveyor, Upgrade CNC-01 |

Product images live in `assets/images/products/` — always use `Image.asset()`, never network URLs.

---

*Read `docs/AI_RULES.md` for the complete rule set. Read `docs/PLAN_MILESTONE_2.md` for full phase details.*