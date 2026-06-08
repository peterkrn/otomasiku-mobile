# Handoff — 2026-06-08

## Session Summary

Replaced BCA Developer API callback flow with manual bukti transfer upload + admin verification. Also fixed product availability handling across admin and mobile.

---

## Changes Made

### Backend (`otomasiku-backend`) — branch: `staging`

#### 1. Payment Proof Flow (NEW)

**New files:**
- `src/app/flows/PaymentProofFlow.ts` — upload to private Supabase bucket (`otomasiku-payment-proofs`), signed URL generation (1h expiry), admin approve/reject with transactional status updates
- `src/interfaces/http/handlers/payment-proof.handler.ts` — 4 HTTP handlers using Busboy multipart

**New endpoints:**
- `POST /api/orders/:id/payment-proof` — customer uploads bukti transfer (image + bankName + accountName + amount)
- `GET /api/orders/:id/payment-proof` — customer checks proof status
- `GET /api/admin/orders/:id/payment-proof` — admin views proof
- `PATCH /api/admin/orders/:id/payment-proof` — admin approves (`→ paid + processing`) or rejects (with reason)

**Modified files:**
- `src/interfaces/http/routes/order.routes.ts` — added customer proof routes
- `src/interfaces/http/routes/admin.routes.ts` — added admin proof routes
- `src/app/flows/CreateOrderFlow.ts` — returns static `vaNumber` from env
- `src/app/flows/GetOrderFlow.ts` — includes `paymentProof` (with signed URL) in order response
- `src/config/env.ts` — added `BCA_VA_NUMBER`, `BCA_ACCOUNT_NAME`, `SUPABASE_PAYMENT_PROOF_BUCKET`

#### 2. Email on Payment Proof Approval

**File:** `src/app/flows/PaymentProofFlow.ts`

On approve: sends `ORDER_PROCESSING` email to both customer and company (`EMAIL_TO_COMPANY`).

#### 3. Status History — Include User Profile

**File:** `src/infra/database/repositories/OrderRepository.ts`

`getStatusHistory()` now includes `user: { full_name, email }` so admin sees who changed the status instead of "Unknown".

#### 4. Customer Details in Order Response

**File:** `src/infra/database/repositories/OrderRepository.ts`

`findById()` now includes `user` relation → returns `customer: { fullName, email, phone, companyName }` in `GET /orders/:id`.

#### 5. Status Transitions — Allow Full Matrix

**Files:** `src/constants/order-statuses.ts`, `src/interfaces/http/handlers/order.handler.ts`

- Added `processing → cancelled` as valid transition
- Removed guard blocking `pending → processing` manually (admin can now do both)
- Valid transitions: `pending → [processing, cancelled]`, `processing → [shipped, cancelled]`, `shipped → [done]`

#### 6. Products — Respect `isPublished=all` Filter

**File:** `src/interfaces/http/handlers/product.handler.ts`

Admin sends `isPublished=all` — backend now returns ALL products (active + inactive) instead of always filtering to `isPublished: true`.

#### 7. Cart — Enrich with Product Availability

**File:** `src/interfaces/http/handlers/cart.handler.ts`

`GET /api/cart` now joins live product data and returns `isAvailable: boolean` per cart item.

---

### Mobile (`otomasiku-mobile`) — branch: `fix/payment-and-product-availability`

#### 8. Payment Proof Upload (NEW)

**New files:**
- `lib/models/payment_proof.dart` + `.g.dart` — PaymentProof model
- `lib/data/repositories/payment_proof_repository.dart` — multipart upload via Dio
- `lib/features/payment/widgets/bukti_transfer_card.dart` — gallery/camera picker, form, status display

**Modified files:**
- `lib/features/payment/payment_screen.dart` — hides countdown when `vaExpiresAt == null`, adds BuktiTransferCard inline, reads VA from env
- `lib/models/order.dart` + `.g.dart` — added `paymentProof` field
- `lib/data/repositories/order_repository.dart` — parses `paymentProof` from API
- `lib/data/repositories/payment_repository.dart` — same
- `lib/providers/repository_providers.dart` — added `paymentProofRepositoryProvider`
- `lib/core/config/env_config.dart` — added `bcaVaNumber`, `bcaAccountName`
- `lib/features/payment_methods/payment_methods_screen.dart` — reads VA from env instead of hardcoded

