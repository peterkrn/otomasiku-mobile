sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException() : super('Tidak ada koneksi internet.');
}

class TimeoutException extends AppException {
  const TimeoutException() : super('Permintaan timeout.');
}

class SessionExpiredException extends AppException {
  const SessionExpiredException() : super('Sesi telah berakhir. Silakan login kembali.');
}

class ApiException extends AppException {
  final String code;
  final int statusCode;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.code,
    required this.statusCode,
    this.details,
  }) : super('API error: $code');
}

class ServerException extends AppException {
  final String correlationId;

  const ServerException({
    required this.correlationId,
  }) : super('Terjadi kesalahan pada server.');
}
