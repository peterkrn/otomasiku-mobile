import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../data/dummy/dummy_cart.dart' as dummy_cart;

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalValue =>
      items.fold(0, (sum, item) => sum + item.productSnapshot.price * item.quantity);

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

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState(items: []));

  void loadCart() {
    state = state.copyWith(items: dummy_cart.dummyCartItems);
  }

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere(
      (i) => i.productId == item.productId,
    );

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = CartItem(
        id: existingItem.id,
        productId: existingItem.productId,
        productSnapshot: existingItem.productSnapshot,
        quantity: existingItem.quantity + item.quantity,
        createdAt: existingItem.createdAt,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.productId == productId) {
        return CartItem(
          id: item.id,
          productId: item.productId,
          productSnapshot: item.productSnapshot,
          quantity: quantity,
          createdAt: item.createdAt,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void clearCart() {
    state = const CartState(items: []);
  }
}
