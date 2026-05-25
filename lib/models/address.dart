import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  final String id;
  final String label;
  final String recipient;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final bool isDefault;
  final DateTime createdAt;

  const Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.isDefault,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  String get fullAddress => '$street, $city, $province $postalCode';

  String get fullLabel => '$label - $fullAddress';
}
