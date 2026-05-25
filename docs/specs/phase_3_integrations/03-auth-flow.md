# Spec 03 — Auth Flow: Supabase Auth, Token Storage, GoRouter Guards, Bootstrap

| Field | Value |
|-------|-------|
| **Phase** | 3 — Backend Integration |
| **Priority** | Critical — all feature specs depend on this |
| **Status** | ⬜ Draft |
| **Depends On** | 01-infrastructure, 02-models-repositories |

---

## Scope

Wire up the complete authentication lifecycle:
- Login / Register via Supabase Auth SDK
- Token storage in `flutter_secure_storage`
- Auto-refresh via Supabase `onAuthStateChange`
- Profile bootstrap after first signup
- GoRouter auth guards (redirect unauthenticated users to `/login`)
- Logout (clear tokens, sign out Supabase, invalidate providers)

---

## New Files

```
lib/core/auth/
├── auth_service.dart            # Supabase auth wrapper
└── token_storage.dart           # flutter_secure_storage wrapper
```

## Modified Files

```
lib/main.dart                    # Initialize Supabase, ProviderScope
lib/app.dart                     # Pass locale from localeProvider to MaterialApp
lib/providers/auth_provider.dart # Replace dummy → real Supabase auth
lib/core/router/app_router.dart  # Add auth guard redirect logic
lib/features/auth/login_screen.dart    # Wire to real auth
lib/features/auth/register_screen.dart # Wire to real auth
```

---

## Auth State Machine

```
App Launch
  │
  ├─ No stored session ──→ /login
  │
  └─ Stored session exists
       │
       ├─ Token valid ──→ /home
       │
       └─ Token expired
            │
            ├─ Refresh success ──→ /home
            └─ Refresh fail ──→ /login (clear storage)
```

---

## Acceptance Criteria

### AC-1: Login stores tokens and navigates to home
```gherkin
Given the user is on the login screen
When the user enters valid email and password and taps "Masuk"
Then supabase.auth.signInWithPassword() is called
And the returned accessToken and refreshToken are stored in flutter_secure_storage
And the user is navigated to /home
And the auth state is "authenticated"
```

### AC-2: Login shows localized error on failure
```gherkin
Given the user enters wrong credentials
When the user taps "Masuk"
Then the API returns error.code "UNAUTHORIZED"
And the screen shows the localized message (not raw server text)
And no navigation occurs
And the loading state is cleared
```

### AC-3: Register creates account and bootstraps profile
```gherkin
Given the user fills in name, email, password on the register screen
When the user taps "Daftar"
Then supabase.auth.signUp() is called
And on success, POST /api/me/bootstrap is called to create the profile row
And tokens are stored in flutter_secure_storage
And the user is navigated to /home
```

### AC-4: GoRouter redirects unauthenticated users
```gherkin
Given the user is not authenticated (no valid token)
When the user navigates to any protected route (/home, /cart, /orders, /profile)
Then GoRouter redirects to /login
And after successful login, the user is redirected back to the originally requested route
```

### AC-5: GoRouter redirects authenticated users away from auth screens
```gherkin
Given the user is authenticated
When the user navigates to /login or /register
Then GoRouter redirects to /home
```

### AC-6: Session persists across app restarts
```gherkin
Given the user logged in previously and the app was closed
When the app is reopened
Then flutter_secure_storage returns the stored tokens
And Supabase session is restored
And the user lands on /home without re-logging in
```

### AC-7: Token auto-refresh works
```gherkin
Given the user's accessToken has expired but refreshToken is valid
When the app is opened or a request is made
Then supabase.auth.refreshSession() is called automatically
And the new accessToken is stored in flutter_secure_storage
And the user remains authenticated
```

### AC-8: Logout clears all state
```gherkin
Given the user is authenticated
When the user taps "Keluar" in the profile screen
Then supabase.auth.signOut() is called
And flutter_secure_storage is cleared (both tokens)
And all Riverpod providers are invalidated (cart, orders, profile)
And the user is navigated to /login
And pressing back does not return to protected screens
```

---

## Implementation Detail

### `token_storage.dart`
```dart
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}
```

### `auth_service.dart`
```dart
class AuthService {
  // Wraps supabase.auth — never expose SupabaseClient directly to providers
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String email, String password, String? fullName);
  Future<void> logout();
  Future<bool> refreshSession();
  Stream<AuthState> get authStateChanges;  // from supabase.auth.onAuthStateChange
  bool get isAuthenticated;
}
```

### `auth_provider.dart` (refactored)
```dart
// AuthState: { isAuthenticated, user, isLoading, error }
// AuthNotifier extends StateNotifier<AuthState>
//   - login() → calls AuthService.login() → stores tokens → calls bootstrap()
//   - register() → calls AuthService.register() → stores tokens → calls bootstrap()
//   - logout() → calls AuthService.logout() → clears tokens → invalidates all providers
//   - init() → called on app start → checks stored token → restores session

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider), ref.read(tokenStorageProvider), ref);
});
```

### `app_router.dart` (auth guard)
```dart
redirect: (context, state) {
  final isAuthenticated = ref.read(authProvider).isAuthenticated;
  final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

  if (!isAuthenticated && !isAuthRoute) return '/login';
  if (isAuthenticated && isAuthRoute) return '/home';
  return null;
},
refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.select((s) => s.isAuthenticated))),
```

### Bootstrap flow
```dart
// Called after successful login AND register
// POST /api/me/bootstrap — creates profile row if it doesn't exist (idempotent)
// On success: store UserProfile in authProvider state
// On failure: log to Crashlytics, continue (non-fatal — profile may already exist)
```

---

## Error Code Mapping (auth-specific)

| Code | Screen Message (Indonesian) |
|------|-----------------------------|
| `UNAUTHORIZED` | "Email atau password salah." |
| `DUPLICATE_ENTRY` | "Email sudah terdaftar. Silakan login." |
| `VALIDATION_ERROR` | "Data tidak valid. Periksa kembali." |
| `RATE_LIMIT_EXCEEDED` | "Terlalu banyak percobaan. Coba lagi nanti." |
| `USER_NOT_FOUND` | "Akun tidak ditemukan." |

---

## Verification Checklist

- [ ] Login with valid credentials → navigates to /home
- [ ] Login with wrong credentials → shows localized error, no navigation
- [ ] Register → bootstrap called → navigates to /home
- [ ] Unauthenticated access to /home → redirected to /login
- [ ] Authenticated access to /login → redirected to /home
- [ ] App restart with valid session → lands on /home
- [ ] App restart with expired token → refresh attempted → /home or /login
- [ ] Logout → all providers invalidated → /login → back button blocked
- [ ] Tokens stored in flutter_secure_storage (not SharedPreferences)
- [ ] `flutter analyze` clean
