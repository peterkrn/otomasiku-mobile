import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../data/dummy/dummy_cart.dart' as dummy_cart;

/// Provider for managing shopping cart state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

/// Shopping cart state
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  /// Total number of items in cart
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Total cart value
  int get totalValue => items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Get quantity of specific product in cart
  int getQuantityForProduct(String productId) {
    if (items.isEmpty) return 0;
    final item = items.firstWhere(
      (i) => i.product.id == productId,
      orElse: () => CartItem(id: '', product: items.first.product, quantity: 0),
    );
    return item.quantity;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Shopping cart notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState(items: []));

  /// Load cart from dummy data (M2 only)
  void loadCart() {
    state = state.copyWith(items: dummy_cart.dummyCartItems);
  }

  /// Add item to cart
  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere(
      (i) => i.product.id == item.product.id,
    );

    if (existingIndex >= 0) {
      // Update quantity
      final updatedItems = List<CartItem>.from(state.items);
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = CartItem(
        id: existingItem.id,
        product: existingItem.product,
        quantity: existingItem.quantity + item.quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  /// Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return CartItem(
          id: item.id,
          product: item.product,
          quantity: quantity,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  /// Remove item from cart
  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  /// Clear cart
  void clearCart() {
    state = const CartState(items: []);
  }
}
