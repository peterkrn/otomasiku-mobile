import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing app locale (Bahasa Indonesia default)
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('id'));

  void setLocale(String languageCode) {
    state = Locale(languageCode);
  }

  void toggleLocale() {
    state = state.languageCode == 'id' ? const Locale('en') : const Locale('id');
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
