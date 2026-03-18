import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../l10n/app_localizations.dart';

/// Product Detail screen placeholder - to be implemented in M2-3
class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback for deep link (no previous route)
              context.goNamed(AppRoute.home);
            }
          },
        ),
        title: Text(l10n.productDetail),
      ),
      body: Center(
        child: Text('Product Detail: $productId'),
      ),
    );
  }
}
