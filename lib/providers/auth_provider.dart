import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/auth/auth_service.dart';
import '../core/auth/token_storage.dart';
import '../data/repositories/auth_repository.dart';
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
  return AuthNotifier(authService, authRepository, ref);
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorCode;
  final String? userId;
  final String? email;
  final String? name;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorCode,
    this.userId,
    this.email,
    this.name,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorCode,
    String? userId,
    String? email,
    String? name,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorCode: errorCode,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._authRepository, this._ref)
      : super(const AuthState()) {
    _init();
  }

  final AuthService _authService;
  final AuthRepository _authRepository;
  final Ref _ref;

  void _init() {
    if (_authService.isAuthenticated) {
      final session = Supabase.instance.client.auth.currentSession;
      state = state.copyWith(
        isAuthenticated: true,
        userId: session?.user.id,
        email: session?.user.email,
        name: session?.user.userMetadata?['full_name'] as String?,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorCode: null);

    final result = await _authService.login(email, password);

    if (result.isSuccess) {
      _updateFromSession();
      await _bootstrap();
    } else {
      state = state.copyWith(
        isLoading: false,
        errorCode: result.errorCode,
      );
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
      _updateFromSession();
      await _bootstrap();
    } else {
      state = state.copyWith(
        isLoading: false,
        errorCode: result.errorCode,
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _ref.invalidate(authProvider);
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorCode: null);
  }

  void _updateFromSession() {
    final session = Supabase.instance.client.auth.currentSession;
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      userId: session?.user.id,
      email: session?.user.email,
      name: session?.user.userMetadata?['full_name'] as String?,
    );
  }

  Future<void> _bootstrap() async {
    try {
      await _authRepository.bootstrap();
    } catch (_) {
      // Non-fatal — profile may already exist
    }
  }
}
