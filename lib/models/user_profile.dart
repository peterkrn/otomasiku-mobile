import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String role;
  final String? fullName;
  final String? phone;
  final String? companyName;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.phone,
    this.companyName,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
