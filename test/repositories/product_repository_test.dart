import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/product_repository.dart';

void main() {
  late Dio dio;
  late ProductRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions());
    repository = ProductRepositoryImpl(dio);
  });

  group('getProducts', () {
    test('returns typed ProductListResponse on success', () async {
      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'data': [
                {
                  'id': 1,
                  'name': 'FR-A840-2.2K-1 Inverter',
                  'slug': 'fr-a840-2-2k-1-inverter',
                  'sku': 'FR-A840-2.2K-1',
                  'brandId': 1,
                  'categoryId': 1,
                  'brand': {'id': 1, 'name': 'Mitsubishi', 'slug': 'mitsubishi'},
                  'category': {'id': 1, 'name': 'Inverter', 'slug': 'inverter'},
                  'price': 15000000,
                  'stock': 10,
                  'version': 1,
                  'unit': 'unit',
                  'minOrder': 1,
                  'images': [
                    {
                      'id': 'img-1',
                      'url': 'assets/images/products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg',
                      'path': 'products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg',
                      'is_primary': true,
                      'sort_order': 0,
                    },
                  ],
                  'isPublished': true,
                  'createdAt': '2026-01-01T00:00:00.000Z',
                  'updatedAt': '2026-01-15T00:00:00.000Z',
                },
              ],
              'total': 1,
              'page': 1,
              'pageSize': 20,
            },
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final result = await repository.getProducts(const ProductFilter());

      expect(result.data.length, 1);
      expect(result.data.first.name, 'FR-A840-2.2K-1 Inverter');
      expect(result.data.first.price, 15000000);
      expect(result.total, 1);
    });

    test('throws ApiException on error response', () async {
      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': false,
            'error': {'code': 'PRODUCT_NOT_FOUND', 'correlationId': 'abc-123'},
          },
        );
      });
      dio.httpClientAdapter = adapter;

      expect(
        () => repository.getProducts(const ProductFilter()),
        throwsA(isA<ApiException>()),
      );
    });
  });
}

class _MockAdapter implements HttpClientAdapter {
  final Response Function(RequestOptions) _handler;

  _MockAdapter(this._handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = _handler(options);
    final body = utf8.encode(jsonEncode(response.data));
    return ResponseBody.fromBytes(
      body,
      response.statusCode!,
      headers: {
        'content-type': [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
