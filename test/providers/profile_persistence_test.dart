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
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late _MockProfileRepository mockProfileRepo;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    mockProfileRepo = _MockProfileRepository();
  });

  ProviderContainer createContainer() => ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(_MockAuthService()),
          authRepositoryProvider.overrideWithValue(_MockAuthRepository()),
          profileRepositoryProvider.overrideWithValue(mockProfileRepo),
        ],
      );

  group('AuthNotifier.updateProfile — persistence', () {
    test('after updateProfile, state.profile reflects updated values', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Set authenticated state with initial profile
      container.read(authProvider.notifier).state =
          container.read(authProvider.notifier).state.copyWith(
            isAuthenticated: true,
            userId: 'user-001',
            profile: const UserProfile(
              id: 'user-001',
              email: 'test@test.com',
              role: 'customer',
              fullName: 'Old Name',
              phone: '08111111111',
            ),
          );

      await container.read(authProvider.notifier).updateProfile(
            const ProfileInput(fullName: 'New Name'),
          );

      final profile = container.read(authProvider).profile;
      expect(profile, isNotNull);
      expect(profile!.fullName, 'New Name');
    });

    test('updateProfile calls refreshProfile after PATCH to get full object',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(authProvider.notifier).state =
          container.read(authProvider.notifier).state.copyWith(
            isAuthenticated: true,
            userId: 'user-001',
          );

      await container.read(authProvider.notifier).updateProfile(
            const ProfileInput(fullName: 'New Name'),
          );

      // Both updateProfile (PATCH) and refreshProfile (GET) should be called
      expect(mockProfileRepo.updateCalls, 1);
      expect(mockProfileRepo.getProfileCalls, greaterThanOrEqualTo(1));
    });

    test('updateProfile throws on API error so UI can catch it', () async {
      mockProfileRepo.shouldThrowOnUpdate = true;
      final container = createContainer();
      addTearDown(container.dispose);

      container.read(authProvider.notifier).state =
          container.read(authProvider.notifier).state.copyWith(
            isAuthenticated: true,
            userId: 'user-001',
          );

      expect(
        () => container.read(authProvider.notifier).updateProfile(
              const ProfileInput(fullName: 'New Name'),
            ),
        throwsA(isA<ApiException>()),
      );
    });
  });
}

class _MockAuthService extends AuthService {
  _MockAuthService()
      : super(supabase: SupabaseClient('http://localhost:54321', 'mock-key'));

  @override
  bool get isAuthenticated => false;

  @override
  Future<AuthResult> login(String email, String password) async =>
      const AuthResult(status: AuthResultStatus.success);

  @override
  Future<AuthResult> register(String email, String password, String? name) async =>
      const AuthResult(status: AuthResultStatus.success);

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshSession() async => true;
}

class _MockAuthRepository implements AuthRepository {
  @override
  Future<void> bootstrap() async {}
}

class _MockProfileRepository implements ProfileRepository {
  int getProfileCalls = 0;
  int updateCalls = 0;
  bool shouldThrowOnUpdate = false;

  @override
  Future<UserProfile> getProfile() async {
    getProfileCalls++;
    return const UserProfile(
      id: 'user-001',
      email: 'test@test.com',
      role: 'customer',
      fullName: 'New Name',
      phone: '08111111111',
    );
  }

  @override
  Future<UserProfile> updateProfile(ProfileInput input) async {
    updateCalls++;
    if (shouldThrowOnUpdate) {
      throw const ApiException(code: 'UPDATE_FAILED', statusCode: 422);
    }
    return UserProfile(
      id: 'user-001',
      email: 'test@test.com',
      role: 'customer',
      fullName: input.fullName ?? 'Old Name',
      phone: input.phone,
    );
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
