import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';

/// Payment Methods Screen showing saved payment methods and instructions
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final String _vaNumber = EnvConfig.bcaVaNumber;
  bool _atmExpanded = false;
  bool _mbankingExpanded = false;
  bool _klikbcaExpanded = false;

  List<String> get _supportContacts {
    final contacts = <String>[];
    if (EnvConfig.hasSupportWhatsapp) {
      contacts.add('WhatsApp: ${EnvConfig.supportWhatsappDisplay}');
    }
    final supportEmail = EnvConfig.supportEmail.trim();
    if (supportEmail.isNotEmpty) {
      contacts.add('Email: $supportEmail');
    }
    return contacts;
  }

  void _copyVaNumber() {
    Clipboard.setData(ClipboardData(text: _vaNumber.replaceAll(' ', '')));
    final l10n = AppLocalizations.of(context);
    AppToast.show(context, l10n.vaCopied, isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoute.home);
            }
          },
        ),
        title: Text(l10n.paymentMethods),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVaCard(l10n, isDark),
            const SizedBox(height: 16),
            _buildInfoBox(l10n, isDark),
            const SizedBox(height: 16),
            _buildSupportCard(l10n, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildVaCard(AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Header with BCA branding
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bcaBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'BCA',
                      style: TextStyle(
                        color: AppColors.bcaBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        l10n.paymentVaTransferFrom,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Utama',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // VA Number section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vaNumberLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.bcaBlue.withValues(alpha: 0.15)
                        : AppColors.bcaBlue.withValues(alpha: 0.05),
                    border: Border.all(
                      color: isDark
                          ? AppColors.bcaBlue.withValues(alpha: 0.4)
                          : AppColors.bcaBlue.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _vaNumber,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _copyVaNumber,
                        icon: const Icon(Icons.copy, size: 14),
                        label: Text(l10n.paymentCopy),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bcaBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Account details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  l10n.paymentAccountHolder,
                  EnvConfig.bcaAccountName,
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(l10n.paymentType, l10n.virtualAccount, isDark),
                const SizedBox(height: 8),
                _buildDetailRow('Bank', 'BCA', isDark),
              ],
            ),
          ),

          // Payment instructions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.paymentHowTo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildExpandableInstruction(
                  icon: Icons.account_balance,
                  title: l10n.paymentViaAtm,
                  expanded: _atmExpanded,
                  onTap: () => setState(() => _atmExpanded = !_atmExpanded),
                  steps: [
                    l10n.atmStep1,
                    l10n.atmStep2,
                    l10n.atmStep3,
                    l10n.atmStep4,
                  ],
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildExpandableInstruction(
                  icon: Icons.phone_android,
                  title: l10n.paymentViaMBanking,
                  expanded: _mbankingExpanded,
                  onTap: () =>
                      setState(() => _mbankingExpanded = !_mbankingExpanded),
                  steps: [
                    l10n.mbankingStep1,
                    l10n.mbankingStep2,
                    l10n.mbankingStep3,
                    l10n.mbankingStep4,
                  ],
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildExpandableInstruction(
                  icon: Icons.language,
                  title: l10n.paymentViaInternetBanking,
                  expanded: _klikbcaExpanded,
                  onTap: () =>
                      setState(() => _klikbcaExpanded = !_klikbcaExpanded),
                  steps: [
                    l10n.ibankingStep1,
                    l10n.ibankingStep2,
                    l10n.ibankingStep3,
                    l10n.ibankingStep4,
                  ],
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableInstruction({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required List<String> steps,
    bool isDark = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildInfoBox(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bcaBlue.withValues(alpha: 0.15)
            : AppColors.bcaBlue.withValues(alpha: 0.05),
        border: Border.all(
          color: isDark
              ? AppColors.bcaBlue.withValues(alpha: 0.4)
              : AppColors.bcaBlue.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.bcaBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.paymentAutoVerify,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.blue.shade300 : AppColors.bcaBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(AppLocalizations l10n, bool isDark) {
    final supportContacts = _supportContacts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.headset_mic, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.supportNeedHelp,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  supportContacts.isEmpty
                      ? l10n.supportContactPhone
                      : supportContacts.join('\n'),
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
          ElevatedButton.icon(
            onPressed: EnvConfig.hasSupportWhatsapp
                ? () async {
                    AppToast.show(
                      context,
                      l10n.openingWhatsApp,
                      isError: false,
                    );
                    await WhatsAppHelper.openRfq();
                  }
                : null,
            icon: const Icon(Icons.chat, size: 14),
            label: Text(l10n.chat),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
