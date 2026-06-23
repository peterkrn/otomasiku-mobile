# Cart System — Critical Bugs

## 1. Checkout quantity mismatch

**Severity**: Critical

When user selects 4 quantity of product X at Rp. 500.000 each:
- Checkout page subtotal shows Rp. 2.000.000 (correct)
- Payment page subtotal shows Rp. 500.000 (wrong — only 1 unit calculated)

**Expected**: Payment page subtotal matches checkout subtotal.

**Suspect**: `createOrder` payload sends only `cartItemIds` and `addressId` — the quantity field may not be passed through to the payment flow, causing it to default to 1. Or the order-items query on payment screen fetches a single item without quantity multiplication.

---

## 2. Order detail crashes after successful checkout

**Severity**: Critical

After checkout succeeds, tapping "View Order" or navigating to order detail shows:
> Something went wrong. Please try again.

The error is not retryable. The order was created server-side but the client cannot display it.

**Expected**: Order detail renders the order with items, status, and amounts.

**Suspect**: Possible API response shape mismatch — `getOrderById` expects `data.order` + `data.items` but the actual response may differ for newly created orders (e.g. items nested differently, or missing before async processing completes).

---

## 3. Stock not decremented after checkout

**Severity**: High

After successful checkout, returning to the product catalog shows the same stock count as before. If stock was 10 units before ordering 4, it still shows 10 units.

**Expected**: Stock should decrement from X to X minus quantity ordered.

**Suspect**: Product list provider caches the response and does not invalidate after checkout. The `ProductListNotifier` has a TTL cache — stock changes on the server are not reflected until cache expires or user manually refreshes.

---

## 4. Cannot cancel pending orders

**Severity**: High

Orders in `pending` status have no cancel option. User cannot cancel to release stock back.

**Expected**: Pending orders should have a cancel action that:
1. Sends cancel request to backend
2. Releases reserved stock
3. Updates order status to `cancelled`

**Suspect**: Cancel endpoint may exist but the UI does not expose the action. The `OrderDetailScreen` status logic may not render a cancel button for `pending` status.
