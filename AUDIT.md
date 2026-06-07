# API & Production-Readiness Audit

**Date:** 2026-06-07  
**Auditor:** Kiro (automated, based on full codebase + API.md + TRANSACTIONS_API_CONTRACT.md + PRD.md)

---

## 0. Pre-Execution Checklist

Before writing a single line of code, the implementing agent **must** complete all steps in this section in order.

### 0.1 Skills to Load

| # | Skill | File | Why |
|---|-------|------|-----|
| 1 | `test-driven-development` | `C:\Users\peter\.kiro\skills\test-driven-development\SKILL.md` | Write failing tests before any fix |
| 2 | `verification-before-completion` | `C:\Users\peter\.kiro\skills\verification-before-completion\SKILL.md` | Run `flutter analyze` + `flutter test` before claiming done |

> `ui-ux-pro-max` is **not** required — all bugs in this audit are data/logic, no UI design changes.  
> `supabase` is **not** required — all calls go through Dio/Express, not the Supabase SDK.

### 0.2 Project Documents to Read

| # | File | Why |
|---|------|-----|
| 1 | `docs/AI_RULES.md` | Mandatory coding conventions — overrides general best practices |
| 2 | `API.md` | Authoritative endpoint list; verify endpoint paths before touching any repository |
| 3 | `TRANSACTIONS_API_CONTRACT.md` | Exact request/response shapes for cart, orders, status history |
| 4 | `AGENTS.md` | Agent roles, branch naming (`feat/spec-XX-...`), commit style (Conventional Commits) |

### 0.3 Source Files to Read Before Each Bug Fix

Read these before touching the corresponding files — not before all bugs together.

**Bug #1 (order parse path):**
- `lib/data/repositories/order_repository.dart`
- `lib/data/repositories/payment_repository.dart`
- `lib/models/order.dart` + `lib/models/order.g.dart`
- `TRANSACTIONS_API_CONTRACT.md` § "3. Order Detail" (response shape)

**Bug #2 (split project providers):**
- `lib/providers/project_provider.dart`
- `lib/features/projects/projects_screen.dart`
- `lib/features/product_detail/product_detail_screen.dart` (the `_SaveToProjectSheet` class at the bottom)

**Bug #3 (status history field names):**
- `lib/data/repositories/order_repository.dart` (`OrderStatusHistory.fromJson`)
- `TRANSACTIONS_API_CONTRACT.md` § "GET /api/orders/:id/status-history" (response shape)

**Bug #4 (cart image field name):**
- `lib/models/cart_item.dart` + `lib/models/cart_item.g.dart`
- `TRANSACTIONS_API_CONTRACT.md` § "1. Cart — GET /api/cart" (`productSnapshot.imageUrl`)

**Bug #5 (missing Order model fields):**
- `lib/models/order.dart` + `lib/models/order.g.dart`
- `TRANSACTIONS_API_CONTRACT.md` § "3. Order Detail" (full field list)
- `lib/features/order/order_detail_screen.dart` (to know which fields are actually rendered)

### 0.4 Branch Strategy

One branch per sprint, not per bug.

| Sprint | Branch name | Bugs covered |
|--------|-------------|-------------|
| 1 | `fix/sprint1-unblock-checkout` | Bug #1, Bug #2 |
| 2 | `fix/sprint2-data-fidelity` | Bug #3, Bug #4 |
| 3 | `fix/sprint3-order-model` | Bug #5, missing `/me/devices` (backend) |

### 0.5 Verification Gate (mandatory before every commit)

```bash
./rtk.exe flutter analyze
./rtk.exe flutter test
```

Both must be clean. If `flutter test` has no tests for the changed code yet, the `test-driven-development` skill requires writing them first.

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Correct / production-ready |
| ⚠️ | Works but has a risk or missing feature |
| ❌ | Broken — will crash or silently return wrong data |
| 🚫 | Endpoint called but does not exist in API |
| 📋 | Planned / UI placeholder only |

