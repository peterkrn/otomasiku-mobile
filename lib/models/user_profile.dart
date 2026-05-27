import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable(createFactory: false)
class UserProfile {
  final String id;
  final String email;
  final String role;
  final String? fullName;
  final String? phone;
  final String? companyName;
  final String? customerType;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.phone,
    this.companyName,
    this.customerType,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'customer',
      fullName: profile['fullName'] as String? ?? json['fullName'] as String?,
      phone: profile['phone'] as String? ?? json['phone'] as String?,
      companyName: profile['companyName'] as String? ?? json['companyName'] as String?,
      customerType: profile['customerType'] as String? ?? json['customerType'] as String?,
      avatarUrl: profile['avatarUrl'] as String? ?? json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
