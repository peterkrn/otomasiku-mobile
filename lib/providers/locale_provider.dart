import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/api_interceptor.dart';

/// Provider for managing app locale (Bahasa Indonesia default)
/// Persists locale choice to flutter_secure_storage
class LocaleNotifier extends StateNotifier<Locale> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LocaleNotifier() : super(const Locale('id'));

  void setLocale(String languageCode) {
    state = Locale(languageCode);
    setInterceptorLanguage(languageCode);
    _storage.write(key: 'app_locale', value: languageCode);
  }

  void toggleLocale() {
    final next = state.languageCode == 'id' ? 'en' : 'id';
    setLocale(next);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Supported locales
const List<Locale> supportedLocales = [
  Locale('id'), // Bahasa Indonesia (default)
  Locale('en'), // English
];
