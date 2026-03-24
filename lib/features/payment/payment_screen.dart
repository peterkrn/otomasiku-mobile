import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_toast.dart';

/// Payment screen showing VA number, countdown timer, and instructions
/// Uses dummy timer for M2 - will be replaced with BCA Sandbox in next phase
class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Timer? _countdownTimer;
  int _remainingSeconds = 24 * 60 * 60; // 24 hours dummy countdown
  final String _vaNumber = '8277 0812 3456 7890'; // Dummy VA
  final int _amount = 19813000; // Dummy amount

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
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _countdownDisplay {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  void _copyVaNumber(AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: _vaNumber.replaceAll(' ', '')));
    AppToast.show(context, l10n.vaCopied, isError: false, bottomOffset: 160);
  }

  void _copyAmount(AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: _amount.toString()));
    AppToast.show(context, 'Jumlah berhasil disalin', isError: false, bottomOffset: 160);
  }

  void _checkStatus() {
    // For M2, simulate payment success
    context.goNamed(
      AppRoute.paymentSuccess,
      pathParameters: {'orderId': widget.orderId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.payment),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCountdownCard(l10n),
            const SizedBox(height: 16),
            _buildVaCard(l10n, isDark),
            const SizedBox(height: 16),
            _buildAmountCard(l10n, isDark),
            const SizedBox(height: 16),
            _buildInstructionsCard(l10n, isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(l10n, isDark),
    );
  }

  Widget _buildCountdownCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bcaBlue, AppColors.bcaBlue.withBlue(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.paymentWaiting,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _countdownDisplay,
                  style: const TextStyle(
                    color: Colors.white,
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
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getExpiryDate(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaCard(AppLocalizations l10n, bool isDark) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _vaNumber,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyVaNumber(l10n),
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.paymentCopy),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.bcaBlue,
                  side: const BorderSide(color: AppColors.bcaBlue),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(AppLocalizations l10n, bool isDark) {
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
                l10n.transferAmount,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () => _copyAmount(l10n),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mitsubishiRed.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy,
                        size: 12,
                        color: AppColors.mitsubishiRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.paymentCopy,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.mitsubishiRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(_amount),
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
          // Expandable payment methods
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
                    'Pilih Transfer → BCA Virtual Account',
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
                    'Pilih Transfer Dana → Transfer ke BCA Virtual Account',
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
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
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

  Widget _buildBottomBar(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bcaBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.paymentCheckStatus,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getExpiryDate() {
    final expiry = DateTime.now().add(const Duration(hours: 24));
    return '${expiry.day} ${_getMonthName(expiry.month)} ${expiry.year}, 23:59 WIB';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}