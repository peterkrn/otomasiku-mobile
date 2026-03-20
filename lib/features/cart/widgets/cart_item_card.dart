import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/cart_item.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Cart item card with product image, name, quantity controls, and remove button
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final product = item.product;
    final hasDiscount = product.hasDiscount;
    final discountAmount = hasDiscount && product.originalPrice != null
        ? (product.originalPrice! - product.price) * item.quantity
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.surfaceVariant,
              child: Image.asset(
                product.primaryImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  _getCategoryIcon(product.category.name),
                  size: 32,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and remove button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Remove button
                    GestureDetector(
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Description (category + series)
                Text(
                  '${_getCategoryLabel(product.category.name, l10n)} ${product.series}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Quantity controls and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Quantity controls
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Minus button
                          GestureDetector(
                            onTap: () {
                              if (item.quantity > 1) {
                                onQuantityChanged(item.quantity - 1);
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: const Text(
                                '−',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          // Quantity
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Plus button
                          GestureDetector(
                            onTap: () => onQuantityChanged(item.quantity + 1),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: const Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price and discount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(item.totalPrice),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mitsubishiRed,
                          ),
                        ),
                        if (discountAmount > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.volumeDiscount(CurrencyFormatter.format(discountAmount)),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'inverter':
        return Icons.bolt;
      case 'plc':
        return Icons.memory;
      case 'hmi':
        return Icons.touch_app;
      case 'servo':
        return Icons.settings;
      default:
        return Icons.devices;
    }
  }

  String _getCategoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'inverter':
        return l10n.inverter;
      case 'plc':
        return l10n.plc;
      case 'hmi':
        return l10n.hmi;
      case 'servo':
        return l10n.servo;
      default:
        return '';
    }
  }
}