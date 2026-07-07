import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product.dart';
import '../../../models/cart_item.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/compare_provider.dart';
import '../../../shared/widgets/product_image.dart' as product_image;
import '../../../shared/widgets/product_price_not_set_dialog.dart';
import 'stock_badge.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
final isInCompare = ref.watch(
  compareProvider.select((s) => s.isInCompare(widget.product.idString)),
);

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.productDetail,
        pathParameters: {'id': widget.product.idString},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
child: product_image.ProductNetworkImage(
  imageUrl: widget.product.primaryImageUrl,
  categorySlug: widget.product.category.slug,
),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: StockBadge(
                    stock: widget.product.stock,
                    isOutOfStock: widget.product.isOutOfStock,
                    isLowStock: widget.product.isLowStock,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _handleCompare(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isInCompare
                            ? AppColors.mitsubishiRed.withValues(alpha: 0.2)
                            : (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.balance,
                        size: 16,
                        color: isInCompare
                            ? AppColors.mitsubishiRed
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textTertiary),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.product.category.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(widget.product.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mitsubishiRed,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    final isAdded = _buttonController.isCompleted;
                    return TextButton(
                      onPressed: _isAdding ? null : _handleAddToCart,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          if (isAdded) return Colors.green;
                          if (states.contains(WidgetState.hovered)) {
                            return AppColors.mitsubishiRed;
                          }
                          return isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                          if (isAdded) return Colors.white;
                          if (states.contains(WidgetState.hovered)) {
                            return Colors.white;
                          }
                          return isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
                        }),
                        overlayColor: WidgetStateProperty.all(
                          Colors.white.withValues(alpha: 0.1),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 6),
                        ),
                        minimumSize: WidgetStateProperty.all(const Size(0, 36)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isAdded) ...[
                            const Icon(Icons.add, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            isAdded ? l10n.added : l10n.addToCartShort,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart() {
    if (!ref.read(authProvider).isAuthenticated) {
      AppToast.show(
        context,
        AppLocalizations.of(context).notLoggedIn,
        isError: true,
      );
      return;
    }
    if (widget.product.price <= 0) {
      showProductPriceNotSetDialog(
        context: context,
        productName: widget.product.name,
        locale: Localizations.localeOf(context).languageCode,
      );
      return;
    }
    setState(() {
      _isAdding = true;
    });

    ref.read(cartProvider.notifier).addItem(
      widget.product.idString,
      1,
      snapshot: CartProductSnapshot(
        name: widget.product.name,
        price: widget.product.price,
        primaryImageUrl: widget.product.primaryImageUrl,
      ),
    );

    AppToast.show(
      context,
      AppLocalizations.of(context).addedToCart(widget.product.name),
      isError: false,
    );

    _buttonController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _buttonController.reverse();
          setState(() {
            _isAdding = false;
          });
        }
      });
    });
  }

  void _handleCompare() {
    final result = ref.read(compareProvider.notifier).toggle(widget.product.idString);
    final l10n = AppLocalizations.of(context);

    if (!result) {
      AppToast.show(context, l10n.compareMaxError, isError: true);
    }
  }
}
