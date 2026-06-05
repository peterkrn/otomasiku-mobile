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
  });
}
