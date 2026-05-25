import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/app_exception.dart';
import '../data/repositories/order_repository.dart';
import '../models/order.dart';
import 'repository_providers.dart';

final orderListProvider =
    AsyncNotifierProvider<OrderListNotifier, List<Order>>(OrderListNotifier.new);

class OrderListNotifier extends AsyncNotifier<List<Order>> {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<Order>> build() async {
    _page = 1;
    _hasMore = true;
    final response = await ref.read(orderRepositoryProvider).getOrders(page: 1);
    _hasMore = response.data.length < response.total;
    return response.data;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    try {
      final response = await ref.read(orderRepositoryProvider).getOrders(page: _page);
      _hasMore = response.data.length < response.total;
      state = AsyncData([...state.value ?? [], ...response.data]);
    } catch (e, st) {
      _page--;
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    try {
      final response = await ref.read(orderRepositoryProvider).getOrders(page: 1);
      _hasMore = response.data.length < response.total;
      state = AsyncData(response.data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final orderDetailProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, id) {
  return ref.read(orderRepositoryProvider).getOrderById(id);
});

final orderStatusHistoryProvider =
    FutureProvider.autoDispose.family<List<OrderStatusHistory>, String>((ref, id) {
  return ref.read(orderRepositoryProvider).getStatusHistory(id);
});

class CreateOrderState {
  final bool isLoading;
  final String? error;
  final CreateOrderResult? result;

  const CreateOrderState({
    this.isLoading = false,
    this.error,
    this.result,
  });
}

final createOrderStateProvider = StateProvider<CreateOrderState>((ref) => const CreateOrderState());

Future<CreateOrderResult> createOrder(
  WidgetRef ref, {
  required String addressId,
  String? notes,
}) async {
  ref.read(createOrderStateProvider.notifier).state = const CreateOrderState(isLoading: true);

  final idempotencyKey = const Uuid().v4();
  try {
    final result = await ref.read(orderRepositoryProvider).createOrder(
      addressId: addressId,
      notes: notes,
      idempotencyKey: idempotencyKey,
    );
    ref.read(createOrderStateProvider.notifier).state = CreateOrderState(result: result);
    return result;
  } on ApiException catch (e) {
    if (e.code == 'IDEMPOTENCY_KEY_EXISTS') {
      if (e.details != null &&
          e.details!.containsKey('orderId')) {
        final orderId = e.details!['orderId'] as String;
        final result = CreateOrderResult(
          orderId: orderId,
          orderNumber: e.details!['orderNumber'] as String? ?? '',
          totalAmount: 0,
        );
        ref.read(createOrderStateProvider.notifier).state = CreateOrderState(result: result);
        return result;
      }
    }
    ref.read(createOrderStateProvider.notifier).state = CreateOrderState(error: e.code);
    rethrow;
  } catch (e) {
    ref.read(createOrderStateProvider.notifier).state = const CreateOrderState(error: 'UNKNOWN');
    rethrow;
  }
}
