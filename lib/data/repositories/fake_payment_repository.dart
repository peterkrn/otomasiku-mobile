import '../../models/order.dart';
import 'payment_repository.dart';

/// Fake implementation used in debug/test builds via Riverpod overrides.
/// Extracted from [PaymentPollingNotifier._fetchAndPoll] kDebugMode block.
class FakePaymentRepository implements PaymentRepository {
  @override
  Future<Order> getPaymentStatus(String orderId) async {
    // Covers bug #5: simulate 2-second payment confirmation in staging.
    await Future.delayed(const Duration(seconds: 2));
    return Order(
      id: orderId,
      orderNumber: 'SIM-$orderId',
      status: 'confirmed',
      paymentStatus: 'paid',
      totalAmount: 0,
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
