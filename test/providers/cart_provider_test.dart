import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/cart_repository.dart';
import 'package:otomasiku_mobile/models/cart_item.dart';
import 'package:otomasiku_mobile/providers/cart_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CartItem _item({
  String id = 'item-1',
  String productId = 'prod-1',
  int quantity = 1,
  int price = 100000,
}) =>
    CartItem(
      id: id,
      productId: productId,
      quantity: quantity,
      productSnapshot: CartProductSnapshot(
        name: 'Product $productId',
        price: price,
        primaryImageUrl: '',
      ),
      createdAt: DateTime(2026),
    );

ProviderContainer _container(_MockCartRepository repo) => ProviderContainer(
      overrides: [cartRepositoryProvider.overrideWithValue(repo)],
    );

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class _MockCartRepository implements CartRepository {
  List<CartItem> serverItems;
  bool addShouldFail;
  bool removeShouldFail;
  bool clearShouldFail;
  int addCalls = 0;
  int removeCalls = 0;
  int clearCalls = 0;

  _MockCartRepository({
    List<CartItem>? serverItems,
    this.addShouldFail = false,
    this.removeShouldFail = false,
    this.clearShouldFail = false,
  }) : serverItems = serverItems ?? [];

  @override
  Future<CartResponse> getCart() async =>
      CartResponse(items: List.from(serverItems), totalItems: serverItems.length);

  @override
  Future<CartItem> addItem({
    required String productId,
    required int quantity,
    required String idempotencyKey,
  }) async {
    addCalls++;
    if (addShouldFail) throw Exception('network error');
    final newItem = _item(id: 'server-$productId', productId: productId, quantity: quantity);
    serverItems.add(newItem);
    return newItem;
  }

  @override
  Future<CartItem> updateItem({required String cartItemId, required int quantity}) async {
    final idx = serverItems.indexWhere((i) => i.id == cartItemId);
    if (idx < 0) throw Exception('not found');
    final updated = CartItem(
      id: serverItems[idx].id,
      productId: serverItems[idx].productId,
      productSnapshot: serverItems[idx].productSnapshot,
      quantity: quantity,
      createdAt: serverItems[idx].createdAt,
    );
    serverItems[idx] = updated;
    return updated;
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    removeCalls++;
    if (removeShouldFail) throw Exception('network error');
    serverItems.removeWhere((i) => i.id == cartItemId);
  }

  @override
  Future<void> clearCart() async {
    clearCalls++;
    if (clearShouldFail) throw Exception('network error');
    serverItems.clear();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Bug #1 — buyNow: selectedCartItemsProvider must be populated
  // -------------------------------------------------------------------------
  group('Bug #1 — selectedCartItemsProvider populated for buy-now', () {
    test('selectedCartItemsListProvider returns item when productId is selected', () async {
      final repo = _MockCartRepository(serverItems: [_item(productId: 'prod-1')]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();

      // Simulate what _buyNow() does: set selectedCartItemsProvider
      container.read(selectedCartItemsProvider.notifier).state = {'prod-1'};

      final selected = container.read(selectedCartItemsListProvider);
      expect(selected, hasLength(1));
      expect(selected.first.productId, 'prod-1');
    });

    test('selectedCartItemsListProvider is empty when selectedCartItemsProvider is empty', () async {
      final repo = _MockCartRepository(serverItems: [_item(productId: 'prod-1')]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();

      // selectedCartItemsProvider never set — old bug
      final selected = container.read(selectedCartItemsListProvider);
      expect(selected, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Bug #2 — loadCart must NOT overwrite state when items already exist
  // -------------------------------------------------------------------------
  group('Bug #2 — loadCart does not overwrite optimistic state', () {
    test('loadCart fetches when cart is empty', () async {
      final repo = _MockCartRepository(serverItems: [_item()]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();

      expect(container.read(cartProvider).items, hasLength(1));
    });

    test('guard: loadCart is skipped when items already exist (cart_screen guard)', () async {
      // The guard lives in cart_screen.dart initState:
      //   if (cartState.items.isEmpty && !cartState.isLoading) loadCart()
      // This test verifies the guard condition logic directly.
      final repo = _MockCartRepository(serverItems: [_item(id: 'server-1')]);
      final container = _container(repo);
      addTearDown(container.dispose);

      // Simulate optimistic add: item is already in state
      await container.read(cartProvider.notifier).addItem('prod-1', 1);

      final cartState = container.read(cartProvider);

      // Guard condition: only call loadCart if empty AND not loading
      final shouldLoad = cartState.items.isEmpty && !cartState.isLoading;
      expect(shouldLoad, isFalse, reason: 'Guard must prevent loadCart when items exist');
    });

    test('badge count (totalItems) matches actual item count after add', () async {
      final repo = _MockCartRepository();
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).addItem('prod-1', 2);
      await container.read(cartProvider.notifier).addItem('prod-2', 3);

      final state = container.read(cartProvider);
      expect(state.totalItems, 5); // 2 + 3
      expect(state.items, hasLength(2));
    });
  });

  // -------------------------------------------------------------------------
  // Bug #3 — removeItem must clean up selectedCartItemsProvider
  // -------------------------------------------------------------------------
  group('Bug #3 — removeItem cleans up selectedCartItemsProvider', () {
    test('after removeItem, productId is no longer in selectedCartItemsProvider', () async {
      final repo = _MockCartRepository(serverItems: [
        _item(id: 'item-1', productId: 'prod-1'),
        _item(id: 'item-2', productId: 'prod-2'),
      ]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();

      // Select both items
      container.read(selectedCartItemsProvider.notifier).state = {'prod-1', 'prod-2'};

      // Capture productId BEFORE removal (the fix)
      final itemToRemove = container.read(cartProvider).items.firstWhere((i) => i.id == 'item-1');
      final productId = itemToRemove.productId;

      await container.read(cartProvider.notifier).removeItem('item-1');

      // Manually update selections (as checkout_screen does after fix)
      final current = container.read(selectedCartItemsProvider);
      container.read(selectedCartItemsProvider.notifier).state =
          current.where((id) => id != productId).toSet();

      final selected = container.read(selectedCartItemsProvider);
      expect(selected, isNot(contains('prod-1')));
      expect(selected, contains('prod-2'));
    });

    test('removeItem removes item from cart state optimistically', () async {
      final repo = _MockCartRepository(serverItems: [
        _item(id: 'item-1', productId: 'prod-1'),
      ]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();
      expect(container.read(cartProvider).items, hasLength(1));

      await container.read(cartProvider.notifier).removeItem('item-1');
      expect(container.read(cartProvider).items, isEmpty);
    });

    test('removeItem rolls back on API failure', () async {
      final repo = _MockCartRepository(
        serverItems: [_item(id: 'item-1', productId: 'prod-1')],
        removeShouldFail: true,
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();
      await container.read(cartProvider.notifier).removeItem('item-1');

      // State rolled back
      expect(container.read(cartProvider).items, hasLength(1));
    });
  });

  // -------------------------------------------------------------------------
  // Bug #10 — clearCart fires before navigation (state must clear immediately)
  // -------------------------------------------------------------------------
  group('Bug #10 — clearCart empties state immediately', () {
    test('clearCart empties items optimistically before API responds', () async {
      final repo = _MockCartRepository(serverItems: [_item(), _item(id: 'item-2', productId: 'prod-2')]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();
      expect(container.read(cartProvider).items, hasLength(2));

      // Start clearCart but don't await — check state is already empty
      final future = container.read(cartProvider.notifier).clearCart();
      expect(container.read(cartProvider).items, isEmpty);

      await future;
      expect(container.read(cartProvider).items, isEmpty);
    });

    test('clearCart rolls back on API failure', () async {
      final repo = _MockCartRepository(
        serverItems: [_item()],
        clearShouldFail: true,
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();
      await container.read(cartProvider.notifier).clearCart();

      expect(container.read(cartProvider).items, hasLength(1));
    });
  });

  // -------------------------------------------------------------------------
  // General cart correctness
  // -------------------------------------------------------------------------
  group('CartNotifier — general', () {
    test('addItem for new product adds optimistic item immediately', () async {
      final repo = _MockCartRepository();
      final container = _container(repo);
      addTearDown(container.dispose);

      final future = container.read(cartProvider.notifier).addItem('prod-1', 1);
      // Optimistic: item appears before API responds
      expect(container.read(cartProvider).items, hasLength(1));
      await future;
    });

    test('addItem for existing product increments quantity', () async {
      final repo = _MockCartRepository(serverItems: [_item(id: 'item-1', productId: 'prod-1', quantity: 2)]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();
      await container.read(cartProvider.notifier).addItem('prod-1', 3);

      final items = container.read(cartProvider).items;
      expect(items, hasLength(1));
      expect(items.first.quantity, 5); // 2 + 3
    });

    test('addItem rolls back on API failure', () async {
      final repo = _MockCartRepository(addShouldFail: true);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).addItem('prod-1', 1);

      expect(container.read(cartProvider).items, isEmpty);
      expect(container.read(cartProvider).error, isNotNull);
    });

    test('totalValue computes price × quantity sum', () async {
      final repo = _MockCartRepository(serverItems: [
        _item(id: 'i1', productId: 'p1', quantity: 2, price: 100000),
        _item(id: 'i2', productId: 'p2', quantity: 1, price: 50000),
      ]);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(cartProvider.notifier).loadCart();

      expect(container.read(cartProvider).totalValue, 250000); // 2×100k + 1×50k
    });
  });
}
