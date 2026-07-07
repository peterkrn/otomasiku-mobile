import 'package:dio/dio.dart';

import '../../core/errors/app_exception.dart';
import '../../core/network/api_response.dart';
import '../../models/cart_item.dart';

abstract class CartRepository {
  Future<CartResponse> getCart();
  Future<CartItem> addItem({
    required String productId,
    required int quantity,
    required String idempotencyKey,
  });
  Future<CartItem> updateItem({
    required String cartItemId,
    required int quantity,
  });
  Future<void> removeItem(String cartItemId);
  Future<void> clearCart();
}

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<CartResponse> getCart() async {
    final response = await _dio.get('/cart');
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
    final rawItems = data['items'];
    if (rawItems is! List) throw ApiException(code: 'INVALID_RESPONSE', statusCode: 0);
    final items = rawItems
        .cast<Map<String, dynamic>>()
        .map((e) => CartItem.fromJson(e))
        .toList();

    return CartResponse(
      items: items,
      totalItems: data['totalItems'] as int,
    );
  }

  @override
  Future<CartItem> addItem({
    required String productId,
    required int quantity,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/cart',
      data: {
        'productId': int.parse(productId),
        'quantity': quantity,
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

    return CartItem.fromJson(apiResponse.data!);
  }

  @override
  Future<CartItem> updateItem({
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await _dio.put(
      '/cart/$cartItemId',
      data: {'quantity': quantity},
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

    return CartItem.fromJson(apiResponse.data!);
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    await _dio.delete('/cart/$cartItemId');
  }

  @override
  Future<void> clearCart() async {
    await _dio.delete('/cart');
  }
}

class CartResponse {
  final List<CartItem> items;
  final int totalItems;

  const CartResponse({
    required this.items,
    required this.totalItems,
  });
}
