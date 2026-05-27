import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class NotificationHandler {
  static void handleMessage(RemoteMessage message, GoRouter router) {
    final type = message.data['type'];
    final orderId = message.data['orderId'];

    if (orderId == null || orderId.isEmpty) return;

    switch (type) {
      case 'payment_confirmed':
      case 'order_status':
        router.push('/orders/$orderId');
        break;
      case 'new_order':
        break;
    }
  }
}
