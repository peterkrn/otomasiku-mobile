import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/auth/auth_service.dart';
import '../core/auth/token_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../models/user_profile.dart';
import 'cart_provider.dart';
import 'repository_providers.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    supabase: Supabase.instance.client,
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final authRepository = ref.read(authRepositoryProvider);
  final profileRepository = ref.read(profileRepositoryProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return AuthNotifier(
    authService,
    authRepository,
    profileRepository,
    tokenStorage,
    onAuthenticated: () {
      ref.read(cartProvider.notifier).loadCart();
    },
  );
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isBootstrapped;
  final String? errorCode;
  final String? userId;
  final String? email;
  final String? name;
  final UserProfile? profile;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isBootstrapped = false,
    this.errorCode,
    this.userId,
    this.email,
    this.name,
    this.profile,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isBootstrapped,
    String? errorCode,
    String? userId,
    String? email,
    String? name,
    UserProfile? profile,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isBootstrapped: isBootstrapped ?? this.isBootstrapped,
      errorCode: errorCode,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      profile: profile ?? this.profile,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._authService,
    this._authRepository,
    this._profileRepository,
    this._tokenStorage, {
    VoidCallback? onAuthenticated,
  })  : _onAuthenticated = onAuthenticated,
        super(const AuthState()) {
    _init();
  }

  final AuthService _authService;
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final TokenStorage _tokenStorage;
  final VoidCallback? _onAuthenticated;

  void _init() {
    if (_authService.isAuthenticated) {
      final session = Supabase.instance.client.auth.currentSession;
      state = state.copyWith(
        isAuthenticated: true,
        userId: session?.user.id,
        email: session?.user.email,
        name: session?.user.userMetadata?['full_name'] as String?,
      );
      Future.microtask(() async {
        await _bootstrap();
        state = state.copyWith(isBootstrapped: true);
        await _loadProfile();
        _onAuthenticated?.call();
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getProfile();
      state = state.copyWith(profile: profile);
    } catch (_) {
      // Non-fatal — profile may not be ready
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorCode: null);

    final result = await _authService.login(email, password);

    if (result.isSuccess) {
      _updateFromSession();
      await _bootstrap();
      state = state.copyWith(isBootstrapped: true);
      // Sync fullName from Supabase metadata to profile if not set
      final metaName = Supabase.instance.client.auth.currentUser
          ?.userMetadata?['full_name'] as String?;
      if (metaName != null && metaName.isNotEmpty) {
        try {
          final profile = await _profileRepository.getProfile();
          if (profile.fullName == null || profile.fullName!.isEmpty) {
            await _profileRepository.updateProfile(ProfileInput(fullName: metaName));
          }
        } catch (_) {}
      }
      await _loadProfile();
      await _registerFcmToken();
      _onAuthenticated?.call();
    } else {
      state = state.copyWith(
        isLoading: false,
        errorCode: result.errorCode,
      );
    }
  }

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _profileRepository.registerDeviceToken(fcmToken);
        await _tokenStorage.saveFcmToken(fcmToken);
      }
    } catch (_) {
      // Non-fatal
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorCode: null);

    final result = await _authService.register(email, password, name);

    if (result.isSuccess) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Email confirmation disabled — user is logged in immediately
        _updateFromSession();
        await _bootstrap();
        state = state.copyWith(isBootstrapped: true);
        // Sync fullName from registration to profile
        if (name.isNotEmpty) {
          try {
            await _profileRepository.updateProfile(ProfileInput(fullName: name));
          } catch (_) {}
        }
        await _loadProfile();
        _onAuthenticated?.call();
      } else {
        // Email confirmation required — not authenticated yet
        state = state.copyWith(isLoading: false);
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        errorCode: result.errorCode,
      );
    }
  }

  Future<void> logout() async {
    try {
      final fcmToken = await _tokenStorage.getFcmToken();
      if (fcmToken != null) {
        await _profileRepository.removeDeviceToken(fcmToken);
      }
      await FirebaseMessaging.instance.deleteToken();
      await _tokenStorage.clearFcmToken();
    } catch (_) {
      // Non-fatal
    }
    await _authService.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorCode: null);
  }

  void _updateFromSession() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      userId: session.user.id,
      email: session.user.email,
      name: session.user.userMetadata?['full_name'] as String?,
    );
  }

  Future<void> _bootstrap() async {
    try {
      await _authRepository.bootstrap();
    } catch (_) {
      // Non-fatal — profile may already exist
    }
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;
    try {
      final profile = await _profileRepository.getProfile();
      state = state.copyWith(profile: profile);
    } catch (_) {
      // Silent
    }
  }

  Future<void> updateProfile(ProfileInput input) async {
    await _profileRepository.updateProfile(input);
    // Re-fetch full profile (PATCH returns partial object)
    await refreshProfile();
  }
}
