import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'repository_providers.dart';

final paymentProvider = AsyncNotifierProvider.autoDispose.family<PaymentNotifier, Order, String>(
  PaymentNotifier.new,
);

class PaymentNotifier extends AutoDisposeFamilyAsyncNotifier<Order, String> {
  @override
  Future<Order> build(String orderId) {
    return ref.read(paymentRepositoryProvider).getPaymentStatus(orderId);
  }

  Future<void> refresh(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(paymentRepositoryProvider).getPaymentStatus(orderId),
    );
  }
}
