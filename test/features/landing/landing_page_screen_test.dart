import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/constants/branding.dart';
import 'package:otomasiku_mobile/features/landing/landing_page_screen.dart';
import 'package:otomasiku_mobile/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LandingPageScreen renders brand and survives intro animations on narrow phones', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: TestApp(
          child: LandingPageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text(otomasikuAppTitle), findsWidgets);
    expect(find.text(otomasikuMarketplaceTagline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LandingPageScreen updates visible copy when language toggle is tapped', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            return TestApp(
              locale: ref.watch(localeProvider),
              child: const LandingPageScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Lihat Katalog'), findsOneWidget);
    expect(find.text('Pemasok tepercaya untuk kebutuhan otomasi industri'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('View Catalog'), findsOneWidget);
    expect(find.text('A trusted supplier for industrial automation needs'), findsOneWidget);
    expect(find.text('Lihat Katalog'), findsNothing);
    expect(find.text('Pemasok tepercaya untuk kebutuhan otomasi industri'), findsNothing);
  });

  testWidgets('LandingPageScreen CTA buttons are large enough on narrow phones', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: TestApp(
          locale: Locale('id'),
          child: LandingPageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
    final catalogButton = find.widgetWithText(OutlinedButton, 'Lihat Katalog');

    expect(tester.getSize(loginButton).height, greaterThanOrEqualTo(58));
    expect(tester.getSize(catalogButton).height, greaterThanOrEqualTo(58));
  });
}
