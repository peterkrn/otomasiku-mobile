import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../l10n/app_localizations.dart';

/// Shows a modal explaining the product cannot be added to cart because its
/// price has not been set yet. Offers a CTA to message the admin on WhatsApp
/// with a pre-filled availability inquiry.
///
/// Returns `true` if the user tapped the WhatsApp CTA, `false` if dismissed.
Future<bool?> showProductPriceNotSetDialog({
  required BuildContext context,
  required String productName,
  String? locale,
}) {
  final l10n = AppLocalizations.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.mitsubishiRed,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.productPriceNotSetTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        l10n.productPriceNotSetBody,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.close),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(ctx).pop(true);
            WhatsAppHelper.openProductAvailabilityInquiry(
              productName,
              locale: locale ?? 'id',
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366), // WhatsApp brand green
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.chat_outlined, size: 18),
          label: Text(
            l10n.productPriceNotSetContactAdmin,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
