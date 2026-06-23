import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';
import 'package:otomasiku_mobile/features/payment/payment_success_screen.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

import '../../helpers/test_app.dart';

class _FakeOrderRepository implements OrderRepository {
  _FakeOrderRepository(this.order);

  final Order order;

  @override
  Future<void> confirmReceived(String orderId) {
    throw UnimplementedError();
  }

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
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId) {
    throw UnimplementedError();
  }
}

Order _order({int totalAmount = 500000}) {
  return Order(
    id: 'order-1',
    orderNumber: 'ORD-001',
    status: 'pending',
    paymentStatus: 'unpaid',
    totalAmount: totalAmount,
    createdAt: DateTime(2026, 6, 16),
    updatedAt: DateTime(2026, 6, 16),
  );
}

void main() {
  testWidgets(
    'payment success screen keeps the routed total when the first detail read returns a smaller non-zero total',
    (tester) async {
      const checkoutTotal = 2000000;
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderRepositoryProvider.overrideWithValue(
              _FakeOrderRepository(_order()),
            ),
          ],
          child: const TestApp(
            child: PaymentSuccessScreen(
              orderId: 'order-1',
              totalAmount: checkoutTotal,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rp. 2.000.000'), findsOneWidget);
      expect(find.text('Rp. 500.000'), findsNothing);
    },
  );
}
