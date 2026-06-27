import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product.dart';

class TieredPricingWidget extends StatelessWidget {
  final Product product;
  final int quantity;
  final ValueChanged<int> onTierSelected;
  final VoidCallback onRfqTap;
  final bool isDark;

  const TieredPricingWidget({
    super.key,
    required this.product,
    required this.quantity,
    required this.onTierSelected,
    required this.onRfqTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tierPrice1 = product.price;
    final tierPrice2 = product.hasDiscount
        ? product.price
        : (product.price * 92) ~/ 100;
    final savings = tierPrice1 - tierPrice2;

    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tieredPricing,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onTierSelected(1),
            child: _PriceTierRow(
              range: '1 - 5 Unit',
              subtitle: l10n.priceNormal,
              price: tierPrice1,
              isSelected: quantity >= 1 && quantity <= 5,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onTierSelected(6),
            child: _PriceTierRow(
              range: '6 - 10 Unit',
              subtitle: l10n.volumeDiscount(CurrencyFormatter.format(savings)),
              price: tierPrice2,
              isBestDeal: true,
              isSelected: quantity >= 6 && quantity <= 10,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '11+ Unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.contactSales,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onRfqTap,
                  child: Text(
                    l10n.rfq,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTierRow extends StatelessWidget {
  final String range;
  final String subtitle;
  final int price;
  final bool isBestDeal;
  final bool isSelected;
  final bool isDark;

  const _PriceTierRow({
    required this.range,
    required this.subtitle,
    required this.price,
    this.isBestDeal = false,
    this.isSelected = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBestDeal
            ? (isDark
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.green.shade50)
            : (isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.surfaceVariant),
        border: Border.all(
          color: isSelected
              ? AppColors.mitsubishiRed
              : (isBestDeal
                  ? (isDark
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.green.shade200)
                  : Colors.transparent),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        range,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isBestDeal
                              ? Colors.green.shade800
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isBestDeal
                              ? Colors.green.shade600
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBestDeal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Best Deal',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            CurrencyFormatter.format(price),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isBestDeal
                  ? Colors.green.shade700
                  : AppColors.mitsubishiRed,
            ),
          ),
        ],
      ),
    );
  }
}
