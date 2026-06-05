import '../errors/app_exception.dart';

/// Minimal l10n contract required by [errorMessageFor] and [translateErrorCode].
/// Implemented by the generated AppLocalizations class via extension.
abstract interface class ErrorL10n {
  // AppException type messages
  String get errorOffline;
  String get errorTimeout;
  String get errorSessionExpired;
  String get errorServer;
  String get errorGeneric;

  // Backend API error code messages
  String get errorInvalidCredentials;
  String get errorUserNotFound;
  String get errorDuplicateEntry;
  String get errorWeakPassword;
  String get errorUnauthorized;
  String get errorProductNotFound;
  String get outOfStock;
  String get available;
  String insufficientStock(int count);
  String get orderNotFound;
  String get errorOrderPaid;
  String get cancelled;
  String get errorPaymentFailed;
  String get errorBcaVaExpired;
  String get errorInvalidAmount;
  String get errorCartEmpty;
  String get errorInvalidQuantity;
  String get errorValidation;
  String get errorServiceUnavailable;
}

/// Maps a thrown [error] object to a localized user-facing string.
String errorMessageFor(Object error, ErrorL10n l10n) {
  return switch (error) {
    NetworkException() => l10n.errorOffline,
    TimeoutException() => l10n.errorTimeout,
    SessionExpiredException() => l10n.errorSessionExpired,
    ServerException() => l10n.errorServer,
    ApiException(:final code, :final details) =>
      translateErrorCode(code, l10n, details: details),
    _ => l10n.errorGeneric,
  };
}

/// Translates error codes from Express backend to localized strings.
/// Accepts [ErrorL10n] so the active locale is always respected.
/// Source: docs/AI_RULES.md — "No hardcoded error text from Express"
String translateErrorCode(
  String code,
  ErrorL10n l10n, {
  Map<String, dynamic>? details,
}) {
  switch (code) {
    // Auth errors
    case 'INVALID_CREDENTIALS':
      return l10n.errorInvalidCredentials;
    case 'USER_NOT_FOUND':
      return l10n.errorUserNotFound;
    case 'EMAIL_ALREADY_IN_USE':
      return l10n.errorDuplicateEntry;
    case 'WEAK_PASSWORD':
      return l10n.errorWeakPassword;
    case 'UNAUTHORIZED':
      return l10n.errorUnauthorized;

    // Product errors
    case 'PRODUCT_NOT_FOUND':
      return l10n.errorProductNotFound;
    case 'OUT_OF_STOCK':
      final available = details?['available'] ?? 0;
      return '${l10n.outOfStock} (${l10n.available}: $available)';
    case 'INSUFFICIENT_STOCK':
      final available = details?['available'] as int? ?? 0;
      return l10n.insufficientStock(available);

    // Order errors
    case 'ORDER_NOT_FOUND':
      return l10n.orderNotFound;
    case 'ORDER_ALREADY_PAID':
      return l10n.errorOrderPaid;
    case 'ORDER_CANCELLED':
      return l10n.cancelled;

    // Payment errors
    case 'PAYMENT_FAILED':
      return l10n.errorPaymentFailed;
    case 'VA_EXPIRED':
      return l10n.errorBcaVaExpired;
    case 'INVALID_AMOUNT':
      return l10n.errorInvalidAmount;

    // Cart errors
    case 'CART_EMPTY':
      return l10n.errorCartEmpty;
    case 'INVALID_QUANTITY':
      return l10n.errorInvalidQuantity;

    // Validation errors
    case 'VALIDATION_ERROR':
      final field = details?['field'] ?? '';
      final message = details?['message'] ?? '';
      return '$field: $message'.trim();
    case 'INVALID_INPUT':
      return l10n.errorValidation;

    // Server errors
    case 'INTERNAL_ERROR':
      return l10n.errorServer;
    case 'SERVICE_UNAVAILABLE':
      return l10n.errorServiceUnavailable;

    // Default
    default:
      return l10n.errorGeneric;
  }
}
