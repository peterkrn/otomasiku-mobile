import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/payment_repository.dart';
import 'package:otomasiku_mobile/features/payment/payment_screen.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

import '../../helpers/test_app.dart';

class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository(this.order);

  final Order order;

  @override
  Future<Order> getPaymentStatus(String orderId) async => order;
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
    'payment screen keeps checkout total when the first order read returns a smaller non-zero total',
    (tester) async {
      const checkoutTotal = 2000000;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paymentRepositoryProvider.overrideWithValue(
              _FakePaymentRepository(_order()),
            ),
          ],
          child: const TestApp(
            child: PaymentScreen(
              orderId: 'order-1',
              totalAmount: checkoutTotal,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rp. 2.000.000'), findsWidgets);
      expect(find.text('Rp. 500.000'), findsNothing);

      final amountField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Transfer Amount',
        ),
      );

      expect(amountField.controller?.text, 'Rp. 2.000.000');
    },
  );
}
