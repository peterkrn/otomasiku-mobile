import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:otomasiku_mobile/core/notifications/notification_handler.dart';

class MockGoRouter implements GoRouter {
  final List<String> pushedPaths = [];

  @override
  Future<T?> push<T>(String location, {Object? extra}) async {
    pushedPaths.add(location);
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

RemoteMessage _buildMessage(String type, [String? orderId]) {
  final data = <String, String>{
    'type': type,
  };
  if (orderId != null) {
    data['orderId'] = orderId;
  }
  return RemoteMessage(data: data);
}

void main() {
  group('NotificationHandler.handleMessage', () {
    late MockGoRouter router;

    setUp(() {
      router = MockGoRouter();
    });

    test('routes to order detail for payment_confirmed', () {
      final message = _buildMessage('payment_confirmed', 'order-123');
      NotificationHandler.handleMessage(message, router);
      expect(router.pushedPaths, ['/orders/order-123']);
    });

    test('routes to order detail for order_status', () {
      final message = _buildMessage('order_status', 'order-456');
      NotificationHandler.handleMessage(message, router);
      expect(router.pushedPaths, ['/orders/order-456']);
    });

    test('ignores new_order type', () {
      final message = _buildMessage('new_order', 'order-789');
      NotificationHandler.handleMessage(message, router);
      expect(router.pushedPaths, isEmpty);
    });

    test('ignores message when orderId is missing', () {
      final message = _buildMessage('payment_confirmed');
      NotificationHandler.handleMessage(message, router);
      expect(router.pushedPaths, isEmpty);
    });

    test('ignores unknown type', () {
      final message = _buildMessage('unknown_type', 'order-999');
      NotificationHandler.handleMessage(message, router);
      expect(router.pushedPaths, isEmpty);
    });
  });
}
