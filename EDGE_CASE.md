# Edge Cases — Otomasiku Mobile

Tracked edge cases encountered during development. Updated whenever `Edge Case` is mentioned.

---

## 1. Compare → Beli → Empty Checkout (Fixed: 2026-05-26)

**Symptom:** User compares products, clicks "Beli" on product detail, navigates to checkout, sees "Keranjang Kosong" and "Mulai Belanja" button.

**Root cause:** `_buyNow()` in `product_detail_screen.dart:890` called `addItem()` and navigated to checkout, but never populated `selectedCartItemsProvider`. Checkout filtered `cartProvider.items` through `selectedCartItemsListProvider` which was an empty set.

**Fix:** `_buyNow()` now sets `selectedCartItemsProvider.notifier.state = {product.idString}` before navigating.

---

## 2. Cart Badge / Cart Page Count Mismatch (Fixed: 2026-05-26)

**Symptom:** Badge shows "13" or "5" randomly. Adding 3 products shows badge "3" but cart page shows only 2 products. Quantity mismatched between badge and actual cart.

**Root cause:** `loadCart()` in `cart_screen.dart:25` unconditionally called on every cart page mount, overwriting optimistic state with server response. If user added items quickly and navigated to cart, the server GET /cart returned before all addItem API calls committed.

**Fix:** `cart_screen.dart` now only calls `loadCart()` if items are empty and not currently loading. Checkout also loads cart if empty. Additionally, `addItem()` for new items preserves optimistic quantity instead of using server response quantity.

---

## 3. Remove Item in Checkout — Dead Code (Fixed: 2026-05-26)

**Symptom:** Removing items from checkout left stale productIds in `selectedCartItemsProvider`.

**Root cause:** `_removeItem()` called `removeItem()` (optimistic removal) first, THEN tried to find the removed item in state. The item was already gone, so the `selectedCartItemsProvider` cleanup never executed.

**Fix:** Capture `productId` from state BEFORE calling `removeItem()`.

---

## 4. Cart Item Card / Subtotal Display (Fixed: 2026-05-26)

**Symptom:** Cart item card showed price×qty as the line-item price. Subtotal calculation was correct but display semantics were wrong — unit price should be stable regardless of quantity.

**Root cause:** `cart_item_card.dart` computed `totalPrice = snapshot.price * item.quantity` instead of showing unit price. Subtotal always displayed even when nothing selected.

**Fix:** 
- Cart item card now shows unit price (`snapshot.price`), not price×qty
- Subtotal shows `-` when `totalItems == 0` (no items selected), `CurrencyFormatter.format(subtotal)` when items are selected
- `addItem()` uses server's `response.quantity` for new items (not optimistic quantity)

---

## 5. BCA Payment Blocks Checkout (Simulated: 2026-05-26)

**Symptom:** Checking out redirects to cart page with "Terjadi kesalahan silakan coba lagi". BCA API unavailable in staging.

**Root cause:** `createOrder` API call fails because Express backend requires BCA integration. Payment polling also fails.

**Fix:** In `kDebugMode`, `createOrder` returns a simulated `CreateOrderResult` and `PaymentPollingNotifier` returns "paid" after 2 seconds. This allows testing the full checkout flow in staging.

---

## 6. Form Input Validation — Wrong Data Types (Fixed: 2026-05-26)

**Symptom:** Name fields accept digits, address fields accept symbols, phone fields accept letters. Label and recipient fields accepted symbols like +-*/%.

**Root cause:** All `TextFormField` widgets had no `inputFormatters` restrictions, or only blocked digits.

**Fix:** Added `FilteringTextInputFormatter` to all form fields:

| Screen | Field | Restriction |
|--------|-------|-------------|
| `edit_address_screen.dart` | Label | Letters + spaces only |
| `edit_address_screen.dart` | Recipient | Letters + spaces only |
| `edit_address_screen.dart` | Phone | Only digits, +, space |
| `edit_address_screen.dart` | Street | Letters, numbers, basic punctuation |
| `edit_address_screen.dart` | City | Letters, spaces only |
| `edit_address_screen.dart` | Province | Letters, spaces only |
| `edit_address_screen.dart` | Postal Code | Digits only |
| `edit_profile_screen.dart` | Full Name | Letters, spaces, ., ,, - |
| `edit_profile_screen.dart` | Phone | Only digits, +, space |
| `edit_profile_screen.dart` | Company | Letters, numbers, basic business chars |
| `register_screen.dart` | Name | Letters, spaces only |

## 7. Pesanan Saya — Raw Render Error (Fixed: 2026-05-26)

**Symptom:** "A RenderCustomMultiChildLayoutBox expected a child of type RenderBox..." red-screen error on all order tabs (Semua/Diproses/Selesai).

**Root cause:** `RetryWidget` (used in `orders_screen.dart:101` error handler) wrapped content in `SliverToBoxAdapter`. A sliver widget was placed inside a regular `async.when()` callback expecting a box widget.

**Fix:** Removed `SliverToBoxAdapter` wrapper from `RetryWidget`. Now returns `Padding > Center > Column` directly.

## 8. Proyek Saya — Project Not Persisting (Fixed: 2026-05-26)

**Symptom:** "Buat Proyek" shows success toast but project never appears in list. "Belum ada proyek" stays.

**Root cause:** Dialog only showed a toast. No state management, no persistence. Project list was hardcoded as `const projects = <Project>[]`.

**Fix:** Added `projectsProvider` (`StateProvider<List<Project>>`). Dialog now appends to provider state with UUID, empty items, and `planning` status.

## 9. Language Toggle + Settings Button Removal (Fixed: 2026-05-26)

**Symptom:** No language switching UI. Settings button in profile AppBar did nothing.

**Root cause:** `LocaleNotifier.toggleLocale()` existed but was never wired to UI. Settings `IconButton` had empty `onPressed`.

**Fix:** 
- Removed Settings `IconButton` from profile AppBar
- Added language toggle menu item (`_buildLocaleToggle`) showing ID/EN indicator, calls `localeProvider.notifier.toggleLocale()`

## 10. "Keranjang Kosong" Flash After Bayar (Fixed: 2026-05-26)

**Symptom:** After clicking "Bayar Pesanan", cart page briefly showed empty cart before payment screen.

**Root cause:** `clearCart()` was called before navigating to payment screen, causing a visual flash of empty cart state.

**Fix:** Moved `clearCart()` to after the mounted check but before `context.pushNamed`. The navigation itself now happens immediately after clearing.

## 11. Pembayaran Berhasil → "Pesanan Tidak Ditemukan" (Fixed: 2026-05-26)

**Symptom:** After payment success, clicking "Lihat Pesanan" shows "pesanan tidak ditemukan".

**Root cause:** Simulated orders (created in `kDebugMode`) aren't on the server. `orderDetailProvider` called `getOrderById()` which failed for sim-* IDs.

**Fix:** `orderDetailProvider` returns a simulated `Order` in `kDebugMode` for IDs starting with "sim-".

## 12. Back Button Missing / App Closes (Fixed: 2026-05-26)

**Symptom:** Payment success screen — back button exits app to Android home.

**Root cause:** `PopScope` and back button both navigated to `AppRoute.home`, which on some navigation stacks causes the app to close.

**Fix:** Back button and `PopScope` now navigate to `AppRoute.orders` instead of `AppRoute.home`.

---

## Template

| # | Symptom | Root cause | Fix | Status |
|---|---------|-----------|-----|--------|
| 7 | ... | ... | ... | 🔴 Open / 🟢 Fixed |
