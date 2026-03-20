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
import '../../../providers/cart_provider.dart';
import '../../../providers/compare_provider.dart';
import 'stock_badge.dart';

/// Product card for home screen grid.
/// Matches HTML mockup: white card, rounded-2xl, border, shadow-sm.
/// Displays: stock badge, image, name, description, price, add-to-cart button.
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
    final cartQuantity = ref.watch(
      cartProvider.select((s) => s.getQuantityForProduct(widget.product.id)),
    );
    final isInCompare = ref.watch(
      compareProvider.select((s) => s.isInCompare(widget.product.id)),
    );

    // Calculate remaining stock after cart items
    final displayStock = widget.product.stock != null
        ? (widget.product.stock! - cartQuantity)
        : null;

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.productDetail,
        pathParameters: {'id': widget.product.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
            // Image area with badges
            Stack(
              children: [
                // Product image
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.asset(
                      widget.product.primaryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            _getCategoryIcon(widget.product.category),
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Stock badge (top-left) - shows remaining after cart
                Positioned(
                  top: 8,
                  left: 8,
                  child: StockBadge(
                    status: widget.product.stockStatus,
                    stockCount: displayStock,
                    leadTime: widget.product.stockLeadTime,
                  ),
                ),
                // Compare button (top-right)
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
                            ? AppColors.mitsubishiRed.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.balance,
                        size: 16,
                        color: isInCompare
                            ? AppColors.mitsubishiRed
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product info - compact layout
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (widget.product.description != null)
                    Text(
                      widget.product.description!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
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

            // Add to cart button with animation
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
                              return AppColors.surfaceVariant;
                            }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (isAdded) return Colors.white;
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.white;
                              }
                              return AppColors.textPrimary;
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
    setState(() {
      _isAdding = true;
    });

    ref
        .read(cartProvider.notifier)
        .addItem(
          CartItem(
            id: DateTime.now().toString(),
            product: widget.product,
            quantity: 1,
          ),
        );

    // Show toast
    AppToast.show(
      context,
      '${widget.product.name} ditambahkan ke keranjang',
      isError: false,
    );

    // Animate button
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
    final result = ref.read(compareProvider.notifier).toggle(widget.product.id);
    final l10n = AppLocalizations.of(context);

    if (!result) {
      // Max 3 products reached
      AppToast.show(context, l10n.compareMaxError, isError: true);
    }
  }

  IconData _getCategoryIcon(ProductCategory category) {
    return switch (category) {
      ProductCategory.inverter => Icons.bolt,
      ProductCategory.plc => Icons.memory,
      ProductCategory.hmi => Icons.desktop_mac,
      ProductCategory.servo => Icons.settings,
    };
  }
}
