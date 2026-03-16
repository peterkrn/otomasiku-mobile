// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:otomasiku_mobile/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: OtomasikuApp()));

    // Verify that the app renders (placeholder screens)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
