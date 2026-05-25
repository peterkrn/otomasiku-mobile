// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  fullName: json['fullName'] as String?,
  phone: json['phone'] as String?,
  companyName: json['companyName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'companyName': instance.companyName,
      'avatarUrl': instance.avatarUrl,
    };
