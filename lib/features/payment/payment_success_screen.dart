import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';

/// Payment success screen shown after successful payment
class PaymentSuccessScreen extends ConsumerWidget {
  final String orderId;

  const PaymentSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                l10n.paymentSuccessTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                l10n.paymentSuccessSubtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Order info card
              _buildOrderInfoCard(context, l10n),
              const Spacer(),
              // Action buttons
              _buildActionButtons(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            l10n.orderNumber,
            orderId,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            l10n.orderDate,
            _getCurrentDate(),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            l10n.total,
            CurrencyFormatter.format(19813000),
            valueColor: AppColors.mitsubishiRed,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // View Order button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.goNamed(
              AppRoute.orderDetail,
              pathParameters: {'id': orderId},
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.viewOrder,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Back to Home button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.goNamed(AppRoute.home),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.backToHome,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day} ${_getMonthName(now.month)} ${now.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}