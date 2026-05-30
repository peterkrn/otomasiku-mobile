import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/notifications/notification_service.dart';

void main() {
  group('NotificationService', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService(
        requestPermission: () async => true,
        getToken: () async => 'test-fcm-token',
        onTokenRefresh: () => const Stream.empty(),
      );
    });

    test('requestPermission returns true on grant', () async {
      final result = await service.requestPermission();
      expect(result, isTrue);
    });

    test('requestPermission returns false on deny', () async {
      final deniedService = NotificationService(
        requestPermission: () async => false,
        getToken: () async => null,
        onTokenRefresh: () => const Stream.empty(),
      );
      final result = await deniedService.requestPermission();
      expect(result, isFalse);
    });

    test('getToken returns token string', () async {
      final token = await service.getToken();
      expect(token, 'test-fcm-token');
    });

    test('getToken returns null when no token', () async {
      final noTokenService = NotificationService(
        requestPermission: () async => false,
        getToken: () async => null,
        onTokenRefresh: () => const Stream.empty(),
      );
      final token = await noTokenService.getToken();
      expect(token, isNull);
    });
  });
}
