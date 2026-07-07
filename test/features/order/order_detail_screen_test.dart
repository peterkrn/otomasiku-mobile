import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/address_repository.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';
import 'package:otomasiku_mobile/features/order/order_detail_screen.dart';
import 'package:otomasiku_mobile/models/address.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

import '../../helpers/test_app.dart';

class _FakeOrderRepository implements OrderRepository {
  _FakeOrderRepository(this.order);

  final Order order;

  @override
  Future<void> confirmReceived(String orderId) async {}

  @override
  Future<CreateOrderResult> createOrder({
    required String addressId,
    required List<String> cartItemIds,
    String? notes,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Order> getOrderById(String id) async => order;

  @override
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId) async => [];
}

class _FakeAddressRepository implements AddressRepository {
  @override
  Future<Address> createAddress(AddressInput input) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAddress(String id) async {}

  @override
  Future<Address> getAddressById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Address>> getAddresses() async => const [];

  @override
  Future<Address> updateAddress(String id, AddressInput input) {
    throw UnimplementedError();
  }
}

Order _order({
  String status = 'cancelled',
  String paymentStatus = 'expired',
}) {
  return Order(
    id: 'order-1',
    orderNumber: 'ORD-001',
    status: status,
    paymentStatus: paymentStatus,
    totalAmount: 250000,
    createdAt: DateTime(2026, 6, 11),
    updatedAt: DateTime(2026, 6, 11),
  );
}

void main() {
  testWidgets('cancelled orders render cancelled status instead of processing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderRepositoryProvider.overrideWithValue(_FakeOrderRepository(_order())),
          addressRepositoryProvider.overrideWithValue(_FakeAddressRepository()),
        ],
        child: const TestApp(
          child: OrderDetailScreen(orderId: 'order-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsOneWidget);
  });
}
