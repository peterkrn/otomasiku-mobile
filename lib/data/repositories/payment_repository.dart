import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../models/order.dart';

abstract class PaymentRepository {
  /// Fetch the current payment/order status for [orderId].
  Future<Order> getPaymentStatus(String orderId);
}

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Order> getPaymentStatus(String orderId) async {
    final response = await _dio.get('/orders/$orderId');
    if (kDebugMode) debugPrint('=== PAYMENT STATUS RAW: ${response.data}');
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

    try {
      final data = apiResponse.data!;
      final orderMap = data['order'] as Map<String, dynamic>;
      orderMap['items'] = data['items'];
      if (data['paymentProof'] != null) {
        orderMap['paymentProof'] = data['paymentProof'];
      }
      return Order.fromJson(orderMap);
    } catch (e) {
      if (kDebugMode) debugPrint('=== ORDER PARSE ERROR: $e\nDATA: ${apiResponse.data}');
      rethrow;
    }
  }
}