---

## 1. Endpoint Audit — All Repository Calls vs API.md

### 1.1 Auth (`auth_repository.dart`)

| Dart Call | HTTP Method | Path | API.md? | Status | Notes |
|-----------|-------------|------|---------|--------|-------|
| `bootstrap()` | `POST` | `/me/bootstrap` | ✅ Section 3 | ✅ | Correct |

### 1.2 Profile (`profile_repository.dart`)

| Dart Call | HTTP Method | Path | API.md? | Status | Notes |
|-----------|-------------|------|---------|--------|-------|
| `getProfile()` | `GET` | `/me` | ✅ Section 3 | ✅ | Correct |
| `updateProfile()` | `PATCH` | `/me` | ✅ Section 3 | ✅ | Correct |
| `uploadAvatar()` | `POST` | `/me/avatar` | ✅ Section 3 | ✅ | Correct |
| `registerDeviceToken()` | `POST` | `/me/devices` | ❌ Not in API.md | 🚫 | Endpoint does not exist — will 404 on every app launch (FCM token registration) |
| `removeDeviceToken()` | `DELETE` | `/me/devices` | ❌ Not in API.md | 🚫 | Endpoint does not exist — will 404 on logout |

### 1.3 Addresses (`address_repository.dart`)

| Dart Call | HTTP Method | Path | API.md? | Status | Notes |
|-----------|-------------|------|---------|--------|-------|
| `getAddresses()` | `GET` | `/addresses` | ✅ Section 4 | ✅ | Correct |
| `getAddressById()` | `GET` | `/addresses/:id` | ✅ Section 4 | ✅ | Correct |
| `createAddress()` | `POST` | `/addresses` | ✅ Section 4 | ✅ | Correct |
| `updateAddress()` | `PUT` | `/addresses/:id` | ✅ Section 4 | ✅ | Correct |
| `deleteAddress()` | `DELETE` | `/addresses/:id` | ✅ Section 4 | ✅ | Correct |

### 1.4 Products (`product_repository.dart`)

| Dart Call | HTTP Method | Path | API.md? | Status | Notes |
|-----------|-------------|------|---------|--------|-------|
| `getProducts()` | `GET` | `/products` | ✅ Section 7 | ✅ | Correct |
| `getProductById()` | `GET` | `/products/:id` | ✅ Section 7 | ✅ | Correct |
| `getBrands()` | `GET` | `/brands` | ✅ Section 5 | ✅ | Correct |
| `getCategories()` | `GET` | `/categories` | ✅ Section 6 | ✅ | Correct |

### 1.5 Cart (`cart_repository.dart`)

| Dart Call | HTTP Method | Path | API.md? | Status | Notes |
|-----------|-------------|------|---------|--------|-------|
| `getCart()` | `GET` | `/cart` | ✅ Section 8 | ✅ | Correct |
| `addItem()` | `POST` | `/cart` | ✅ Section 8 | ✅ | Uses `X-Idempotency-Key` header ✅ |
| `updateItem()` | `PUT` | `/cart/:id` | ✅ Section 8 | ✅ | Correct |
| `removeItem()` | `DELETE` | `/cart/:id` | ✅ Section 8 | ✅ | Correct |
| `clearCart()` | `DELETE` | `/cart` | ✅ Section 8 | ✅ | Correct |

### 1.6 Orders (`order_repository.dart`)

| Dart Call | HTTP Method | Path | API.md? | Status | Notes |
|-----------|-------------|------|---------|--------|-------|
| `getOrders()` | `GET` | `/orders` | ✅ Section 9 | ✅ | Correct |
| `getOrderById()` | `GET` | `/orders/:id` | ✅ Section 9 | ❌ | **Response parsing broken** — see Bug #1 |
| `createOrder()` | `POST` | `/orders` | ✅ Section 9 | ✅ | Uses `X-Idempotency-Key` header ✅ |
| `getStatusHistory()` | `GET` | `/orders/:id/status-history` | ✅ Section 9 | ❌ | **Field names all wrong** — see Bug #3 |

