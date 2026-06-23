# Cart System Bugs — Safer Execution Plan

This version replaces the original fix order with a lower-risk sequence:

1. Build a reproducible feedback loop for each bug before changing code.
2. Separate confirmed mobile-only fixes from backend-dependent fixes.
3. Do not hardcode new mobile API behavior until the backend contract is verified.
4. Do not abort after a successful order creation response, because the order already exists server-side at that point.

---

## Phase 0 — Preconditions And Guardrails

This phase must be completed before implementation.

### 0.1 Confirm the authoritative API contract

There is a contract mismatch in the repo:

- `lib/data/repositories/order_repository.dart` currently sends `cartItemIds` in `POST /orders`
- `docs/API.md` and `TRANSACTIONS_API_CONTRACT.md` document `POST /orders` as `{ addressId, notes? }`

Before changing code, confirm:

1. Whether partial-cart checkout is officially supported
2. Whether `cartItemIds` is a real backend field or stale mobile-only behavior
3. Whether a customer cancel endpoint exists for pending orders
4. The expected response shape for newly-created orders from `GET /orders/:id`

If the backend contract is different from the repo docs, update the contract doc first or in the same change set.

### 0.2 Build a feedback loop for each bug

Do not rely on static code inspection alone. Capture a reproducible pass/fail loop first.

Required loops:

- Bug `#1`: Create a multi-quantity checkout with at least `quantity = 2`
- Bug `#2`: Open order detail immediately after checkout success
- Bug `#3`: Return to catalog after checkout and compare stock before vs after
- Bug `#4`: Open a pending order and verify whether cancel is available and functional

Preferred evidence source:

- Use the existing debug `Dio` logging already configured in `lib/core/network/api_client.dart`
- Capture the raw `POST /orders` response
- Capture the raw `GET /orders/:id` response immediately after creation

Avoid adding extra ad-hoc logs unless the current logging is insufficient.

### 0.3 Fix debug-only false positives before manual verification

The debug/test fakes currently return placeholder totals:

- `lib/data/repositories/fake_order_repository.dart` returns `totalAmount: 1`
- `lib/data/repositories/fake_payment_repository.dart` returns `totalAmount: 0`

These values can create false failures during manual verification and test runs.

Before validating Bug `#1`, align fake repository totals with realistic order totals or explicitly bypass fake implementations in the verification path.

---

## Phase 1 — Mobile-Only Fixes We Can Ship Safely

These fixes do not require new backend behavior.

### Bug #3: Stock not decremented after checkout

**Severity**: High  
**Risk**: Low  
**Status**: Safe to implement immediately after Phase 0

**Confirmed cause**:

`ProductListNotifier` in `lib/providers/product_provider.dart` uses a 5-minute TTL cache and checkout does not invalidate it after successful order creation.

**Implementation**:

1. In `lib/features/checkout/checkout_screen.dart`, invalidate the product list after successful `createOrder` and local cart cleanup:
   ```dart
   ref.invalidate(productListProvider);
   ```
2. If Bug `#4` later adds customer-side cancellation with stock restoration, also invalidate `productListProvider` after a successful cancel action.

**Verification loop**:

1. Record stock on catalog
2. Checkout quantity `N`
3. Return to catalog
4. Confirm stock displays `oldStock - N` without waiting for TTL expiry

### Bug #2: Order detail crashes after successful checkout

**Severity**: Critical  
**Risk**: Low-Medium  
**Status**: Safe to implement on the mobile side after Phase 0

**Confirmed cause**:

Both repositories use the same fragile parse path:

- `lib/data/repositories/order_repository.dart`
- `lib/data/repositories/payment_repository.dart`

They assume `data['order']` is always a non-null map. If the server briefly returns an incomplete or transitional shape for a newly-created order, the cast throws.

**Implementation**:

1. Harden `OrderRepositoryImpl.getOrderById()`:
   - Read `data['order']` as `Map<String, dynamic>?`
   - If missing, throw an internal retryable `ApiException`, for example `ORDER_NOT_READY`
   - Normalize `items` to `data['items'] ?? <dynamic>[]`
   - Preserve `paymentProof` only when present
2. Apply the same normalization to `PaymentRepositoryImpl.getPaymentStatus()`
3. Add one short retry to the order detail read path:
   - `orderDetailProvider`
4. Add the same retry behavior to the payment read path:
   - `paymentProvider`
5. Keep `ORDER_NOT_READY` internal to the retry path unless it needs to surface to users
6. Verify that empty `items` renders safely in `OrderDetailScreen`

**Important note**:

Retrying only `orderDetailProvider` is not enough. The payment flow also reads order detail through `paymentProvider`, so both paths must be hardened together.

**Verification loop**:

1. Complete checkout
2. Open order detail immediately
3. Open payment screen immediately
4. Confirm neither path crashes on the first read

---

## Phase 2 — Contract-Dependent Fixes

These fixes should not be implemented until Phase 0 contract checks are complete.

### Bug #1: Checkout quantity mismatch

**Severity**: Critical  
**Risk**: High  
**Status**: Blocked on evidence + contract confirmation

**Why this is risky**:

The bug may not be a single checkout-screen problem. There are at least four possible failure points:

1. `POST /orders` request payload does not match the real backend contract
2. Backend order creation computes totals incorrectly
3. `GET /orders/:id` returns a wrong non-zero `totalAmount`
4. Debug/test fake repositories inject placeholder totals and make the UI appear broken

**Do not implement this unsafe behavior**:

- Do not show a mismatch toast and abort navigation after `createOrder` succeeds

