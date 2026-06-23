import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'order_not_ready_retry.dart';
import 'repository_providers.dart';

final paymentProvider = AsyncNotifierProvider.autoDispose
    .family<PaymentNotifier, Order, String>(PaymentNotifier.new);

class PaymentNotifier extends AutoDisposeFamilyAsyncNotifier<Order, String> {
  @override
  Future<Order> build(String orderId) {
    return _getPaymentStatusWithRetry(orderId);
  }

  Future<void> refresh(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _getPaymentStatusWithRetry(orderId));
  }

  Future<Order> _getPaymentStatusWithRetry(String orderId) async {
    final repository = ref.read(paymentRepositoryProvider);
    return retryOrderNotReady(load: () => repository.getPaymentStatus(orderId));
  }
}
