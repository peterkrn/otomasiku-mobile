import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/address_repository.dart';

void main() {
  late Dio dio;
  late AddressRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions());
    repository = AddressRepositoryImpl(dio);
  });

  group('getAddresses', () {
    test('returns list of Address on success', () async {
      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'data': [
              {
                'id': 'addr-1',
                'label': 'Rumah',
                'recipient': 'Budi',
                'phone': '08123456789',
                'street': 'Jl. Merdeka No. 1',
                'city': 'Jakarta',
                'province': 'DKI Jakarta',
                'postalCode': '10110',
                'isDefault': true,
                'createdAt': '2026-01-01T00:00:00.000Z',
              },
              {
                'id': 'addr-2',
                'label': 'Kantor',
                'recipient': 'Siti',
                'phone': '08198765432',
                'street': 'Jl. Sudirman No. 10',
                'city': 'Jakarta',
                'province': 'DKI Jakarta',
                'postalCode': '10220',
                'isDefault': false,
                'createdAt': '2026-02-15T00:00:00.000Z',
              },
            ],
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final result = await repository.getAddresses();

      expect(result.length, 2);
      expect(result.first.id, 'addr-1');
      expect(result.first.label, 'Rumah');
      expect(result.first.isDefault, true);
      expect(result.first.createdAt, DateTime.utc(2026, 1, 1));
    });

    test('throws ApiException on error response', () async {
      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': false,
            'error': {'code': 'ADDRESSES_NOT_FOUND', 'correlationId': 'abc-123'},
          },
        );
      });
      dio.httpClientAdapter = adapter;

      expect(
        () => repository.getAddresses(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('getAddressById', () {
    test('returns Address on success', () async {
      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        expect(options.path, '/addresses/addr-1');
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'id': 'addr-1',
              'label': 'Rumah',
              'recipient': 'Budi',
              'phone': '08123456789',
              'street': 'Jl. Merdeka No. 1',
              'city': 'Jakarta',
              'province': 'DKI Jakarta',
              'postalCode': '10110',
              'isDefault': true,
              'createdAt': '2026-01-01T00:00:00.000Z',
            },
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final result = await repository.getAddressById('addr-1');

      expect(result.id, 'addr-1');
      expect(result.label, 'Rumah');
    });
  });

  group('createAddress', () {
    test('sends correct data and returns created Address', () async {
      final input = AddressInput(
        label: 'Kantor',
        recipient: 'Siti',
        phone: '08198765432',
        street: 'Jl. Sudirman No. 10',
        city: 'Jakarta',
        province: 'DKI Jakarta',
        postalCode: '10220',
        isDefault: false,
      );

      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        expect(options.path, '/addresses');
        expect(options.method, 'POST');
        expect(
          options.data,
          {
            'label': 'Kantor',
            'recipient': 'Siti',
            'phone': '08198765432',
            'street': 'Jl. Sudirman No. 10',
            'city': 'Jakarta',
            'province': 'DKI Jakarta',
            'postalCode': '10220',
            'isDefault': false,
          },
        );
        return Response(
          requestOptions: options,
          statusCode: 201,
          data: {
            'success': true,
            'data': {
              'id': 'addr-new',
              'label': 'Kantor',
              'recipient': 'Siti',
              'phone': '08198765432',
              'street': 'Jl. Sudirman No. 10',
              'city': 'Jakarta',
              'province': 'DKI Jakarta',
              'postalCode': '10220',
              'isDefault': false,
              'createdAt': '2026-05-01T00:00:00.000Z',
            },
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final result = await repository.createAddress(input);

      expect(result.id, 'addr-new');
      expect(result.label, 'Kantor');
      expect(result.isDefault, false);
    });
  });

  group('updateAddress', () {
    test('sends correct data and returns updated Address', () async {
      final input = AddressInput(
        label: 'Rumah Baru',
        recipient: 'Budi',
        phone: '08123456789',
        street: 'Jl. Baru No. 5',
        city: 'Jakarta',
        province: 'DKI Jakarta',
        postalCode: '10110',
        isDefault: true,
      );

      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        expect(options.path, '/addresses/addr-1');
        expect(options.method, 'PUT');
        expect(options.data['label'], 'Rumah Baru');
        expect(options.data['isDefault'], true);
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'id': 'addr-1',
              'label': 'Rumah Baru',
              'recipient': 'Budi',
              'phone': '08123456789',
              'street': 'Jl. Baru No. 5',
              'city': 'Jakarta',
              'province': 'DKI Jakarta',
              'postalCode': '10110',
              'isDefault': true,
              'createdAt': '2026-01-01T00:00:00.000Z',
            },
          },
        );
      });
      dio.httpClientAdapter = adapter;

      final result = await repository.updateAddress('addr-1', input);

      expect(result.id, 'addr-1');
      expect(result.label, 'Rumah Baru');
      expect(result.isDefault, true);
    });
  });

  group('deleteAddress', () {
    test('calls DELETE endpoint', () async {
      dio.options.baseUrl = 'http://test.com';
      final adapter = _MockAdapter((options) {
        expect(options.path, '/addresses/addr-1');
        expect(options.method, 'DELETE');
        return Response(
          requestOptions: options,
          statusCode: 204,
          data: null,
        );
      });
      dio.httpClientAdapter = adapter;

      await repository.deleteAddress('addr-1');
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
    final body = response.data != null
        ? utf8.encode(jsonEncode(response.data))
        : Uint8List(0);
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
