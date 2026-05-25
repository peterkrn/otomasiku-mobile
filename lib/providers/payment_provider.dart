import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'repository_providers.dart';

final paymentPollingProvider = AsyncNotifierProvider.autoDispose.family<PaymentPollingNotifier, Order, String>(
  PaymentPollingNotifier.new,
);

class PaymentPollingNotifier extends AutoDisposeFamilyAsyncNotifier<Order, String> {
  Timer? _pollingTimer;

  @override
  Future<Order> build(String arg) {
    ref.onDispose(() => _pollingTimer?.cancel());
    return _fetchAndPoll(arg);
  }

  Future<Order> _fetchAndPoll(String orderId) async {
    final order = await ref.read(orderRepositoryProvider).getOrderById(orderId);
    if (order.paymentStatus != 'paid') {
      _startPolling(orderId);
    }
    return order;
  }

  void _startPolling(String orderId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final order = await ref.read(orderRepositoryProvider).getOrderById(orderId);
        state = AsyncData(order);
        if (order.paymentStatus == 'paid') {
          _pollingTimer?.cancel();
        }
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  Future<void> checkNow(String orderId) async {
    _pollingTimer?.cancel();
    state = const AsyncLoading();
    try {
      final order = await ref.read(orderRepositoryProvider).getOrderById(orderId);
      state = AsyncData(order);
      if (order.paymentStatus != 'paid') {
        _startPolling(orderId);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