### 1.7 Payment (`payment_repository.dart`)

| Dart Call | HTTP Method | Path | API.md? | Status | Notes |
|-----------|-------------|------|---------|--------|-------|
| `getPaymentStatus()` | `GET` | `/orders/:id` | ✅ Section 9 | ❌ | **Same parse error as `getOrderById`** — see Bug #1 |

### 1.8 Projects (no repository)

| Feature | Backend API | Status | Notes |
|---------|------------|--------|-------|
| Projects / RFQ | ❌ No endpoints in API.md | 📋 | Feature is intentionally local-only for now. But it is **broken** due to a split provider — see Bug #2 |

---

## 2. Contract Mismatch Bugs

### Bug #1 — `GET /api/orders/:id` response path (CRITICAL — checkout & payment broken)

**Severity:** 🔴 Critical — crashes payment screen on every real order  
**Files affected:**
- `lib/data/repositories/order_repository.dart` → `getOrderById()`
- `lib/data/repositories/payment_repository.dart` → `getPaymentStatus()`

**Root cause:**  
The contract says `GET /api/orders/:id` returns:
```json
{ "success": true, "data": { "order": { ...fields }, "items": [...] } }
```

Both repositories extract `apiResponse.data` and pass it directly to `Order.fromJson()`, but `data` is `{ "order": {...}, "items": [...] }`, not the order object. The parser then tries to read `data["orderNumber"]` which is `null`, causing:

```
type 'Null' is not a subtype of type 'String' in type cast
```

**Fix required:**
```dart
// order_repository.dart — getOrderById()
final data = apiResponse.data!;
final orderMap = data['order'] as Map<String, dynamic>;
orderMap['items'] = data['items']; // inject items into order map
return Order.fromJson(orderMap);

// payment_repository.dart — getPaymentStatus()
// Same fix
```

**Also:** `GET /api/orders` list endpoint returns order objects that **do not** include the nested `{ "order": {...}, "items": [...] }` wrapper — they are flat order objects. So `getOrders()` is parsing correctly. Only the single-order endpoint has the wrapper.

---

### Bug #2 — Project feature: disconnected Riverpod providers (CRITICAL — feature broken)

**Severity:** 🔴 Critical — user creates a project, it never appears in the bookmark modal  
**Files affected:**
- `lib/features/projects/projects_screen.dart`
- `lib/features/product_detail/product_detail_screen.dart` (`_SaveToProjectSheet`)
- `lib/providers/project_provider.dart`

**Root cause:**  
Two completely separate providers exist for projects:

| Provider | Type | Used in | Behavior |
|----------|------|---------|---------|
| `projectsProvider` | `StateProvider<List<Project>>` | `projects_screen.dart` | User creates projects here — writes to this provider |
| `projectProvider` | `StateNotifierProvider<ProjectNotifier, ProjectState>` | `_SaveToProjectSheet` | Bookmark modal reads from THIS provider — always empty |

When the user creates project "A" in `ProjectsScreen`, it goes into `projectsProvider`. When they open the bookmark modal, it watches `projectProvider.projects`, which is an entirely different, always-empty list.

**Fix required:**  
Delete `project_provider.dart` and `projectsProvider` in `projects_screen.dart`. Consolidate everything into a single `projectsProvider` (or rename to avoid confusion). The `_SaveToProjectSheet` must watch the same provider that `ProjectsScreen` writes to.

---

### Bug #3 — `OrderStatusHistory.fromJson` field names (MEDIUM — status timeline shows nothing)

**Severity:** 🟡 Medium — order detail status history silently shows no data  
**File:** `lib/data/repositories/order_repository.dart`

**Contract response fields:**
```json
{ "from_status": "...", "to_status": "...", "changed_by": "...", "note": "...", "created_at": "..." }
```

