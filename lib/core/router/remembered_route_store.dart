import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberedRouteStore {
  RememberedRouteStore._();

  static const String _key = 'remembered_route_v1';
  static final RememberedRouteStore instance = RememberedRouteStore._();

  Future<void> saveFromState(GoRouterState state) async {
    final routeName = state.name;
    if (routeName == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'name': routeName,
        'pathParameters': state.pathParameters,
        'queryParameters': state.uri.queryParameters,
      }),
    );
  }

  Future<RememberedRoute?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final name = map['name'] as String?;
      if (name == null || name.isEmpty) return null;

      return RememberedRoute(
        name: name,
        pathParameters: Map<String, String>.from(
          map['pathParameters'] as Map? ?? const <String, String>{},
        ),
        queryParameters: Map<String, String>.from(
          map['queryParameters'] as Map? ?? const <String, String>{},
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class RememberedRoute {
  final String name;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const RememberedRoute({
    required this.name,
    required this.pathParameters,
    required this.queryParameters,
  });
}
