import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/core/utils/error_handler.dart';

// Stub AppLocalizations with minimal surface for testing.
// We verify the *key* selected, not the translated string, so we return the key itself.
class _FakeL10n implements ErrorL10n {
  @override
  String get errorOffline => 'errorOffline';
  @override
  String get errorTimeout => 'errorTimeout';
  @override
  String get errorSessionExpired => 'errorSessionExpired';
  @override
  String get errorServer => 'errorServer';
  @override
  String get errorGeneric => 'errorGeneric';
  @override
  String translateCode(String code, {Map<String, dynamic>? details}) =>
      'translated:$code';
}

void main() {
  final l10n = _FakeL10n();

  group('errorMessageFor', () {
    test('NetworkException → errorOffline', () {
      final msg = errorMessageFor(const NetworkException(), l10n);
      expect(msg, 'errorOffline');
    });

    test('TimeoutException → errorTimeout', () {
      final msg = errorMessageFor(const TimeoutException(), l10n);
      expect(msg, 'errorTimeout');
    });

    test('SessionExpiredException → errorSessionExpired', () {
      final msg = errorMessageFor(const SessionExpiredException(), l10n);
      expect(msg, 'errorSessionExpired');
    });

    test('ServerException → errorServer', () {
      final msg = errorMessageFor(
          const ServerException(correlationId: 'abc-123'), l10n);
      expect(msg, 'errorServer');
    });

    test('ApiException → translated via code', () {
      final msg = errorMessageFor(
          const ApiException(code: 'PRODUCT_NOT_FOUND', statusCode: 404), l10n);
      expect(msg, 'translated:PRODUCT_NOT_FOUND');
    });

    test('unknown error → errorGeneric', () {
      final msg = errorMessageFor(Exception('unexpected'), l10n);
      expect(msg, 'errorGeneric');
    });
  });
}
