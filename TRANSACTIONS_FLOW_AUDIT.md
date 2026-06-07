# Transactions Flow Audit & Change Plan
# Add to Cart → Upload Bukti Transfer → Admin Verifies → Order Selesai

**Date:** 2026-06-08  
**Scope:** Full transaction flow across three repos — `otomasiku-mobile` (Flutter), `otomasiku-api` (Express), `otomasiku-admin` (Flutter Web)  
**Breaking change:** Remove BCA Developer API callback. Replace with manual BCA Virtual Account + customer uploads bukti transfer + admin verifies.

---

## 0. Pre-Execution Checklist

### 0.1 Skills to Load

| # | Skill | File | When |
|---|-------|------|------|
| 1 | `test-driven-development` | `C:\Users\peter\.kiro\skills\test-driven-development\SKILL.md` | Before writing any implementation code |
| 2 | `ui-ux-pro-max` | `C:\Users\peter\.kiro\skills\ui-ux-pro-max\SKILL.md` | Before building/modifying any Flutter screen or widget |
| 3 | `supabase` | `C:\Users\peter\.kiro\skills\supabase\SKILL.md` | When touching Supabase Storage (bukti transfer upload) |
| 4 | `verification-before-completion` | `C:\Users\peter\.kiro\skills\verification-before-completion\SKILL.md` | Before claiming any spec done — run analyze + test |

### 0.2 Source of Truth Documents

| # | Document | Path | What to extract |
|---|----------|------|----------------|
| 1 | **AI_RULES.md** | `docs/AI_RULES.md` | Mandatory patterns — overrides everything |
| 2 | **ARCHITECTURE.md** | `docs/ARCHITECTURE.md` | DB schema, service responsibility split |
| 3 | **PRD.md** | `docs/PRD.md` | Module 5 (Checkout), Module 6 (Payment), Module 11 (Admin Orders) |
| 4 | **API.md** | `API.md` | Current endpoint contracts — will be updated by this plan |
| 5 | **TRANSACTIONS_API_CONTRACT.md** | `TRANSACTIONS_API_CONTRACT.md` | Current request/response shapes — will be updated by this plan |
| 6 | **AUDIT.md** | `AUDIT.md` | Known bugs already fixed; do not re-introduce them |

### 0.3 Files to Read Per Repo Before Touching Anything

#### `otomasiku-mobile` (Flutter)

| File | Why |
|------|-----|
| `lib/data/repositories/order_repository.dart` | Order create + get flows |
| `lib/data/repositories/payment_repository.dart` | Payment status polling — will be removed |
| `lib/models/order.dart` + `order.g.dart` | Order model — needs new fields |
| `lib/models/cart_item.dart` | Checkout item shape |
| `lib/features/checkout/checkout_screen.dart` | Checkout flow entry |
| `lib/features/payment/payment_screen.dart` | Will be replaced by bukti transfer upload screen |
| `lib/features/payment/payment_success_screen.dart` | Post-payment success state |
| `lib/features/order/order_detail_screen.dart` | Must display payment proof status |
| `lib/providers/payment_provider.dart` | BCA polling — will be removed |
| `lib/providers/order_provider.dart` | Order state management |
| `lib/l10n/app_id.arb` | All existing i18n keys |
| `lib/l10n/app_en.arb` | Mirror keys |
| `lib/core/router/app_router.dart` | Route names — new screens need routes |

#### `otomasiku-api` (Express)

| File | Why |
|------|-----|
| `src/routes/payment.routes.ts` | BCA callback — will be replaced |
| `src/routes/order.routes.ts` | Payment proof endpoints go here |
| `src/services/payment.service.ts` | Will be rewritten |
| `src/services/order.service.ts` | `createOrder` transaction — `va_number` field changes |
| `src/middleware/bca-signature.ts` | Will be deleted |
| `src/config/bca.ts` | Will be deleted |
| `src/schemas/payment.schema.ts` | Will be replaced with bukti transfer schemas |
| `prisma/schema.prisma` | `PaymentProof` model — already exists, needs audit |
| `src/routes/admin.routes.ts` | Admin order status update — needs full transition matrix |
| `src/services/email.service.ts` | Email on payment approval (not callback) |

#### `otomasiku-admin` (Flutter Web)

| File | Why |
|------|-----|
| `lib/features/orders/order_list_screen.dart` | Admin order list — must show payment proof pending badge |
| `lib/features/orders/order_detail_screen.dart` | Admin must see bukti transfer + approve/reject + update status |
| `lib/data/repositories/admin_order_repository.dart` | Admin endpoints for verify proof + status update |
| `lib/l10n/app_id.arb` + `app_en.arb` | Admin-side i18n keys |

### 0.4 Branch Strategy

