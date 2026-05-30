import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  final String orderId;
  final int totalAmount;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    this.totalAmount = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              context.goNamed(AppRoute.orders);
            }
          },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            onPressed: () => context.goNamed(AppRoute.orders),
          ),
          backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.paymentSuccessTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.paymentSuccessSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                orderAsync.when(
                  data: (order) => _buildOrderInfoCard(
                    context, l10n, order,
                    // Use API total if non-zero, else use totalAmount passed from checkout
                    order.totalAmount > 0 ? order.totalAmount : totalAmount,
                    isDark,
                  ),
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => _buildOrderInfoCardSimple(l10n, totalAmount, isDark),
                ),
                const Spacer(),
                _buildActionButtons(context, l10n, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context, AppLocalizations l10n, Order order, int displayTotal, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(l10n.orderNumber, order.orderNumber, isDark),
          Divider(height: 24, color: isDark ? AppColors.darkBorder : AppColors.border),
          _buildInfoRow(l10n.orderDate, _formatDate(order.createdAt), isDark),
          Divider(height: 24, color: isDark ? AppColors.darkBorder : AppColors.border),
          _buildInfoRow(
            l10n.total,
            CurrencyFormatter.format(displayTotal),
            isDark,
            valueColor: AppColors.mitsubishiRed,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCardSimple(AppLocalizations l10n, int displayTotal, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(l10n.orderNumber, orderId, isDark),
          Divider(height: 24, color: isDark ? AppColors.darkBorder : AppColors.border),
          _buildInfoRow(l10n.orderDate, _formatDate(DateTime.now()), isDark),
          if (displayTotal > 0) ...[
            Divider(height: 24, color: isDark ? AppColors.darkBorder : AppColors.border),
            _buildInfoRow(
              l10n.total,
              CurrencyFormatter.format(displayTotal),
              isDark,
              valueColor: AppColors.mitsubishiRed,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.goNamed(AppRoute.home),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
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

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}
