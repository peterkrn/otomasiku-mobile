import 'package:supabase_flutter/supabase_flutter.dart';

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

class AuthService {
  AuthService({
    required SupabaseClient supabase,
    TokenStorage? tokenStorage,
  })  : _supabase = supabase,
        _tokenStorage = tokenStorage ?? TokenStorage();

  final SupabaseClient _supabase;
  final TokenStorage _tokenStorage;

  bool get isAuthenticated => _supabase.auth.currentSession != null;

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
        emailRedirectTo: 'io.otomasiku.app://confirm-email',
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

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _tokenStorage.clearTokens();
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
