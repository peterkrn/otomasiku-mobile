# Spec 01 — Infrastructure: Dio Client, Interceptors, Env Config, Connectivity

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | Critical — all other specs depend on this |
| **Status** | ✅ Done |
| **Depends On** | — (first spec) |

---

## Scope

Set up the entire network layer from scratch:
- Environment configuration (dev/prod base URLs)
- Dio HTTP client singleton with interceptors
- Auth token injection + 401 auto-refresh
- Standardized error mapping
- Connectivity detection (offline banner)

---

## New Files

```
lib/core/config/
├── env_config.dart              # Base URLs, Supabase keys per environment

lib/core/network/
├── api_client.dart              # Dio singleton + interceptor wiring
├── api_interceptor.dart         # Auth injection, 401 refresh, error normalization
├── api_response.dart            # Generic typed response wrapper
└── connectivity_service.dart    # Stream-based network state

lib/core/errors/
└── app_exception.dart           # Typed exception classes
```

## Modified Files

```
lib/main.dart                    # Initialize Supabase + connectivity service
pubspec.yaml                     # Add: dio, supabase_flutter, flutter_secure_storage,
                                 #      connectivity_plus, uuid, json_annotation,
                                 #      firebase_crashlytics, firebase_performance,
                                 #      firebase_messaging, flutter_local_notifications
                                 # Dev: json_serializable, build_runner
```

---

## Acceptance Criteria

### AC-1: Dio client injects auth token
```gherkin
Given a valid Supabase JWT is stored in flutter_secure_storage
When any authenticated Dio request is made
Then the request includes "Authorization: Bearer <token>" header
And the request includes "Accept-Language: id" (or "en" per locale)
And the request includes "x-correlation-id: <uuid>" header
```

### AC-2: 401 triggers token refresh
```gherkin
Given the Supabase JWT has expired
When a Dio request returns HTTP 401
Then the interceptor calls supabase.auth.refreshSession()
And retries the original request with the new token
And if refresh fails, clears stored tokens and redirects to /login
```

### AC-3: Network errors are typed
```gherkin
Given any Dio request fails
When the error is a DioException
Then it is mapped to a typed AppException subclass:
  - DioExceptionType.connectionError → NetworkException
  - HTTP 4xx with error.code → ApiException(code, statusCode)
  - HTTP 5xx → ServerException(correlationId)
  - DioExceptionType.connectionTimeout → TimeoutException
And the raw DioException is never exposed to UI code
```

### AC-4: Offline banner shows when no network
```gherkin
Given the device has no internet connection
When any screen is visible
Then an offline banner appears at the top: "Tidak ada koneksi internet"
When internet is restored
Then the banner disappears automatically
```

### AC-5: Environment config selects correct base URL
```gherkin
Given the app is built in debug mode
Then EnvConfig.apiBaseUrl points to the staging Railway URL
Given the app is built in release mode
Then EnvConfig.apiBaseUrl points to the production Railway URL
```

---

## Implementation Detail

### `env_config.dart`
```dart
class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://otomasiku-api-staging.up.railway.app/api',
  );
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

### `api_client.dart`
```dart
// Dio singleton — one instance for the entire app
// Base options: connectTimeout 10s, receiveTimeout 30s
// Interceptors (in order): ApiInterceptor, LogInterceptor (debug only)
// Provider: final apiClientProvider = Provider<Dio>((ref) => ApiClient.instance);
```

### `api_interceptor.dart`
```dart
// onRequest:
//   1. Read token from flutter_secure_storage
//   2. Add Authorization header
//   3. Add Accept-Language from localeProvider
//   4. Add x-correlation-id (UUID v4)
//
// onError:
//   1. If 401 → attempt supabase.auth.refreshSession()
//      - Success: update stored token, retry request
//      - Failure: clear tokens, throw SessionExpiredException
//   2. Map DioException → AppException subclass
//   3. Log to Firebase Crashlytics (non-fatal) for 5xx errors
```

### `api_response.dart`
```dart
// Express success shape: { "success": true, "data": T }
// Express error shape:   { "success": false, "error": { "code": String, "correlationId": String, "details": Map? } }

class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
}

class ApiError {
  final String code;
  final String correlationId;
  final Map<String, dynamic>? details;
}
```

### `app_exception.dart`
```dart
sealed class AppException implements Exception {
  final String message;
}
class NetworkException extends AppException {}       // No internet
class TimeoutException extends AppException {}       // Request timed out
class SessionExpiredException extends AppException {}// 401 + refresh failed
class ApiException extends AppException {            // 4xx with error.code
  final String code;
  final int statusCode;
  final Map<String, dynamic>? details;
}
class ServerException extends AppException {         // 5xx
  final String correlationId;
}
```

### `connectivity_service.dart`
```dart
// Uses connectivity_plus
// Exposes: Stream<bool> isConnected
// Provider: final connectivityProvider = StreamProvider<bool>((ref) => ...)
// Used by: offline_banner.dart widget (shared/widgets/)
```

---

## pubspec.yaml additions

```yaml
dependencies:
  dio: ^5.7.0
  supabase_flutter: ^2.8.4
  flutter_secure_storage: ^9.2.4
  connectivity_plus: ^6.1.4
  uuid: ^4.5.1
  json_annotation: ^4.9.0
  firebase_core: ^3.13.1
  firebase_crashlytics: ^4.3.5
  firebase_performance: ^0.10.1+5
  firebase_messaging: ^15.2.5
  flutter_local_notifications: ^18.0.1

dev_dependencies:
  json_serializable: ^6.9.5
  build_runner: ^2.4.15
```

> Pin exact versions. Run `flutter pub get` after adding.

---

## Verification Checklist

- [ ] `flutter analyze` clean after adding all files
- [ ] Dio instance is a singleton (not recreated per request)
- [ ] Auth token is read from `flutter_secure_storage`, not memory
- [ ] 401 retry only happens once (no infinite loop)
- [ ] `AppException` subtypes cover all error cases
- [ ] `connectivityProvider` emits correctly on airplane mode toggle
- [ ] No `print()` statements — use `debugPrint()` wrapped in `kDebugMode`
