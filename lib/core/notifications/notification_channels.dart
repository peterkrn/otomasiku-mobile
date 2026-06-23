import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const orderUpdatesChannel = AndroidNotificationChannel(
  'order_updates',
  'Update Pesanan',
  description: 'Notifikasi perubahan status pesanan',
  importance: Importance.high,
);

const paymentChannel = AndroidNotificationChannel(
  'payment',
  'Pembayaran',
  description: 'Konfirmasi pembayaran',
  importance: Importance.high,
);