**Dart `fromJson` reads:**
```dart
status:    json['status']    // ← key doesn't exist → null → type cast crash
changedAt: json['changedAt'] // ← key doesn't exist → DateTime.parse(null) crash
changedBy: json['changedBy'] // ← key doesn't exist → null (ok, nullable)
notes:     json['notes']     // ← key doesn't exist → null (ok, nullable)
```

The model needs to be redesigned to match the actual contract shape:

| Contract field | Dart should read | Current Dart reads |
|----------------|------------------|--------------------|
| `to_status` | `json['to_status']` | `json['status']` ❌ |
| `from_status` | `json['from_status']` | not read ❌ |
| `created_at` | `json['created_at']` | `json['changedAt']` ❌ |
| `changed_by` | `json['changed_by']` | `json['changedBy']` ❌ |
| `note` | `json['note']` | `json['notes']` ❌ |

---

### Bug #4 — `CartProductSnapshot.primaryImageUrl` field name (MEDIUM — cart images broken)

**Severity:** 🟡 Medium — all cart item images are blank when loaded from API  
**File:** `lib/models/cart_item.dart` / `lib/models/cart_item.g.dart`

**Contract field name:** `imageUrl`  
**Dart model field:** `primaryImageUrl` (also the JSON key, per generated code)

The generated deserializer reads `json['primaryImageUrl']`, but the API sends `imageUrl`. Result: every cart item's image is blank (falls back to empty string default).

**Fix:** Add `@JsonKey(name: 'imageUrl')` to `primaryImageUrl` in `CartProductSnapshot`.

---

### Bug #5 — `Order` model missing contract fields (LOW — display only)

**Severity:** 🟢 Low — missing fields are not critical for current UI  
**File:** `lib/models/order.dart`

Fields present in `GET /api/orders/:id` contract but absent from the Dart `Order` model:

| Contract field | Type | Impact |
|----------------|------|--------|
| `subtotal` | `String` (BigInt) | Not displayed in order detail breakdown |
| `shippingCost` | `String` (BigInt) | Not displayed in order detail |
| `userId` | `String` | Not needed for UI |
| `shippedAt` | `DateTime?` | Not shown in timeline |
| `deliveredAt` | `DateTime?` | Not shown in timeline |
| `adminNotes` | `String?` | Not displayed |

---

## 3. Endpoint Coverage Summary

