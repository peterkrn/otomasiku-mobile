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
/// Single table with sticky first column for attribute names
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final compareState = ref.watch(compareProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get products from dummy data
    final products = compareState.productIds.map((id) {
      try {
        return dummyProducts.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }).whereType<Product>().toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.compareProducts),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
          ? _buildEmptyState(context, l10n, isDark)
          : OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.topLeft,
              child: ClipRect(
                child: _buildCompareTable(context, l10n, ref, products, isDark),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 64,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noProducts,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk untuk dibandingkan',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
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
    bool isDark,
  ) {
    // Get all unique specification keys from all products
    final specKeys = <String>{};
    for (final product in products) {
      if (product.specifications != null) {
        specKeys.addAll(product.specifications!.keys);
      }
    }

    // Column widths
    const labelColumnWidth = 80.0;
    const productColumnWidth = 140.0;

    // Only show "Add product" column if less than 2 products
    final showAddColumn = products.length < 2;
    final totalColumns = products.length + (showAddColumn ? 1 : 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: ClipRect(
        child: Container(
          width: labelColumnWidth + totalColumns * productColumnWidth + 2,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: PRODUK header + product images
            _buildProductRow(context, l10n, ref, products, labelColumnWidth, productColumnWidth, isDark, showAddColumn),
            // Specification rows
            ...specKeys.map((key) => _buildSpecRow(key, products, labelColumnWidth, productColumnWidth, isDark, showAddColumn)),
            // Buy buttons row
            _buildBuyButtonRow(context, l10n, products, labelColumnWidth, productColumnWidth, isDark, showAddColumn),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildProductRow(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    List<Product> products,
    double labelWidth,
    double columnWidth,
    bool isDark,
    bool showAddColumn,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label column - "PRODUK"
          Container(
            width: labelWidth,
            height: 250,
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FAFB),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'PRODUK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          // Product columns
          ...products.map((product) => SizedBox(
            width: columnWidth,
            height: 250,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            product.primaryImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                _getCategoryIcon(product.category),
                                size: 32,
                                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Product name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Brand
                      Text(
                        _brandToString(product.brand),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Price
                      Text(
                        CurrencyFormatter.formatCompact(product.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mitsubishiRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Stock badge
                      _buildStockBadge(product, isDark),
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
                          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
          // Add product column (only if less than 2 products)
          if (showAddColumn)
            Container(
              width: columnWidth,
              height: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.goNamed(AppRoute.home),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(Product product, bool isDark) {
    String text;
    Color bgColor;
    Color textColor;

    switch (product.stockStatus) {
      case StockStatus.inStock:
        text = '${product.stock ?? 0} unit';
        bgColor = isDark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
        textColor = isDark ? Colors.green.shade300 : const Color(0xFF16A34A);
        break;
      case StockStatus.lowStock:
        text = 'Stok ${product.stock}';
        bgColor = isDark ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFFFEF3C7);
        textColor = isDark ? Colors.orange.shade300 : const Color(0xFFD97706);
        break;
      case StockStatus.outOfStock:
        text = 'Habis';
        bgColor = isDark ? AppColors.mitsubishiRed.withValues(alpha: 0.2) : const Color(0xFFFEE2E2);
        textColor = AppColors.mitsubishiRed;
        break;
      case StockStatus.leadTime:
        text = 'Indent';
        bgColor = isDark ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFFFED7AA);
        textColor = isDark ? Colors.orange.shade300 : const Color(0xFFEA580C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSpecRow(
    String specKey,
    List<Product> products,
    double labelWidth,
    double columnWidth,
    bool isDark,
    bool showAddColumn,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label column
          Container(
            width: labelWidth,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FAFB),
            child: Text(
              _getLabelForKey(specKey),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          // Product value columns
          ...products.map((product) {
            final value = product.specifications?[specKey] ?? '-';
            return Container(
              width: columnWidth,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            );
          }),
          // Empty column for "add product" (only if less than 2 products)
          if (showAddColumn)
            Container(
              width: columnWidth,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Text(
                '-',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBuyButtonRow(
    BuildContext context,
    AppLocalizations l10n,
    List<Product> products,
    double labelWidth,
    double columnWidth,
    bool isDark,
    bool showAddColumn,
  ) {
    return Container(
      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FAFB),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty label column
          SizedBox(
            width: labelWidth,
            height: 68,
          ),
          // Buy buttons
          ...products.map((product) => Container(
            width: columnWidth,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
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
          )),
          // Empty column for "add product" (only if less than 2 products)
          if (showAddColumn)
            SizedBox(
              width: columnWidth,
              height: 68,
            ),
        ],
      ),
    );
  }

  String _getLabelForKey(String key) {
    const labels = {
      'Power': 'DAYA',
      'Voltage': 'TEGANGAN',
      'Warranty': 'GARANSI',
      'Phase': 'FASE',
      'Current': 'ARUS',
      'Frequency': 'FREKUENSI',
    };
    return labels[key] ?? key.toUpperCase();
  }

  IconData _getCategoryIcon(ProductCategory category) {
    return switch (category) {
      ProductCategory.inverter => Icons.bolt,
      ProductCategory.plc => Icons.memory,
      ProductCategory.hmi => Icons.desktop_mac,
      ProductCategory.servo => Icons.settings,
    };
  }

  String _brandToString(ProductBrand brand) {
    return switch (brand) {
      ProductBrand.mitsubishi => 'Mitsubishi',
      ProductBrand.danfoss => 'Danfoss',
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