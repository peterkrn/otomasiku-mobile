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

  const CartState({required this.items, this.isLoading = false, this.error});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalValue => items.fold(
    0,
    (sum, item) => sum + item.productSnapshot.price * item.quantity,
  );

  CartState copyWith({List<CartItem>? items, bool? isLoading, String? error}) {
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
  int _mutationVersion = 0;

  Future<void> loadCart() async {
    final requestVersion = _mutationVersion;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.getCart();
      if (requestVersion != _mutationVersion) {
        state = state.copyWith(isLoading: false, error: null);
        return;
      }
      state = CartState(items: response.items);
    } on ApiException catch (e) {
      if (requestVersion != _mutationVersion) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(isLoading: false, error: e.code);
    } catch (e) {
      if (requestVersion != _mutationVersion) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(isLoading: false, error: 'UNKNOWN');
    }
  }

  Future<void> addItem(
    String productId,
    int quantity, {
    CartProductSnapshot? snapshot,
  }) async {
    final previousState = state;
    final idempotencyKey = const Uuid().v4();
    final existingIndex = previousState.items.indexWhere(
      (i) => i.productId == productId,
    );
    final previousItem = existingIndex >= 0
        ? previousState.items[existingIndex]
        : null;
    _markMutation();

    final optimisticItem = CartItem(
      id: _generateLocalId(),
      productId: productId,
      quantity: quantity,
      productSnapshot:
          snapshot ??
          const CartProductSnapshot(name: '', price: 0, primaryImageUrl: ''),
      createdAt: DateTime.now(),
    );

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

    try {
      final response = previousItem != null && !_isLocalId(previousItem.id)
          ? await _repository.updateItem(
              cartItemId: previousItem.id,
              quantity: previousItem.quantity + quantity,
            )
          : await _addItemWithRetry(
              productId,
              previousItem == null
                  ? quantity
                  : previousItem.quantity + quantity,
              idempotencyKey,
            );
      _applyPersistedItemResponse(
        productId: productId,
        optimisticItemId: optimisticItem.id,
        response: response,
      );
    } on ApiException catch (e) {
      if (e.code == 'CART_ITEM_ALREADY_EXISTS') {
        try {
          final response = await _incrementExistingItem(
            previousState: previousState,
            productId: productId,
            quantityToAdd: quantity,
          );
          _replaceItem(
            productId: productId,
            optimisticItemId: optimisticItem.id,
            response: response,
          );
          return;
        } on ApiException catch (updateError) {
          state = previousState;
          state = state.copyWith(error: updateError.code);
          return;
        } catch (e) {
          state = previousState;
          state = state.copyWith(error: 'UNKNOWN');
          return;
        }
      }
      state = previousState;
      state = state.copyWith(error: e.code);
    } catch (e) {
      state = previousState;
      state = state.copyWith(error: 'UNKNOWN');
    }
  }

  Future<CartItem> _addItemWithRetry(
    String productId,
    int quantity,
    String idempotencyKey,
  ) async {
    try {
      return await _repository.addItem(
        productId: productId,
        quantity: quantity,
        idempotencyKey: idempotencyKey,
      );
    } on ApiException catch (e) {
      if (e.code == 'USER_NOT_FOUND') {
        for (var attempt = 0; attempt < 2; attempt++) {
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            return await _repository.addItem(
              productId: productId,
              quantity: quantity,
              idempotencyKey: idempotencyKey,
            );
          } on ApiException catch (retryError) {
            if (retryError.code != 'USER_NOT_FOUND' || attempt == 1) {
              rethrow;
            }
          }
        }
      }
      rethrow;
    }
  }

  void _applyPersistedItemResponse({
    required String productId,
    required String optimisticItemId,
    required CartItem response,
  }) {
    final quantityOverride = _findItemByProductId(
      state.items,
      productId,
    )?.quantity;
    _replaceItem(
      productId: productId,
      optimisticItemId: optimisticItemId,
      response: response,
      quantityOverride: quantityOverride,
    );
  }

  Future<CartItem> _incrementExistingItem({
    required CartState previousState,
    required String productId,
    required int quantityToAdd,
  }) async {
    final previousItem = _findItemByProductId(previousState.items, productId);
    if (previousItem != null && !_isLocalId(previousItem.id)) {
      return _repository.updateItem(
        cartItemId: previousItem.id,
        quantity: previousItem.quantity + quantityToAdd,
      );
    }

    final cart = await _repository.getCart();
    final serverItem = _findItemByProductId(cart.items, productId);
    if (serverItem == null) {
      throw const ApiException(
        code: 'CART_ITEM_ALREADY_EXISTS',
        statusCode: 409,
      );
    }

    return _repository.updateItem(
      cartItemId: serverItem.id,
      quantity: serverItem.quantity + quantityToAdd,
    );
  }

  void _replaceItem({
    required String productId,
    required String optimisticItemId,
    required CartItem response,
    int? quantityOverride,
  }) {
    final updatedItems = List<CartItem>.from(state.items);
    final idx = updatedItems.indexWhere(
      (item) => item.productId == productId || item.id == optimisticItemId,
    );

    final resolvedItem = CartItem(
      id: response.id,
      productId: response.productId,
      productSnapshot: response.productSnapshot,
      quantity: quantityOverride ?? response.quantity,
      createdAt: response.createdAt,
      isAvailable: response.isAvailable,
    );

    if (idx >= 0) {
      updatedItems[idx] = resolvedItem;
    } else {
      updatedItems.add(resolvedItem);
    }

    state = state.copyWith(items: updatedItems, error: null);
  }

  CartItem? _findItemByProductId(Iterable<CartItem> items, String productId) {
    for (final item in items) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final previousState = state;
    _markMutation();

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
    _markMutation();

    state = state.copyWith(
      items: state.items.where((i) => i.id != cartItemId).toList(),
    );

    try {
      await _repository.removeItem(cartItemId);
    } catch (e) {
      state = previousState;
    }
  }

  void removeItemsLocally(Set<String> cartItemIds) {
    _markMutation();
    state = state.copyWith(
      items: state.items
          .where((item) => !cartItemIds.contains(item.id))
          .toList(),
    );
  }

  Future<void> clearCart() async {
    final previousState = state;
    _markMutation();
    state = const CartState(items: []);

    try {
      await _repository.clearCart();
    } catch (e) {
      state = previousState;
    }
  }

  String _generateLocalId() => 'local-${DateTime.now().millisecondsSinceEpoch}';

  bool _isLocalId(String id) => id.startsWith('local-');

  void _markMutation() {
    _mutationVersion++;
  }
}

final selectedCartItemsListProvider = Provider<List<CartItem>>((ref) {
  final selectedIds = ref.watch(selectedCartItemsProvider);
  final cartItems = ref.watch(cartProvider).items;
  return cartItems.where((item) => selectedIds.contains(item.id)).toList();
});
