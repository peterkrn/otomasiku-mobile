import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/order.dart';
import '../../providers/payment_provider.dart';
import '../../shared/widgets/app_error_view.dart';
import 'widgets/bukti_transfer_card.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final int totalAmount;

  const PaymentScreen({super.key, required this.orderId, this.totalAmount = 0});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  void _copyAmount(AppLocalizations l10n, int amount) {
    Clipboard.setData(ClipboardData(text: amount.toString()));
    AppToast.show(context, l10n.paymentCopied, isError: false, bottomOffset: 160);
  }

  Future<void> _attemptLeavePayment() async {
    final l10n = AppLocalizations.of(context);
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.paymentLeaveTitle),
        content: Text(l10n.paymentLeaveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRoute.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(paymentProvider(widget.orderId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _attemptLeavePayment();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _attemptLeavePayment,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(l10n.payment),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          elevation: 0,
        ),
        body: orderAsync.when(
          data: (order) => _buildContent(order, l10n, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(paymentProvider(widget.orderId)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Order order, AppLocalizations l10n, bool isDark) {
    final displayTotal = order.totalAmount > 0 ? order.totalAmount : widget.totalAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOrderInfoCard(order, displayTotal, l10n, isDark),
          const SizedBox(height: 16),
          _buildQrisCard(displayTotal, l10n, isDark),
          const SizedBox(height: 16),
          BuktiTransferCard(
            order: order,
            isDark: isDark,
            onUploadSuccess: () {
              if (!mounted) return;
              context.goNamed(
                AppRoute.paymentPending,
                pathParameters: {'orderId': widget.orderId},
                queryParameters: {
                  'totalAmount': displayTotal.toString(),
                },
              );
            },
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(
    Order order,
    int displayTotal,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paymentQrisTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(l10n.orderNumber, order.orderNumber, isDark),
          const SizedBox(height: 12),
          _buildInfoRow(l10n.total, CurrencyFormatter.format(displayTotal), isDark,
              valueColor: AppColors.mitsubishiRed),
        ],
      ),
    );
  }

  Widget _buildQrisCard(int displayTotal, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            l10n.paymentScanQris,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/qris/qris_code.png',
              width: double.infinity,
              height: 320,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 48,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                    const SizedBox(height: 8),
                    Text('QRIS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.paymentQrisMerchant,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                CurrencyFormatter.format(displayTotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mitsubishiRed,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _copyAmount(l10n, displayTotal),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.mitsubishiRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.copy, size: 14, color: AppColors.mitsubishiRed),
                ),
              ),
            ],
          ),
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
}
