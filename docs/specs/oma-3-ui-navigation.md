# Spec: OMA-3 — Tampilan & Navigasi Aplikasi

| Field | Value |
|-------|-------|
| **JIRA ID** | OMA-3 |
| **Epic** | OMA-3: Tampilan & Navigasi Aplikasi |
| **Sprint** | Sprint 1 |
| **Milestone** | Milestone 2 |
| **Priority** | High |
| **Story Points** | 6 |
| **Status** | ⬜ Draft |

---

## User Story

> **Sebagai** pelanggan Otomasiku,
> **Saya ingin** melihat semua layar utama aplikasi dan bisa berpindah antar layar dengan lancar,
> **Sehingga** saya bisa menjelajahi katalog produk, keranjang, checkout, dan profil saya tanpa hambatan.

---

## Context & References

| Reference | Link |
|-----------|------|
| PRD Module | `docs/PRD.md` § Modules 1–8 (all customer-facing) |
| Architecture | `docs/ARCHITECTURE.md` § Flutter folder structure, Hybrid Supabase + Express design |
| HTML Mockups | All 18 files in `ui-otomasiku-marketplace/` |
| AI Rules | `docs/AI_RULES.md` § UI Rules, i18n, File Naming, Mandatory Patterns |
| Plan Phase | `docs/PLAN_MILESTONE_2.md` § Phase M2-0 through M2-9 (BCA Sandbox exception) |
| Product Catalog | `docs/DUMMY_PRODUCT_MAPPING_PLAN.md` § 4 (10 products for Milestone 2) |

---

## Scope

This is the **parent epic spec** for all UI slicing work in Milestone 2. It covers:

- 18 screens total across 10 implementation phases (M2-0 to M2-9)
- All screens use dummy data (no backend) — **EXCEPTION:** BCA payment flow calls mini Express backend for VA creation
- All screens must pixel-match HTML mockups
- Milestone 2 uses **10 dummy products** (not full 125-product catalog)

### Sub-Task Breakdown (each gets its own spec)

| Sub-Task | JIRA | Spec File | M2 Phase |
|----------|------|-----------|----------|
| Project Setup & Dummy Data | — | `oma-3-0-project-setup.md` | M2-0 |
| Splash, Login & Register | — | `oma-3-1-auth-screens.md` | M2-1 |
| Bottom Nav & Home Screen | OMA-3 sub | `oma-3-2-home-screen.md` | M2-2 |
| Halaman Katalog (Grid + Search) | OMA-3 sub | `oma-3-3-product-catalog.md` | M2-2/M2-3 |
| Detail Produk | OMA-3 sub | `oma-3-4-product-detail.md` | M2-3 |
| Keranjang Belanja | OMA-3 sub | `oma-3-5-cart-screen.md` | M2-4 |
| Checkout & Shipping | OMA-3 sub | `oma-3-6-checkout.md` | M2-5 |
| Payment & Payment Success | OMA-3 sub | `oma-3-7-payment.md` | M2-6 |
| Order Detail | OMA-3 sub | `oma-3-8-order-detail.md` | M2-7 |
| Profile, Projects & Compare | OMA-3 sub | `oma-3-9-profile-projects.md` | M2-8 |
| Polish & Device Testing | — | `oma-3-10-polish.md` | M2-9 |

---

## Acceptance Criteria (Epic-Level)

### AC-1: All 15 screens are navigable
```gherkin
Given the app is launched on an Android device/emulator
When the user follows the complete customer flow
  (Splash → Login → Home → Search → Detail → Cart → Checkout → Shipping → Payment → Payment Success → Order Detail → Profile → Projects → Compare)
Then all 15 screens render without errors
And navigation between screens works (forward and back)
```

### AC-2: Bottom navigation works across all tabs
```gherkin
Given the user is logged in and on the Home screen
When the user taps each bottom nav tab (Beranda, Cari, Proyek, Keranjang, Profil)
Then the correct screen loads for each tab
And the active tab is highlighted in Mitsubishi Red (#E7192D)
And the cart badge shows the correct item count
```

