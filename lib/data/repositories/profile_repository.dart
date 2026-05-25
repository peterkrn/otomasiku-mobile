import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile(ProfileInput input);
  Future<String> uploadAvatar(File imageFile);
  Future<void> registerDeviceToken(String fcmToken);
  Future<void> removeDeviceToken(String fcmToken);
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProfile> getProfile() async {
    final response = await _dio.get('/me');
    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          null,
        );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        code: apiResponse.error?.code ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
        details: apiResponse.error?.details,
      );
    }

    return UserProfile.fromJson(
      apiResponse.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<UserProfile> updateProfile(ProfileInput input) async {
    final response = await _dio.put('/me', data: input.toJson());
    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          null,
        );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        code: apiResponse.error?.code ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
        details: apiResponse.error?.details,
      );
    }

    return UserProfile.fromJson(
      apiResponse.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<String> uploadAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imageFile.path),
    });
    final response = await _dio.post('/me/avatar', data: formData);
    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          null,
        );

    if (!apiResponse.success || apiResponse.data == null) {
      throw ApiException(
        code: apiResponse.error?.code ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
        details: apiResponse.error?.details,
      );
    }

    return apiResponse.data!['avatarUrl'] as String;
  }

  @override
  Future<void> registerDeviceToken(String fcmToken) async {
    await _dio.post('/me/devices', data: {'fcmToken': fcmToken});
  }

  @override
  Future<void> removeDeviceToken(String fcmToken) async {
    await _dio.delete('/me/devices', data: {'fcmToken': fcmToken});
  }
}

class ProfileInput {
  final String? fullName;
  final String? phone;
  final String? companyName;

  const ProfileInput({
    this.fullName,
    this.phone,
    this.companyName,
  });

  Map<String, dynamic> toJson() => {
    if (fullName != null) 'fullName': fullName,
    if (phone != null) 'phone': phone,
    if (companyName != null) 'companyName': companyName,
  };
}
