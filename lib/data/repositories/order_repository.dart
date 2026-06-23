import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/bigint_converter.dart';
import '../../models/order.dart';
import 'order_detail_parser.dart';

abstract class OrderRepository {
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20});
  Future<Order> getOrderById(String id);
  Future<CreateOrderResult> createOrder({
    required String addressId,
    required List<String> cartItemIds,
    String? notes,
    required String idempotencyKey,
  });
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId);
  Future<void> confirmReceived(String orderId);
}

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get(
      '/orders',
      queryParameters: {'page': page, 'pageSize': pageSize},
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

    final data = apiResponse.data!;
    final rawData = data['data'];
    if (rawData is! List) {
      throw ApiException(code: 'INVALID_RESPONSE', statusCode: 0);
    }
    final orders = rawData
        .cast<Map<String, dynamic>>()
        .map((e) => Order.fromJson(e))
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

    final data = apiResponse.data!;
    return parseOrderDetailData(data, statusCode: response.statusCode ?? 200);
  }

  @override
  Future<CreateOrderResult> createOrder({
    required String addressId,
    required List<String> cartItemIds,
    String? notes,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/orders',
      data: {
        'addressId': addressId,
        'cartItemIds': cartItemIds,
        // ignore: use_null_aware_elements
        if (notes != null) 'notes': notes,
      },
      options: Options(headers: {'X-Idempotency-Key': idempotencyKey}),
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

    final rawItems = json['data'];
    if (rawItems is! List) {
      throw ApiException(code: 'INVALID_RESPONSE', statusCode: 0);
    }
    return rawItems
        .cast<Map<String, dynamic>>()
        .map((e) => OrderStatusHistory.fromJson(e))
        .toList();
  }

  @override
  Future<void> confirmReceived(String orderId) async {
    final response = await _dio.patch('/orders/$orderId/confirm-received');
    final json = response.data as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;

    if (!success) {
      throw ApiException(
        code: 'UNKNOWN',
        statusCode: response.statusCode ?? 200,
      );
    }
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
  final String fromStatus;
  final String toStatus;
  final DateTime createdAt;
  final String? changedBy;
  final String? note;

  const OrderStatusHistory({
    required this.fromStatus,
    required this.toStatus,
    required this.createdAt,
    this.changedBy,
    this.note,
  });

  /// Alias for backward-compat with UI that reads `.status`
  String get status => toStatus;

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      fromStatus: json['from_status'] as String,
      toStatus: json['to_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      changedBy: json['changed_by'] as String?,
      note: json['note'] as String?,
    );
  }
}
