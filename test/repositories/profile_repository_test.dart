import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/profile_repository.dart';
import 'package:otomasiku_mobile/models/user_profile.dart';

void main() {
  late Dio dio;
  late ProfileRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions());
    repository = ProfileRepositoryImpl(dio);
  });

  group('getProfile', () {
    test('returns UserProfile on success', () async {
      dio.options.baseUrl = 'http://test.com';
      dio.httpClientAdapter = _MockAdapter((options) => Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'id': 'user-001',
            'email': 'test@otomasi.com',
            'role': 'customer',
            'fullName': 'Test User',
            'phone': '08123456789',
            'companyName': 'PT Otomasi',
            'avatarUrl': null,
          },
        },
      ));

      final profile = await repository.getProfile();

      expect(profile, isA<UserProfile>());
      expect(profile.id, 'user-001');
      expect(profile.email, 'test@otomasi.com');
      expect(profile.fullName, 'Test User');
      expect(profile.phone, '08123456789');
      expect(profile.companyName, 'PT Otomasi');
    });

    test('throws ApiException on error response', () async {
      dio.options.baseUrl = 'http://test.com';
      dio.httpClientAdapter = _MockAdapter((options) => Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': false,
          'error': {
            'code': 'USER_NOT_FOUND',
            'correlationId': 'abc-123',
          },
        },
      ));

      expect(
        () => repository.getProfile(),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('updateProfile', () {
    test('sends correct data and returns updated profile', () async {
      dio.options.baseUrl = 'http://test.com';

      RequestOptions? captured;
      dio.httpClientAdapter = _MockAdapter((options) {
        captured = options;
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'id': 'user-001',
              'email': 'test@otomasi.com',
              'role': 'customer',
              'fullName': 'Updated Name',
              'phone': '08123456789',
              'companyName': 'PT Otomasi',
              'avatarUrl': null,
            },
          },
        );
      });

      final input = ProfileInput(fullName: 'Updated Name');
      final profile = await repository.updateProfile(input);

      expect(captured?.path, '/me');
      expect(captured?.method, 'PATCH');
      expect(
        (captured?.data as Map<String, dynamic>)['fullName'],
        'Updated Name',
      );
      expect(profile.fullName, 'Updated Name');
    });
  });

  group('registerDeviceToken', () {
    test('sends POST with correct payload', () async {
      dio.options.baseUrl = 'http://test.com';

      RequestOptions? captured;
      dio.httpClientAdapter = _MockAdapter((options) {
        captured = options;
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true},
        );
      });

      await repository.registerDeviceToken('fcm-token-123');

      expect(captured?.path, '/me/devices');
      expect(captured?.method, 'POST');
      expect(
        (captured?.data as Map<String, dynamic>)['fcmToken'],
        'fcm-token-123',
      );
    });
  });

  group('removeDeviceToken', () {
    test('sends DELETE with correct payload', () async {
      dio.options.baseUrl = 'http://test.com';

      RequestOptions? captured;
      dio.httpClientAdapter = _MockAdapter((options) {
        captured = options;
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true},
        );
      });

      await repository.removeDeviceToken('fcm-token-456');

      expect(captured?.path, '/me/devices');
      expect(captured?.method, 'DELETE');
      expect(
        (captured?.data as Map<String, dynamic>)['fcmToken'],
        'fcm-token-456',
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
