import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'notification_channels.dart';
import 'notification_handler.dart';

class NotificationService {
  final Future<bool> Function() _requestPermission;
  final Future<String?> Function() _getToken;
  final Stream<String> Function() _onTokenRefresh;
  GoRouter? _router;

  NotificationService({
    Future<bool> Function()? requestPermission,
    Future<String?> Function()? getToken,
    Stream<String> Function()? onTokenRefresh,
  })  : _requestPermission = requestPermission ?? _defaultRequestPermission,
        _getToken = getToken ?? _defaultGetToken,
        _onTokenRefresh = onTokenRefresh ?? _defaultOnTokenRefresh;

  static Future<bool> _defaultRequestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  static Future<String?> _defaultGetToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  static Stream<String> _defaultOnTokenRefresh() =>
      FirebaseMessaging.instance.onTokenRefresh;

  Future<void> initialize({required GoRouter router}) async {
    _router = router;

    await _requestPermission();

    final token = await _getToken();
    if (token != null) {
      // token retrieved
    }

    await _setupLocalNotifications();
    _registerListeners();
  }

  Future<bool> requestPermission() => _requestPermission();

  Future<String?> getToken() => _getToken();

  Stream<String> get onTokenRefresh => _onTokenRefresh();

  Future<void> _setupLocalNotifications() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidPlugin =
        plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(orderUpdatesChannel);
    await androidPlugin?.createNotificationChannel(paymentChannel);
  }

  void _registerListeners() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (_router != null) {
        NotificationHandler.handleMessage(message, _router!);
      }
    });
    _onTokenRefresh().listen((_) {});
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      FlutterLocalNotificationsPlugin().show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'order_updates',
            'Update Pesanan',
            channelDescription: 'Notifikasi perubahan status pesanan',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
