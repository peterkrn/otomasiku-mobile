import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';

class CheckoutPaymentSummary extends StatefulWidget {
  final int totalItems;
  final int subtotal;
  final int discount;
  final int total;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;
  final bool isDark;

  const CheckoutPaymentSummary({
    super.key,
    required this.totalItems,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.isDark,
  });

  @override
  State<CheckoutPaymentSummary> createState() => _CheckoutPaymentSummaryState();
}

class _CheckoutPaymentSummaryState extends State<CheckoutPaymentSummary> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

    return Column(
      children: [
        _SummaryRow(
          label: l10n.subtotal,
          value: CurrencyFormatter.format(widget.subtotal),
          isDark: isDark,
        ),
        _SummaryRow(
          label: l10n.volumeDiscountLabel,
          value: widget.discount > 0
              ? '- ${CurrencyFormatter.format(widget.discount)}'
              : CurrencyFormatter.format(0),
          valueColor: widget.discount > 0 ? AppColors.success : null,
          isDark: isDark,
        ),
        _SummaryRow(
          label: l10n.shippingCost,
          value: l10n.freeShipping,
          valueColor: AppColors.success,
          isDark: isDark,
        ),
        Divider(
          height: 24,
          color: isDark ? AppColors.darkBorder : AppColors.divider,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalPayment,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              CurrencyFormatter.format(widget.total),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.mitsubishiRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: widget.termsAccepted,
                onChanged: (v) => widget.onTermsChanged(v ?? false),
                activeColor: AppColors.mitsubishiRed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => widget.onTermsChanged(!widget.termsAccepted),
                child: Text(
                  l10n.termsAgree,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ??
                  (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
