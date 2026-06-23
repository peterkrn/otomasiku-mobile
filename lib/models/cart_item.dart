import 'package:json_annotation/json_annotation.dart';

import '../core/converters/to_string_converter.dart';

import '../core/utils/bigint_converter.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  @ToStringConverter()
  final String id;
  @ToStringConverter()
  final String productId;
  final int quantity;
  final CartProductSnapshot productSnapshot;
  final DateTime createdAt;
  @JsonKey(defaultValue: true)
  final bool isAvailable;

  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.productSnapshot,
    required this.createdAt,
    this.isAvailable = true,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}

@JsonSerializable()
class CartProductSnapshot {
  final String name;

  @BigIntStringConverter()
  final int price;

  @JsonKey(name: 'imageUrl', defaultValue: '')
  final String primaryImageUrl;

  const CartProductSnapshot({
    required this.name,
    required this.price,
    required this.primaryImageUrl,
  });

  factory CartProductSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CartProductSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$CartProductSnapshotToJson(this);
}

