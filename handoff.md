# Handoff — 2026-06-07

## Changes Made

### Backend (`otomasiku-backend`)

#### 1. Fix: Welcome email sent repeatedly (BUG)

**File:** `src/infra/database/repositories/ProfileRepository.ts`

**Root cause:** `upsertDefaultCustomer` used `update: {}` (empty) in the Prisma upsert. Since nothing was written on update, `updated_at` remained equal to `created_at` for existing users. The `isNew` detection (`|updated_at - created_at| < 1000ms`) always returned `true`, firing a welcome email on every bootstrap call.

**Fix:** Changed to `update: { updated_at: new Date() }` so existing users get `updated_at` bumped, making the diff > 0 and `isNew = false`.

#### 2. Fix: `POST /api/cart` returning 201 instead of 200 (CONTRACT VIOLATION)

**File:** `src/interfaces/http/handlers/cart.handler.ts`

**Root cause:** Handler returned `res.status(201)` but `TRANSACTIONS_API_CONTRACT.md` specifies `200` for this endpoint.

**Fix:** Changed to `res.json(responseBody)` (default 200) and updated idempotency key storage from 201 → 200.

---

### Mobile (`otomasiku-mobile`)

#### 3. Feature: Pull-to-refresh on product detail screen

**File:** `lib/features/product_detail/product_detail_screen.dart`

Added `RefreshIndicator` wrapping the `SingleChildScrollView` with `AlwaysScrollableScrollPhysics`. Calls `productListProvider.notifier.refresh()` — same network path as the home screen for consistent refresh duration/feel.

#### 4. Feature: Image gallery with PageView + dot indicators

**File:** `lib/features/product_detail/product_detail_screen.dart`

Replaced single static image with:
- `PageView.builder` when product has 2+ images (sorted by `sortOrder`)
- Animated pill-style dot indicators (active = 20px red, inactive = 6px translucent)
- Falls back to single image when only 1 image exists
- Dark mode compatible

#### 5. Fix: Unmodifiable list sort crash in image gallery

**File:** `lib/features/product_detail/product_detail_screen.dart`

**Root cause:** `product.images..sort()` mutated the original list in-place. The list from JSON deserialization / `const []` default is unmodifiable → runtime error.

**Fix:** Changed to `List<ProductImage>.from(product.images)..sort(...)` to sort a mutable copy.

---

## Contract Audit Summary

Full audit of all transaction endpoints against `TRANSACTIONS_API_CONTRACT.md`:

| Endpoint | Status |
|----------|--------|
| `GET /api/cart` | ✅ Compliant |
| `POST /api/cart` | ✅ Fixed (was 201, now 200) |
| `PUT /api/cart/:id` | ✅ Compliant |
| `DELETE /api/cart/:id` | ✅ Compliant |
| `DELETE /api/cart` | ✅ Compliant |
| `POST /api/orders` | ✅ Compliant (201) |
| `GET /api/orders` | ✅ Compliant |
| `GET /api/orders/:id` | ✅ Compliant |
| `GET /api/orders/:id/status-history` | ✅ Compliant |
| `PATCH /api/admin/orders/:id/status` | ✅ Compliant |
| `POST /api/payment/bca/callback` | ✅ Compliant |
| BigInt serialization (prices as strings) | ✅ Via `BigInt.prototype.toJSON` |
| UUID param validation | ✅ All via `parseUuid` |
| Idempotency-Key enforcement | ✅ Cart + Orders |

---

## Files Modified

```
# Backend
src/infra/database/repositories/ProfileRepository.ts   # isNew fix
src/interfaces/http/handlers/cart.handler.ts            # 201→200

# Mobile
lib/features/product_detail/product_detail_screen.dart  # refresh + gallery + sort fix
```

---

## Pending (unchanged from previous handoff)

| Item | Action |
|------|--------|
| `AdminAuditLog.resource_id` migration | Run `pnpm db:migrate` on staging/prod |
| Product text search index | Optional — only if latency confirmed at scale |
