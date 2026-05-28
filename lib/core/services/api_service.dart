import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for making authenticated API calls to Express backend
class ApiService {
  ApiService._();

  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String? get _authToken =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  static Dio get _dio {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    ));
    return dio;
  }

  /// GET /api/addresses
  static Future<List<dynamic>> getAddresses() async {
    try {
      final response = await _dio.get('/addresses');
      return response.data['data'] ?? [];
    } catch (_) {
      return [];
    }
  }

  /// POST /api/addresses
  static Future<Map<String, dynamic>> createAddress({
    required String label,
    required String recipient,
    required String phone,
    required String street,
    required String city,
    required String province,
    required String postalCode,
  }) async {
    final response = await _dio.post('/addresses',
      data: {
        'label': label,
        'recipient': recipient,
        'phone': phone,
        'street': street,
        'city': city,
        'province': province,
        'postalCode': postalCode,
        'isDefault': true,
      },
      options: Options(headers: {
        'X-Idempotency-Key': 'addr-${DateTime.now().millisecondsSinceEpoch}',
      }),
    );
    return response.data['data'] ?? response.data;
  }

  /// Get default address or create one
  static Future<String> getDefaultAddressId() async {
    final addresses = await getAddresses();
    if (addresses.isNotEmpty) {
      final defaultAddr = addresses.firstWhere(
        (a) => a['isDefault'] == true,
        orElse: () => addresses.first,
      );
      return defaultAddr['id'].toString();
    }
    final newAddr = await createAddress(
      label: 'Kantor',
      recipient: 'Customer',
      phone: '08123456789',
      street: 'Jl. Industri No. 1',
      city: 'Jakarta',
      province: 'DKI Jakarta',
      postalCode: '12345',
    );
    return newAddr['id'].toString();
  }

  /// POST /api/cart — add item to server cart
  static Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post('/cart',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
        options: Options(headers: {
          'X-Idempotency-Key': 'cart-$productId-${DateTime.now().millisecondsSinceEpoch}',
        }),
      );
      print('=== CART API: ${response.statusCode} ${response.data}');
    } on DioException catch (e) {
      print('=== CART API ERROR: ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  /// DELETE /api/cart
  static Future<void> clearCart() async {
    try {
      await _dio.delete('/cart');
    } catch (_) {}
  }

  /// POST /api/orders
  static Future<Map<String, dynamic>> createOrder({
    required String addressId,
  }) async {
    try {
      final response = await _dio.post('/orders',
        data: {'addressId': addressId},
        options: Options(headers: {
          'X-Idempotency-Key': 'order-${DateTime.now().millisecondsSinceEpoch}',
        }),
      );
      print('=== ORDER API: ${response.statusCode} ${response.data}');
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      print('=== ORDER API ERROR: ${e.response?.statusCode} ${e.response?.data}');
      final data = e.response?.data;
      final errorMsg = data?['error']?['message'] ?? data?['error']?['code'] ?? 'Order failed';
      throw Exception(errorMsg);
    }
  }
}
