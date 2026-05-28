import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/bigint_converter.dart';
import '../../models/order.dart';

abstract class OrderRepository {
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20});
  Future<Order> getOrderById(String id);
  Future<CreateOrderResult> createOrder({
    required String addressId,
    String? notes,
    required String idempotencyKey,
  });
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId);
}

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/orders', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
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

    final data = apiResponse.data!;
    final orders = (data['data'] as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderListResponse(
      data: orders,
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  @override
  Future<Order> getOrderById(String id) async {
    final response = await _dio.get('/orders/$id');
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

    return Order.fromJson(apiResponse.data!);
  }

  @override
  Future<CreateOrderResult> createOrder({
    required String addressId,
    String? notes,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/orders',
      data: {
        'addressId': addressId,
        if (notes != null) 'notes': notes,
      },
      options: Options(headers: {'X-Idempotency-Key': idempotencyKey}),
    );
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

    final data = apiResponse.data!;
    return CreateOrderResult(
      orderId: data['orderId'].toString(),
      orderNumber: data['orderNumber'] as String,
      totalAmount: const BigIntStringConverter().fromJson(data['totalAmount']),
    );
  }

  @override
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId) async {
    final response = await _dio.get('/orders/$orderId/status-history');
    final json = response.data as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;

    if (!success || json['data'] == null) {
      throw ApiException(
        code: 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
      );
    }

    final items = json['data'] as List;
    return items
        .map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class OrderListResponse {
  final List<Order> data;
  final int total;
  final int page;
  final int pageSize;

  const OrderListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}

class CreateOrderResult {
  final String orderId;
  final String orderNumber;
  final int totalAmount;

  const CreateOrderResult({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
  });
}

class OrderStatusHistory {
  final String status;
  final DateTime changedAt;
  final String? changedBy;
  final String? notes;

  const OrderStatusHistory({
    required this.status,
    required this.changedAt,
    this.changedBy,
    this.notes,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: json['status'] as String,
      changedAt: DateTime.parse(json['changedAt'] as String),
      changedBy: json['changedBy'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
