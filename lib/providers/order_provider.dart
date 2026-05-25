import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../data/dummy/dummy_orders.dart' as dummy_orders;

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});

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

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(const OrderState(orders: [])) {
    loadOrders();
  }

  void loadOrders() {
    state = state.copyWith(orders: dummy_orders.dummyOrders);
  }

  Order? getOrderById(String id) {
    try {
      return state.orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  void setCurrentOrder(String id) {
    final order = getOrderById(id);
    state = state.copyWith(currentOrder: order);
  }

  void createOrder(Order order) {
    state = state.copyWith(
      orders: [order, ...state.orders],
      currentOrder: order,
    );
  }

  void updateOrderStatus(String id, String status) {
    final updatedOrders = state.orders.map((o) {
      if (o.id == id) {
        return Order(
          id: o.id,
          orderNumber: o.orderNumber,
          status: status,
          paymentStatus: o.paymentStatus,
          totalAmount: o.totalAmount,
          vaNumber: o.vaNumber,
          vaExpiresAt: o.vaExpiresAt,
          shippingAddress: o.shippingAddress,
          items: o.items,
          notes: o.notes,
          resiNumber: o.resiNumber,
          createdAt: o.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return o;
    }).toList();

    state = state.copyWith(orders: updatedOrders);
  }
}