**Dependencies added:** `image_picker: ^1.1.2`

#### 9. Cart — Greyed-out Unavailable Products

**Modified files:**
- `lib/models/cart_item.dart` + `.g.dart` — added `isAvailable` field (defaults `true`)
- `lib/features/cart/widgets/cart_item_card.dart` — 50% opacity + red banner "Produk ini sedang tidak tersedia", disabled controls

#### 10. ARB Keys Added (both `app_id.arb` + `app_en.arb`)

Payment proof: `paymentUploadProof`, `paymentProofPending`, `paymentProofApproved`, `paymentProofRejectedReason`, `paymentReupload`, `paymentBankName`, `paymentAccountName`, `paymentAmount`, `paymentPickImage`, `paymentTakePhoto`, `paymentSubmitProof`, `paymentProofUploaded`, `paymentFieldsRequired`

Product: `productUnavailable`

---

### Admin (`otomasiku-admin`) — branch: `staging`

#### 11. Payment Proof Review Card

**Modified files:**
- `src/types/api.ts` — added `PaymentProof` type, `customer` field to `OrderWithItems`
- `src/lib/orders.ts` — added `fetchPaymentProof()`, `verifyPaymentProof()`
- `src/app/(dashboard)/orders/[id]/OrderDetailContent.tsx` — payment proof card (image preview, approve/reject buttons), rich customer info (name, email, phone, company)

#### 12. Status Transitions Updated

**File:** `src/app/(dashboard)/orders/[id]/OrderDetailContent.tsx`

`VALID_TRANSITIONS` now matches backend: `pending → [processing, cancelled]`, `processing → [shipped, cancelled]`, `shipped → [done]`

---

## Environment Variables Required

### Railway (otomasiku-backend) — ADD THESE:

| Variable | Example |
|----------|---------|
| `BCA_VA_NUMBER` | `1234567890` |
| `BCA_ACCOUNT_NAME` | `PT Otomasiku Nusantara` |
| `SUPABASE_PAYMENT_PROOF_BUCKET` | `otomasiku-payment-proofs` |

### Mobile `.env` — ADD THESE:

| Variable | Example |
|----------|---------|
| `BCA_VA_NUMBER` | `1234567890` |
| `BCA_ACCOUNT_NAME` | `PT Otomasiku Nusantara` |

---

## Supabase Setup Required

- **Private bucket** `otomasiku-payment-proofs` — ✅ already created
- No RLS policies needed (backend uses service role key)

---

## Design Decisions

1. **No Prisma schema changes / no migrations** — reused existing `PaymentProof` model and `VerificationStatus` enum (`pending`/`approved`/`rejected`). Order `payment_status` stays `unpaid` until proof approved → `paid`.
2. **BCA callback flow NOT deleted** — left intact for backward compat. New flow runs alongside it.
3. **Signed URLs** — payment proof images stored in private bucket, accessed via 1-hour signed URLs generated at read time.
4. **Cart availability** — backend enriches at read time (not stored), so changes take effect immediately on next cart load.

---

## Verification Status

| Repo | Build | Tests |
|------|-------|-------|
| `otomasiku-backend` | ✅ `tsc --noEmit` clean | ✅ 129 tests pass |
| `otomasiku-mobile` | ✅ `flutter analyze` clean (1 pre-existing warning) | — |
| `otomasiku-admin` | ✅ `tsc --noEmit` clean | — |

---

## Open PRs

| Repo | Branch | URL |
|------|--------|-----|
| `otomasiku-mobile` | `fix/payment-and-product-availability` | https://github.com/peterkrn/otomasiku-mobile/pull/new/fix/payment-and-product-availability |

Backend and admin changes pushed directly to `staging`.
