class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    if (success) {
      return ApiResponse<T>(
        success: true,
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : json['data'] as T?,
      );
    }
    return ApiResponse<T>(
      success: false,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ApiError {
  final String code;
  final String correlationId;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.correlationId,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      correlationId: json['correlationId'] as String? ?? '',
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
