import 'package:json_annotation/json_annotation.dart';

import '../core/utils/bigint_converter.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem {
  @_ToStringConverter()
  final String id;
  @_ToStringConverter()
  final String productId;
  final int quantity;
  final CartProductSnapshot productSnapshot;
  final DateTime createdAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.productSnapshot,
    required this.createdAt,
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

  @JsonKey(defaultValue: '')
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

class _ToStringConverter implements JsonConverter<String, dynamic> {
  const _ToStringConverter();

  @override
  String fromJson(dynamic value) => value.toString();

  @override
  dynamic toJson(String value) => value;
}
