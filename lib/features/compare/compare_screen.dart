import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../providers/compare_provider.dart';
import '../../providers/product_provider.dart';
import '../../shared/widgets/product_image.dart' as product_image;

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final compareState = ref.watch(compareProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final productsAsync = ref.watch(productListProvider);
    final products = productsAsync.valueOrNull ?? [];
    final compareProducts = products
        .where((p) => compareState.productIds.contains(p.idString))
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoute.home);
            }
          },
        ),
        title: Text(l10n.compareProducts),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: compareProducts.isEmpty
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
      body: productsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : compareProducts.isEmpty
              ? _buildEmptyState(context, l10n, isDark)
              : _buildCompareTable(context, l10n, ref, compareProducts, isDark),
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
            l10n.compareEmptyHint,
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
    const tableBorderWidth = 1.0;
    const labelColumnWidth = 80.0;
    const productColumnWidth = 140.0;
    final showAddColumn = products.isNotEmpty;

    final totalColumns = products.length + (showAddColumn ? 1 : 0);
    final contentWidth = labelColumnWidth + totalColumns * productColumnWidth;
    final tableWidth = contentWidth + (tableBorderWidth * 2);

    final attributeKeys = ['series', 'variant', 'unit', 'minOrder', 'stock', 'price'];

    return SingleChildScrollView(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: contentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductRow(
                    context,
                    l10n,
                    ref,
                    products,
                    labelColumnWidth,
                    productColumnWidth,
                    isDark,
                    showAddColumn,
                  ),
                  ...attributeKeys.map(
                    (key) => _buildAttributeRow(
                      key,
                      l10n,
                      products,
                      labelColumnWidth,
                      productColumnWidth,
                      isDark,
                      showAddColumn,
                    ),
                  ),
                  _buildBuyButtonRow(
                    context,
                    l10n,
                    products,
                    labelColumnWidth,
                    productColumnWidth,
                    isDark,
                    showAddColumn,
                  ),
                ],
              ),
            ),
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
          Container(
            width: labelWidth,
            height: 270,
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FAFB),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                l10n.compareSpecProduct,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          ...products.map((product) => SizedBox(
            width: columnWidth,
            height: 270,
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
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: product_image.ProductNetworkImage(
                            imageUrl: product.primaryImageUrl,
                            categorySlug: product.category.slug,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                      Text(
                        product.brand.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCompact(product.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mitsubishiRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStockBadge(product, l10n, isDark),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(compareProvider.notifier).toggle(product.idString);
                        if (ref.read(compareProvider).productIds.isEmpty) {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.goNamed(AppRoute.home);
                          }
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
          if (showAddColumn)
            Container(
              width: columnWidth,
              height: 270,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.goNamed(AppRoute.home),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
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
                      const SizedBox(height: 10),
                      Text(
                        l10n.compareAddProduct,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(Product product, AppLocalizations l10n, bool isDark) {
    String text;
    Color bgColor;
    Color textColor;

    if (product.isOutOfStock) {
      text = l10n.stockEmpty;
      bgColor = isDark ? AppColors.mitsubishiRed.withValues(alpha: 0.2) : const Color(0xFFFEE2E2);
      textColor = AppColors.mitsubishiRed;
    } else if (product.isLowStock) {
      text = l10n.stockLow(product.stock);
      bgColor = isDark ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFFFEF3C7);
      textColor = isDark ? Colors.orange.shade300 : const Color(0xFFD97706);
    } else {
      text = l10n.stockUnit(product.stock);
      bgColor = isDark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
      textColor = isDark ? Colors.green.shade300 : const Color(0xFF16A34A);
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

  Widget _buildAttributeRow(
    String attributeKey,
    AppLocalizations l10n,
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
          Container(
            width: labelWidth,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FAFB),
            child: Text(
              _getLabelForKey(l10n, attributeKey),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          ...products.map((product) {
            final value = _getAttributeValue(product, attributeKey);
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
          SizedBox(
            width: labelWidth,
            height: 68,
          ),
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
                pathParameters: {'id': product.idString},
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
          if (showAddColumn)
            SizedBox(
              width: columnWidth,
              height: 68,
            ),
        ],
      ),
    );
  }

  String _getLabelForKey(AppLocalizations l10n, String key) {
    switch (key) {
      case 'series':
        return l10n.compareSpecSeries;
      case 'variant':
        return l10n.compareSpecVariant;
      case 'unit':
        return l10n.compareSpecUnit;
      case 'minOrder':
        return l10n.compareSpecMinOrder;
      case 'stock':
        return l10n.compareSpecStock;
      case 'price':
        return l10n.compareSpecPrice;
      default:
        return key.toUpperCase();
    }
  }

  String _getAttributeValue(Product product, String key) {
    switch (key) {
      case 'series':
        return product.series ?? '-';
      case 'variant':
        return product.variant ?? '-';
      case 'unit':
        return product.unit;
      case 'minOrder':
        return '${product.minOrder}';
      case 'stock':
        return '${product.stock}';
      case 'price':
        return CurrencyFormatter.formatCompact(product.price);
      default:
        return '-';
    }
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).clear),
        content: Text(AppLocalizations.of(context).clearCompareConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(compareProvider.notifier).clear();
              Navigator.pop(ctx);
              AppToast.show(context, AppLocalizations.of(context).compareCleared, isError: false);
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
