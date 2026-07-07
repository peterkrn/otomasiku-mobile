import '../../models/order.dart';
import 'payment_repository.dart';

const _simulatedTotalAmount = 500000;

/// Fake implementation used in debug/test builds via Riverpod overrides.
/// Extracted from [PaymentNotifier.build] kDebugMode block.
class FakePaymentRepository implements PaymentRepository {
  @override
  Future<Order> getPaymentStatus(String orderId) async {
    // Covers bug #5: simulate 2-second payment confirmation in staging.
    await Future.delayed(const Duration(seconds: 2));
    return Order(
      id: orderId,
      orderNumber: 'SIM-$orderId',
      status: 'processing',
      paymentStatus: 'paid',
      totalAmount: _simulatedTotalAmount,
      shippingAddress: const OrderAddress(
        recipient: '',
        phone: '',
        street: '',
        city: '',
        province: '',
        postalCode: '',
      ),
      items: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
