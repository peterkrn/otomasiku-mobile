import 'package:dio/dio.dart';

abstract class AuthRepository {
  Future<void> bootstrap();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> bootstrap() async {
    await _dio.post('/me/bootstrap');
  }
}
