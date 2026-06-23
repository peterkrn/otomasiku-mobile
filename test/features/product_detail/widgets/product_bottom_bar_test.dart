import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/features/product_detail/widgets/product_bottom_bar.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('product bottom bar hides the save-to-project action', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          bottomNavigationBar: ProductBottomBar(
            quantity: 1,
            displayStock: 10,
            isAddingToCart: false,
            onDecrement: () {},
            onIncrement: () {},
            onSaveToProject: () {},
            onAddToCart: () {},
            onBuyNow: () {},
            isDark: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_border), findsNothing);
  });
}
