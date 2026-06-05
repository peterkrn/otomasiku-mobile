# 🛠️ Otomasiku — Cross-Repo Remediation & Audit Plan (Master)

> **Status:** 📝 Plan (no code changes yet) · **Created:** 2026-06-05
> **Scope:** All 3 repos — `otomasiku-mobile` (Flutter), `otomasiku-backend` (Express/Prisma), `otomasiku-admin` (Next.js)
> **Owner of this doc:** central hub. Per-repo execution detail lives in:
> - Backend → `otomasiku-backend/REMEDIATION_PLAN.md`
> - Admin → `otomasiku-admin/REMEDIATION_PLAN.md`
> - Mobile error/image work → this file (§3, §4)

---

## 0. How to Read This Plan

This is a **pre-launch hardening plan**. It has three goals, in priority order:

1. **Zero raw error screens** in the Flutter app (the user's #1 requirement). A global safety net + reusable typed error views + per-page specific error states. → §3
2. **Product images appear** everywhere they should (catalog grid, search, cart, checkout, compare, detail). Root cause is in the backend list serializer. → §4
3. **A verified feature matrix** — every feature classified ✅ Succeeded / ⚠️ Error / ⬜ Coming Soon, with evidence. → §2

### Status legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Implemented **and** code-evidence supports it works. **Provisional** until on-device verification by the project owner. |
| ⚠️ | Implemented but has a **confirmed bug** (in code or in `bug.md`/`EDGE_CASE.md`) — needs a fix. |
| ⬜ | **Coming Soon** — not integrated to the real backend, or stubbed/simulated/partial. |
| 🔌 | Integration/contract issue **spanning repos** — fix must be coordinated. |

> ⚠️ **Verification honesty note (per `verification-before-completion` skill):** I have **not** executed the app, the backend, or any tests while writing this plan. Every ✅ below is a *code-reading* judgment, not a runtime proof. The verification commands in §6 must be run during execution before any ✅ is treated as final. **Device/emulator testing is done by the project owner** (their emulator can't run on the dev machine) — so this plan never assigns "run on emulator" to the agent; it produces a manual device test checklist instead (§6.3).

---

## 1. System Map (confirmed by code reading)

```
Flutter app (otomasiku-mobile)
  ├── Supabase SDK ──→ Supabase Auth (login/register/refresh/reset)
  └── Dio ──→ Express API (otomasiku-backend, Railway)
                 ├── Prisma ──→ Supabase PostgreSQL
                 └── Supabase Storage (product images/docs, avatars)

Admin panel (otomasiku-admin, Next.js)
  └── authFetch ──→ same Express API (/api/* incl. /api/admin/*)
```

- **Error envelope (all endpoints):** `{ "success": false, "error": { "code", "correlationId", "details" } }` — confirmed in `otomasiku-backend/src/interfaces/http/middlewares/error-handler` + `API.md`.
- **Money:** `int` Rupiah in Flutter; backend serializes Prisma `BigInt` → string (see `index.ts` BigInt.toJSON shim + `BigIntStringConverter` in Flutter).
- **Auth:** Supabase JWT as `Authorization: Bearer`. 401 → one refresh attempt in `ApiInterceptor`, else `onSessionExpired` → `/login`.

---

## 2. Cross-Repo Feature Matrix

> Provisional statuses from code reading. Confirm with §6 before sign-off.

### 2.1 Mobile (Flutter) — customer app

| # | Feature | Screen / Provider | Status | Notes / Evidence |
|---|---------|-------------------|--------|------------------|
| M1 | Splash + manual entry | `splash_screen.dart` | ✅ | Router never auto-redirects from splash. |
| M2 | Login | `login_screen.dart` / `auth_provider` | ✅ | bug.md #7,#9,#20 fixed. |
| M3 | Register + email confirmation | `register_screen.dart` | ✅ | bug.md #7,#8,#9 fixed. |
| M4 | Forgot / reset password (deep link) | `forgot_password_screen.dart`, `reset_password_screen.dart` | ✅ | bug.md #26,#27. Verify deep link `io.otomasiku.app://login-callback` on device. |
| M5 | "Remember me" | `token_storage.dart` | ✅ | bug.md #28. |
| M6 | Product catalog (grid + pagination) | `home_screen.dart`, `product_provider` | ⚠️🔌 | **No images** (backend list bug §4). **Pagination `_hasMore` logic suspect** (§5-B5). |
| M7 | Product brand/category filter | `product_provider`, `catalog_provider` | ⚠️🔌 | **Filter broken**: Flutter sends `brand`/`category`; backend reads `brandId`/`categoryId` (§5-B1). |
| M8 | Search | `search_screen.dart` | ✅ | Uses `search` param (matches backend). No images until §4. |
| M9 | Product detail (gallery, specs, tiers) | `product_detail_screen.dart` | ✅ | Detail endpoint **does** return `images` — should show once data exists. |
| M10 | Compare | `compare_screen.dart` | ✅ | bug.md #21,#22,#23. Note hardcoded strings (§5-C). |
| M11 | Cart CRUD + optimistic + idempotency | `cart_screen.dart`, `cart_provider` | ✅ | bug.md #11,#12; EDGE_CASE #2,#3,#4. |
| M12 | Checkout + place order | `checkout_screen.dart`, `order_provider` | ✅ | bug.md #1,#2,#3,#5; EDGE_CASE #1,#10. |
| M13 | Payment (BCA VA, countdown, polling) | `payment_screen.dart`, `payment_provider` | ⬜ | **Simulated in `kDebugMode`** (EDGE_CASE #5). Real BCA sandbox path unverified. |
| M14 | Payment success | `payment_success_screen.dart` | ✅ | bug.md #1,#11,#12. |
| M15 | Orders list + detail + status timeline | `orders_screen.dart`, `order_detail_screen.dart` | ⚠️🔌 | App side OK (EDGE_CASE #7 fixed). **Admin shows 0 items** → backend detail bug (§5-B3). |
| M16 | Profile view/edit | `profile_screen.dart`, `edit_profile_screen.dart` | ✅ | handoff.md done. |
| M17 | Avatar upload | `POST /api/me/avatar` | ⬜ | Endpoint exists; **Flutter wiring pending** (handoff "Still Pending"). |
| M18 | Addresses CRUD | `address_provider`, `edit_address_screen.dart`, `shipping_screen.dart` | ✅ | Repo tests exist. Hardcoded toast string (§5-C). |
| M19 | Projects ("Simpan ke Proyek") | `project_provider`, `projects_screen.dart` | ⬜ | **Local-only `StateProvider`**, no backend endpoint. bug.md #24,#25. |
| M20 | Payment methods screen | `payment_methods_screen.dart` | ✅ | RFQ → WhatsApp (bug.md #31). |
| M21 | Push notifications (FCM) | `core/notifications/*` | ⬜ | Service exists; **token registration on login + deep-linking pending** (handoff). |
| M22 | Offline banner / connectivity | `connectivity_provider`, `offline_banner.dart` | ✅ | — |
| M23 | i18n (ID/EN) + locale toggle | `l10n/*`, `locale_provider` | ✅ | bug.md #9 (toggle). Build fails if ARB keys missing in either file. |
| M24 | Theme (light/dark) | `theme_provider`, `app.dart` | ✅ | M3 surfaces overridden (bug.md #14). |
| M25 | **Global raw-error safety net** | — | ⚠️ | **MISSING.** No `ErrorWidget.builder` / `FlutterError.onError` / `runZonedGuarded`. → §3. This is the headline gap. |

### 2.2 Backend (Express) — `otomasiku-backend`

| # | Feature | Location | Status | Notes |
|---|---------|----------|--------|-------|
| B1 | Auth (signup/login/logout/refresh) | `auth.handler.ts` | ✅ | — |
| B2 | Me / profile / bootstrap / avatar | `me.handler.ts`, `me-extra.handler.ts` | ✅ | — |
| B3 | Addresses CRUD | `address.handler.ts` | ✅ | Policy tested. |
| B4 | Brands / Categories CRUD | `brand.handler.ts`, `category.handler.ts` | ✅ | — |
| B5 | Products list | `product.handler.ts` `getProducts` | ⚠️🔌 | **`mapToEntity` drops `images`** → list returns no images (§4). Filter reads `brandId`/`categoryId` only (§5-B1). |
| B6 | Product detail / slug | `getProductById/Slug` | ✅ | `findById` attaches `images`+`documents`. |
| B7 | Product assets (upload/list/reorder/primary/delete) | `product.handler.ts`, `product-asset.handler.ts` | ✅ | Supabase Storage; max 8 images; auto-primary. |
| B8 | Cart CRUD + idempotency | `cart.handler.ts` | ✅ | Repo tested. |
| B9 | Orders create/list/detail/status-history | `order.handler.ts` | ⚠️ | **`GET /admin/orders/:id` items missing** (bug.md Remaining #1) → verify includes order items (§5-B3). |
| B10 | Admin orders (list/export/status) | `admin.handler.ts`, `order.handler.ts` | ✅ | Status flows tested (CancelOrder, UpdateShipping, ConfirmDelivery). |
| B11 | Admin users (list/role) | `admin.handler.ts` | ✅ | — |
| B12 | Admin stats / email-logs / audit-logs | `admin.handler.ts` | ✅ | — |
| B13 | Admin WhatsApp contacts | `admin.handler.ts` | ✅ | — |
| B14 | Payment BCA callback (HMAC) | `payment.handler.ts`, `ProcessBcaCallbackFlow` | ✅ | Flow + signature tested. Real sandbox path = owner verification. |
| B15 | Error envelope + correlation + rate limit + security headers | `middlewares/*` | ✅ | — |

### 2.3 Admin (Next.js) — `otomasiku-admin`

| # | Feature | Location | Status | Notes |
|---|---------|----------|--------|-------|
| A1 | Login (Supabase) | `app/login/*` | ✅ | — |
| A2 | Dashboard stats | `(dashboard)/DashboardContent.tsx` | ✅ | — |
| A3 | Orders list / detail / status / export | `(dashboard)/orders/*`, `lib/orders.ts` | ⚠️🔌 | **"0 items in this order"** → depends on backend B9 fix (§5-B3). |
| A4 | Users list / role | `(dashboard)/users/*` | ✅ | — |
| A5 | Products CRUD | `(dashboard)/products/*`, `ProductForm.tsx`, `lib/products.ts` | ✅ | — |
| A6 | Product image manager | `ProductImageManager.tsx` | ✅🔌 | Works vs `/assets` + `/images`. Has Supabase fallback on 404. Verify after backend §4 (§ admin plan). |
| A7 | Product document manager | `ProductDocumentManager.tsx` | ✅ | — |
| A8 | Brands / Categories admin | `(dashboard)/brands`, `categories` | ✅ | — |
| A9 | Payments view | `(dashboard)/payments/*` | ✅ | — |
| A10 | Email logs | `(dashboard)/email-logs/*` | ✅ | — |
| A11 | Error boundaries | `error.tsx`, `global-error.tsx`, `not-found.tsx`, `ErrorState.tsx` | ✅ | Already present; review for parity (§ admin plan). |

---

## 3. WORKSTREAM A — Zero Raw Errors (Mobile) 🔴 Priority 1

**Goal:** It must be **impossible** for the user to ever see Flutter's built-in red/gray error screen or a raw exception string. Every failure shows a branded, localized, actionable screen.

### 3.1 Root-cause classes of "raw error"

| Class | Example (from `flutter_errors.md`) | Current handling | Fix |
|-------|-----------------------------------|------------------|-----|
| **Build/layout assertion** | `RenderCustomMultiChildLayoutBox expected … but received RenderSliverToBoxAdapter` | none → red screen | A1 global `ErrorWidget.builder` + A4 fix sliver/box misuse |
| **Router element-tree assertion** | `_elements.contains(element)`, `_dependents.isEmpty` | partially fixed (bug.md #17,#18) but recurs | A1 safety net + A4 harden nav patterns |
| **Uncaught async/zone errors** | Dio/parse errors outside `.when` | inconsistent | A2 `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError` |
| **Async provider error states** | `.when(error:)` showing `Text('$err')` | inconsistent (some raw) | A3 reusable `AppErrorView` everywhere |
| **Image load failure** | network image 404 | generic placeholder only | A5 specific image error state |

### 3.2 Tasks

**A1 — Global `ErrorWidget.builder` (the safety net).**
- New file: `lib/core/errors/app_error_widget.dart` → `AppErrorWidget(FlutterErrorDetails details)`.
- Behavior: branded scaffold-safe widget (icon + friendly localized message + "Muat ulang"/"Kembali ke Beranda"). Must be **constraint-safe** (it can be inserted into any parent, incl. slivers/rows) — render inside a `Material` + `Center` with `mainAxisSize.min`, no unbounded `Expanded`.
- In `main.dart`: `ErrorWidget.builder = (d) => AppErrorWidget(d);`
- **Debug vs release (confirmed best practice):** in `kDebugMode` show `details.exceptionAsString()` + stack in a scrollable box; in release show only the friendly message + a short copyable correlation/report id. Record to Crashlytics in both.

**A2 — Catch non-widget errors.** In `main.dart`:
- Wrap `runApp` in `runZonedGuarded`.
- `FlutterError.onError = (d) { FlutterError.presentError(d); FirebaseCrashlytics.instance.recordFlutterError(d); }`
- `PlatformDispatcher.instance.onError = (e, st) { Crashlytics.recordError(e, st, fatal: true); return true; }`
- Zone `onError` → Crashlytics. (Crashlytics already used in `ApiInterceptor`.)

**A3 — Reusable typed error view.** New file `lib/shared/widgets/app_error_view.dart`:
- `AppErrorView({required Object error, VoidCallback? onRetry, AppErrorKind? kindOverride})`.
- Picks icon/copy by mapping the thrown object via a **new** helper `errorMessageFor(Object error, AppLocalizations l10n)` added to `lib/core/utils/error_handler.dart`:
  - `NetworkException` → offline icon + "Tidak ada koneksi" + retry.
  - `TimeoutException` → "Permintaan timeout" + retry.
  - `SessionExpiredException` → "Sesi berakhir" + go to login.
  - `ServerException` → "Kesalahan server" + correlationId (debug) + retry.
  - `ApiException` → `translateErrorCode(e.code, l10n, details: e.details)`.
  - unknown → generic + retry.
- Deprecate/replace `RetryWidget` usages with `AppErrorView`.

**A4 — Eliminate the structural root causes** (so the safety net is rarely hit):
- Audit every route **outside** the `StatefulShellRoute` uses `parentNavigatorKey: _rootNavigatorKey` (verified present today — keep it as a regression check).
- Rule: navigate **out of the shell** with `pushNamed`, never `goNamed` (bug.md #18). Add to `AI_RULES.md`.
- Ensure no sliver widget is returned into a box `.when` callback (EDGE_CASE #7). `AppErrorView` is a box widget; add a `AppErrorSliver` variant for `CustomScrollView` error states (orders tabs).

**A5 — Specific image error state.** Enhance `lib/shared/widgets/product_image.dart`:
- Add named constructors / params: `ProductNetworkImage.card()` (subtle placeholder, current behavior) and `ProductNetworkImage.detail()` (gallery: show error tile with icon + "Gagal memuat gambar" + tap-to-retry via `CachedNetworkImage` `errorWidget` + a key bump).
- In `kDebugMode`, append the failing URL/status under the message.

**A6 — Per-page error-state sweep.** Replace ad-hoc/raw error UI with `AppErrorView`/`AppErrorSliver`:

| File | Line (approx) | Current | Replace with |
|------|---------------|---------|--------------|
| `features/checkout/widgets/address_selector.dart` | 193 | `Text(...)` raw error | `AppErrorView(error:…, onRetry:…)` |
| `features/home/screens/home_screen.dart` | 149 | `RetryWidget` | `AppErrorView` + empty state when 0 products |
| `features/order/orders_screen.dart` | 101 | `RetryWidget` (sliver context) | `AppErrorSliver` |
| `features/shipping/shipping_screen.dart` | 68 | `Center(...)` | `AppErrorView` |
| `features/payment/payment_screen.dart` | 113 | `Center(...)` | `AppErrorView` (+ VA_EXPIRED/PAYMENT_FAILED specific copy) |
| `features/payment/payment_success_screen.dart` | 94 | fallback card | keep, but ensure no raw text |
| `features/product_detail/product_detail_screen.dart` | 59 | `_buildErrorScreen` | route through `AppErrorView` + PRODUCT_NOT_FOUND copy |
| `features/order/order_detail_screen.dart` | 31, 218 | Scaffold/static fallback | `AppErrorView` + keep static timeline fallback |

**A7 — i18n + hardcoded-string cleanup.** Add new error ARB keys to **both** `app_id.arb` and `app_en.arb` (build fails otherwise). Replace confirmed hardcoded strings (AI_RULES violation):
- `product_detail_screen.dart:556,587` → "Anda belum login…" → `l10n.notLoggedIn`.
- `edit_address_screen.dart:110` → "Gagal menyimpan alamat" → `l10n.addressSaveFailed`.
- `search_screen.dart:175,177` → compare toasts → existing `l10n.compareMaxError`/`l10n.addedToCompare`.

### 3.3 TDD for Workstream A (per `test-driven-development` skill)
Write the failing test **first** for each unit:
- `test/core/errors/error_handler_test.dart` — `errorMessageFor` returns the right localized string for each `AppException` subtype + `ApiException` codes (table-driven). RED → GREEN.
- `test/shared/widgets/app_error_view_test.dart` — renders message, shows retry button, fires `onRetry`; in debug shows details. (widget test)
- `test/shared/widgets/app_error_widget_test.dart` — `AppErrorWidget` builds without throwing inside a constrained box and inside an unconstrained context.
- Regression test for A4: a widget test that pumps the orders error sliver inside a `CustomScrollView` and asserts no exception (reproduces EDGE_CASE #7 red→green).

### 3.4 Acceptance criteria (Workstream A)
- [ ] `ErrorWidget.builder` set before `runApp`; manual "throw in build" smoke test shows branded screen, not red box. (owner device test)
- [ ] No `.when(error:)` callback in `lib/` renders a raw `Text('$err'|error.toString())`. (grep §6.2)
- [ ] All new strings exist in both ARB files; `flutter gen-l10n` / `flutter pub get` succeeds.
- [ ] `flutter analyze` clean; new tests pass.

---

## 4. WORKSTREAM B — Product Images Code Path 🔴 Priority 1 (cross-repo) 🔌

**Confirmed root cause:** `otomasiku-backend/.../ProductRepository.ts` → `findMany()` **does** `include: { images: true }`, but `mapToEntity()` constructs a scalar `Product` entity and **discards images**. So `GET /api/products` (list) returns products **without** an `images` array. The Flutter grid/cards rely on `Product.primaryImageUrl`, which returns `''` when `images` is empty → every card falls back to the placeholder icon.
Detail (`findById`) is fine — it `Object.assign(entity, { images, documents })`.

**Decision (owner-approved): fix the code path only.** Assume admins upload images going forward; do not seed/migrate data in this plan.

### 4.1 Coordinated tasks (detail in per-repo plans)

| Repo | Task | File |
|------|------|------|
| **backend** | Include a serialized image set in the **list** response (at minimum `primaryImageUrl`, ideally full `images[]`), without N+1. | `ProductRepository.findMany` + `getProducts` serializer → see backend plan §B-1 |
| **backend** | Decide list payload shape: add `images: [{id,url,isPrimary,sortOrder}]` (camelCase) to each product, matching detail. Update `API.md` §7. | backend plan §B-1 |
| **mobile** | `Product.images` already parsed (`@JsonKey(defaultValue: [])`) + `primaryImageUrl` getter already exists — **likely no model change** once backend returns `images`. Confirm the list JSON key casing matches `ProductImage` (`is_primary`/`sort_order` vs `isPrimary`). | `lib/models/product.dart` — see §5-B2 (casing contract) |
| **admin** | Confirm `ProductImageManager` still aligns with `/images` (snake_case) + `/assets`; remove Supabase 404-fallback once backend list/endpoints are stable (optional). | admin plan §AD-1 |

### 4.2 ⚠️ Contract decision to lock (cross-repo) 🔌
The detail endpoint returns image rows from Prisma. Confirm the **exact JSON casing** the Flutter `ProductImage.fromJson` expects:
- Flutter `ProductImage` uses `@JsonKey(name: 'is_primary')`, `@JsonKey(name: 'sort_order')`, plus `id` (String via converter? — **verify**), `url`, `path`.
- Backend `/images` endpoint returns snake_case (`is_primary`, `sort_order`) — admin maps it manually.
- **The list/detail `images` embedded in the product** must use the **same casing** Flutter expects. **Lock one contract** and document in `API.md`. Recommended: embed `images` as `{ id, url, isPrimary, sortOrder }` and update Flutter `ProductImage` JsonKeys to match — OR keep snake_case and ensure Flutter keys match. (Pick one; see §5-B2.)

### 4.3 Acceptance criteria (Workstream B)
- [ ] `GET /api/products` returns each product with a non-empty `images` (or `primaryImageUrl`) when the product has images. (backend test + manual curl)
- [ ] Flutter grid/search/cart/compare show real images (owner device test).
- [ ] `flutter analyze` clean; backend `tsc`/tests pass; no model regression in `test/models/product_test.dart`.

---

## 5. WORKSTREAM C — Other Confirmed Bugs

| ID | Severity | Bug | Repo(s) | Fix summary |
|----|----------|-----|---------|-------------|
| **B1** | High 🔌 | **Brand/category filter no-op** — Flutter sends `brand`/`category` (slugs); backend reads `brandId`/`categoryId` (ints). | mobile + backend | Lock contract. Recommended: backend accepts `brand`/`category` as **slug** (resolve slug→id) for the public list **and** keeps `brandId`/`categoryId` (admin). Update `API.md`. Flutter keeps sending slugs. (Detail in backend plan §B-2.) |
| **B2** | High 🔌 | **ProductImage JSON casing contract** unverified between list/detail and Flutter model. | mobile + backend | Confirm/lock casing (see §4.2). Add a model parse test from a real sample payload. |
| **B3** | High 🔌 | **Admin order detail shows "0 items"** (bug.md Remaining #1). Flutter sends cart correctly (server computes totalAmount), so suspect `GET /admin/orders/:id` (or its serializer) omits `items`. | backend (+admin verify) | Backend: ensure admin order-detail includes order items (eager load + serialize). Admin: render items. (Detail in backend plan §B-3, admin plan §AD-2.) |
| **B4** | Med | **Catalog pagination `_hasMore`**: `productListProvider.loadMore` sets `_hasMore = response.data.length < response.total` using the **page** length, not cumulative loaded count → can stop early/late. | mobile | Track cumulative loaded count: `_hasMore = loaded.length < response.total`. Add provider test. |
| **B5** | Med | **Payment is simulated in `kDebugMode`** (EDGE_CASE #5) + simulated order detail for `sim-*` ids. Fine for dev, but must be clearly gated and not leak to release. | mobile | Audit `kDebugMode` branches in `order_repository`/`payment_provider`/`order_detail`; ensure release path hits real API. Document as "Coming Soon: live BCA sandbox verification". |
| **B6** | Low | **Hardcoded UI strings** (AI_RULES violation) in product detail/edit address/search. | mobile | Move to ARB (§3.2 A7). |
| **B7** | Low | **Projects feature is local-only** (no persistence/backend). | mobile (+backend future) | Mark ⬜ Coming Soon explicitly in UI or backlog a `projects` API. No fix required for launch; document. |

---

## 6. Verification Strategy (evidence-based, no agent emulator runs)

> Per the owner's instruction, the **agent never runs a device/emulator**. The agent runs static + unit/widget verification; the **owner** runs the device checklist.

### 6.1 Commands the agent MUST run before claiming any task done

**Mobile (`otomasiku-mobile`, Flutter only):**
```bash
./rtk.exe flutter pub get          # regenerates l10n + .g.dart; fails if ARB keys missing
./rtk.exe flutter analyze          # must be clean
./rtk.exe flutter test             # all unit/widget tests
```

**Backend (`otomasiku-backend`, pnpm/Node only — run in that repo, never here):**
```bash
pnpm install
pnpm tsc --noEmit        # or: pnpm build  — type-check the image/filter changes
pnpm test                # Vitest/Jest — Product/Order/Cart repos + flows
```

**Admin (`otomasiku-admin`, pnpm/Node only):**
```bash
pnpm install
pnpm lint
pnpm build               # Next.js production build must succeed
```

> ⚠️ **Never cross-run** (AGENTS.md): Flutter commands only in the mobile repo; pnpm commands only in backend/admin.

### 6.2 Static greps that must return **zero** matches (mobile) after Workstream A
```bash
# raw error text rendered to the user
rg "Text\('Error" lib/
rg "error\.toString\(\)" lib/ | rg -v "debugPrint|Crashlytics|catch"
rg "\.when\(" lib/ -A3 | rg "Text\(\s*'\\\$err"
# hardcoded Indonesian UI strings flagged in §5-B6 (manual review of hits)
rg "Anda belum login|Gagal menyimpan alamat" lib/
```

### 6.3 Owner device test checklist (manual, on real device)
- [ ] Force a build error (temp) → branded screen, not red box. Then revert.
- [ ] Airplane mode → open Home → `AppErrorView` offline state + retry works.
- [ ] Catalog grid shows **real product images** (post §4) + filter by brand/category returns filtered results (post §5-B1).
- [ ] Product detail gallery shows images; broken image → "Gagal memuat gambar" tile.
- [ ] Cart / checkout / payment / orders error paths never show raw text.
- [ ] Admin order detail shows line items (post §5-B3).
- [ ] Toggle ID/EN — all new error strings localized.

---

## 7. Sequencing

```
Phase 1 (backend, unblocks mobile):
  B-1 images in list  ·  B-2 filter contract  ·  B-3 admin order items
  → tsc + tests + update API.md

Phase 2 (mobile error overhaul — independent of Phase 1):
  A1 ErrorWidget.builder · A2 zone/FlutterError · A3 AppErrorView + errorMessageFor
  A4 nav/sliver hardening · A5 image error state · A6 page sweep · A7 i18n
  → flutter analyze + flutter test + grep gate

Phase 3 (mobile contract alignment, after Phase 1):
  B2 ProductImage casing · B1 filter slugs · B4 pagination · verify images render
  → flutter analyze + flutter test

Phase 4 (admin verify, after Phase 1):
  AD-1 image manager vs stabilized endpoints · AD-2 order items render
  → lint + build

Phase 5 (cleanup / docs):
  B5 kDebugMode audit · B6 strings · B7 projects status · update bug.md/EDGE_CASE.md
```

Phase 1 and Phase 2 can run in parallel (different repos, no shared files).

---

## 8. Branching & PRs (per AGENTS.md / git_safety)
- Mobile: `feat/zero-raw-errors`, `fix/product-images-render`, `fix/catalog-filter-pagination`.
- Backend: `fix/product-list-images`, `fix/admin-order-items`, `fix/product-filter-contract`.
- Admin: `chore/verify-image-manager`.
- Conventional Commits. No direct pushes to `master`/`main`. Request code review per `.agents/skills/code-review/SKILL.md` before merge.

---

## 9. Open Questions / Assumptions
1. **Assumption:** ProductImage list contract will be locked to match the Flutter model (§4.2). If the owner prefers the backend to be source of truth, Flutter `ProductImage` JsonKeys change instead — either way the plan covers it.
2. **Assumption:** No data seeding for images (owner chose "fix code path only"). If existing products have **no** uploaded images, grids stay on placeholders until admins upload — that is expected, not a bug.
3. **BCA live sandbox** verification is owner-driven; marked ⬜ Coming Soon, not in scope to "make pass" here.
```
