// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  id: const _ToStringConverter().fromJson(json['id']),
  productId: const _ToStringConverter().fromJson(json['productId']),
  quantity: (json['quantity'] as num).toInt(),
  productSnapshot: CartProductSnapshot.fromJson(
    json['productSnapshot'] as Map<String, dynamic>,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'id': const _ToStringConverter().toJson(instance.id),
  'productId': const _ToStringConverter().toJson(instance.productId),
  'quantity': instance.quantity,
  'productSnapshot': instance.productSnapshot,
  'createdAt': instance.createdAt.toIso8601String(),
};

CartProductSnapshot _$CartProductSnapshotFromJson(Map<String, dynamic> json) =>
    CartProductSnapshot(
      name: json['name'] as String,
      price: const BigIntStringConverter().fromJson(json['price']),
      primaryImageUrl: json['primaryImageUrl'] as String? ?? '',
    );

Map<String, dynamic> _$CartProductSnapshotToJson(
  CartProductSnapshot instance,
) => <String, dynamic>{
  'name': instance.name,
  'price': const BigIntStringConverter().toJson(instance.price),
  'primaryImageUrl': instance.primaryImageUrl,
};
