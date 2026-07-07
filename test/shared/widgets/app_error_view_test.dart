import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/l10n/app_localizations.dart';
import 'package:otomasiku_mobile/shared/widgets/app_error_view.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  group('AppErrorView', () {
    testWidgets('renders retry button and fires onRetry', (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrap(
        AppErrorView(
          error: const NetworkException(),
          onRetry: () => retried = true,
        ),
      ));
      await tester.pump();

      // Retry button must be present
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(retried, isTrue);
    });

    testWidgets('no retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const AppErrorView(error: NetworkException()),
      ));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not throw inside constrained box', (tester) async {
      await tester.pumpWidget(_wrap(
        SizedBox(
          width: 300,
          height: 200,
          child: AppErrorView(error: Exception('test')),
        ),
      ));
      // No overflow exception
      expect(tester.takeException(), isNull);
    });
  });

  group('AppErrorSliver', () {
    testWidgets('renders inside CustomScrollView without exception', (tester) async {
      var retried = false;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              AppErrorSliver(
                error: const NetworkException(),
                onRetry: () => retried = true,
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ElevatedButton), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(retried, isTrue);
    });
  });
}
