import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing authentication state (M2 dummy auth)
/// In Milestone 2, auth is faked with a simple boolean
/// In Milestone 3, this will integrate with Supabase Auth
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Authentication state
class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? name;
  final String? email;

  const AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.name,
    this.email,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? name,
    String? email,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

/// Authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Login with dummy credentials (M2 only)
  void login(String email, String password) {
    // M2 dummy login — always succeeds
    state = state.copyWith(
      isLoggedIn: true,
      email: email,
      name: 'Peter', // Dummy user name
      userId: 'user-001',
    );
  }

  /// Register with dummy credentials (M2 only)
  void register(String name, String email, String password) {
    // M2 dummy register — always succeeds
    state = state.copyWith(
      isLoggedIn: true,
      email: email,
      name: name,
      userId: 'user-001',
    );
  }

  /// Logout
  void logout() {
    state = const AuthState(isLoggedIn: false);
  }
}
