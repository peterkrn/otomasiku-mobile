# Current State — Big Refactor Bug Fixes

> **Whenever `edge case` or `edge cases` is mentioned, update this file** to document new bugs found and fixed. Source of truth for resolved bugs: `EDGE_CASE.md`.

**Branch:** `feat/spec-08-09-profile-push`  
**Last updated:** 2026-05-26  
**Total resolved:** 12

---

| # | Category | Symptom | Root Cause | File(s) Changed |
|---|----------|---------|------------|-----------------|
| 1 | Cart | Compare → Beli → empty checkout ("Keranjang Kosong") | `_buyNow()` never populated `selectedCartItemsProvider` | `product_detail_screen.dart` |
| 2 | Cart | Badge shows random counts; cart page shows fewer items | `loadCart()` overwrote optimistic state on every mount | `cart_screen.dart`, `checkout_screen.dart`, `cart_provider.dart` |
| 3 | Cart | Removing items in checkout left stale selections | `_removeItem()` read state AFTER optimistic removal | `checkout_screen.dart` |
| 4 | Cart | Cart item card showed price×qty instead of unit price | `totalPrice` computed wrong; subtotal always visible | `cart_item_card.dart`, `cart_screen.dart`, `cart_provider.dart` |
| 5 | Payment | Checkout redirects to error ("Terjadi kesalahan") | BCA API unavailable in staging; `createOrder` + polling fail | `order_repository.dart`, `payment_provider.dart` (kDebugMode simulation) |
| 6 | Input | Name fields accept digits; symbols pass in label/recipient | No `inputFormatters` or only digit-block | `edit_address_screen.dart`, `edit_profile_screen.dart`, `register_screen.dart` |
| 7 | UI | Orders screen red error: RenderCustomMultiChildLayoutBox | `RetryWidget` used `SliverToBoxAdapter` in box context | `retry_widget.dart` |
| 8 | Feature | "Buat Proyek" toast shows but project list stays empty | No state persistence; hardcoded empty list | `projects_screen.dart` (added `projectsProvider`) |
| 9 | UX | No language switch; Settings button does nothing | `toggleLocale()` unwired; empty `onPressed` | `profile_screen.dart` (removed Settings, added lang toggle) |
| 10 | UX | Empty cart flashes after clicking "Bayar Pesanan" | `clearCart()` fired before navigation | `checkout_screen.dart` (reordered) |
| 11 | Payment | "Lihat Pesanan" shows "pesanan tidak ditemukan" | Simulated order IDs not recognized by `getOrderById` | `order_provider.dart` (simulated Order for sim-* in kDebugMode) |
| 12 | Nav | Back button on payment success exits app | Back + PopScope navigated to `AppRoute.home` | `payment_success_screen.dart` (now navigates to orders) |

---

## Files Touched (this session)

```
lib/
├── features/
│   ├── address/edit_address_screen.dart          (input validation)
│   ├── auth/register_screen.dart                 (input validation)
│   ├── cart/cart_screen.dart                     (loadCart guard, subtotal display)
│   ├── cart/widgets/cart_item_card.dart          (unit price display)
│   ├── checkout/checkout_screen.dart             (clearCart ordering, address provider, removeItem, cart load)
│   ├── order/orders_screen.dart                  (no changes — error was in RetryWidget)
│   ├── order/order_detail_screen.dart            (no direct changes)
│   ├── payment/payment_screen.dart               (no direct changes)
│   ├── payment/payment_success_screen.dart       (back navigation target)
│   ├── product_detail/product_detail_screen.dart (selectedCartItemsProvider in _buyNow)
│   ├── profile/profile_screen.dart               (language toggle, remove Settings)
│   ├── profile/edit_profile_screen.dart          (input validation)
│   └── projects/projects_screen.dart             (projectsProvider persistence)
├── providers/
│   ├── cart_provider.dart                        (response.quantity, optimistic merge)
│   ├── payment_provider.dart                     (kDebugMode simulation)
│   └── order_provider.dart                       (kDebugMode order detail simulation)
├── data/repositories/
│   └── order_repository.dart                     (kDebugMode createOrder simulation)
└── shared/widgets/
    └── retry_widget.dart                         (removed SliverToBoxAdapter)
```
