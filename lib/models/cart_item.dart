import 'product.dart';

/// Cart item model for Otomasiku Marketplace
class CartItem {
  final String id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  /// Calculate total price for this cart item (money-safe integer multiplication)
  int get totalPrice => product.price * quantity;
}
