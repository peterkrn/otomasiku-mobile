import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import 'api_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio dio;

  bool _initialized = false;

  void configure({
    required SupabaseClient supabase,
    void Function()? onSessionExpired,
  }) {
    if (_initialized) return;
    _initialized = true;

    dio = Dio(BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(ApiInterceptor(
      supabase: supabase,
      dio: dio,
      onSessionExpired: onSessionExpired,
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: true,
        error: true,
      ));
    }
  }
}
