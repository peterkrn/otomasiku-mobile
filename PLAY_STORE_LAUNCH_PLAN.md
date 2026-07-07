# Play Store Launch Plan: QRIS Stock Hold, Proof Upload, and Expiry Safety

## Summary
- Ship a checkout-held stock model for tomorrow’s Play Store release: the first successful checkout reserves stock, and unpaid orders automatically release stock after 24 hours.
- Make checkout honor **selected cart items only**, because the current mobile UX is partial-checkout but the backend currently converts the whole cart into an order.
- Restore the existing payment-proof flow on mobile instead of the current “Saya Sudah Bayar” no-op, and keep the existing backend/admin proof-verification APIs.
- Avoid schema churn before launch: reuse existing `payment_proofs`, `payment_status`, and `va_expires_at`; treat `va_expires_at` as the QRIS/manual-payment deadline in this release.

## Public Interface Changes
- `POST /api/orders` request body gains required `cartItemIds: string[]` of selected cart-item UUIDs; backend rejects empty, foreign, missing, or unavailable IDs.
- Mobile cart selection state changes from `productId`-based selection to `cartItemId`-based selection so the request can target exact items.
- Order creation clears only the submitted cart items, not the user’s entire cart.
- Every newly created unpaid QRIS/manual-verification order gets `va_expires_at = created_at + 24h`; no new endpoint is needed because order detail already returns `vaExpiresAt` and `paymentProof`.

## Implementation Changes
- **Backend**
  - Update the create-order DTO and flow to load only submitted `cartItemIds`, validate ownership, validate live stock, keep optimistic locking, create the order, deduct stock, and delete only those selected cart items.
  - Keep order creation as `status = pending` and `payment_status = unpaid`, but always populate `va_expires_at` with the 24-hour deadline.
  - Add an env-gated in-process expiry sweep in the backend app, running every 5 minutes, that finds orders with `status = pending`, `payment_status = unpaid`, and `va_expires_at <= now`, then marks them `status = cancelled` and `payment_status = expired`, restores stock exactly once, and writes order-status history using `SYSTEM_USER_ID`.
  - Make expiry cancellation idempotent by guarding the cancellation/update path so repeated sweeps or duplicate runners do not double-restore stock.
  - Keep the existing payment-proof upload and admin verification endpoints; do not add new proof APIs.
  - Normalize proof-flow and stock-conflict errors so mobile can show specific messages for `STOCK_CONFLICT`, paid-order proof upload, rejected proof re-upload, and expired/cancelled orders.

- **Mobile**
  - Change cart and checkout selection logic to track selected `cartItemId`s and send them in the order-create request.
  - Preserve unselected cart items after successful checkout; only submitted items are removed locally after the order is created.
  - Keep the current payment route, but replace the current “Saya Sudah Bayar” navigation-only action with an inline proof-upload form below the QRIS section.
  - Use the existing proof fields with launch-safe defaults:
    - `amount` is prefilled from `order.totalAmount` and read-only.
    - `bankName` is required free text for the payment source/app/bank.
    - `accountName` is required free text for the payer name.
    - proof image is required and uploaded via the existing multipart endpoint.
  - After successful proof upload, navigate to the pending screen and invalidate order/payment providers so proof status is fresh immediately.
  - Keep 15-second polling on the pending screen; route to order detail when payment becomes `paid`, show rejection reason plus re-upload CTA when proof is rejected, and show an expiry message plus stock-release guidance when the order becomes `cancelled + expired`.
  - Add a compact pending-payment/proof-status section to order detail so users can still see deadline, proof state, and rejection reason after leaving the pending screen.
  - Add/finish i18n coverage for stock-changed, proof-uploaded, proof-rejected, payment-expired, and stock-released messaging, and remove generic fallback messaging for this flow.

- **Admin / Ops**
  - No admin repo code change is required by default; the admin repo already has payment-proof fetch/approve/reject support.
  - Add a launch-day ops checklist: confirm proof uploads appear in admin order detail, confirm approval moves order to `processing`, and confirm expired unpaid orders are being cancelled/restocked by the sweep.

## Test Plan
- **Backend**
  - `CreateOrderFlow`: empty selection, foreign cart item IDs, unavailable product, insufficient stock, selected-items-only checkout, and clearing only submitted cart items.
  - Concurrency: two users attempt to buy the last unit; first checkout succeeds, second fails with stock conflict/insufficient stock.
  - Expiry sweep: expired pending/unpaid order becomes `cancelled + expired`, stock is restored once, rerunning the sweep is a no-op.
  - Payment proof flow: happy-path upload, invalid file type, oversized file, wrong owner, upload after paid/cancelled order, approve moves order to `processing`, reject keeps order pending and allows re-upload.
  - Verification commands: `pnpm lint`, `pnpm test`, `pnpm build`.

- **Mobile**
  - Provider/repository tests for selected `cartItemId` handling, create-order payload contents, partial cart preservation, and error translation for `STOCK_CONFLICT`.
  - Payment-flow tests for proof upload success, rejected-proof retry state, pending-screen polling transition to paid, and expired-order messaging.
  - Verification commands: `./rtk.exe flutter analyze`, `./rtk.exe flutter test`, `./rtk.exe flutter build appbundle`.

- **Manual release scenarios**
  - A and B both add the last unit; A checks out first, B fails at checkout.
  - A checks out and never uploads proof; after 24 hours the order expires, stock returns, and B can checkout.
  - A uploads proof; admin approves in `otomasiku-admin`; mobile pending screen transitions to paid/processing.
  - A uploads incorrect proof; admin rejects; mobile shows reject reason and allows re-upload on the same order.

## Skills To Load
- **`otomasiku-mobile`**
  - Load `ui-ux-pro-max`.
  - Load `verification-before-completion`.
  - `flutter-ui` is **not available** in this session; use `ui-ux-pro-max` as the replacement.
  - Recommended extra: `test-driven-development`, because this change adds new provider/payment-flow behavior that should be test-led.

- **`otomasiku-backend`**
  - Load `test-driven-development`.
  - Load `verification-before-completion`.
  - Recommended extra: `supabase`, because proof uploads and signed URLs depend on Supabase Storage.

## Assumptions Locked
- Stock is reserved at checkout, not at payment approval.
- Checkout uses selected cart items only.
- Payment proof upload is restored for this release candidate.
- Unpaid orders hold stock for 24 hours, then auto-cancel and restock.
- `va_expires_at` is reused as the payment-deadline field for launch; no schema rename happens before tomorrow.
- Launch-day backend deployment is assumed to be a single production instance, so an env-gated in-process expiry sweep is acceptable for tomorrow’s release.
