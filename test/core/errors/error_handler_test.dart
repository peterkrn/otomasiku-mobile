import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/core/utils/error_handler.dart';

class _FakeL10n implements ErrorL10n {
  @override String get errorOffline => 'errorOffline';
  @override String get errorTimeout => 'errorTimeout';
  @override String get errorSessionExpired => 'errorSessionExpired';
  @override String get errorServer => 'errorServer';
  @override String get errorGeneric => 'errorGeneric';

  @override String get errorInvalidCredentials => 'errorInvalidCredentials';
  @override String get errorUserNotFound => 'errorUserNotFound';
  @override String get errorDuplicateEntry => 'errorDuplicateEntry';
  @override String get errorWeakPassword => 'errorWeakPassword';
  @override String get errorUnauthorized => 'errorUnauthorized';
  @override String get errorProductNotFound => 'errorProductNotFound';
  @override String get outOfStock => 'outOfStock';
  @override String get available => 'available';
  @override String insufficientStock(int count) => 'insufficientStock:$count';
  @override String get orderNotFound => 'orderNotFound';
  @override String get errorOrderPaid => 'errorOrderPaid';
  @override String get cancelled => 'cancelled';
  @override String get errorPaymentFailed => 'errorPaymentFailed';
  @override String get errorBcaVaExpired => 'errorBcaVaExpired';
  @override String get errorInvalidAmount => 'errorInvalidAmount';
  @override String get errorCartEmpty => 'errorCartEmpty';
  @override String get errorInvalidQuantity => 'errorInvalidQuantity';
  @override String get errorValidation => 'errorValidation';
  @override String get errorServiceUnavailable => 'errorServiceUnavailable';
}

void main() {
  final l10n = _FakeL10n();

  group('errorMessageFor', () {
    test('NetworkException → errorOffline', () {
      expect(errorMessageFor(const NetworkException(), l10n), 'errorOffline');
    });

    test('TimeoutException → errorTimeout', () {
      expect(errorMessageFor(const TimeoutException(), l10n), 'errorTimeout');
    });

    test('SessionExpiredException → errorSessionExpired', () {
      expect(errorMessageFor(const SessionExpiredException(), l10n), 'errorSessionExpired');
    });

    test('ServerException → errorServer', () {
      expect(errorMessageFor(const ServerException(correlationId: 'abc'), l10n), 'errorServer');
    });

    test('ApiException PRODUCT_NOT_FOUND → localized string', () {
      final msg = errorMessageFor(
          const ApiException(code: 'PRODUCT_NOT_FOUND', statusCode: 404), l10n);
      expect(msg, 'errorProductNotFound');
    });

    test('ApiException INVALID_CREDENTIALS → localized string', () {
      final msg = errorMessageFor(
          const ApiException(code: 'INVALID_CREDENTIALS', statusCode: 401), l10n);
      expect(msg, 'errorInvalidCredentials');
    });

    test('unknown error → errorGeneric', () {
      expect(errorMessageFor(Exception('unexpected'), l10n), 'errorGeneric');
    });
  });

  group('translateErrorCode', () {
    test('STOCK_CONFLICT reuses insufficient stock message with available count', () {
      final msg = translateErrorCode('STOCK_CONFLICT', l10n, details: {'available': 2});
      expect(msg, 'insufficientStock:2');
    });

    test('OUT_OF_STOCK includes available count', () {
      final msg = translateErrorCode('OUT_OF_STOCK', l10n, details: {'available': 3});
      expect(msg, contains('3'));
      expect(msg, contains('outOfStock'));
    });

    test('VALIDATION_ERROR → errorValidation (no raw server text)', () {
      final msg = translateErrorCode('VALIDATION_ERROR', l10n,
          details: {'field': 'email', 'message': 'required'});
      expect(msg, 'errorValidation');
    });

    test('unknown code → errorGeneric', () {
      expect(translateErrorCode('UNKNOWN_CODE', l10n), 'errorGeneric');
    });
  });
}