| Sprint | Branch | Repos | Scope |
|--------|--------|-------|-------|
| 1 | `feat/payment-proof-backend` | `otomasiku-api` | DB migration, new endpoints, remove BCA callback |
| 2 | `feat/payment-proof-mobile` | `otomasiku-mobile` | Replace payment screen, add bukti transfer upload, order detail updates |
| 3 | `feat/payment-proof-admin` | `otomasiku-admin` | Admin verify proof UI + full status transition UI |

> Backend (Sprint 1) must be merged and deployed to staging before Sprint 2 Flutter work starts.

### 0.5 Verification Gate

```bash
# otomasiku-mobile
./rtk.exe flutter analyze      # must be clean
./rtk.exe flutter test         # must pass

# otomasiku-api
pnpm run build                 # TypeScript must compile clean
pnpm run test                  # all tests pass
pnpm prisma generate           # schema in sync

# otomasiku-admin
./rtk.exe flutter analyze
./rtk.exe flutter test
```

---

## 1. What Is Changing — Executive Summary

### Removed

| Item | Reason |
|------|--------|
| `POST /api/payment/bca/callback` endpoint | No longer using BCA Developer API automatic callback |
| `BCA_API_KEY`, `BCA_API_SECRET`, `BCA_CLIENT_ID`, `BCA_CLIENT_SECRET`, `BCA_CALLBACK_SECRET` env vars | BCA Developer API no longer used |
| `src/middleware/bca-signature.ts` | HMAC validation for BCA — no longer needed |
| `src/config/bca.ts` | BCA client config — no longer needed |
| `lib/providers/payment_provider.dart` (polling logic) | No more auto-verification via callback |
| `vaNumber` and `vaExpiresAt` fields on Order as dynamic per-order values | VA is now a static company account number shown to all customers |

### Added

| Item | Description |
|------|-------------|
| `POST /api/orders/:id/payment-proof` | Customer uploads bukti transfer (image via multipart) |
| `GET /api/orders/:id/payment-proof` | Customer checks their proof status |
| `GET /api/admin/orders/:id/payment-proof` | Admin views the proof |
| `PATCH /api/admin/orders/:id/payment-proof` | Admin approves or rejects the proof |
| `PATCH /api/admin/orders/:id/status` (expanded) | Admin can set `pending → processing → shipped → done → cancelled` with resi required for `shipped` |
| New `PaymentScreen` (Flutter) | Shows static BCA VA number + upload bukti transfer form |
| New `BuktiTransferUploadScreen` or inline upload in `PaymentScreen` | Camera/gallery picker + upload + status polling |
| Admin order detail: payment proof review card | Shows image, approve/reject buttons |
| Admin order detail: full status transition buttons | All valid next states shown contextually |
| New ARB keys (Flutter + Admin) | All new strings go into both `app_id.arb` and `app_en.arb` |

### Changed

| Item | Change |
|------|--------|
| `Order.payment_status` flow | `unpaid → pending_verification → paid → rejected` (replaces callback-driven `unpaid → paid`) |
| `Order.status` admin transitions | `pending → processing → shipped → done → cancelled` (previously only `pending → cancelled` manually) |
| `PaymentScreen` (Flutter) | From BCA VA countdown to: static VA display + bukti transfer upload |
| `order_detail_screen.dart` (Flutter) | Add payment proof status card |
| `TRANSACTIONS_API_CONTRACT.md` | Updated (see Section 4) |

---

## 2. New Payment Flow

```
Customer                    Flutter App               Express API              Admin App
───────                     ───────────               ───────────              ─────────
Place order             →   POST /api/orders      →   Create order (pending, unpaid)
                        ←   { orderId, vaNumber* }    * static company VA from config
                        
Sees payment screen         Display static BCA VA number
                            Display order total
                            Display "upload bukti transfer" CTA

Transfers via BCA               (outside app)

Uploads screenshot      →   POST /orders/:id/      →   Validate image (MIME, size)
of bank receipt             payment-proof               Upload to Supabase Storage
                                                        Set payment_status = 'pending_verification'
                                                        Log status history note
                        ←   { proofId, status: 'pending_verification' }

Sees "menunggu             Flutter shows waiting state
verifikasi" state          with proof thumbnail

                                                        Admin sees badge on order list
                                                    ←   GET /admin/orders (badge count)
                                                    
                                                        Admin opens order detail
                                                    ←   GET /admin/orders/:id/payment-proof
                                                    
                                                        Admin approves proof          
                                                    →   PATCH /admin/orders/:id/payment-proof
                                                        { action: 'approve' }
                                                        → payment_status = 'paid'
                                                        → order status = 'processing'
                                                        → log status history
                                                        → send email to company (Nodemailer)
                                                        
                             Flutter polls GET /orders/:id
                             sees payment_status = 'paid'
                             → navigate to payment success
                             
                             OR admin rejects:
                                                    →   PATCH /admin/orders/:id/payment-proof
                                                        { action: 'reject', reason: '...' }
                                                        → payment_status = 'rejected'
                                                        → notify customer (future: push notif)
                             Flutter shows rejection reason
                             with option to re-upload

Admin ships order       →   PATCH /admin/orders/:id/status
                            { status: 'shipped', resiNumber: 'JNE123' }
                            * resiNumber strictly required for shipped

Customer sees shipped       Flutter polls or refreshes
status with resi no.

Admin marks done        →   PATCH /admin/orders/:id/status
                            { status: 'done' }
```