| Repository | Endpoints Called | In API? | Bugs |
|------------|-----------------|---------|------|
| `auth_repository` | 1 / 1 | 100% ✅ | None |
| `profile_repository` | 4 / 4 called; 2 of 4 don't exist | 50% ⚠️ | `POST /me/devices`, `DELETE /me/devices` → 404 |
| `address_repository` | 5 / 5 | 100% ✅ | None |
| `product_repository` | 4 / 4 | 100% ✅ | None |
| `cart_repository` | 5 / 5 | 100% ✅ | None (but see Bug #4 for data shape) |
| `order_repository` | 4 / 4 | 100% ✅ | Bug #1 (parse path), Bug #3 (status history fields) |
| `payment_repository` | 1 / 1 | 100% ✅ | Bug #1 (same parse path as order) |
| Projects | 0 (no repository) | N/A | Bug #2 (split providers) |

---

## 4. Feature Production-Readiness

### 4.1 Customer-Facing Features

| Feature | Screen | Endpoint(s) | Status | Blocker? |
|---------|--------|-------------|--------|---------|
| Splash | `splash_screen.dart` | None | ✅ Ready | — |
| Login | `login_screen.dart` | Supabase Auth | ✅ Ready | — |
| Register | `register_screen.dart` | Supabase Auth | ✅ Ready | — |
| Forgot Password | `forgot_password_screen.dart` | Supabase Auth | ✅ Ready | — |
| Product Catalog (list) | `home_screen.dart` | `GET /products` | ✅ Ready | — |
| Product Search | `search_screen.dart` | `GET /products?search=` | ✅ Ready | — |
| Product Detail | `product_detail_screen.dart` | `GET /products/:id` | ✅ Ready | — |
| Image Gallery (multi-image) | `product_detail_screen.dart` | — | ✅ Ready | — |
| Add to Cart | `product_detail_screen.dart` | `POST /cart` | ✅ Ready | — |
| Cart | `cart_screen.dart` | `GET /cart`, `PUT /cart/:id`, `DELETE /cart/:id` | ⚠️ Nearly ready | Cart images blank (Bug #4) |
| Checkout | `checkout_screen.dart` | `POST /orders` | ✅ Ready | Create order works |
| Payment (BCA VA) | `payment_screen.dart` | `GET /orders/:id` (polling) | ❌ Broken | Bug #1 — crashes on parse |
| Payment Success | `payment_success_screen.dart` | — | ✅ Ready | — |
| Payment Methods | `payment_methods_screen.dart` | None | 📋 Placeholder | UI-only, no functionality |
| Orders List | `orders_screen.dart` | `GET /orders` | ✅ Ready | — |
| Order Detail | `order_detail_screen.dart` | `GET /orders/:id` | ❌ Broken | Bug #1 — crashes on parse |
| Order Status History | `order_detail_screen.dart` | `GET /orders/:id/status-history` | ❌ Broken | Bug #3 — all fields wrong |
| Download Invoice | `order_detail_screen.dart` | None | 📋 `comingSoon` toast | Not implemented |
| Profile View/Edit | `profile_screen.dart`, `edit_profile_screen.dart` | `GET /me`, `PATCH /me` | ✅ Ready | — |
| Avatar Upload | `edit_profile_screen.dart` | `POST /me/avatar` | ✅ Ready | — |
| Addresses CRUD | `shipping_screen.dart`, `edit_address_screen.dart` | `/addresses/*` | ✅ Ready | — |
| Compare Products | `compare_screen.dart` | None (local state) | ⚠️ UI-only | No API — compare is local only |
| Projects (Proyek Saya) | `projects_screen.dart` | None | ❌ Broken | Bug #2 — split providers |
| Save to Project (bookmark) | `product_detail_screen.dart` | None | ❌ Broken | Bug #2 — split providers |
| Device Token (FCM push) | Called on auth events | `POST /me/devices` | 🚫 404 | Endpoint missing from API |
| Settings / Theme / Locale | `settings_screen.dart` | None | ✅ Ready | Local only |

### 4.2 Critical Path (Checkout Flow)

The core B2B purchase flow end-to-end:

```
Browse → Product Detail → Add to Cart → Checkout → Order Created → Payment Screen → VA → Paid → Success
```

| Step | Status | Note |
|------|--------|------|
| Browse products | ✅ | — |
| Add to cart | ✅ | Cart images blank (Bug #4, non-blocking) |
| Checkout / create order | ✅ | `POST /orders` works correctly |
| Redirect to payment screen | ✅ | orderId passed correctly |
| Payment screen loads order | ❌ | **Crashes here — Bug #1** |
| VA countdown display | ❌ | Unreachable due to crash |
| Poll for `paymentStatus = paid` | ❌ | Unreachable due to crash |
| Navigate to success screen | ❌ | Unreachable due to crash |

**The checkout flow fails at step 5.** Bug #1 is the only blocker to the entire payment experience.

---

## 5. Bugs Priority Matrix

| Bug | Severity | Feature Impact | Fix Complexity | Fix First? |
|-----|----------|---------------|----------------|-----------|
| **Bug #1** — `GET /orders/:id` parse path | 🔴 Critical | Breaks entire payment flow + order detail | Low — 2-line fix per repository | ✅ Yes |
| **Bug #2** — Split project providers | 🔴 Critical | Projects feature completely non-functional | Low — delete one provider, update one import | ✅ Yes |
| **Bug #3** — `OrderStatusHistory` field names | 🟡 Medium | Status timeline shows nothing | Low — fix `fromJson` field keys | Soon |
| **Bug #4** — `CartProductSnapshot.imageUrl` | 🟡 Medium | All cart images blank | Low — add `@JsonKey(name: 'imageUrl')` | Soon |
| **Bug #5** — Missing `Order` model fields | 🟢 Low | Missing fields in order detail UI | Medium — add fields + regenerate `.g.dart` | Later |
| **Missing** — `POST/DELETE /me/devices` | 🟡 Medium | FCM push never registered | Needs backend endpoint first | Backlog |

---

## 6. What Needs to Be Built (Gaps vs PRD)

| PRD Feature | API Exists? | Flutter Exists? | Gap |
|-------------|------------|----------------|-----|
| BCA VA payment (full flow) | ✅ | ✅ (broken by Bug #1) | Fix Bug #1 |
| Projects / RFQ (backend) | ❌ | ✅ (broken by Bug #2) | Design & implement project API endpoints |
| Compare products (backend) | ❌ | ✅ (UI-only) | Acceptable as local-only for v1 |
| Payment methods management | ❌ | ✅ (placeholder) | Not in PRD scope — remove or keep as placeholder |
| Download invoice | ❌ | ✅ (placeholder) | Implement PDF generation endpoint |
| FCM push notifications | ❌ | ✅ (calls missing endpoint) | Implement `POST /me/devices` in API |
| Contact support | ❌ | ✅ (placeholder) | WhatsApp deep link would suffice |
| Admin dashboard | ✅ | ❌ (Flutter Web, not in this repo) | Separate admin app or web panel |

---

## 7. Fix Plan (Recommended Order)

### Sprint 1 — Unblock the critical path

1. **Fix Bug #1** in `order_repository.dart` (getOrderById) and `payment_repository.dart` (getPaymentStatus):  
   Change `Order.fromJson(apiResponse.data!)` to `Order.fromJson(apiResponse.data!['order'] as Map<String, dynamic>)`, then inject `items` from `data['items']` into the order map.

2. **Fix Bug #2** in `projects_screen.dart` and `product_detail_screen.dart`:  
   Remove `projectsProvider` (StateProvider) from `projects_screen.dart`. Make `ProjectsScreen` use `projectProvider` (the `StateNotifierProvider`) everywhere. The `_SaveToProjectSheet` already uses the right one.

### Sprint 2 — Data fidelity

3. **Fix Bug #3** — Update `OrderStatusHistory.fromJson` field keys to match contract snake_case fields (`to_status`, `created_at`, `changed_by`, `note`). Update the model to carry `fromStatus` and `toStatus` instead of a single `status`.

4. **Fix Bug #4** — Add `@JsonKey(name: 'imageUrl')` to `CartProductSnapshot.primaryImageUrl`. Run `flutter pub run build_runner build`.

### Sprint 3 — Polish & completeness

5. **Fix Bug #5** — Add missing fields to `Order` model (`subtotal`, `shippingCost`, `shippedAt`, `deliveredAt`, `adminNotes`). Update order detail screen to display them.

6. **Backend:** Implement `POST /me/devices` and `DELETE /me/devices` endpoints in Express API for FCM token management.

7. **Backend:** Design and implement project/RFQ API endpoints so the project feature can persist across sessions.

---

## 8. Files to Change for Sprint 1 (Minimum Viable Fix)

```
lib/data/repositories/order_repository.dart    # getOrderById — fix data path
lib/data/repositories/payment_repository.dart  # getPaymentStatus — fix data path
lib/features/projects/projects_screen.dart     # remove projectsProvider, use projectProvider
lib/features/product_detail/product_detail_screen.dart  # already uses correct provider (no change needed)
```

> The `_SaveToProjectSheet` in `product_detail_screen.dart` already reads from `projectProvider` (the `StateNotifierProvider`). The only change needed is in `projects_screen.dart`: replace all references to `projectsProvider` (StateProvider) with `projectProvider.notifier.createProject(name)` for writes and `projectProvider` for reads.
