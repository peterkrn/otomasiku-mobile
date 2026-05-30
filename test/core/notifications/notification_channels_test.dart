import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:otomasiku_mobile/core/notifications/notification_channels.dart';

void main() {
  group('Notification channels', () {
    test('orderUpdatesChannel has correct id and importance', () {
      expect(orderUpdatesChannel.id, 'order_updates');
      expect(orderUpdatesChannel.importance, Importance.high);
    });

    test('paymentChannel has correct id and importance', () {
      expect(paymentChannel.id, 'payment');
      expect(paymentChannel.importance, Importance.high);
    });
  });
}
