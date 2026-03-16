import 'dummy_products.dart';
import '../../models/cart_item.dart';

/// Dummy cart items for Milestone 2 UI development
/// Source: docs/PLAN_MILESTONE_2.md § "Other Dummy Data Files"
/// Pre-filled cart: FR-A820-0.4K × 2, FX5U-32MT/ESS × 1
final List<CartItem> dummyCartItems = [
  CartItem(
    id: 'cart-001',
    product: dummyProducts[0], // FR-A820-0.4K-1
    quantity: 2,
  ),
  CartItem(
    id: 'cart-002',
    product: dummyProducts[2], // FX5U-32MT/ES
    quantity: 1,
  ),
];

/// Calculate cart subtotal
int get cartSubtotal {
  return dummyCartItems.fold(0, (sum, item) => sum + item.totalPrice);
}

/// Calculate total cart items count
int get cartItemCount {
  return dummyCartItems.fold(0, (sum, item) => sum + item.quantity);
}
