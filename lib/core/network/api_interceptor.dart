import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../errors/app_exception.dart';
import 'api_response.dart';

String _currentLanguageCode = 'id';

void setInterceptorLanguage(String languageCode) {
  _currentLanguageCode = languageCode;
}

class ApiInterceptor extends Interceptor {
  ApiInterceptor({
    required SupabaseClient supabase,
    required Dio dio,
    void Function()? onSessionExpired,
  })  : _supabase = supabase,
        _dio = dio,
        _onSessionExpired = onSessionExpired;

  final SupabaseClient _supabase;
  final Dio _dio;
  final void Function()? _onSessionExpired;
  final Uuid _uuid = const Uuid();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final session = _supabase.auth.currentSession;
    if (session?.accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${session!.accessToken}';
    }

    options.headers['Accept-Language'] = _currentLanguageCode;
    options.headers['x-correlation-id'] = _uuid.v4();

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldAttemptTokenRefresh(err)) {
      try {
        final authResponse = await _supabase.auth.refreshSession();
        if (authResponse.session != null) {
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] =
              'Bearer ${authResponse.session!.accessToken}';
          retryOptions.extra['_is_retrying'] = true;

          final response = await _dio.fetch(retryOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        _onSessionExpired?.call();
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const SessionExpiredException(),
        ),
      );
      return;
    }

    handler.next(_mapToAppException(err));
  }

  bool _shouldAttemptTokenRefresh(DioException err) {
    if (err.response?.statusCode != 401) return false;
    if (err.requestOptions.extra['_is_retrying'] == true) return false;
    final path = err.requestOptions.path;
    if (path == '/auth/token' || path.contains('/refresh')) return false;
    return true;
  }

  DioException _mapToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
        return DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DioException(
          requestOptions: err.requestOptions,
          error: const TimeoutException(),
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final data = err.response?.data;

        if (statusCode >= 500) {
          String correlationId = '';
          if (data is Map<String, dynamic>) {
            final errorData = data['error'];
            if (errorData is Map<String, dynamic>) {
              correlationId = errorData['correlationId'] as String? ?? '';
            }
          }
          try {
            FirebaseCrashlytics.instance.recordError(
              err,
              err.stackTrace,
              reason: 'Server error $statusCode',
            );
          } catch (_) {
            // Firebase may not be initialized yet
          }
          return DioException(
            requestOptions: err.requestOptions,
            error: ServerException(correlationId: correlationId),
          );
        }

        if (statusCode >= 400 && data is Map<String, dynamic>) {
          final apiResponse = ApiResponse<dynamic>.fromJson(data, null);
          if (apiResponse.error != null) {
            return DioException(
              requestOptions: err.requestOptions,
              error: ApiException(
                code: apiResponse.error!.code,
                statusCode: statusCode,
                details: apiResponse.error!.details,
              ),
            );
          }
        }

        return DioException(
          requestOptions: err.requestOptions,
          error: ApiException(
            code: 'HTTP_$statusCode',
            statusCode: statusCode,
          ),
        );
      default:
        return DioException(
          requestOptions: err.requestOptions,
          error: ApiException(
            code: 'UNKNOWN',
            statusCode: 0,
            details: {'type': err.type.name},
          ),
        );
    }
  }
}
