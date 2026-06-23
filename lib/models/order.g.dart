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
  subtotal: const NullableBigIntStringConverter().fromJson(json['subtotal']),
  shippingCost: const NullableBigIntStringConverter().fromJson(
    json['shippingCost'],
  ),
  vaNumber: json['vaNumber'] as String?,
  vaExpiresAt: json['vaExpiresAt'] == null
      ? null
      : DateTime.parse(json['vaExpiresAt'] as String),
  addressId: json['addressId'] as String?,
  shippingAddress: json['shippingAddress'] == null
      ? null
      : OrderAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  adminNotes: json['adminNotes'] as String?,
  resiNumber: json['resiNumber'] as String?,
  shippedAt: json['shippedAt'] == null
      ? null
      : DateTime.parse(json['shippedAt'] as String),
  deliveredAt: json['deliveredAt'] == null
      ? null
      : DateTime.parse(json['deliveredAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  paymentProof: json['paymentProof'] == null
      ? null
      : PaymentProof.fromJson(json['paymentProof'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': const _ToStringConverter().toJson(instance.id),
  'orderNumber': instance.orderNumber,
  'status': instance.status,
  'paymentStatus': instance.paymentStatus,
  'totalAmount': const BigIntStringConverter().toJson(instance.totalAmount),
  'subtotal': const NullableBigIntStringConverter().toJson(instance.subtotal),
  'shippingCost': const NullableBigIntStringConverter().toJson(
    instance.shippingCost,
  ),
  'vaNumber': instance.vaNumber,
  'vaExpiresAt': instance.vaExpiresAt?.toIso8601String(),
  'addressId': instance.addressId,
  'shippingAddress': instance.shippingAddress,
  'items': instance.items,
  'notes': instance.notes,
  'adminNotes': instance.adminNotes,
  'resiNumber': instance.resiNumber,
  'shippedAt': instance.shippedAt?.toIso8601String(),
  'deliveredAt': instance.deliveredAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'paymentProof': instance.paymentProof?.toJson(),
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
