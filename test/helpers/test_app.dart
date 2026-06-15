import 'package:flutter/material.dart';
import 'package:otomasiku_mobile/l10n/app_localizations.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key, required this.child, this.locale = const Locale('en')});

  final Widget child;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}
