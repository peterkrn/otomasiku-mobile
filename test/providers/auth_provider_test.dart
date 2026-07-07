import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/auth/auth_service.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/auth_repository.dart';
import 'package:otomasiku_mobile/data/repositories/profile_repository.dart';
import 'package:otomasiku_mobile/models/user_profile.dart';
import 'package:otomasiku_mobile/providers/auth_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAuthService mockAuthService;
  late _MockProfileRepository mockProfileRepository;

  const testProfile = UserProfile(
    id: 'user-001',
    email: 'test@otomasi.com',
    role: 'customer',
    fullName: 'Test User',
    phone: '08123456789',
    companyName: 'PT Otomasi',
  );

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
        profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        authProvider.overrideWith(
          (ref) => AuthNotifier(
            mockAuthService,
            _MockAuthRepository(),
            mockProfileRepository,
            ref.read(tokenStorageProvider),
          ),
        ),
      ],
    );
  }

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    mockAuthService = _MockAuthService();
    mockProfileRepository = _MockProfileRepository();
  });

  tearDown(() async {
    await mockAuthService.dispose();
  });

  group('AuthState.profile', () {
    test('starts as null', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(authProvider);
      expect(state.profile, isNull);
    });
  });

  group('AuthNotifier.refreshProfile', () {
    test('loads profile and updates state', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);

      notifier.state = notifier.state.copyWith(
        isAuthenticated: true,
        userId: 'user-001',
      );

      await notifier.refreshProfile();

      final state = container.read(authProvider);
      expect(state.profile, isNotNull);
      expect(state.profile!.id, 'user-001');
      expect(state.profile!.fullName, 'Test User');
      expect(state.isLoading, false);
    });

    test('does nothing when not authenticated', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);

      mockProfileRepository.getProfileCalls = 0;

      await notifier.refreshProfile();

      expect(mockProfileRepository.getProfileCalls, 0);
      expect(container.read(authProvider).profile, isNull);
    });
  });

  group('AuthNotifier.updateProfile', () {
    test('calls repository and updates profile', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);

      notifier.state = notifier.state.copyWith(
        isAuthenticated: true,
        userId: 'user-001',
      );

      final input = ProfileInput(fullName: 'Updated Name');
      await notifier.updateProfile(input);

      final state = container.read(authProvider);
      expect(state.profile, isNotNull);
      expect(state.profile!.fullName, 'Updated Name');
      expect(state.isLoading, false);
    });

    test('rethrows on error so UI can catch it', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);

      mockProfileRepository.shouldThrow = true;

      final input = ProfileInput(fullName: 'Updated Name');
      expect(() => notifier.updateProfile(input), throwsA(isA<ApiException>()));
    });
  });

  group('AuthNotifier.logout', () {
    test('clears profile on logout', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authProvider.notifier);

      notifier.state = notifier.state.copyWith(
        isAuthenticated: true,
        userId: 'user-001',
        profile: testProfile,
      );

      await notifier.logout();

      expect(notifier.state.profile, isNull);
      expect(notifier.state.isAuthenticated, false);
    });
  });

  group('AuthNotifier.signInWithGoogle', () {
    test(
      'does not set an error while waiting for OAuth callback session',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(authProvider.notifier);

        mockAuthService.googleResult = const AuthResult(
          status: AuthResultStatus.success,
        );

        await notifier.signInWithGoogle();

        final state = container.read(authProvider);
        expect(state.isLoading, false);
        expect(state.errorCode, isNull);
        expect(state.isAuthenticated, false);
      },
    );

    test(
      'marks the user authenticated after the OAuth callback arrives',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final notifier = container.read(authProvider.notifier);

        mockAuthService.googleResult = const AuthResult(
          status: AuthResultStatus.success,
        );

        await notifier.signInWithGoogle();
        mockAuthService.emitSignedIn(_testSession());

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final state = container.read(authProvider);
        expect(state.isAuthenticated, true);
        expect(state.userId, 'user-001');
        expect(state.profile?.fullName, 'Test User');
      },
    );
  });
}

class _MockAuthService extends AuthService {
  _MockAuthService()
    : super(supabase: SupabaseClient('http://localhost:54321', 'mock-key'));

  final StreamController<AuthStateChangePayload> _authStateController =
      StreamController<AuthStateChangePayload>.broadcast();
  Session? _currentSession;
  AuthResult googleResult = const AuthResult(status: AuthResultStatus.success);

  @override
  Stream<AuthStateChangePayload> get authStateChanges =>
      _authStateController.stream;

  @override
  Session? get currentSession => _currentSession;

  @override
  bool get isAuthenticated => _currentSession != null;

  @override
  Future<AuthResult> login(String email, String password) async {
    return const AuthResult(status: AuthResultStatus.success);
  }

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String? name,
  ) async {
    return const AuthResult(status: AuthResultStatus.success);
  }

  @override
  Future<AuthResult> signInWithGoogle() async => googleResult;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshSession() async => true;

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

class _MockAuthRepository implements AuthRepository {
  @override
  Future<void> bootstrap() async {}
}

class _MockProfileRepository implements ProfileRepository {
  bool shouldThrow = false;
  int getProfileCalls = 0;
  UserProfile _lastUpdated = const UserProfile(
    id: 'user-001',
    email: 'test@otomasi.com',
    role: 'customer',
    fullName: 'Test User',
    phone: '08123456789',
    companyName: 'PT Otomasi',
  );

  @override
  Future<UserProfile> getProfile() async {
    getProfileCalls++;
    if (shouldThrow) {
      throw const ApiException(code: 'UNKNOWN', statusCode: 500);
    }
    return _lastUpdated;
  }

  @override
  Future<UserProfile> updateProfile(ProfileInput input) async {
    if (shouldThrow) {
      throw const ApiException(code: 'UPDATE_FAILED', statusCode: 422);
    }
    _lastUpdated = UserProfile(
      id: 'user-001',
      email: 'test@otomasi.com',
      role: 'customer',
      fullName: input.fullName ?? 'Test User',
      phone: input.phone,
      companyName: input.companyName,
    );
    return _lastUpdated;
  }

  @override
  Future<String> uploadAvatar(File imageFile) async => 'avatar.jpg';

  @override
  Future<void> registerDeviceToken(String fcmToken) async {}

  @override
  Future<void> removeDeviceToken(String fcmToken) async {}

  @override
  Future<void> deleteAccount() async {}
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
