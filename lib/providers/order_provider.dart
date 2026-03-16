import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../data/dummy/dummy_orders.dart' as dummy_orders;

/// Provider for managing orders state
final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});

/// Order state
class OrderState {
  final List<Order> orders;
  final Order? currentOrder;
  final bool isLoading;
  final String? error;

  const OrderState({
    required this.orders,
    this.currentOrder,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? currentOrder,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      currentOrder: currentOrder ?? this.currentOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Order notifier
class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(const OrderState(orders: [])) {
    loadOrders();
  }

  /// Load orders from dummy data (M2 only)
  void loadOrders() {
    state = state.copyWith(orders: dummy_orders.dummyOrders);
  }

  /// Get order by ID
  Order? getOrderById(String id) {
    try {
      return state.orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Set current order (for detail view)
  void setCurrentOrder(String id) {
    final order = getOrderById(id);
    state = state.copyWith(currentOrder: order);
  }

  /// Create order (M2 dummy — simulates creation)
  void createOrder(Order order) {
    state = state.copyWith(
      orders: [order, ...state.orders],
      currentOrder: order,
    );
  }

  /// Update order status
  void updateOrderStatus(String id, OrderStatus status) {
    final updatedOrders = state.orders.map((o) {
      if (o.id == id) {
        return o.copyWith(status: status);
      }
      return o;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }
}
