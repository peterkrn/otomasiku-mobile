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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: products.map((product) => _buildProductColumn(context, l10n, ref, product, orderedKeys)).toList(),
      ),
    );
  }

  Widget _buildProductColumn(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    Product product,
    List<String> specKeys,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product image with remove button
          Stack(
            children: [
              // Product image
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    product.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        _getCategoryIcon(product.category),
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              // Remove button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    ref.read(compareProvider.notifier).toggle(product.id);
                    if (ref.read(compareProvider).productIds.isEmpty) {
                      context.pop();
                    }
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Product info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Brand
                Text(
                  product.brand == ProductBrand.mitsubishi ? 'Mitsubishi' : 'Danfoss',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Price
                Text(
                  CurrencyFormatter.formatCompact(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mitsubishiRed,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Specifications
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: specKeys.map((key) {
                final value = product.specifications?[key] ?? '-';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Buy button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pushNamed(
                  AppRoute.productDetail,
                  pathParameters: {'id': product.id},
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.buy,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
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