Once `createOrder` returns success, the order already exists server-side. Aborting navigation there risks desynchronizing cart, payment, and order state.

**Investigation order**:

1. Capture one failing multi-quantity checkout end-to-end
2. Compare:
   - local checkout subtotal
   - `POST /orders` response `totalAmount`
   - immediate `GET /orders/:id` response `totalAmount`
3. Determine which hop first becomes wrong
4. Confirm whether the backend supports selected cart item IDs or always orders the entire cart

**Hypotheses to test**:

1. If `POST /orders` already returns the wrong total, then the bug is in request contract or backend order creation
2. If `POST /orders` is correct but `GET /orders/:id` is wrong, then the bug is in backend order detail serialization
3. If both API responses are correct but payment UI is wrong, then the bug is in the mobile display/fallback logic
4. If the failure only appears in debug paths, then fake repositories are contaminating verification

**Likely mobile follow-up after evidence is collected**:

If the `createOrder` response is correct but later order reads are wrong, update all payment-related displays to use a safe fallback strategy consistently, not only `payment_screen.dart`.

Files that must be reviewed together:

- `lib/features/payment/payment_screen.dart`
- `lib/features/payment/payment_pending_screen.dart`
- `lib/features/payment/payment_success_screen.dart`
- `lib/features/payment/widgets/bukti_transfer_card.dart`

**Backend coordination required if contract mismatch is confirmed**:

- Ensure `POST /orders` uses the real selected items and their quantities
- Ensure `GET /orders/:id` returns `totalAmount = SUM(unitPrice * quantity) + shippingCost`
- Document whether the endpoint accepts selected cart IDs or always consumes the full cart

**Verification loop**:

1. Select a cart item with quantity greater than `1`
2. Complete checkout
3. Compare totals on:
   - checkout screen
   - payment screen
   - payment pending screen
   - payment success screen
   - payment proof amount field

### Bug #4: Cannot cancel pending orders

**Severity**: High  
**Risk**: High  
**Status**: Blocked until customer cancel contract is verified

**Current uncertainty**:

The mobile plan assumes a customer endpoint like:

```text
PATCH /orders/:id/cancel
```

But the current repo docs only clearly document admin-side order status mutation.

**Do not implement mobile-only cancel behavior until the endpoint is confirmed**:

Required confirmation:

1. Exact customer cancel endpoint path and method
2. Allowed order statuses for customer cancel
3. Expected success response shape
4. Error codes such as:
   - `ORDER_ALREADY_CANCELLED`
   - `ORDER_ALREADY_PAID`
   - `INVALID_STATUS_TRANSITION`
5. Whether stock restoration is synchronous and guaranteed on cancel

**If the endpoint exists**:

Implement the mobile side with:

1. `cancelOrder(String orderId)` in `OrderRepository`
2. Matching fake repository method
3. Pending-order cancel button in `OrderDetailScreen`
4. Localized confirmation and success strings in both ARB files
5. Provider invalidation after success:
   - `orderDetailProvider(widget.orderId)`
   - `orderListProvider`
   - `productListProvider`

**If the endpoint does not exist**:

Treat Bug `#4` as a backend + mobile feature, not a mobile-only bugfix.

**Additional cleanup to include when touching this area**:

`OrderDetailScreen` currently uses `e.toString()` for a user-facing error in the confirm-received path. Replace that with `errorMessageFor(e, l10n.asErrorL10n)` while updating action handling in the screen.

**Verification loop**:

1. Open a `pending` order
2. Cancel it
3. Confirm status becomes `cancelled`
4. Confirm order list updates
5. Confirm product stock is refreshed if stock restoration is part of the backend behavior

---

## Recommended Execution Order

Use this order instead of the original bug-number sequence:

1. Phase 0 — contract confirmation and reproducible evidence capture
2. Fix debug fake totals if they interfere with verification
3. Bug `#3` — cache invalidation after checkout
4. Bug `#2` — defensive order parsing and short retries in both order and payment paths
5. Bug `#1` — only after captured evidence identifies the failing hop
6. Bug `#4` — only after customer cancel contract is confirmed

---

## Regression Test Plan

Add tests at the correct seam before or alongside fixes where practical.

### Mobile tests to add or update

1. Product list cache invalidates after successful checkout
2. Order repository tolerates `items: null` or missing `items`
3. Payment repository tolerates transitional order detail responses
4. Order detail provider retries once on `ORDER_NOT_READY`
5. Payment provider retries once on `ORDER_NOT_READY`
6. Multi-quantity total is displayed consistently across payment-related screens once the correct source of truth is confirmed
7. Pending-order cancel button only appears when the backend-supported status allows it

### Contract tests to keep aligned

1. `POST /orders` request shape matches the documented contract
2. `GET /orders/:id` response shape matches `TRANSACTIONS_API_CONTRACT.md`

---

## Verification Checklist

Run after each implemented phase:

| Step | Command |
|------|---------|
| 1. Run tests | `./rtk.exe flutter test` |
| 2. Analyze | `./rtk.exe flutter analyze` |

Manual verification checklist:

1. Multi-quantity checkout total matches across checkout and payment surfaces
2. Order detail opens immediately after checkout without crashing
3. Catalog stock updates immediately after checkout
4. Pending-order cancel only ships if the customer endpoint is confirmed and working
5. No user-facing raw exception strings appear in toasts or error views

---

## Stop Conditions

Pause implementation and realign if any of these happen:

1. The backend contract in code and docs do not match
2. A fix depends on an undocumented customer endpoint
3. The bug cannot be reproduced with a reliable loop
4. The debug fake repositories are still influencing the verification path