---

## 3. New `payment_status` State Machine

```
unpaid
  │
  └──(customer uploads proof)──→ pending_verification
                                      │
                              ┌───────┴───────┐
                              ▼               ▼
                            paid           rejected ──→ (customer re-uploads)
                              │                              │
                              ▼                              └──→ pending_verification
                        (order continues)
```

> `rejected` allows re-upload: customer can replace the proof and re-submit.  
> Each upload replaces the previous proof for the same order (or appends — see Section 4.3).

---

## 4. New & Updated API Contracts

### 4.1 Order Creation — unchanged shape, `vaNumber` becomes static config

`POST /api/orders` response stays the same shape. The `vaNumber` returned is now sourced from a server-side config variable (`BCA_VA_NUMBER`) — a static company account number — not a dynamically generated per-order VA from BCA Developer API.

```json
// POST /api/orders → 201
{
  "success": true,
  "data": {
    "orderId": "uuid",
    "orderNumber": "OMA-20260608-0001",
    "totalAmount": "3000000",
    "vaNumber": "1234567890",
    "vaExpiresAt": null
  }
}
```

> `vaExpiresAt` is now always `null` — manual VA has no expiry. Flutter must not show countdown.

---

### 4.2 Upload Bukti Transfer

```
POST /api/orders/:id/payment-proof
Auth: customer (owns the order)
Content-Type: multipart/form-data
```

**Form fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | file (JPEG/PNG/WEBP, max 5MB) | ✅ | Screenshot / foto bukti transfer |
| `bankName` | string | ✅ | Nama bank pengirim (e.g. "BCA") |
| `accountName` | string | ✅ | Nama rekening pengirim |
| `amount` | string (BigInt) | ✅ | Nominal yang ditransfer dalam Rupiah (e.g. "3000000") |

**Response 201:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "orderId": "uuid",
    "imageUrl": "https://storage.supabase.co/...",
    "bankName": "BCA",
    "accountName": "PT Maju Jaya",
    "amount": "3000000",
    "status": "pending_verification",
    "uploadedAt": "2026-06-08T10:00:00.000Z"
  }
}
```

**Validation rules (server-side):**
- Order must belong to the authenticated customer (`order.user_id === req.user.id`)
- Order `payment_status` must be `unpaid` or `rejected` (re-upload allowed)
- Order `status` must not be `cancelled`
- Image MIME: `image/jpeg`, `image/png`, `image/webp` only
- Image size: max 5MB
- `amount` must be a valid numeric string (BigInt-parseable)

**Error codes:**

| Code | HTTP | Condition |
|------|------|-----------|
| `ORDER_NOT_FOUND` | 404 | Order does not exist or does not belong to user |
| `PAYMENT_ALREADY_PAID` | 409 | `payment_status` is already `paid` |
| `ORDER_CANCELLED` | 409 | Order is cancelled |
| `INVALID_FILE_TYPE` | 400 | Not JPEG/PNG/WEBP |
| `FILE_TOO_LARGE` | 400 | > 5MB |
| `INVALID_AMOUNT` | 400 | Amount is not a valid numeric string |

---

### 4.3 Get Payment Proof (Customer)

```
GET /api/orders/:id/payment-proof
Auth: customer (owns the order)
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "orderId": "uuid",
    "imageUrl": "https://storage.supabase.co/...",
    "bankName": "BCA",
    "accountName": "PT Maju Jaya",
    "amount": "3000000",
    "status": "pending_verification",
    "rejectReason": null,
    "uploadedAt": "2026-06-08T10:00:00.000Z",
    "verifiedAt": null
  }
}
```

> Returns `404` with `PAYMENT_PROOF_NOT_FOUND` if no proof uploaded yet.

---

### 4.4 Get Payment Proof (Admin)

```
GET /api/admin/orders/:id/payment-proof
Auth: admin
```

Same response shape as 4.3, with addition of `verifiedBy` (admin user ID).

---

### 4.5 Admin: Verify Payment Proof

```
PATCH /api/admin/orders/:id/payment-proof
Auth: admin
```

**Request:**
```json
// Approve
{ "action": "approve" }

