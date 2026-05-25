import 'package:dio/dio.dart';

import '../../models/cart_item.dart';
import '../../core/network/api_response.dart';

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
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    final data = apiResponse.data!;
    final items = (data['items'] as List)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
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
        'productId': productId,
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
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    return CartItem.fromJson(apiResponse.data!['data'] as Map<String, dynamic>);
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
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    return CartItem.fromJson(apiResponse.data!['data'] as Map<String, dynamic>);
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
