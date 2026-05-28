import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/app_exception.dart';
import '../data/repositories/cart_repository.dart';
import '../models/cart_item.dart';
import 'repository_providers.dart';

final selectedCartItemsProvider = StateProvider<Set<String>>((ref) => {});

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.read(cartRepositoryProvider);
  return CartNotifier(repository);
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
  CartNotifier(this._repository) : super(const CartState(items: []));

  final CartRepository _repository;

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.getCart();
      state = CartState(items: response.items);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.code);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'UNKNOWN');
    }
  }

  Future<void> addItem(String productId, int quantity) async {
    final previousState = state;

    final optimisticItem = CartItem(
      id: _generateLocalId(),
      productId: productId,
      quantity: quantity,
      productSnapshot: const CartProductSnapshot(
        name: '',
        price: 0,
        primaryImageUrl: '',
      ),
      createdAt: DateTime.now(),
    );

    final existingIndex = state.items.indexWhere((i) => i.productId == productId);
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = CartItem(
        id: existing.id,
        productId: existing.productId,
        productSnapshot: existing.productSnapshot,
        quantity: existing.quantity + quantity,
        createdAt: existing.createdAt,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, optimisticItem]);
    }

    final idempotencyKey = const Uuid().v4();
    try {
      final response = await _repository.addItem(
        productId: productId,
        quantity: quantity,
        idempotencyKey: idempotencyKey,
      );

      if (existingIndex >= 0) {
        final updatedItems = List<CartItem>.from(state.items);
        final idx = updatedItems.indexWhere((i) => i.productId == productId);
        if (idx >= 0) {
          updatedItems[idx] = CartItem(
            id: response.id,
            productId: response.productId,
            productSnapshot: response.productSnapshot,
            quantity: updatedItems[idx].quantity,
            createdAt: response.createdAt,
          );
          state = state.copyWith(items: updatedItems);
        }
      } else {
        final updatedItems = List<CartItem>.from(state.items);
        final idx = updatedItems.indexWhere((i) => i.id == optimisticItem.id);
        if (idx >= 0) {
          updatedItems[idx] = CartItem(
            id: response.id,
            productId: response.productId,
            productSnapshot: response.productSnapshot,
            quantity: response.quantity,
            createdAt: response.createdAt,
          );
          state = state.copyWith(items: updatedItems);
        }
      }
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        await _repository.addItem(
          productId: productId,
          quantity: quantity,
          idempotencyKey: const Uuid().v4(),
        );
        return;
      }
      // USER_NOT_FOUND means bootstrap hasn't completed yet — retry once after delay
      if (e.code == 'USER_NOT_FOUND') {
        await Future.delayed(const Duration(seconds: 2));
        try {
          await _repository.addItem(
            productId: productId,
            quantity: quantity,
            idempotencyKey: const Uuid().v4(),
          );
          return;
        } catch (_) {}
      }
      state = previousState;
      state = state.copyWith(error: e.code);
    } catch (e) {
      state = previousState;
      state = state.copyWith(error: 'UNKNOWN');
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final previousState = state;

    final updatedItems = state.items.map((item) {
      if (item.id == cartItemId) {
        return CartItem(
          id: item.id,
          productId: item.productId,
          productSnapshot: item.productSnapshot,
          quantity: newQuantity,
          createdAt: item.createdAt,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);

    try {
      await _repository.updateItem(
        cartItemId: cartItemId,
        quantity: newQuantity,
      );
    } on ApiException catch (e) {
      state = previousState;
      state = state.copyWith(error: e.code);
    } catch (e) {
      state = previousState;
      state = state.copyWith(error: 'UNKNOWN');
    }
  }

  Future<void> removeItem(String cartItemId) async {
    final previousState = state;

    state = state.copyWith(
      items: state.items.where((i) => i.id != cartItemId).toList(),
    );

    try {
      await _repository.removeItem(cartItemId);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> clearCart() async {
    final previousState = state;
    state = const CartState(items: []);

    try {
      await _repository.clearCart();
    } catch (e) {
      state = previousState;
    }
  }

  String _generateLocalId() => 'local-${DateTime.now().millisecondsSinceEpoch}';
}

final selectedCartItemsListProvider = Provider<List<CartItem>>((ref) {
  final selectedIds = ref.watch(selectedCartItemsProvider);
  final cartItems = ref.watch(cartProvider).items;
  return cartItems.where((item) => selectedIds.contains(item.productId)).toList();
});
