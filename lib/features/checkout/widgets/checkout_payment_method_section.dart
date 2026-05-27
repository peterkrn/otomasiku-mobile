import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class CheckoutPaymentMethodSection extends StatefulWidget {
  final bool isDark;

  const CheckoutPaymentMethodSection({super.key, required this.isDark});

  @override
  State<CheckoutPaymentMethodSection> createState() =>
      _CheckoutPaymentMethodSectionState();
}

class _CheckoutPaymentMethodSectionState
    extends State<CheckoutPaymentMethodSection> {
  bool _atmExpanded = false;
  bool _mbankingExpanded = false;
  bool _klikbcaExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = widget.isDark;

    return Column(
      children: [
        // BCA VA selector
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bcaBlue.withValues(alpha: 0.2)
                : const Color(0xFFE3F2FD),
            border: Border.all(color: AppColors.bcaBlue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bcaBlue, width: 4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bcaVirtualAccount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.bankTransfer,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bcaBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BCA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.paymentHowTo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _ExpandableInstruction(
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
        _ExpandableInstruction(
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
        _ExpandableInstruction(
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
      ],
    );
  }
}

class _ExpandableInstruction extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool expanded;
  final VoidCallback onTap;
  final List<String> steps;
  final bool isDark;

  const _ExpandableInstruction({
    required this.icon,
    required this.title,
    required this.expanded,
    required this.onTap,
    required this.steps,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
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
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
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
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
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
}
