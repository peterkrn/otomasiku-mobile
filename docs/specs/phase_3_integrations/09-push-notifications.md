# Spec 09 — Push Notifications: FCM Setup, Device Token, Notification Routing

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | Medium |
| **Status** | ⬜ Draft |
| **Depends On** | 03 (auth — token registration requires authenticated user) |
| **API Endpoints** | `POST /api/me/device-token`, `DELETE /api/me/device-token` |

---

## Scope

Set up Firebase Cloud Messaging (FCM) for Android push notifications. Register device token with the backend after login. Handle foreground, background, and terminated notification taps. Route notification taps to the correct screen via GoRouter.

> FCM is free and unlimited. Firebase is already in the project for Crashlytics and Performance Monitoring — no new Firebase project needed.

---

## New Files

```
lib/core/notifications/
├── notification_service.dart      # FCM init, permission, token management
├── notification_handler.dart      # Route notification taps to GoRouter
└── notification_channels.dart     # Android notification channel definitions
```

## Modified Files

```
lib/main.dart                      # Initialize NotificationService after Supabase
lib/providers/auth_provider.dart   # Register token on login, remove on logout
android/app/src/main/AndroidManifest.xml  # Default notification channel
```

---

## Notification Types

| Type | `data.type` | `data.orderId` | Navigates To |
|------|-------------|----------------|--------------|
| Payment confirmed | `payment_confirmed` | ✅ | `/orders/:orderId` |
| Order processing | `order_status` | ✅ | `/orders/:orderId` |
| Order shipped | `order_status` | ✅ | `/orders/:orderId` |
| Order done | `order_status` | ✅ | `/orders/:orderId` |
| New order (admin) | `new_order` | ✅ | (admin only — ignore in mobile) |

---

## Acceptance Criteria

### AC-1: Permission requested after login
```gherkin
Given the user just logged in for the first time
When the home screen loads
Then an in-app explanation is shown first: "Aktifkan notifikasi untuk update status pesanan Anda"
And a "Aktifkan" button triggers the system permission dialog
If the user grants permission
Then the FCM token is obtained and registered via POST /api/me/device-token
If the user denies
Then the app works normally without notifications
And no error is shown
```

### AC-2: Device token registered after login
```gherkin
Given the user logs in successfully
When the auth flow completes
Then FirebaseMessaging.instance.getToken() is called
And POST /api/me/device-token is called with { token, platform: "android" }
On success: token stored locally (to use for logout cleanup)
On failure: log to Crashlytics (non-fatal), continue silently
```

### AC-3: Foreground notification shows local notification
```gherkin
Given the app is in the foreground
When a push notification arrives
Then a local notification is displayed using flutter_local_notifications
And it shows the notification title and body
And tapping it routes to the correct screen
```

### AC-4: Background/terminated notification tap routes correctly
```gherkin
Given the app is in the background or terminated
When the user taps a push notification
Then the app opens
And navigates to the correct screen based on data.type and data.orderId:
  - payment_confirmed or order_status → /orders/:orderId
```

### AC-5: Token refresh updates backend
```gherkin
Given the FCM token is refreshed by Firebase
When FirebaseMessaging.onTokenRefresh fires
Then POST /api/me/device-token is called with the new token
```

### AC-6: Token removed on logout
```gherkin
Given the user taps "Keluar"
When the logout flow runs
Then DELETE /api/me/device-token is called with the stored token
And FirebaseMessaging.instance.deleteToken() is called
And the locally stored token is cleared
```

---

## Implementation Detail

### `notification_channels.dart`
```dart
// Android notification channels
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
```

### `notification_service.dart`
```dart
class NotificationService {
  Future<void> initialize() async {
    // 1. Initialize flutter_local_notifications
    // 2. Create Android notification channels
    // 3. Set up FirebaseMessaging.onMessage (foreground) → show local notification
    // 4. Set up FirebaseMessaging.onMessageOpenedApp (background tap) → route
    // 5. Check getInitialMessage() (terminated tap) → route
  }

  Future<void> requestPermission() async {
    // NotificationSettings settings = await FirebaseMessaging.instance.requestPermission()
    // Return whether granted
  }

  Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  Stream<String> get onTokenRefresh => FirebaseMessaging.instance.onTokenRefresh;
}
```

### `notification_handler.dart`
```dart
class NotificationHandler {
  static void handleMessage(RemoteMessage message, GoRouter router) {
    final type = message.data['type'];
    final orderId = message.data['orderId'];

    switch (type) {
      case 'payment_confirmed':
      case 'order_status':
        if (orderId != null) router.push('/orders/$orderId');
        break;
      // Ignore admin-only types
    }
  }
}
```

### `AndroidManifest.xml` addition
```xml
<meta-data
  android:name="com.google.firebase.messaging.default_notification_channel_id"
  android:value="order_updates" />
```

---

## Verification Checklist

- [ ] Permission dialog shown after first login (with in-app explanation first)
- [ ] Device token registered via POST /api/me/device-token after login
- [ ] Foreground notification shows local notification
- [ ] Background tap navigates to correct order screen
- [ ] Terminated app tap navigates to correct order screen
- [ ] Token refresh updates backend
- [ ] Logout removes token from backend and Firebase
- [ ] Notification channels created on Android
- [ ] `flutter analyze` clean
