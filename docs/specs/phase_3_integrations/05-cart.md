# Spec 05 — Cart: CRUD, Optimistic UI, Idempotency

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | High |
| **Status** | ⬜ Draft |
| **Depends On** | 01, 02, 03 |
| **API Endpoints** | `GET /api/cart`, `POST /api/cart`, `PUT /api/cart/:id`, `DELETE /api/cart/:id`, `DELETE /api/cart` |

---

## Scope

Replace dummy cart data with real API. Implement optimistic UI for quantity changes and item removal (update local state immediately, revert on failure). Enforce idempotency key on add-to-cart.

---

## Modified Files

```
lib/providers/cart_provider.dart      # Replace dummy → StateNotifier with real API
lib/features/cart/                    # Wire cart screen to real provider
lib/features/home/widgets/product_card.dart  # "Tambah" button uses real cart
lib/features/product_detail/          # "Tambah ke Keranjang" uses real cart
```

---

## API Reference

### `POST /api/cart` — requires `X-Idempotency-Key` header
```
Body: { "productId": "uuid", "quantity": 1 }
Response 200: { "success": true, "data": CartItem }
Error 400: INSUFFICIENT_STOCK → { details: { available: N, requested: M } }
Error 409: CART_ITEM_ALREADY_EXISTS
```

### `PUT /api/cart/:id`
```
Body: { "quantity": 3 }
Response 200: { "success": true, "data": CartItem }
```

### `DELETE /api/cart/:id`
```
Response 204
```

### `DELETE /api/cart`
```
Response 204 (clear all)
```

---

## Acceptance Criteria

### AC-1: Cart loads from API on screen open
```gherkin
Given the user navigates to the cart screen
When the screen loads
Then GET /api/cart is called
And the cart items are displayed with productSnapshot name, price, quantity
And the total is calculated: sum of (price × quantity) for all items
And prices use CurrencyFormatter
```

### AC-2: Add to cart sends idempotency key
```gherkin
Given the user taps "Tambah" on a product card
When the add-to-cart request is sent
Then POST /api/cart is called with X-Idempotency-Key: <uuid_v4>
And the cart badge count increments immediately (optimistic)
And a snackbar confirms "Ditambahkan ke keranjang"
If the request fails
Then the cart badge reverts to its previous count
And a localized error snackbar is shown
```

### AC-3: Quantity update is optimistic
```gherkin
Given the user is on the cart screen
When the user taps "+" to increase quantity of an item
Then the quantity and total update immediately in the UI (optimistic)
And PUT /api/cart/:id is called in the background
If the request fails (e.g. INSUFFICIENT_STOCK)
Then the quantity reverts to the previous value
And a localized error is shown: "Stok tidak mencukupi. Tersedia: N unit."
```

### AC-4: Remove item is optimistic
```gherkin
Given the user taps the remove button on a cart item
Then the item disappears from the list immediately (optimistic)
And DELETE /api/cart/:id is called in the background
If the request fails
Then the item reappears in the list
And a localized error snackbar is shown
```

### AC-5: Cart badge reflects real count
```gherkin
Given the user has 3 items in cart
When the cart screen is visible
Then the bottom nav cart icon shows badge "3"
When the user removes an item
Then the badge updates to "2" immediately
```

### AC-6: Empty cart state
```gherkin
Given the user has no items in cart
When the cart screen loads
Then an empty state is shown: illustration + "Keranjang belanja kosong"
And a "Mulai Belanja" button navigates to /home
```

### AC-7: CART_ITEM_ALREADY_EXISTS is handled gracefully
```gherkin
Given a product is already in the cart
When the user taps "Tambah" on that product again
Then the API returns CART_ITEM_ALREADY_EXISTS
Then the cart quantity for that item is incremented by 1 via PUT /api/cart/:id
And no error is shown to the user
```

---

## Provider Design

```dart
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  int get totalPrice => items.fold(0, (sum, item) => sum + (item.productSnapshot.price * item.quantity));
}

class CartNotifier extends StateNotifier<CartState> {
  Future<void> loadCart();

  Future<void> addItem(String productId, int quantity) async {
    // 1. Optimistic: increment badge
    // 2. POST /api/cart with X-Idempotency-Key
    // 3. On success: reload cart
    // 4. On CART_ITEM_ALREADY_EXISTS: call updateItem instead
    // 5. On failure: revert optimistic change
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    // 1. Optimistic: update local state
    // 2. PUT /api/cart/:id
    // 3. On failure: revert
  }

  Future<void> removeItem(String cartItemId) async {
    // 1. Optimistic: remove from local list
    // 2. DELETE /api/cart/:id
    // 3. On failure: re-insert item
  }

  Future<void> clearCart();
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.read(cartRepositoryProvider));
});

// Cart item count for badge
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});
```

---

## Idempotency Key Generation

```dart
// Generate once per add-to-cart attempt, not per retry
// Store in local variable, not provider state
import 'package:uuid/uuid.dart';
final idempotencyKey = const Uuid().v4();
```

---

## Verification Checklist

- [ ] Cart loads real data from API
- [ ] Add to cart sends `X-Idempotency-Key` header
- [ ] Quantity +/- updates optimistically, reverts on failure
- [ ] Remove item optimistic, reverts on failure
- [ ] Cart badge updates in real-time
- [ ] Empty cart state shown correctly
- [ ] `CART_ITEM_ALREADY_EXISTS` → increment quantity silently
- [ ] `INSUFFICIENT_STOCK` → show localized error with available count
- [ ] `dummy_cart.dart` no longer imported
- [ ] `flutter analyze` clean
