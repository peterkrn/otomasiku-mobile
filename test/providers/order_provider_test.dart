import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/fake_order_repository.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/providers/order_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kAddress = OrderAddress(
  recipient: 'Test User',
  phone: '081234567890',
  street: 'Jl. Test 1',
  city: 'Jakarta',
  province: 'DKI Jakarta',
  postalCode: '12345',
);

Order _order({
  String id = 'order-1',
  String status = 'processing',
  String paymentStatus = 'pending',
}) => Order(
  id: id,
  orderNumber: 'ORD-001',
  status: status,
  paymentStatus: paymentStatus,
  totalAmount: 500000,
  shippingAddress: _kAddress,
  items: const [],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

ProviderContainer _container(_MockOrderRepository repo) => ProviderContainer(
  overrides: [orderRepositoryProvider.overrideWithValue(repo)],
);

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class _MockOrderRepository implements OrderRepository {
  final Map<String, Order> _orders;
  bool createShouldFail;
  int getByIdCalls = 0;
  int createCalls = 0;
  List<String>? lastCartItemIds;
  final List<Object>? getByIdResponses;

  _MockOrderRepository({
    Map<String, Order>? orders,
    this.createShouldFail = false,
    this.getByIdResponses,
  }) : _orders = orders ?? {};

  @override
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20}) async {
    final items = _orders.values.toList();
    return OrderListResponse(
      data: items,
      total: items.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Order> getOrderById(String id) async {
    getByIdCalls++;
    if (getByIdResponses != null && getByIdCalls <= getByIdResponses!.length) {
      final scripted = getByIdResponses![getByIdCalls - 1];
      if (scripted is Order) {
        return scripted;
      }
      if (scripted is ApiException) {
        throw scripted;
      }
      throw StateError('Unsupported scripted response: $scripted');
    }
    final order = _orders[id];
    if (order == null) {
      throw ApiException(code: 'ORDER_NOT_FOUND', statusCode: 404);
    }
    return order;
  }

  @override
  Future<CreateOrderResult> createOrder({
    required String addressId,
    required List<String> cartItemIds,
    String? notes,
    required String idempotencyKey,
  }) async {
    createCalls++;
    lastCartItemIds = cartItemIds;
    if (createShouldFail) {
      throw ApiException(code: 'SERVER_ERROR', statusCode: 500);
    }
    const result = CreateOrderResult(
      orderId: 'order-new',
      orderNumber: 'ORD-NEW',
      totalAmount: 500000,
    );
    _orders['order-new'] = _order(id: 'order-new');
    return result;
  }

  @override
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId) async => [];

  @override
  Future<void> confirmReceived(String orderId) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Bug #11 — "Lihat Pesanan" shows "pesanan tidak ditemukan" for sim- orders
  // -------------------------------------------------------------------------
  group('Bug #11 — orderDetailProvider handles sim- IDs in kDebugMode', () {
    test('returns order from repository for real order IDs', () async {
      final repo = _MockOrderRepository(
        orders: {'order-1': _order(id: 'order-1')},
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      final order = await container.read(orderDetailProvider('order-1').future);

      expect(order.id, 'order-1');
      expect(repo.getByIdCalls, 1);
    });

    test('throws ORDER_NOT_FOUND for unknown real order IDs', () async {
      final repo = _MockOrderRepository();
      final container = _container(repo);
      addTearDown(container.dispose);

      expect(
        () => container.read(orderDetailProvider('unknown-id').future),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'ORDER_NOT_FOUND'),
        ),
      );
    });

    // The fix for bug #11: sim- IDs are handled by FakeOrderRepository.getOrderById,
    // which is injected via Riverpod override in debug builds.
    // In tests, we override orderRepositoryProvider with FakeOrderRepository directly.
    test('sim- IDs return a synthetic Order via FakeOrderRepository', () async {
      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(FakeOrderRepository()),
        ],
      );
      addTearDown(container.dispose);

      final order = await container.read(
        orderDetailProvider('sim-12345').future,
      );

      expect(order.id, 'sim-12345');
      expect(order.paymentStatus, 'paid'); // FakeOrderRepository returns 'paid'
    });

    test(
      'FakeOrderRepository keeps simulated totals consistent and non-placeholder',
      () async {
        final repo = FakeOrderRepository();

        final result = await repo.createOrder(
          addressId: 'addr-1',
          cartItemIds: const ['item-1'],
          idempotencyKey: 'key-1',
        );
        final order = await repo.getOrderById(result.orderId);

        expect(result.totalAmount, greaterThan(0));
        expect(order.totalAmount, greaterThan(0));
        expect(result.totalAmount, order.totalAmount);
      },
    );

    test('retries once when the order is not ready yet', () async {
      final repo = _MockOrderRepository(
        getByIdResponses: [
          const ApiException(code: 'ORDER_NOT_READY', statusCode: 503),
          _order(id: 'order-1'),
        ],
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      final order = await container.read(orderDetailProvider('order-1').future);

      expect(order.id, 'order-1');
      expect(repo.getByIdCalls, 2);
    });

    test('retries multiple times when the order is still warming up', () async {
      final repo = _MockOrderRepository(
        getByIdResponses: [
          const ApiException(code: 'ORDER_NOT_READY', statusCode: 503),
          const ApiException(code: 'ORDER_NOT_READY', statusCode: 503),
          _order(id: 'order-1'),
        ],
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      final order = await container.read(orderDetailProvider('order-1').future);

      expect(order.id, 'order-1');
      expect(repo.getByIdCalls, 3);
    });
  });

  // -------------------------------------------------------------------------
  // orderListProvider
  // -------------------------------------------------------------------------
  group('orderListProvider', () {
    test('builds with orders from repository', () async {
      final repo = _MockOrderRepository(
        orders: {
          'order-1': _order(id: 'order-1'),
          'order-2': _order(id: 'order-2', status: 'done'),
        },
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      final orders = await container.read(orderListProvider.future);
      expect(orders, hasLength(2));
    });

    test('builds with empty list when no orders', () async {
      final repo = _MockOrderRepository();
      final container = _container(repo);
      addTearDown(container.dispose);

      final orders = await container.read(orderListProvider.future);
      expect(orders, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // OrderCreateNotifier
  // -------------------------------------------------------------------------
  group('OrderCreateNotifier', () {
    test('starts in idle state', () {
      final repo = _MockOrderRepository();
      final container = _container(repo);
      addTearDown(container.dispose);

      final state = container.read(orderCreateProvider);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.result, isNull);
    });

    test('createOrder sets error state on failure', () async {
      final repo = _MockOrderRepository(createShouldFail: true);
      final container = _container(repo);
      addTearDown(container.dispose);

      expect(
        () => container
            .read(orderCreateProvider.notifier)
            .createOrder(addressId: 'addr-1', cartItemIds: const ['item-1']),
        throwsA(isA<ApiException>()),
      );

      // Allow microtask to settle
      await Future.delayed(Duration.zero);

      final state = container.read(orderCreateProvider);
      expect(state.error, 'SERVER_ERROR');
      expect(state.isLoading, false);
    });

    test('createOrder returns result and sets state on success', () async {
      final repo = _MockOrderRepository();
      final container = _container(repo);
      addTearDown(container.dispose);

      final result = await container
          .read(orderCreateProvider.notifier)
          .createOrder(
            addressId: 'addr-1',
            cartItemIds: const ['item-1', 'item-2'],
          );

      expect(result.orderId, isNotEmpty);
      expect(repo.lastCartItemIds, const ['item-1', 'item-2']);
      final state = container.read(orderCreateProvider);
      expect(state.result, isNotNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });
  });
}