// Reject
{ "action": "reject", "reason": "Nominal tidak sesuai" }
```

**Rules:**
- `action` must be `"approve"` or `"reject"`
- `reason` is required when `action = "reject"`
- Proof `status` must be `pending_verification` (cannot re-approve/re-reject)

**On `approve`:**
1. `payment_proof.status` → `"approved"`, `verified_at` = now, `verified_by` = admin user ID
2. `order.payment_status` → `"paid"`
3. `order.status` → `"processing"` (automatic — payment confirmed, begin fulfillment)
4. Insert `OrderStatusHistory`: `from: "pending"`, `to: "processing"`, note: `"Bukti transfer diverifikasi"`
5. Send email to company via Nodemailer with order details + shipping address

**On `reject`:**
1. `payment_proof.status` → `"rejected"`, `reject_reason` = reason
2. `order.payment_status` → `"rejected"`
3. Insert `OrderStatusHistory` note: `"Bukti transfer ditolak: {reason}"`
4. (Future) push notification to customer

**Response 200:**
```json
{
  "success": true,
  "data": {
    "proofId": "uuid",
    "orderId": "uuid",
    "action": "approve",
    "newPaymentStatus": "paid",
    "newOrderStatus": "processing"
  }
}
```

**Error codes:**

| Code | HTTP | Condition |
|------|------|-----------|
| `ORDER_NOT_FOUND` | 404 | — |
| `PAYMENT_PROOF_NOT_FOUND` | 404 | No proof uploaded yet |
| `PROOF_ALREADY_VERIFIED` | 409 | Status is not `pending_verification` |
| `REJECT_REASON_REQUIRED` | 400 | `action = reject` without `reason` |

---

### 4.6 Admin: Update Order Status (Expanded)

```
PATCH /api/admin/orders/:id/status
Auth: admin
```

**Valid transitions:**

```
pending     → processing   ❌ NOT manually — only via payment proof approval (4.5)
pending     → cancelled    ✅
processing  → shipped      ✅ requires resiNumber
processing  → cancelled    ✅
shipped     → done         ✅
done        → (none)       locked
cancelled   → (none)       locked
```

> `pending → processing` can only happen via `PATCH /admin/orders/:id/payment-proof` with `action: approve`. This endpoint cannot set `processing` directly — doing so bypasses payment verification.

**Request:**
```json
{
  "status": "shipped",
  "resiNumber": "JNE123456789",
  "adminNotes": "Dikirim via JNE Reguler",
  "notifyUser": true
}
```

**Field rules:**

| Field | Required | Condition |
|-------|----------|-----------|
| `status` | ✅ | Must be a valid target status per transition matrix above |
| `resiNumber` | Conditional | **Required** when `status = "shipped"` — rejected with `RESI_NUMBER_REQUIRED` if absent |
| `adminNotes` | ❌ | Optional note stored in `admin_notes` |
| `notifyUser` | ❌ | Default `true` — triggers WhatsApp/push notification (future) |

**Error codes:**

| Code | HTTP | Condition |
|------|------|-----------|
| `ORDER_NOT_FOUND` | 404 | — |
| `INVALID_STATUS_TRANSITION` | 400 | Transition not in matrix, includes `{ from, to, validTransitions }` in details |
| `RESI_NUMBER_REQUIRED` | 400 | `status = shipped` without `resiNumber` |
| `CANNOT_SET_PROCESSING_MANUALLY` | 400 | Admin tries to set `processing` directly — must go through payment proof approval |

---

### 4.7 Updated `GET /api/orders/:id` — Added Fields

The `order` object now includes `paymentProof` when available:

```json
{
  "success": true,
  "data": {
    "order": {
      "id": "uuid",
      "orderNumber": "OMA-20260608-0001",
      "userId": "uuid",
      "addressId": "uuid",
      "subtotal": "3000000",
      "shippingCost": "0",
      "totalAmount": "3000000",
      "status": "processing",
      "paymentStatus": "paid",
      "vaNumber": "1234567890",
      "vaExpiresAt": null,
      "resiNumber": null,
      "shippedAt": null,
      "deliveredAt": null,
      "notes": "...",
      "adminNotes": null,
      "createdAt": "...",
      "updatedAt": "..."
    },
    "items": [...],
    "paymentProof": {
      "id": "uuid",
      "status": "approved",
      "imageUrl": "https://...",
      "bankName": "BCA",
      "accountName": "PT Maju Jaya",
      "amount": "3000000",
      "rejectReason": null,
      "uploadedAt": "...",
      "verifiedAt": "..."
    }
  }
}
```

> `paymentProof` is `null` if no proof has been uploaded yet.

---

## 5. Database Changes

### 5.1 `orders` Table — No structural change

The `va_number` and `va_expires_at` columns remain but are sourced from config (static), not BCA Developer API. No migration needed.

### 5.2 `payment_proofs` Table — Expand `status` enum

Current: `"pending" | "approved" | "rejected"`  
New: `"pending_verification" | "approved" | "rejected"`

> Rename `"pending"` to `"pending_verification"` for clarity. Requires a migration.

```sql
-- Migration: rename payment_proof status value
UPDATE payment_proofs SET status = 'pending_verification' WHERE status = 'pending';
```

Also confirm `payment_proofs` has the `reject_reason` column (already in schema ✅).

### 5.3 `orders` Table — Expand `payment_status` enum values

Current implied values: `"unpaid" | "paid" | "expired"`  
New: `"unpaid" | "pending_verification" | "paid" | "rejected"`

> `"expired"` is removed since there is no VA expiry in manual flow.

```sql
-- Migration: no structural change needed if stored as VARCHAR.
-- Old 'expired' status should be treated as 'unpaid' going forward.
-- Document this in migration notes.
```

### 5.4 `orders` Table — `order_status` values

Current: `"pending" | "processing" | "shipped" | "done" | "cancelled"`  
No change needed — the existing values cover the full new transition matrix.

### 5.5 New env variable

```env
# Static BCA Virtual Account number (company's corporate BCA account)
BCA_VA_NUMBER=1234567890
BCA_ACCOUNT_NAME=PT Otomasiku Nusantara
```

> Remove: `BCA_API_KEY`, `BCA_API_SECRET`, `BCA_CLIENT_ID`, `BCA_CLIENT_SECRET`, `BCA_API_BASE_URL`, `BCA_CALLBACK_SECRET`

---

## 6. Flutter Mobile — Files to Create / Modify

### 6.1 New Screen: `PaymentScreen` (replace existing)

**File:** `lib/features/payment/payment_screen.dart`  
**Replaces:** Current countdown + VA polling screen

**New behavior:**
1. Displays static BCA VA number from order response
2. Displays total amount to transfer (with copy button)
3. Displays "Cara Transfer" instructions (collapsible, same as before)
4. **New:** Upload Bukti Transfer card — shows upload button if no proof yet, or proof thumbnail + status if already uploaded
5. **Polling:** `GET /api/orders/:id` every 10 seconds — when `paymentStatus` = `"paid"` → navigate to success
6. **No countdown** — `vaExpiresAt` is null; remove all countdown logic

**Removes:**
- `_countdownTimer`, `_remaining()`, `_countdownDisplay()`, `_buildCountdownCard()`
- `paymentPollingProvider` (or repurpose without BCA dependency)

### 6.2 New Widget: `BuktiTransferCard`

**File:** `lib/features/payment/widgets/bukti_transfer_card.dart`

States:
- **Empty:** "Upload Bukti Transfer" button with camera/gallery picker
- **Pending verification:** Proof thumbnail + "Menunggu Verifikasi Admin" chip
- **Rejected:** Proof thumbnail + rejection reason + "Upload Ulang" button
- **Approved:** Green checkmark + "Pembayaran Dikonfirmasi"

### 6.3 New Repository: `PaymentProofRepository`

**File:** `lib/data/repositories/payment_proof_repository.dart`

```dart
abstract class PaymentProofRepository {
  Future<PaymentProof> uploadProof({
    required String orderId,
    required File imageFile,
    required String bankName,
    required String accountName,
    required int amount,
  });
  Future<PaymentProof?> getProof(String orderId);
}
```

### 6.4 New Model: `PaymentProof`

**File:** `lib/models/payment_proof.dart`

```dart
@JsonSerializable()
class PaymentProof {
  final String id;
  final String orderId;
  final String imageUrl;
  final String bankName;
  final String accountName;
  @BigIntStringConverter()
  final int amount;
  final String status; // 'pending_verification' | 'approved' | 'rejected'
  final String? rejectReason;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;
}
```

### 6.5 Update: `Order` Model

**File:** `lib/models/order.dart`

Add fields:
- `subtotal` (`int`, BigIntStringConverter) 
- `shippingCost` (`int`, BigIntStringConverter)
- `userId` (`String?`)
- `resiNumber` (`String?`) — already present ✅
- `shippedAt` (`DateTime?`)
- `deliveredAt` (`DateTime?`)
- `adminNotes` (`String?`)
- `paymentProof` (`PaymentProof?`) — nullable, from `GET /orders/:id`

Remove:
- `vaExpiresAt` countdown usage (keep field, but never show countdown if null)

### 6.6 Update: `OrderRepositoryImpl.getOrderById`

**File:** `lib/data/repositories/order_repository.dart`

Parse `paymentProof` from `data['paymentProof']` when present.

### 6.7 Update: `OrderDetailScreen`

**File:** `lib/features/order/order_detail_screen.dart`

Add payment proof status card:
- If `paymentProof == null && paymentStatus == 'unpaid'` → show "Belum upload bukti transfer" with button to navigate back to payment screen
- If `paymentProof?.status == 'pending_verification'` → yellow chip "Menunggu Verifikasi"
- If `paymentProof?.status == 'rejected'` → red chip + rejection reason
- If `paymentProof?.status == 'approved'` → green chip "Pembayaran Dikonfirmasi"

Also add `resiNumber` display when `status == 'shipped'`.

### 6.8 Remove: `PaymentRepository` (old BCA polling)

**File:** `lib/data/repositories/payment_repository.dart`  
**File:** `lib/providers/payment_provider.dart`

Delete. Payment screen now uses `orderDetailProvider` directly for polling, not a separate payment repository.

> Or: keep `payment_provider.dart` but remove BCA-specific logic. Only poll `GET /orders/:id`. Remove `fake_payment_repository.dart` too.

### 6.9 New ARB Keys — `app_id.arb` + `app_en.arb`

All new keys must be added to **both** files before use.

| Key | Indonesian | English |
|-----|-----------|---------|
| `paymentBcaVaTitle` | `Pembayaran BCA Virtual Account` | `BCA Virtual Account Payment` |
| `paymentTransferTo` | `Transfer ke Nomor VA` | `Transfer to VA Number` |
| `paymentUploadProof` | `Upload Bukti Transfer` | `Upload Transfer Proof` |
| `paymentProofPending` | `Menunggu Verifikasi Admin` | `Awaiting Admin Verification` |
| `paymentProofApproved` | `Pembayaran Dikonfirmasi` | `Payment Confirmed` |
| `paymentProofRejected` | `Bukti Transfer Ditolak` | `Transfer Proof Rejected` |
| `paymentProofRejectedReason` | `Alasan: {reason}` | `Reason: {reason}` |
| `paymentReupload` | `Upload Ulang` | `Re-upload` |
| `paymentBankName` | `Nama Bank` | `Bank Name` |
| `paymentAccountName` | `Nama Rekening Pengirim` | `Sender Account Name` |
| `paymentAmount` | `Nominal Transfer` | `Transfer Amount` |
| `paymentPickImage` | `Pilih dari Galeri` | `Choose from Gallery` |
| `paymentTakePhoto` | `Ambil Foto` | `Take Photo` |
| `paymentSubmitProof` | `Kirim Bukti Transfer` | `Submit Transfer Proof` |
| `paymentProofUploaded` | `Bukti transfer berhasil dikirim` | `Transfer proof submitted` |
| `orderStatusPending` | `Menunggu Pembayaran` | `Awaiting Payment` |
| `orderStatusProcessing` | `Diproses` | `Processing` |
| `orderStatusShipped` | `Dikirim` | `Shipped` |
| `orderStatusDone` | `Selesai` | `Done` |
| `orderStatusCancelled` | `Dibatalkan` | `Cancelled` |
| `orderResiNumber` | `Nomor Resi` | `Tracking Number` |
| `errorPaymentAlreadyPaid` | `Pembayaran sudah dikonfirmasi.` | `Payment already confirmed.` |
| `errorOrderCancelled` | `Pesanan ini sudah dibatalkan.` | `This order has been cancelled.` |
| `errorInvalidFileType` | `File harus berupa gambar (JPEG/PNG/WEBP).` | `File must be an image (JPEG/PNG/WEBP).` |
| `errorFileTooLarge` | `Ukuran file maksimal 5MB.` | `Maximum file size is 5MB.` |
| `errorPaymentProofNotFound` | `Bukti transfer belum diunggah.` | `Transfer proof not yet uploaded.` |

---

## 7. Express Backend — Files to Create / Modify / Delete

### 7.1 Delete

| File | Reason |
|------|--------|
| `src/middleware/bca-signature.ts` | BCA HMAC validation no longer needed |
| `src/config/bca.ts` | BCA Developer API client no longer needed |
| `src/routes/payment.routes.ts` (or gut it) | Remove `POST /payments/bca/callback` |

### 7.2 Modify: `src/routes/order.routes.ts`

Add:
```
POST   /orders/:id/payment-proof        requireAuth  + validate(uploadProofSchema)  + multer
GET    /orders/:id/payment-proof        requireAuth
```

### 7.3 Modify: `src/routes/admin.routes.ts`

Add:
```
GET    /admin/orders/:id/payment-proof  requireAdmin
PATCH  /admin/orders/:id/payment-proof  requireAdmin  + validate(verifyProofSchema)
```

Update:
```
PATCH  /admin/orders/:id/status         requireAdmin  + validate(updateStatusSchema)
```

### 7.4 Modify: `src/schemas/payment.schema.ts`

Replace BCA callback schema with:

```typescript
export const uploadProofSchema = z.object({
  bankName: z.string().min(1).max(100),
  accountName: z.string().min(1).max(200),
  amount: z.string().regex(/^\d+$/, 'Must be a numeric string'),
});

