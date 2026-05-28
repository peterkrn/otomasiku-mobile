import 'dart:async';
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

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final int totalAmount;

  const PaymentScreen({super.key, required this.orderId, this.totalAmount = 0});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Timer? _countdownTimer;
  bool _navigatedToSuccess = false;
  bool _atmExpanded = false;
  bool _mbankingExpanded = false;
  bool _klikbcaExpanded = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Duration _remaining(Order order) {
    if (order.vaExpiresAt == null) return Duration.zero;
    final diff = order.vaExpiresAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String _countdownDisplay(Duration remaining) {
    if (remaining == Duration.zero) return '00:00:00';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  void _copyVaNumber(AppLocalizations l10n, String vaNumber) {
    Clipboard.setData(ClipboardData(text: vaNumber.replaceAll(' ', '')));
    AppToast.show(context, l10n.vaCopied, isError: false, bottomOffset: 160);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(paymentPollingProvider(widget.orderId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(paymentPollingProvider(widget.orderId), (prev, next) {
      next.whenData((order) {
        if (order.paymentStatus == 'paid' && !_navigatedToSuccess && mounted) {
          _navigatedToSuccess = true;
          _countdownTimer?.cancel();
          final displayTotal = order.totalAmount > 0 ? order.totalAmount : widget.totalAmount;
          context.goNamed(
            AppRoute.paymentSuccess,
            pathParameters: {'orderId': widget.orderId},
            queryParameters: {'totalAmount': displayTotal.toString()},
          );
        }
      });
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed(AppRoute.home);
        }
      },
      child: Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.goNamed(AppRoute.home),
        ),
        title: Text(l10n.payment),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: orderAsync.when(
        data: (order) => _buildPaymentContent(order, l10n, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.mitsubishiRed),
              const SizedBox(height: 16),
              Text(l10n.errorGeneric),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(paymentPollingProvider(widget.orderId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: null,
    ),
    );
  }

  Widget _buildPaymentContent(Order order, AppLocalizations l10n, bool isDark) {
    final remaining = _remaining(order);
    final isExpired = remaining == Duration.zero && order.vaExpiresAt != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCountdownCard(order, remaining, isExpired, l10n),
          const SizedBox(height: 16),
          _buildVaCard(order, isExpired, l10n, isDark),
          const SizedBox(height: 16),
          _buildAmountCard(order, l10n, isDark),
          const SizedBox(height: 16),
          _buildInstructionsCard(l10n, isDark),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(paymentPollingProvider(widget.orderId).notifier).checkNow(widget.orderId),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.checkPaymentStatus),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mitsubishiRed,
                side: const BorderSide(color: AppColors.mitsubishiRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }

  Widget _buildOrderRef(Order order, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${l10n.orderNumber}:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            order.orderNumber,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(Order order, Duration remaining, bool isExpired, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [Colors.grey.shade600, Colors.grey.shade800]
              : [AppColors.bcaBlue, AppColors.bcaBlue.withBlue(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOrderRef(order, l10n),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExpired ? 'Waktu pembayaran habis' : l10n.paymentWaiting,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isExpired ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isExpired ? '-' : _countdownDisplay(remaining),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: isExpired ? 0.5 : 1),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.payBefore,
            style: TextStyle(
              color: Colors.white.withValues(alpha: isExpired ? 0.3 : 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.vaExpiresAt != null
                ? _formatDate(order.vaExpiresAt!)
                : '-',
            style: TextStyle(
              color: Colors.white.withValues(alpha: isExpired ? 0.3 : 1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaCard(Order order, bool isExpired, AppLocalizations l10n, bool isDark) {
    final vaNumber = order.vaNumber;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.vaNumberLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bcaBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BCA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (vaNumber != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vaNumber,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: isExpired
                          ? (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                ),
                if (!isExpired)
                  OutlinedButton.icon(
                    onPressed: () => _copyVaNumber(l10n, vaNumber),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(l10n.paymentCopy),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.bcaBlue,
                      side: const BorderSide(color: AppColors.bcaBlue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            )
          else
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sedang membuat nomor VA...',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(Order order, AppLocalizations l10n, bool isDark) {
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
            l10n.transferAmount,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(order.totalAmount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.mitsubishiRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.paymentHowTo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildExpandableInstruction(
                  icon: Icons.account_balance,
                  title: 'via ATM BCA',
                  expanded: _atmExpanded,
                  onTap: () => setState(() => _atmExpanded = !_atmExpanded),
                  steps: const [
                    'Masukkan kartu ATM dan PIN Anda',
                    'Pilih menu Transfer',
                    'Pilih Ke Rekening BCA Virtual Account',
                    'Masukkan nomor VA yang diberikan',
                    'Masukkan nominal sesuai tagihan lalu konfirmasi',
                  ],
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildExpandableInstruction(
                  icon: Icons.phone_android,
                  title: 'via BCA Mobile / myBCA',
                  expanded: _mbankingExpanded,
                  onTap: () => setState(() => _mbankingExpanded = !_mbankingExpanded),
                  steps: const [
                    'Buka aplikasi BCA Mobile atau myBCA',
                    'Login dengan PIN / biometrik',
                    'Pilih Transfer \u2192 BCA Virtual Account',
                    'Masukkan nomor VA yang diberikan',
                    'Cek detail dan konfirmasi pembayaran',
                  ],
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildExpandableInstruction(
                  icon: Icons.language,
                  title: 'via KlikBCA Internet Banking',
                  expanded: _klikbcaExpanded,
                  onTap: () => setState(() => _klikbcaExpanded = !_klikbcaExpanded),
                  steps: const [
                    'Login di klikbca.com',
                    'Pilih Transfer Dana \u2192 Transfer ke BCA Virtual Account',
                    'Masukkan nomor VA yang diberikan',
                    'Masukkan nominal dan konfirmasi dengan KeyBCA',
                  ],
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableInstruction({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required List<String> steps,
    required bool isDark,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.bcaBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}. ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}
