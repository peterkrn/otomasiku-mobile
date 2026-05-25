import 'dummy_products.dart';
import '../../models/cart_item.dart';

final List<CartItem> dummyCartItems = [
  CartItem(
    id: 'cart-001',
    productId: dummyProducts[0].id,
    productSnapshot: CartProductSnapshot(
      name: dummyProducts[0].name,
      price: dummyProducts[0].price,
      primaryImageUrl: dummyProducts[0].primaryImageUrl,
    ),
    quantity: 2,
    createdAt: DateTime(2024, 1, 1),
  ),
  CartItem(
    id: 'cart-002',
    productId: dummyProducts[2].id,
    productSnapshot: CartProductSnapshot(
      name: dummyProducts[2].name,
      price: dummyProducts[2].price,
      primaryImageUrl: dummyProducts[2].primaryImageUrl,
    ),
    quantity: 1,
    createdAt: DateTime(2024, 1, 1),
  ),
];

int get cartSubtotal {
  return dummyCartItems.fold(
    0,
    (sum, item) => sum + item.productSnapshot.price * item.quantity,
  );
}

int get cartItemCount {
  return dummyCartItems.fold(0, (sum, item) => sum + item.quantity);
}
