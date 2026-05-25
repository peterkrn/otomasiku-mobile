# Spec 06 — Checkout & Orders: Checkout Flow, Order Creation, Order History

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | High |
| **Status** | ⬜ Draft |
| **Depends On** | 01, 02, 03, 05 |
| **API Endpoints** | `POST /api/orders`, `GET /api/orders`, `GET /api/orders/:id`, `GET /api/orders/:id/status-history` |

---

## Scope

Wire up the checkout flow (address selection → order summary → place order) and order history/detail screens to real API. Enforce idempotency on order creation. Handle all stock/address error cases.

---

## Modified Files

```
lib/providers/order_provider.dart     # Replace dummy → real API
lib/features/checkout/               # Wire checkout screens to real providers
lib/features/orders/                  # Wire order list + detail to real API
```

---

## Checkout Flow

```
Cart Screen
  └─ "Lanjut ke Checkout" button
       │
       ▼
Checkout Screen
  ├─ Address selector (from /api/addresses)
  ├─ Order summary (items from cart state — already loaded)
  ├─ Notes input (optional, max 500 chars)
  └─ "Buat Pesanan" button
       │
       ▼ POST /api/orders (with X-Idempotency-Key)
       │
       ├─ Success → Payment Screen (spec 07)
       └─ Error → show localized error, stay on checkout
```

---

## Acceptance Criteria

### AC-1: Checkout screen shows cart summary and address selector
```gherkin
Given the user navigates to checkout
When the screen loads
Then the cart items are displayed (from cartProvider — no extra API call)
And the subtotal is shown using CurrencyFormatter
And the user's saved addresses are loaded from GET /api/addresses
And the default address is pre-selected
And a "Tambah Alamat" option is available if no addresses exist
```

### AC-2: Place order sends idempotency key
```gherkin
Given the user has selected an address and reviews the order
When the user taps "Buat Pesanan"
Then a loading state is shown on the button
And POST /api/orders is called with:
  - body: { addressId, notes? }
  - header: X-Idempotency-Key: <uuid_v4>
  - header: Authorization: Bearer <token>
On success (201):
  - Navigate to payment screen with orderId
  - Cart is cleared (cartProvider.clearCart())
```

### AC-3: Insufficient stock error on checkout
```gherkin
Given a product's stock was depleted between add-to-cart and checkout
When POST /api/orders returns INSUFFICIENT_STOCK
Then the user stays on the checkout screen
And a localized error is shown: "Stok tidak mencukupi untuk [product]. Tersedia: N unit."
And the user can go back to cart to update quantities
```

### AC-4: Order history loads paginated
```gherkin
Given the user navigates to the orders screen
When the screen loads
Then GET /api/orders?page=1&pageSize=20 is called
And orders are displayed sorted by newest first
And each order card shows: orderNumber, status badge, totalAmount, createdAt
When the user scrolls to the bottom
Then the next page is loaded and appended
```

### AC-5: Order detail shows full information
```gherkin
Given the user taps an order card
When the order detail screen loads
Then GET /api/orders/:id is called
And the screen shows: order number, status, items list, shipping address, total, notes
And GET /api/orders/:id/status-history is called
And a status timeline is shown (pending → confirmed → processing → shipped → done)
And the current status is highlighted
```

### AC-6: Order status badge colors
```gherkin
Given an order with status "pending"
Then the badge is orange: "Menunggu Pembayaran"
Given status "confirmed" or "processing"
Then the badge is blue: "Diproses"
Given status "shipped"
Then the badge is purple: "Dikirim"
Given status "done"
Then the badge is green: "Selesai"
Given status "cancelled"
Then the badge is red: "Dibatalkan"
```

### AC-7: Pull-to-refresh on order list
```gherkin
Given the user is on the orders screen
When the user pulls down to refresh
Then the order list resets to page 1 and re-fetches
```

### AC-8: Empty order history state
```gherkin
Given the user has no orders
When the orders screen loads
Then an empty state is shown: "Belum ada pesanan"
And a "Mulai Belanja" button navigates to /home
```

---

## Provider Design

```dart
// Order creation state
class CreateOrderState {
  final bool isLoading;
  final String? error;
  final CreateOrderResult? result;
}

class OrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  int _page = 1;
  bool _hasMore = true;

  Future<void> loadOrders();
  Future<void> loadMore();
  Future<void> refresh();
}

final orderListProvider = AsyncNotifierProvider<OrderNotifier, List<Order>>(OrderNotifier.new);

final orderDetailProvider = FutureProvider.autoDispose.family<Order, String>((ref, id) {
  return ref.read(orderRepositoryProvider).getOrderById(id);
});

final orderStatusHistoryProvider = FutureProvider.autoDispose.family<List<OrderStatusHistory>, String>((ref, id) {
  return ref.read(orderRepositoryProvider).getStatusHistory(id);
});

// Checkout action — not a provider, called directly from screen
// Returns CreateOrderResult on success, throws AppException on failure
```

---

## Error Code Mapping (order-specific)

| Code | Screen Message |
|------|----------------|
| `INSUFFICIENT_STOCK` | "Stok tidak mencukupi untuk {product}. Tersedia: {available} unit." |
| `PRODUCT_UNAVAILABLE` | "Produk {name} sudah tidak tersedia." |
| `ADDRESS_NOT_FOUND` | "Alamat tidak ditemukan. Pilih alamat lain." |
| `BAD_REQUEST` | "Keranjang belanja kosong." |
| `IDEMPOTENCY_KEY_EXISTS` | (silent — return cached response, navigate to payment) |

---

## Verification Checklist

- [ ] Checkout screen shows cart items without extra API call
- [ ] Addresses loaded from API, default pre-selected
- [ ] Place order sends `X-Idempotency-Key`
- [ ] On success: navigate to payment, cart cleared
- [ ] `INSUFFICIENT_STOCK` shows localized error with available count
- [ ] `IDEMPOTENCY_KEY_EXISTS` treated as success (navigate to payment)
- [ ] Order list paginates correctly
- [ ] Order detail shows status timeline
- [ ] Status badge colors match spec
- [ ] `dummy_orders.dart` no longer imported
- [ ] `flutter analyze` clean
