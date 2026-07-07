import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/order.dart';
import '../../providers/payment_provider.dart';
import 'payment_proof_state.dart';
import 'payment_total_resolver.dart';

class PaymentPendingScreen extends ConsumerStatefulWidget {
  final String orderId;
  final int totalAmount;

  const PaymentPendingScreen({
    super.key,
    required this.orderId,
    this.totalAmount = 0,
  });

  @override
  ConsumerState<PaymentPendingScreen> createState() =>
      _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends ConsumerState<PaymentPendingScreen> {
  Timer? _pollingTimer;

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.orders);
    }
  }

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    final notifier = ref.read(paymentProvider(widget.orderId).notifier);
    await notifier.refresh(widget.orderId);

    if (!mounted) return;

    final orderAsync = ref.read(paymentProvider(widget.orderId));
    orderAsync.whenData((order) {
      if (shouldStopPaymentPolling(order)) {
        _pollingTimer?.cancel();
        _handleTerminalState(order);
      }
    });
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(paymentProvider(widget.orderId).notifier);
    await notifier.refresh(widget.orderId);

    if (!mounted) return;

    final orderAsync = ref.read(paymentProvider(widget.orderId));
    orderAsync.whenData((order) {
      if (shouldStopPaymentPolling(order)) {
        _pollingTimer?.cancel();
        _handleTerminalState(order);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(paymentProvider(widget.orderId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: _handleBack,
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 0),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top,
                    size: 72,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 24),
                orderAsync.when(
                  data: (order) => Column(
                    children: [
                      _buildStatusCopy(order, l10n, isDark),
                      const SizedBox(height: 32),
                      _buildOrderInfoCard(
                        order,
                        resolvePaymentDisplayTotal(
                          order: order,
                          routedTotalAmount: widget.totalAmount,
                        ),
                        l10n,
                        isDark,
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Column(
                    children: [
                      _buildFallbackCopy(l10n, isDark),
                      const SizedBox(height: 32),
                      _buildOrderInfoCardSimple(
                        l10n,
                        widget.totalAmount,
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildActionButtons(
                  context,
                  l10n,
                  isDark,
                  orderAsync.valueOrNull,
                ),
              ],
            ),
          ),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(l10n.orderNumber, order.orderNumber, isDark),
          Divider(
            height: 24,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          _buildInfoRow(l10n.orderDate, _formatDate(order.createdAt), isDark),
          Divider(
            height: 24,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
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

  Widget _buildOrderInfoCardSimple(
    AppLocalizations l10n,
    int displayTotal,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(l10n.orderNumber, widget.orderId, isDark),
          Divider(
            height: 24,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          _buildInfoRow(l10n.orderDate, _formatDate(DateTime.now()), isDark),
          if (displayTotal > 0) ...[
            Divider(
              height: 24,
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
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

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  valueColor ??
                  (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    Order? order,
  ) {
    final viewState = order == null
        ? PaymentProofViewState.pendingReview
        : resolvePaymentProofViewState(order);
    final isRejected = viewState == PaymentProofViewState.rejected;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (isRejected) {
                context.goNamed(
                  AppRoute.payment,
                  pathParameters: {'orderId': widget.orderId},
                  queryParameters: {
                    'totalAmount': widget.totalAmount.toString(),
                  },
                );
                return;
              }
              context.goNamed(
                AppRoute.orderDetail,
                pathParameters: {'id': widget.orderId},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isRejected ? l10n.paymentReupload : l10n.paymentViewOrder,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.goNamed(AppRoute.home),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.paymentBackToShopping,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCopy(Order order, AppLocalizations l10n, bool isDark) {
    final viewState = resolvePaymentProofViewState(order);

    IconData icon;
    String title;
    String subtitle;

    switch (viewState) {
      case PaymentProofViewState.approved:
        icon = Icons.verified_rounded;
        title = l10n.paymentProofApproved;
        subtitle = l10n.paymentSuccess;
        break;
      case PaymentProofViewState.rejected:
        icon = Icons.error_outline_rounded;
        title = l10n.paymentReupload;
        subtitle = l10n.paymentProofRejectedReason(
          order.paymentProof?.rejectReason ?? '-',
        );
        break;
      case PaymentProofViewState.expired:
        icon = Icons.timer_off_outlined;
        title = l10n.paymentTimeExpired;
        subtitle = l10n.paymentExpiredStockReleased;
        break;
      case PaymentProofViewState.uploadRequired:
        icon = Icons.upload_file_outlined;
        title = l10n.paymentUploadProof;
        subtitle = l10n.paymentPendingDescription;
        break;
      case PaymentProofViewState.pendingReview:
        icon = Icons.hourglass_top;
        title = l10n.paymentPendingTitle;
        subtitle = l10n.paymentPendingSubtitle;
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Icon(icon, size: 24, color: AppColors.warning),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (viewState == PaymentProofViewState.pendingReview) ...[
          const SizedBox(height: 16),
          Text(
            l10n.paymentPendingDescription,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ] else if (viewState == PaymentProofViewState.expired) ...[
          const SizedBox(height: 16),
          Text(
            l10n.paymentExpiredCheckoutAgain,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackCopy(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        Text(
          l10n.paymentPendingTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.paymentPendingSubtitle,
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.paymentPendingDescription,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleTerminalState(Order order) {
    final l10n = AppLocalizations.of(context);
    final viewState = resolvePaymentProofViewState(order);

    if (viewState == PaymentProofViewState.approved) {
      AppToast.show(context, l10n.paymentSuccess, isError: false);
      context.goNamed(
        AppRoute.orderDetail,
        pathParameters: {'id': widget.orderId},
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }
}