### AC-3: Product catalog displays 10 dummy products
```gherkin
Given the app loads dummy data from dummy_products.dart (10 products)
When the user views the Home screen product grid
Then all 10 products are available (via scroll/pagination)
And each product card shows: real image, name, price, stock badge
And prices are formatted as "Rp X.XXX.XXX"
```

### AC-4: Visual fidelity matches HTML mockups
```gherkin
Given each Flutter screen is compared side-by-side with its HTML mockup
When inspecting colors, spacing, fonts, borders, and layout
Then the Flutter screen is pixel-faithful to the HTML reference
And uses Mitsubishi Red (#E7192D), Inter font, #F9FAFB background
```

### AC-5: Release APK runs on physical device
```gherkin
Given a release APK is built (flutter build apk --release)
When installed on a physical Android device
Then the full customer flow completes without crashes
And touch targets are ≥ 44dp
And the payment countdown timer runs smoothly
```

---

## Technical Design (Epic-Level)

### Architecture
- **State:** Riverpod (StateProvider for auth, StateNotifierProvider for cart)
- **Navigation:** GoRouter with ShellRoute for bottom nav
- **Data:** All from `lib/data/dummy/` files — 10 products, 1 user, 2 addresses, 3 orders, 2 projects
- **Images:** `Image.asset()` from `assets/images/products/` (real product photos)
- **Payment:** BCA Sandbox via mini Express backend (2 endpoints: create VA, callback)

### Screen Inventory

| # | Screen | Route | Phase |
|---|--------|-------|-------|
| 1 | Splash | `/` | M2-1 |
| 2 | Login | `/login` | M2-1 |
| 3 | Register | `/register` | M2-1 |
| 4 | Home | `/home` | M2-2 |
| 5 | Search Results | `/search` | M2-3 |
| 6 | Product Detail | `/product/:id` | M2-3 |
| 7 | Cart | `/cart` | M2-4 |
| 8 | Checkout | `/checkout` | M2-5 |
| 9 | Shipping | `/shipping` | M2-5 |
| 10 | Payment | `/payment/:orderId` | M2-6 |
| 11 | Payment Success | `/payment-success/:orderId` | M2-6 |
| 12 | Order Detail | `/order/:id` | M2-7 |
| 13 | Profile | `/profile` | M2-8 |
| 14 | Projects | `/projects` | M2-8 |
| 15 | Compare | `/compare` | M2-8 |

---

## Implementation Order

Follow `docs/PLAN_MILESTONE_2.md` strictly — each M2 phase is a sequential unit:

1. **M2-0:** Bootstrap (Flutter project, deps, dummy data, 10 products, theme, router)
2. **M2-1:** Auth screens (Splash, Login, Register)
3. **M2-2:** Bottom nav + Home screen (product grid with 10 products)
4. **M2-3:** Search + Product Detail
5. **M2-4:** Cart
6. **M2-5:** Checkout + Shipping
7. **M2-6:** Payment + Payment Success (BCA Sandbox via mini Express backend)
8. **M2-7:** Order Detail
9. **M2-8:** Profile, Projects, Compare
10. **M2-9:** Polish + device testing

**Each phase must pass its exit criteria before starting the next.**

---

## Out of Scope (Milestone 2)

- Full backend API calls (dummy data only)
- Supabase Auth integration (fake `isLoggedIn` boolean)
- Full 125-product catalog (only 10 dummy products)
- Real BCA production payment (Sandbox only via mini backend)
- Admin dashboard screens

---

## Notes

This epic spec serves as the overview. Each sub-task spec (listed above) will contain the detailed Given/When/Then acceptance criteria, exact file changes, widget trees, and verification checklists for that specific screen or feature.

The SDD workflow for this epic:
1. Write sub-task spec → get approval → implement → verify → mark ✅
2. Repeat for each M2 phase in order
3. After M2-9, the entire epic is ✅ DONE
