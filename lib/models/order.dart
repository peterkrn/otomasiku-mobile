import 'package:json_annotation/json_annotation.dart';

import '../core/utils/bigint_converter.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  @_ToStringConverter()
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;

  @BigIntStringConverter()
  final int totalAmount;

  final String? vaNumber;
  final DateTime? vaExpiresAt;
  final OrderAddress? shippingAddress;
  final List<OrderItem>? items;
  final String? notes;
  final String? resiNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    this.vaNumber,
    this.vaExpiresAt,
    this.shippingAddress,
    this.items,
    this.notes,
    this.resiNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderItem {
  @_ToStringConverter()
  final String productId;
  final String productName;
  final int quantity;

  @BigIntStringConverter()
  final int unitPrice;

  @BigIntStringConverter()
  final int subtotal;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class OrderAddress {
  final String recipient;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String postalCode;

  const OrderAddress({
    required this.recipient,
    required this.phone,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) =>
      _$OrderAddressFromJson(json);

  Map<String, dynamic> toJson() => _$OrderAddressToJson(this);
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

class _ToStringConverter implements JsonConverter<String, dynamic> {
  const _ToStringConverter();

  @override
  String fromJson(dynamic value) => value.toString();

  @override
  dynamic toJson(String value) => value;
}
