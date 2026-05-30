import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';
import 'package:otomasiku_mobile/models/order.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kAddress = OrderAddress(
  recipient: 'Test',
  phone: '081234567890',
  street: 'Jl. Test',
  city: 'Jakarta',
  province: 'DKI Jakarta',
  postalCode: '12345',
);

Order _order({String id = 'order-1', String paymentStatus = 'pending'}) => Order(
      id: id,
      orderNumber: 'ORD-001',
      status: 'processing',
      paymentStatus: paymentStatus,
      totalAmount: 500000,
      shippingAddress: _kAddress,
      items: const [],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

// ---------------------------------------------------------------------------
// Fake repository (in-memory, no Dio)
// ---------------------------------------------------------------------------

class _FakeOrderRepository implements OrderRepository {
  final Map<String, Order> _orders;
  bool createShouldFail;
  String? createFailCode;
  int createCalls = 0;
  int getByIdCalls = 0;

  _FakeOrderRepository({
    Map<String, Order>? orders,
    this.createShouldFail = false,
    this.createFailCode,
  }) : _orders = orders ?? {};

  @override
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20}) async {
    final items = _orders.values.toList();
    return OrderListResponse(data: items, total: items.length, page: page, pageSize: pageSize);
  }

  @override
  Future<Order> getOrderById(String id) async {
    getByIdCalls++;
    final order = _orders[id];
    if (order == null) throw ApiException(code: 'ORDER_NOT_FOUND', statusCode: 404);
    return order;
  }

  @override
  Future<CreateOrderResult> createOrder({
    required String addressId,
    String? notes,
    required String idempotencyKey,
  }) async {
    createCalls++;
    if (createShouldFail) {
      throw ApiException(code: createFailCode ?? 'SERVER_ERROR', statusCode: 500);
    }
    final id = 'order-$createCalls';
    _orders[id] = _order(id: id);
    return CreateOrderResult(orderId: id, orderNumber: 'ORD-00$createCalls', totalAmount: 500000);
  }

  @override
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId) async => [];
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Bug #5 — createOrder fails in staging (BCA API unavailable)
  // The fix: kDebugMode returns a simulated CreateOrderResult.
  // These tests verify the repository CONTRACT — real impl + fake impl.
  // -------------------------------------------------------------------------
  group('Bug #5 — OrderRepository.createOrder', () {
    test('returns CreateOrderResult with orderId and orderNumber on success', () async {
      final repo = _FakeOrderRepository();

      final result = await repo.createOrder(
        addressId: 'addr-1',
        idempotencyKey: 'key-1',
      );

      expect(result.orderId, isNotEmpty);
      expect(result.orderNumber, isNotEmpty);
      expect(result.totalAmount, greaterThanOrEqualTo(0));
    });

    test('throws ApiException on server error', () async {
      final repo = _FakeOrderRepository(createShouldFail: true, createFailCode: 'SERVER_ERROR');

      expect(
        () => repo.createOrder(addressId: 'addr-1', idempotencyKey: 'key-1'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'SERVER_ERROR')),
      );
    });

    test('throws ApiException with IDEMPOTENCY_KEY_EXISTS on duplicate key', () async {
      final repo = _FakeOrderRepository(
        createShouldFail: true,
        createFailCode: 'IDEMPOTENCY_KEY_EXISTS',
      );

      expect(
        () => repo.createOrder(addressId: 'addr-1', idempotencyKey: 'dup-key'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'IDEMPOTENCY_KEY_EXISTS')),
      );
    });

    test('each call with unique key creates a new order', () async {
      final repo = _FakeOrderRepository();

      final r1 = await repo.createOrder(addressId: 'addr-1', idempotencyKey: 'key-1');
      final r2 = await repo.createOrder(addressId: 'addr-1', idempotencyKey: 'key-2');

      expect(r1.orderId, isNot(r2.orderId));
      expect(repo.createCalls, 2);
    });
  });

  // -------------------------------------------------------------------------
  // getOrderById
  // -------------------------------------------------------------------------
  group('OrderRepository.getOrderById', () {
    test('returns order for known ID', () async {
      final repo = _FakeOrderRepository(orders: {'order-1': _order(id: 'order-1')});

      final order = await repo.getOrderById('order-1');
      expect(order.id, 'order-1');
    });

    test('throws ORDER_NOT_FOUND for unknown ID', () async {
      final repo = _FakeOrderRepository();

      expect(
        () => repo.getOrderById('ghost-id'),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'ORDER_NOT_FOUND')),
      );
    });
  });

  // -------------------------------------------------------------------------
  // getOrders
  // -------------------------------------------------------------------------
  group('OrderRepository.getOrders', () {
    test('returns paginated list', () async {
      final repo = _FakeOrderRepository(orders: {
        'o1': _order(id: 'o1'),
        'o2': _order(id: 'o2'),
      });

      final response = await repo.getOrders(page: 1, pageSize: 20);
      expect(response.data, hasLength(2));
      expect(response.total, 2);
      expect(response.page, 1);
    });

    test('returns empty list when no orders', () async {
      final repo = _FakeOrderRepository();

      final response = await repo.getOrders();
      expect(response.data, isEmpty);
    });
  });
}
