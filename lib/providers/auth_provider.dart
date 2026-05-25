import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  AuthNotifier() : super(const AuthState()) {
    _loadAuthState();
  }

  /// Load persisted auth state on init
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      state = state.copyWith(
        isLoggedIn: true,
        name: prefs.getString('userName') ?? '',
        email: prefs.getString('userEmail') ?? '',
        userId: prefs.getString('userId') ?? '',
      );
    }
  }

  /// Login with dummy credentials (M2 only)
  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', 'John Doe');
    await prefs.setString('userEmail', email);
    await prefs.setString('userId', 'user-001');

    state = state.copyWith(
      isLoggedIn: true,
      email: email,
      name: 'John Doe',
      userId: 'user-001',
    );
  }

  /// Register with dummy credentials (M2 only)
  Future<void> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userId', 'user-001');

    state = state.copyWith(
      isLoggedIn: true,
      email: email,
      name: name,
      userId: 'user-001',
    );
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }
}