export const verifyProofSchema = z.object({
  action: z.enum(['approve', 'reject']),
  reason: z.string().min(1).max(500).optional(),
}).refine(
  (data) => data.action !== 'reject' || (data.reason && data.reason.length > 0),
  { message: 'Reason is required when rejecting', path: ['reason'] }
);
```

### 7.5 Modify: `src/schemas/order.schema.ts`

Update `updateStatusSchema`:

```typescript
export const updateOrderStatusSchema = z.object({
  status: z.enum(['pending', 'processing', 'shipped', 'done', 'cancelled']),
  resiNumber: z.string().min(1).max(100).optional(),
  adminNotes: z.string().max(500).optional(),
  notifyUser: z.boolean().default(true),
}).refine(
  (data) => data.status !== 'shipped' || (data.resiNumber && data.resiNumber.length > 0),
  { message: 'resiNumber is required when status is shipped', path: ['resiNumber'] }
);
```

### 7.6 New: `src/services/payment-proof.service.ts`

Handles:
- `uploadProof(orderId, userId, file, bankName, accountName, amount)`:
  - Validate order ownership + status
  - Upload image to Supabase Storage at `payment-proofs/{orderId}/{timestamp}.{ext}`
  - Upsert `PaymentProof` record (replace if already rejected)
  - Update `order.payment_status` = `'pending_verification'`
- `verifyProof(orderId, adminId, action, reason?)`:
  - Validate proof exists + status is `pending_verification`
  - Approve: set `proof.status = 'approved'`, `order.payment_status = 'paid'`, `order.status = 'processing'`, insert status history, send email
  - Reject: set `proof.status = 'rejected'`, `proof.reject_reason = reason`, `order.payment_status = 'rejected'`, insert status history

### 7.7 Modify: `src/services/order.service.ts`

`createOrder` response: add `vaNumber` from `process.env.BCA_VA_NUMBER`.  
Remove any BCA Developer API call from this flow.

### 7.8 Modify: `src/services/order-status.service.ts` (or inside `order.service.ts`)

Implement full status transition matrix with guards:
- Reject `processing` if set directly (use `CANNOT_SET_PROCESSING_MANUALLY`)
- Require `resiNumber` for `shipped`
- Reject transitions from terminal states (`done`, `cancelled`)
- Log every transition to `order_status_history`

### 7.9 Modify: `src/services/email.service.ts`

Trigger email on proof approval (not BCA callback).

### 7.10 Prisma Migration

```sql
-- 001_payment_proof_status_rename.sql
UPDATE payment_proofs SET status = 'pending_verification' WHERE status = 'pending';
```

Run: `pnpm prisma db push` (or create a named migration via `pnpm prisma migrate dev --name payment_proof_status_rename`).

---

## 8. Admin App (`otomasiku-admin`) — Files to Create / Modify

### 8.1 Modify: `order_detail_screen.dart`

Add **Payment Proof Card**:
- Shows proof image (tappable → full screen view)
- Shows bank name, account name, amount
- Shows status chip (pending / approved / rejected)
- If `status == 'pending_verification'`: "Setujui" (green) + "Tolak" (red) buttons
- Reject action opens a dialog to input reason

Add **Order Status Card** (replacing simple status badge):
- Shows current status
- Shows valid next-state buttons contextually:
  - `pending` → "Batalkan" only (processing only via payment proof approval)
  - `processing` → "Tandai Dikirim" (opens dialog for resi input) + "Batalkan"
  - `shipped` → "Tandai Selesai"
  - `done` / `cancelled` → no action buttons

### 8.2 New ARB Keys (Admin) — `app_id.arb` + `app_en.arb`

| Key | Indonesian | English |
|-----|-----------|---------|
| `adminPaymentProof` | `Bukti Transfer` | `Transfer Proof` |
| `adminApproveProof` | `Setujui Bukti Transfer` | `Approve Transfer Proof` |
| `adminRejectProof` | `Tolak Bukti Transfer` | `Reject Transfer Proof` |
| `adminRejectReason` | `Alasan Penolakan` | `Rejection Reason` |
| `adminRejectReasonHint` | `Contoh: Nominal tidak sesuai` | `Example: Amount mismatch` |
| `adminMarkShipped` | `Tandai Dikirim` | `Mark as Shipped` |
| `adminMarkDone` | `Tandai Selesai` | `Mark as Done` |
| `adminCancelOrder` | `Batalkan Pesanan` | `Cancel Order` |
| `adminResiNumberInput` | `Masukkan Nomor Resi` | `Enter Tracking Number` |
| `adminStatusUpdated` | `Status pesanan diperbarui` | `Order status updated` |
| `adminProofApproved` | `Bukti transfer disetujui` | `Transfer proof approved` |
| `adminProofRejected` | `Bukti transfer ditolak` | `Transfer proof rejected` |
| `adminOrderStatusPending` | `Menunggu Pembayaran` | `Awaiting Payment` |
| `adminOrderStatusProcessing` | `Diproses` | `Processing` |
| `adminOrderStatusShipped` | `Dikirim` | `Shipped` |
| `adminOrderStatusDone` | `Selesai` | `Done` |
| `adminOrderStatusCancelled` | `Dibatalkan` | `Cancelled` |
| `errorCannotSetProcessingManually` | `Status Diproses hanya bisa diubah melalui verifikasi bukti transfer.` | `Processing status can only be set via payment proof approval.` |
| `errorResiRequired` | `Nomor resi wajib diisi saat mengubah status ke Dikirim.` | `Tracking number is required when marking as Shipped.` |

---

## 9. Affected File Summary

### `otomasiku-mobile`

| File | Action | Sprint |
|------|--------|--------|
| `lib/features/payment/payment_screen.dart` | Rewrite | 2 |
| `lib/features/payment/widgets/bukti_transfer_card.dart` | Create | 2 |
| `lib/features/order/order_detail_screen.dart` | Modify | 2 |
| `lib/data/repositories/payment_repository.dart` | Delete or gut | 2 |
| `lib/data/repositories/payment_proof_repository.dart` | Create | 2 |
| `lib/models/order.dart` + `order.g.dart` | Add fields | 2 |
| `lib/models/payment_proof.dart` | Create | 2 |
| `lib/providers/payment_provider.dart` | Gut BCA logic, keep polling | 2 |
| `lib/providers/repository_providers.dart` | Add `paymentProofRepositoryProvider` | 2 |
| `lib/core/router/app_router.dart` | No new routes needed (upload inline) | — |
| `lib/l10n/app_id.arb` | Add new keys (Section 6.9) | 2 |
| `lib/l10n/app_en.arb` | Mirror new keys | 2 |

### `otomasiku-api`

| File | Action | Sprint |
|------|--------|--------|
| `src/middleware/bca-signature.ts` | Delete | 1 |
| `src/config/bca.ts` | Delete | 1 |
| `src/routes/payment.routes.ts` | Delete or gut callback route | 1 |
| `src/routes/order.routes.ts` | Add proof upload/get routes | 1 |
| `src/routes/admin.routes.ts` | Add proof verify routes + update status route | 1 |
| `src/schemas/payment.schema.ts` | Replace BCA schema with proof schemas | 1 |
| `src/schemas/order.schema.ts` | Update `updateStatusSchema` with resi validation | 1 |
| `src/services/payment-proof.service.ts` | Create | 1 |
| `src/services/order.service.ts` | Remove BCA VA call, add static VA from config | 1 |
| `src/services/order-status.service.ts` | Full transition matrix + resi guard | 1 |
| `src/services/email.service.ts` | Trigger on proof approval | 1 |
| `prisma/schema.prisma` | Audit `PaymentProof` model (likely no change) | 1 |
| `.env.example` | Remove BCA API keys, add `BCA_VA_NUMBER`, `BCA_ACCOUNT_NAME` | 1 |

### `otomasiku-admin`

| File | Action | Sprint |
|------|--------|--------|
| `lib/features/orders/order_detail_screen.dart` | Add proof card + full status transition buttons | 3 |
| `lib/data/repositories/admin_order_repository.dart` | Add `verifyProof()`, `updateStatus()` with full params | 3 |
| `lib/l10n/app_id.arb` | Add new admin keys (Section 8.2) | 3 |
| `lib/l10n/app_en.arb` | Mirror new admin keys | 3 |

---

## 10. Testing Requirements

Each item below maps to the `test-driven-development` skill — write the failing test **before** the implementation.

### Backend Tests

| Test | File |
|------|------|
| Upload proof — success path | `test/payment-proof/upload.test.ts` |
| Upload proof — wrong MIME type → 400 `INVALID_FILE_TYPE` | same |
| Upload proof — order not owned by user → 404 | same |
| Upload proof — order already paid → 409 `PAYMENT_ALREADY_PAID` | same |
| Upload proof — re-upload after rejection → replaces previous proof | same |
| Admin approve proof — sets `payment_status = paid`, `status = processing` | `test/payment-proof/verify.test.ts` |
| Admin reject proof — sets `payment_status = rejected`, stores reason | same |
| Admin reject without reason → 400 `REJECT_REASON_REQUIRED` | same |
| Admin approve already-approved proof → 409 `PROOF_ALREADY_VERIFIED` | same |
| Status update: `processing → shipped` with resi → success | `test/order-status/transitions.test.ts` |
| Status update: `processing → shipped` without resi → 400 `RESI_NUMBER_REQUIRED` | same |
| Status update: manually set `processing` → 400 `CANNOT_SET_PROCESSING_MANUALLY` | same |
| Status update: `done → cancelled` → 400 `INVALID_STATUS_TRANSITION` | same |
| Status update: `cancelled → shipped` → 400 `INVALID_STATUS_TRANSITION` | same |
| All transitions log to `order_status_history` | same |

### Flutter Tests

| Test | File |
|------|------|
| `BuktiTransferCard` renders upload button when no proof | `test/features/payment/bukti_transfer_card_test.dart` |
| `BuktiTransferCard` renders pending chip when proof is `pending_verification` | same |
| `BuktiTransferCard` renders rejection reason when proof is `rejected` | same |
| `PaymentScreen` does NOT show countdown when `vaExpiresAt` is null | `test/features/payment/payment_screen_test.dart` |
| `OrderDetailScreen` shows payment proof status card | `test/features/order/order_detail_screen_test.dart` |
| All new ARB keys exist in both `app_id.arb` and `app_en.arb` | `test/l10n/arb_keys_test.dart` |
| `PaymentProof.fromJson` parses all fields correctly | `test/models/payment_proof_test.dart` |
