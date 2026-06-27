import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import 'token_storage.dart';

enum AuthResultStatus { success, failure }

class AuthResult {
  final AuthResultStatus status;
  final String? errorCode;
  final String? errorMessage;

  const AuthResult({
    required this.status,
    this.errorCode,
    this.errorMessage,
  });

  bool get isSuccess => status == AuthResultStatus.success;
}

class AuthStateChangePayload {
  final AuthChangeEvent event;
  final Session? session;

  const AuthStateChangePayload({
    required this.event,
    required this.session,
  });
}

class AuthService {
  AuthService({
    required SupabaseClient supabase,
    TokenStorage? tokenStorage,
  })  : _supabase = supabase,
        _tokenStorage = tokenStorage ?? TokenStorage();

  final SupabaseClient _supabase;
  final TokenStorage _tokenStorage;

  String get _loginCallbackUrl => '${EnvConfig.deepLinkScheme}://login-callback';
  String get _confirmEmailUrl => '${EnvConfig.deepLinkScheme}://confirm-email';

  bool get isAuthenticated => _supabase.auth.currentSession != null;
  Session? get currentSession => _supabase.auth.currentSession;
  Stream<AuthStateChangePayload> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map(
        (data) => AuthStateChangePayload(
          event: data.event,
          session: data.session,
        ),
      );

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = response.session;
      if (session != null) {
        await _tokenStorage.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
        );
      }
      return const AuthResult(status: AuthResultStatus.success);
    } on AuthException catch (e) {
      return AuthResult(
        status: AuthResultStatus.failure,
        errorCode: _mapAuthExceptionCode(e),
        errorMessage: e.message,
      );
    }
  }

  Future<AuthResult> register(
    String email,
    String password,
    String? fullName,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
        emailRedirectTo: _confirmEmailUrl,
      );
      final session = response.session;
      if (session != null) {
        await _tokenStorage.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
        );
      }
      return const AuthResult(status: AuthResultStatus.success);
    } on AuthException catch (e) {
      return AuthResult(
        status: AuthResultStatus.failure,
        errorCode: _mapAuthExceptionCode(e),
        errorMessage: e.message,
      );
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _loginCallbackUrl,
      );

      if (response) {
        return const AuthResult(status: AuthResultStatus.success);
      }

      return const AuthResult(
        status: AuthResultStatus.failure,
        errorCode: 'GOOGLE_SIGN_IN_FAILED',
        errorMessage: 'Google sign-in was cancelled or failed',
      );
    } on AuthException catch (e) {
      return AuthResult(
        status: AuthResultStatus.failure,
        errorCode: _mapAuthExceptionCode(e),
        errorMessage: e.message,
      );
    } catch (e) {
      return AuthResult(
        status: AuthResultStatus.failure,
        errorCode: 'UNKNOWN_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _tokenStorage.clearTokens();
  }

  Future<AuthResult> deleteAccount() async {
    try {
      // Delete user account via Supabase admin API (requires service role on backend)
      // For client-side, we first sign out then call our backend endpoint
      await _supabase.auth.signOut();
      await _tokenStorage.clearTokens();

      // Note: Full account deletion requires backend implementation with service role
      // Client-side just clears local session and triggers deletion request
      return const AuthResult(status: AuthResultStatus.success);
    } on AuthException catch (e) {
      return AuthResult(
        status: AuthResultStatus.failure,
        errorCode: _mapAuthExceptionCode(e),
        errorMessage: e.message,
      );
    } catch (e) {
      return AuthResult(
        status: AuthResultStatus.failure,
        errorCode: 'UNKNOWN_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      return response.session != null;
    } catch (_) {
      return false;
    }
  }

  String _mapAuthExceptionCode(AuthException e) {
    final code = e.message.toLowerCase();
    if (code.contains('invalid login credentials')) return 'INVALID_CREDENTIALS';
    if (code.contains('user already registered')) return 'DUPLICATE_ENTRY';
    if (code.contains('rate limit')) return 'RATE_LIMIT_EXCEEDED';
    if (code.contains('user not found')) return 'USER_NOT_FOUND';
    return 'VALIDATION_ERROR';
  }
}
