// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: const _ToStringConverter().fromJson(json['id']),
  orderNumber: json['orderNumber'] as String,
  status: json['status'] as String,
  paymentStatus: json['paymentStatus'] as String,
  totalAmount: const BigIntStringConverter().fromJson(json['totalAmount']),
  vaNumber: json['vaNumber'] as String?,
  vaExpiresAt: json['vaExpiresAt'] == null
      ? null
      : DateTime.parse(json['vaExpiresAt'] as String),
  shippingAddress: json['shippingAddress'] == null
      ? null
      : OrderAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  resiNumber: json['resiNumber'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': const _ToStringConverter().toJson(instance.id),
  'orderNumber': instance.orderNumber,
  'status': instance.status,
  'paymentStatus': instance.paymentStatus,
  'totalAmount': const BigIntStringConverter().toJson(instance.totalAmount),
  'vaNumber': instance.vaNumber,
  'vaExpiresAt': instance.vaExpiresAt?.toIso8601String(),
  'shippingAddress': instance.shippingAddress,
  'items': instance.items,
  'notes': instance.notes,
  'resiNumber': instance.resiNumber,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  productId: const _ToStringConverter().fromJson(json['productId']),
  productName: json['productName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: const BigIntStringConverter().fromJson(json['unitPrice']),
  subtotal: const BigIntStringConverter().fromJson(json['subtotal']),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'productId': const _ToStringConverter().toJson(instance.productId),
  'productName': instance.productName,
  'quantity': instance.quantity,
  'unitPrice': const BigIntStringConverter().toJson(instance.unitPrice),
  'subtotal': const BigIntStringConverter().toJson(instance.subtotal),
};

OrderAddress _$OrderAddressFromJson(Map<String, dynamic> json) => OrderAddress(
  recipient: json['recipient'] as String,
  phone: json['phone'] as String,
  street: json['street'] as String,
  city: json['city'] as String,
  province: json['province'] as String,
  postalCode: json['postalCode'] as String,
);

Map<String, dynamic> _$OrderAddressToJson(OrderAddress instance) =>
    <String, dynamic>{
      'recipient': instance.recipient,
      'phone': instance.phone,
      'street': instance.street,
      'city': instance.city,
      'province': instance.province,
      'postalCode': instance.postalCode,
    };
