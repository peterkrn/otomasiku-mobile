import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/features/shared/widgets/bottom_nav_bar.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('bottom navigation hides the project tab', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: Scaffold(bottomNavigationBar: BottomNavBar(currentIndex: 0)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Project'), findsNothing);
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
    expect(find.byIcon(Icons.folder), findsNothing);
  });
}
