import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/payment_repository.dart';
import 'package:otomasiku_mobile/features/payment/payment_pending_screen.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

import '../../helpers/test_app.dart';

class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository(this.order);

  final Order order;

  @override
  Future<Order> getPaymentStatus(String orderId) async => order;
}

Order _order({
  String status = 'pending',
  String paymentStatus = 'unpaid',
  String orderNumber = 'ORD-001',
}) {
  return Order(
    id: 'order-1',
    orderNumber: orderNumber,
    status: status,
    paymentStatus: paymentStatus,
    totalAmount: 250000,
    createdAt: DateTime(2026, 6, 11),
    updatedAt: DateTime(2026, 6, 11),
  );
}

void main() {
  testWidgets('pending payment screen does not overflow on narrow phones with long order numbers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(
            _FakePaymentRepository(
              _order(
                orderNumber: 'cfe6be4b-2b75-416c-bd32-b5427b911234',
              ),
            ),
          ),
        ],
        child: const TestApp(
          child: PaymentPendingScreen(orderId: 'order-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Order Number'), findsOneWidget);
    expect(
      find.text('cfe6be4b-2b75-416c-bd32-b5427b911234'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired orders explain that stock has been released', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(
            _FakePaymentRepository(_order(status: 'cancelled', paymentStatus: 'expired')),
          ),
        ],
        child: const TestApp(
          child: PaymentPendingScreen(orderId: 'order-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stock has been released for this expired order.'), findsOneWidget);
  });
}
