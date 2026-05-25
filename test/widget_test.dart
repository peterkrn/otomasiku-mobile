// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:otomasiku_mobile/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OtomasikuApp()));
    await tester.pump(const Duration(seconds: 4));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
