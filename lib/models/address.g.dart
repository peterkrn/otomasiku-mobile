// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  id: json['id'] as String,
  label: json['label'] as String,
  recipient: json['recipient'] as String,
  phone: json['phone'] as String,
  street: json['street'] as String,
  city: json['city'] as String,
  province: json['province'] as String,
  postalCode: json['postalCode'] as String,
  isDefault: json['isDefault'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'recipient': instance.recipient,
  'phone': instance.phone,
  'street': instance.street,
  'city': instance.city,
  'province': instance.province,
  'postalCode': instance.postalCode,
  'isDefault': instance.isDefault,
  'createdAt': instance.createdAt.toIso8601String(),
};
