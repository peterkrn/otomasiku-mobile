import '../../models/order.dart';
import 'order_repository.dart';

const _simulatedTotalAmount = 500000;

/// Fake implementation used in debug/test builds via Riverpod overrides.
/// Extracted from [OrderRepositoryImpl] and [orderDetailProvider] kDebugMode blocks.
class FakeOrderRepository implements OrderRepository {
  final List<Order> _orders = [];

  @override
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20}) async {
    return OrderListResponse(
      data: List.from(_orders),
      total: _orders.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Order> getOrderById(String id) async {
    // Covers bug #11: sim- IDs must resolve without hitting the real API.
    final existing = _orders.where((o) => o.id == id).firstOrNull;
    if (existing != null) return existing;
    return _simulatedOrder(id);
  }

  @override
  Future<CreateOrderResult> createOrder({
    required String addressId,
    required List<String> cartItemIds,
    String? notes,
    required String idempotencyKey,
  }) async {
    // Covers bug #5: BCA API unavailable in staging.
    final id = 'sim-${DateTime.now().millisecondsSinceEpoch}';
    final order = _simulatedOrder(id);
    _orders.add(order);
    return CreateOrderResult(
      orderId: id,
      orderNumber: 'SIM-$id',
      totalAmount: _simulatedTotalAmount,
    );
  }

  @override
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId) async => [];

  @override
  Future<void> confirmReceived(String orderId) async {}

  static Order _simulatedOrder(String id) => Order(
    id: id,
    orderNumber: 'SIM-$id',
    status: 'processing',
    paymentStatus: 'paid',
    totalAmount: _simulatedTotalAmount,
    shippingAddress: const OrderAddress(
      recipient: 'Peter Kurniawan',
      phone: '081234567890',
      street: 'Jl. Industri No. 45, Kawasan MM2100',
      city: 'Bekasi',
      province: 'Jawa Barat',
      postalCode: '17530',
    ),
    items: const [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
