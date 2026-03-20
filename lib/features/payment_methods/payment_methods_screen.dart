import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';

/// Payment Methods Screen showing saved payment methods and instructions
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final String _vaNumber = '1234 5678 9012 3456';
  bool _atmExpanded = false;
  bool _mbankingExpanded = false;
  bool _klikbcaExpanded = false;

  void _copyVaNumber() {
    Clipboard.setData(ClipboardData(text: _vaNumber.replaceAll(' ', '')));
    AppToast.show(context, 'Nomor VA berhasil disalin!', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.paymentMethods),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVaCard(l10n),
            const SizedBox(height: 16),
            _buildInfoBox(l10n),
            const SizedBox(height: 16),
            _buildSupportCard(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildVaCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                      const Text(
                        'Virtual Account BCA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Transfer dari rekening BCA mana saja',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  'Nomor Virtual Account',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bcaBlue.withValues(alpha: 0.05),
                    border: Border.all(
                      color: AppColors.bcaBlue.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _vaNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _copyVaNumber,
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('Salin'),
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
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow('Atas Nama', 'PT Otomasiku Indonesia'),
                const SizedBox(height: 8),
                _buildDetailRow('Jenis', 'Virtual Account'),
                const SizedBox(height: 8),
                _buildDetailRow('Bank', 'BCA'),
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
                  'Cara Pembayaran',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildExpandableInstruction(
                  icon: Icons.account_balance,
                  title: 'via ATM BCA',
                  expanded: _atmExpanded,
                  onTap: () => setState(() => _atmExpanded = !_atmExpanded),
                  steps: const [
                    'Masukkan kartu ATM dan PIN Anda',
                    'Pilih menu Transfer',
                    'Pilih Ke Rekening BCA Virtual Account',
                    'Masukkan nomor VA: 1234567890123456',
                    'Masukkan nominal sesuai tagihan lalu konfirmasi',
                  ],
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
                    'Masukkan nomor VA: 1234567890123456',
                    'Cek detail dan konfirmasi pembayaran',
                  ],
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
                    'Masukkan nomor VA: 1234567890123456',
                    'Masukkan nominal dan konfirmasi dengan KeyBCA',
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.bcaBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary,
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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

  Widget _buildInfoBox(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bcaBlue.withValues(alpha: 0.05),
        border: Border.all(
          color: AppColors.bcaBlue.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.bcaBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pembayaran akan diverifikasi otomatis. Pastikan nominal yang ditransfer sesuai dengan total tagihan agar pesanan dapat diproses.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.bcaBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.headset_mic,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Butuh bantuan?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hubungi tim kami di 021-1234-5678',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              AppToast.show(context, 'Membuka WhatsApp...', isError: false);
            },
            icon: const Icon(Icons.chat, size: 14),
            label: const Text('Chat'),
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