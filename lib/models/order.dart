import 'package:json_annotation/json_annotation.dart';

import '../core/converters/to_string_converter.dart';

import '../core/utils/bigint_converter.dart';
import 'payment_proof.dart';

part 'order.g.dart';

const orderTimelineStatuses = <String>['pending', 'processing', 'shipped', 'done'];

bool isCompletedOrderStatus(String status) => status == 'done';

bool isFulfillmentOrderStatus(String status) =>
    status == 'processing' || status == 'shipped';

@JsonSerializable()
class Order {
  @ToStringConverter()
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;

  @BigIntStringConverter()
  final int totalAmount;

  @NullableBigIntStringConverter()
  final int? subtotal;

  @NullableBigIntStringConverter()
  final int? shippingCost;

  final String? vaNumber;
  final DateTime? vaExpiresAt;
  final String? addressId;
  final OrderAddress? shippingAddress;
  final List<OrderItem>? items;
  final String? notes;
  final String? adminNotes;
  final String? resiNumber;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PaymentProof? paymentProof;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    this.subtotal,
    this.shippingCost,
    this.vaNumber,
    this.vaExpiresAt,
    this.addressId,
    this.shippingAddress,
    this.items,
    this.notes,
    this.adminNotes,
    this.resiNumber,
    this.shippedAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
    this.paymentProof,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderItem {
  @ToStringConverter()
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
  done,
  cancelled,
}

