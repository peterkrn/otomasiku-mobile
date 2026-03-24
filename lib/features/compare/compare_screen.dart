import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../data/dummy/dummy_products.dart';
import '../../models/product.dart';
import '../../providers/compare_provider.dart';

/// Compare screen showing side-by-side product comparison
/// Horizontal scroll with sticky first column for attribute names
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final compareState = ref.watch(compareProvider);

    // Get products from dummy data
    final products = compareState.productIds.map((id) {
      try {
        return dummyProducts.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }).whereType<Product>().toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.compareProducts),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: products.isEmpty
                ? null
                : () => _showClearAllDialog(context, ref),
            child: Text(
              l10n.clear,
              style: const TextStyle(
                color: AppColors.mitsubishiRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: products.isEmpty
          ? _buildEmptyState(context, l10n)
          : _buildCompareTable(context, l10n, ref, products),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.compare_arrows,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noProducts,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk untuk dibandingkan',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.goNamed(AppRoute.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.cartStartShopping),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareTable(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    List<Product> products,
  ) {
    // Get all unique specification keys from all products
    final specKeys = <String>{};
    for (final product in products) {
      if (product.specifications != null) {
        specKeys.addAll(product.specifications!.keys);
      }
    }

    // Define standard attributes order
    final orderedKeys = ['Power', 'Voltage', 'Warranty', ...specKeys.where((k) => !['Power', 'Voltage', 'Warranty'].contains(k))];

    // Calculate column width based on number of products
    final productColumnWidth = 140.0;
    final labelColumnWidth = 80.0;
    final totalWidth = labelColumnWidth + (products.length * productColumnWidth);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Product images row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Empty space for label column
                SizedBox(width: labelColumnWidth),
                // Product images
                ...products.map((product) => SizedBox(
                  width: productColumnWidth,
                  child: _buildProductHeader(context, l10n, ref, product),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Comparison table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: totalWidth,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Header row with product names
                  _buildHeaderRow(products, labelColumnWidth, productColumnWidth),
                  // Specification rows
                  ...orderedKeys.map((key) => _buildSpecRow(key, products, labelColumnWidth, productColumnWidth)),
                  // Buy buttons row
                  _buildBuyButtonRow(context, l10n, products, labelColumnWidth, productColumnWidth),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProductHeader(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    Product product,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            // Product image
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  product.primaryImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      _getCategoryIcon(product.category),
                      size: 40,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Product name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Price
            Text(
              CurrencyFormatter.formatCompact(product.price),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.mitsubishiRed,
              ),
            ),
          ],
        ),
        // Remove button
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () {
              ref.read(compareProvider.notifier).toggle(product.id);
              if (ref.read(compareProvider).productIds.isEmpty) {
                context.pop();
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(List<Product> products, double labelWidth, double columnWidth) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Label column
          SizedBox(
            width: labelWidth,
            child: Text(
              'SPESIFIKASI',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Product name columns
          ...products.map((product) => SizedBox(
            width: columnWidth,
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String specKey, List<Product> products, double labelWidth, double columnWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Label column
          SizedBox(
            width: labelWidth,
            child: Text(
              specKey,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Product value columns
          ...products.map((product) {
            final value = product.specifications?[specKey] ?? '-';
            return SizedBox(
              width: columnWidth,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBuyButtonRow(BuildContext context, AppLocalizations l10n, List<Product> products, double labelWidth, double columnWidth) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Empty label column
          SizedBox(width: labelWidth),
          // Buy buttons
          ...products.map((product) => SizedBox(
            width: columnWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => context.pushNamed(
                  AppRoute.productDetail,
                  pathParameters: {'id': product.id},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.buy,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    return switch (category) {
      ProductCategory.inverter => Icons.bolt,
      ProductCategory.plc => Icons.memory,
      ProductCategory.hmi => Icons.desktop_mac,
      ProductCategory.servo => Icons.settings,
    };
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).clear),
        content: const Text('Hapus semua produk dari perbandingan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(compareProvider.notifier).clear();
              Navigator.pop(ctx);
              AppToast.show(context, 'Perbandingan dikosongkan', isError: false);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mitsubishiRed,
            ),
            child: Text(AppLocalizations.of(context).confirm),
          ),
        ],
      ),
    );
  }
}