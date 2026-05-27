import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';

class ProductBottomBar extends StatelessWidget {
  final int quantity;
  final int displayStock;
  final int? selectedTierMin;
  final bool isAddingToCart;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onSaveToProject;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool isDark;

  const ProductBottomBar({
    super.key,
    required this.quantity,
    required this.displayStock,
    this.selectedTierMin,
    required this.isAddingToCart,
    required this.onDecrement,
    required this.onIncrement,
    required this.onSaveToProject,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity stepper
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final minQty = selectedTierMin ?? 1;
                      if (quantity > minQty) {
                        onDecrement();
                      } else if (quantity == minQty && minQty > 1) {
                        AppToast.show(
                          context,
                          l10n.minQuantityTier(minQty),
                          isError: true,
                          bottomOffset: 100,
                        );
                      }
                    },
                    icon: Icon(Icons.remove,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 48),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: quantity < displayStock ? onIncrement : null,
                    icon: Icon(Icons.add,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 48),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Save to project
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: onSaveToProject,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.zero,
                ),
                child: Icon(Icons.bookmark_border,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            // Add to cart
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: isAddingToCart ? null : onAddToCart,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isAddingToCart
                        ? Colors.green
                        : AppColors.mitsubishiRed,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.zero,
                ),
                child: Icon(
                  isAddingToCart
                      ? Icons.check
                      : Icons.shopping_cart_outlined,
                  size: 20,
                  color: isAddingToCart ? Colors.green : AppColors.mitsubishiRed,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Buy now
            Expanded(
              child: ElevatedButton(
                onPressed: onBuyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.buy,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
