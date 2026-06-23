import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/app_exception.dart';
import '../data/repositories/order_repository.dart';
import '../models/order.dart';
import 'order_not_ready_retry.dart';
import 'repository_providers.dart';

final orderListProvider = AsyncNotifierProvider<OrderListNotifier, List<Order>>(
  OrderListNotifier.new,
);

class OrderListNotifier extends AsyncNotifier<List<Order>> {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<List<Order>> build() async {
    _page = 1;
    _hasMore = true;
    try {
      final response = await ref
          .read(orderRepositoryProvider)
          .getOrders(page: 1);
      _hasMore = response.data.length < response.total;
      return response.data;
    } catch (e) {
      throw ApiException(
        code: e is ApiException ? e.code : 'PARSE_ERROR',
        statusCode: e is ApiException ? e.statusCode : 0,
      );
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    try {
      final response = await ref
          .read(orderRepositoryProvider)
          .getOrders(page: _page);
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
      final response = await ref
          .read(orderRepositoryProvider)
          .getOrders(page: 1);
      _hasMore = response.data.length < response.total;
      state = AsyncData(response.data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final orderDetailProvider = FutureProvider.autoDispose.family<Order, String>((
  ref,
  id,
) async {
  final repository = ref.read(orderRepositoryProvider);
  return retryOrderNotReady(load: () => repository.getOrderById(id));
});

final orderStatusHistoryProvider = FutureProvider.autoDispose
    .family<List<OrderStatusHistory>, String>((ref, id) {
      return ref.read(orderRepositoryProvider).getStatusHistory(id);
    });

class CreateOrderState {
  final bool isLoading;
  final String? error;
  final CreateOrderResult? result;

  const CreateOrderState({this.isLoading = false, this.error, this.result});
}

final orderCreateProvider =
    NotifierProvider<OrderCreateNotifier, CreateOrderState>(
      OrderCreateNotifier.new,
    );

class OrderCreateNotifier extends Notifier<CreateOrderState> {
  @override
  CreateOrderState build() => const CreateOrderState();

  Future<CreateOrderResult> createOrder({
    required String addressId,
    required List<String> cartItemIds,
    String? notes,
  }) async {
    state = const CreateOrderState(isLoading: true);

    final idempotencyKey = const Uuid().v4();
    try {
      final result = await ref
          .read(orderRepositoryProvider)
          .createOrder(
            addressId: addressId,
            cartItemIds: cartItemIds,
            notes: notes,
            idempotencyKey: idempotencyKey,
          );
      state = CreateOrderState(result: result);
      return result;
    } on ApiException catch (e) {
      if (e.code == 'IDEMPOTENCY_KEY_EXISTS' &&
          e.details != null &&
          e.details!.containsKey('orderId')) {
        final orderId = e.details!['orderId'] as String;
        final result = CreateOrderResult(
          orderId: orderId,
          orderNumber: e.details!['orderNumber'] as String? ?? '',
          totalAmount: 0,
        );
        state = CreateOrderState(result: result);
        return result;
      }
      state = CreateOrderState(error: e.code);
      rethrow;
    } catch (e) {
      state = const CreateOrderState(error: 'UNKNOWN');
      rethrow;
    }
  }
}
