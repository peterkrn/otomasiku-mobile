import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_error_widget.dart';

void main() {
  group('AppErrorWidget', () {
    testWidgets('builds without throwing in constrained box', (tester) async {
      final details = FlutterErrorDetails(exception: Exception('test error'));
      await tester.pumpWidget(MaterialApp(
        home: SizedBox(
          width: 300,
          height: 300,
          child: AppErrorWidget(details),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds without throwing in unconstrained context', (tester) async {
      final details = FlutterErrorDetails(exception: Exception('test'));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppErrorWidget(details),
        ),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows error icon', (tester) async {
      final details = FlutterErrorDetails(exception: Exception('any error'));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AppErrorWidget(details)),
      ));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows exception text in debug mode', (tester) async {
      // kDebugMode is true in test runs
      const message = 'specific error for test';
      final details = FlutterErrorDetails(exception: Exception(message));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AppErrorWidget(details)),
      ));
      if (kDebugMode) {
        expect(find.textContaining(message), findsOneWidget);
      }
    });

    testWidgets('shows localized errorGeneric message', (tester) async {
      final details = FlutterErrorDetails(exception: Exception('any'));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AppErrorWidget(details)),
      ));
      // AppLocalizations not injected → falls back to English hardcoded string
      expect(find.text('Something went wrong.'), findsOneWidget);
    });
  });
}
