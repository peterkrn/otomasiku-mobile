import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../models/payment_proof.dart';

abstract class PaymentProofRepository {
  Future<PaymentProof> uploadProof({
    required String orderId,
    required File imageFile,
    required String bankName,
    required String accountName,
    required int amount,
  });

  Future<PaymentProof?> getProof(String orderId);
}

class PaymentProofRepositoryImpl implements PaymentProofRepository {
  PaymentProofRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaymentProof> uploadProof({
    required String orderId,
    required File imageFile,
    required String bankName,
    required String accountName,
    required int amount,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
      'bankName': bankName,
      'accountName': accountName,
      'amount': amount.toString(),
    });

    final response = await _dio.post(
      '/orders/$orderId/payment-proof',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
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

    return PaymentProof.fromJson(apiResponse.data!);
  }

  @override
  Future<PaymentProof?> getProof(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId/payment-proof');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        return null;
      }

      return PaymentProof.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
