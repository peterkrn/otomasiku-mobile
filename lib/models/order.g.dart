// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: const _ToStringConverter().fromJson(json['id']),
  orderNumber: (json['orderNumber'] ?? json['order_number'] ?? '') as String,
  status: json['status'] as String,
  paymentStatus: (json['paymentStatus'] ?? json['payment_status'] ?? 'pending') as String,
  totalAmount: const BigIntStringConverter().fromJson(json['totalAmount'] ?? json['total_amount']),
  vaNumber: (json['vaNumber'] ?? json['va_number']) as String?,
  vaExpiresAt: (json['vaExpiresAt'] ?? json['va_expires_at']) == null
      ? null
      : DateTime.parse((json['vaExpiresAt'] ?? json['va_expires_at']) as String),
  addressId: (json['addressId'] ?? json['address_id']) as String?,
  shippingAddress: (json['shippingAddress'] ?? json['shipping_address']) == null
      ? null
      : OrderAddress.fromJson((json['shippingAddress'] ?? json['shipping_address']) as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  resiNumber: (json['resiNumber'] ?? json['resi_number']) as String?,
  createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
  updatedAt: DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String),
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
  productId: const _ToStringConverter().fromJson(json['productId'] ?? json['product_id']),
  productName: (json['productName'] ?? json['product_name'] ?? '') as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: const BigIntStringConverter().fromJson(json['unitPrice'] ?? json['unit_price']),
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
  street: (json['street'] ?? json['address'] ?? '') as String,
  city: json['city'] as String,
  province: json['province'] as String,
  postalCode: (json['postalCode'] ?? json['postal_code'] ?? '') as String,
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
