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
