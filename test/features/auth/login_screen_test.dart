import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:otomasiku_mobile/core/auth/auth_service.dart';
import 'package:otomasiku_mobile/core/auth/token_storage.dart';
import 'package:otomasiku_mobile/core/router/app_router.dart';
import 'package:otomasiku_mobile/data/repositories/auth_repository.dart';
import 'package:otomasiku_mobile/data/repositories/profile_repository.dart';
import 'package:otomasiku_mobile/features/auth/login_screen.dart';
import 'package:otomasiku_mobile/l10n/app_localizations.dart';
import 'package:otomasiku_mobile/models/user_profile.dart';
import 'package:otomasiku_mobile/providers/auth_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';
import 'package:otomasiku_mobile/shared/widgets/google_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, Session, User;

import '../../helpers/test_app.dart';

class _FakeAuthService implements AuthService {
  final StreamController<AuthStateChangePayload> _authStateController =
      StreamController<AuthStateChangePayload>.broadcast();
  Session? _currentSession;
  AuthResult googleResult = const AuthResult(status: AuthResultStatus.failure);

  @override
  Stream<AuthStateChangePayload> get authStateChanges =>
      _authStateController.stream;

  @override
  Session? get currentSession => _currentSession;

  @override
  bool get isAuthenticated => _currentSession != null;

  @override
  Future<AuthResult> login(String email, String password) async {
    return const AuthResult(status: AuthResultStatus.failure);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshSession() async => false;

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String? fullName,
  ) async {
    return const AuthResult(status: AuthResultStatus.failure);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    return googleResult;
  }

  void emitSignedIn(Session session) {
    _currentSession = session;
    _authStateController.add(
      AuthStateChangePayload(event: AuthChangeEvent.signedIn, session: session),
    );
  }

  Future<void> dispose() async {
    await _authStateController.close();
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> bootstrap() async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getProfile() {
    throw UnimplementedError();
  }

  @override
  Future<void> registerDeviceToken(String fcmToken) async {}

  @override
  Future<void> removeDeviceToken(String fcmToken) async {}

  @override
  Future<String> uploadAvatar(File imageFile) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> updateProfile(ProfileInput input) {
    throw UnimplementedError();
  }
}

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearFcmToken() async {}

  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getFcmToken() async => null;

  @override
  Future<bool> getRememberMe() async => true;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveFcmToken(String token) async {}

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}

  @override
  Future<void> setRememberMe(bool value) async {}
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

Session _testSession() {
  return Session(
    accessToken: 'header.payload.signature',
    refreshToken: 'refresh-token',
    tokenType: 'bearer',
    user: const User(
      id: 'user-001',
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{'full_name': 'Test User'},
      aud: 'authenticated',
      email: 'test@otomasi.com',
      createdAt: '2026-06-12T00:00:00.000Z',
    ),
  );
}

GoRouter _buildLoginRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home Placeholder'))),
      ),
      GoRoute(
        path: '/landing',
        name: AppRoute.landing,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Landing Placeholder'))),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Register Placeholder'))),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRoute.forgotPassword,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Forgot Password Placeholder')),
        ),
      ),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginScreen does not overflow on narrow phones', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authService = _FakeAuthService();
    addTearDown(authService.dispose);
    final authRepository = _FakeAuthRepository();
    final profileRepository = _FakeProfileRepository();
    final tokenStorage = _FakeTokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              authService,
              authRepository,
              profileRepository,
              tokenStorage,
            ),
          ),
        ],
        child: const TestApp(child: LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('LoginScreen renders Google sign-in with a vector icon', (
    tester,
  ) async {
    final authService = _FakeAuthService();
    addTearDown(authService.dispose);
    final authRepository = _FakeAuthRepository();
    final profileRepository = _FakeProfileRepository();
    final tokenStorage = _FakeTokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              authService,
              authRepository,
              profileRepository,
              tokenStorage,
            ),
          ),
        ],
        child: const TestApp(child: LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final googleButton = find.widgetWithText(
      OutlinedButton,
      'Masuk dengan Google',
    );

    expect(googleButton, findsOneWidget);
    expect(
      find.descendant(of: googleButton, matching: find.byType(GoogleIcon)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: googleButton, matching: find.byType(Image)),
      findsNothing,
    );
  });

  testWidgets(
    'LoginScreen redirects to home after Google OAuth callback signs user in',
    (tester) async {
      final authService = _FakeAuthService()
        ..googleResult = const AuthResult(status: AuthResultStatus.success);
      addTearDown(authService.dispose);
      final authRepository = _FakeAuthRepository();
      final profileRepository = _FakeProfileRepository();
      final tokenStorage = _FakeTokenStorage();
      final router = _buildLoginRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(authService),
            authRepositoryProvider.overrideWithValue(authRepository),
            profileRepositoryProvider.overrideWithValue(profileRepository),
            tokenStorageProvider.overrideWithValue(tokenStorage),
            authProvider.overrideWith(
              (ref) => AuthNotifier(
                authService,
                authRepository,
                profileRepository,
                tokenStorage,
              ),
            ),
          ],
          child: _RouterTestApp(router: router),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home Placeholder'), findsNothing);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Masuk dengan Google'),
      );
      await tester.pumpAndSettle();

      authService.emitSignedIn(_testSession());
      await tester.pumpAndSettle();

      expect(find.text('Home Placeholder'), findsOneWidget);
    },
  );
}
