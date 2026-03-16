/// Order status enum
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

/// Order model for Otomasiku Marketplace
class Order {
  final String id;
  final String orderNumber;
  final List<OrderItem> items;
  final OrderStatus status;
  final int subtotal;
  final int shippingCost;
  final int tax;
  final int discount;
  final int total;
  final DateTime createdAt;
  final String? paymentMethod;
  final String? vaNumber;
  final DateTime? paymentDeadline;
  final String? shippingAddressName;
  final String? shippingAddressFull;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.discount,
    required this.total,
    required this.createdAt,
    this.paymentMethod,
    this.vaNumber,
    this.paymentDeadline,
    this.shippingAddressName,
    this.shippingAddressFull,
  });

  Order copyWith({
    String? id,
    String? orderNumber,
    List<OrderItem>? items,
    OrderStatus? status,
    int? subtotal,
    int? shippingCost,
    int? tax,
    int? discount,
    int? total,
    DateTime? createdAt,
    String? paymentMethod,
    String? vaNumber,
    DateTime? paymentDeadline,
    String? shippingAddressName,
    String? shippingAddressFull,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vaNumber: vaNumber ?? this.vaNumber,
      paymentDeadline: paymentDeadline ?? this.paymentDeadline,
      shippingAddressName: shippingAddressName ?? this.shippingAddressName,
      shippingAddressFull: shippingAddressFull ?? this.shippingAddressFull,
    );
  }
}

/// Order item model
class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int price;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  /// Calculate total price for this item (money-safe integer multiplication)
  int get totalPrice => price * quantity;
}
