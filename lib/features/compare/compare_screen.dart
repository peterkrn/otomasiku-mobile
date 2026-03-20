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

    return Column(
      children: [
        // Product cards header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Product cards row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: products.map((product) => Expanded(
                  child: _buildProductCard(context, l10n, ref, product),
                )).toList(),
              ),
            ],
          ),
        ),
        // Comparison table
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 80),
                        ...products.map((p) => Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                      ],
                    ),
                  ),
                  // Specification rows
                  ...orderedKeys.map((key) => _buildSpecRow(key, products)),
                ],
              ),
            ),
          ),
        ),
        // Bottom padding
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    Product product,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Product image
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        _getCategoryIcon(product.category),
                        size: 32,
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
              const SizedBox(height: 4),
              // Brand
              Text(
                product.brand == ProductBrand.mitsubishi ? 'Mitsubishi' : 'Danfoss',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // Price
              Text(
                CurrencyFormatter.formatCompact(product.price),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mitsubishiRed,
                ),
              ),
              const SizedBox(height: 8),
              // Buy button
              SizedBox(
                width: double.infinity,
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          // Remove button
          Positioned(
            top: 0,
            right: 0,
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
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String specKey, List<Product> products) {
    // Find the best value to highlight
    String? bestValue;
    bool shouldHighlight = ['Power', 'Warranty'].contains(specKey);

    if (shouldHighlight) {
      int bestIdx = -1;
      double bestVal = -1;

      for (int i = 0; i < products.length; i++) {
        final val = products[i].specifications?[specKey];
        if (val != null) {
          // Extract numeric value
          final numMatch = RegExp(r'[\d.]+').firstMatch(val);
          if (numMatch != null) {
            final numVal = double.tryParse(numMatch.group(0) ?? '0') ?? 0;
            // For power, higher is better; for warranty, higher is better
            if (numVal > bestVal) {
              bestVal = numVal;
              bestIdx = i;
            }
          }
        }
      }

      if (bestIdx >= 0) {
        bestValue = products[bestIdx].specifications?[specKey];
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 80,
            child: Text(
              specKey,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Values
          ...products.map((product) {
            final value = product.specifications?[specKey] ?? '-';
            final isBest = shouldHighlight && value == bestValue;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: isBest
                      ? BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        )
                      : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                      color: isBest ? AppColors.success : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
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