import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// These channel names/descriptions are Android system constants used for
// channel registration. They are intentionally hardcoded because:
// 1. They're const values required at compile time for channel creation
// 2. No BuildContext is available during notification initialization
// 3. Android channel names are shown in system settings (not user-facing UI)
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
