import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

/// Screen for permanent account deletion
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _isConfirmed = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          title: Text(l10n.deleteAccount),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.deleteAccountWarning,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.redAccent : Colors.red,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // What happens section
              Text(
                l10n.whatHappensWhenYouDelete,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              _buildDataSection(
                icon: Icons.delete_forever,
                iconColor: Colors.red,
                title: l10n.dataDeletedImmediately,
                items: [
                  l10n.dataDeletedProfile,
                  l10n.dataDeletedAddresses,
                  l10n.dataDeletedPaymentMethods,
                  l10n.dataDeletedCart,
                  l10n.dataDeletedProjectFavorites,
                ],
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildDataSection(
                icon: Icons.schedule_outlined,
                iconColor: Colors.orange,
                title: l10n.dataRetainedTemporarily,
                items: [
                  l10n.dataRetainedOrders,
                  l10n.dataRetainedTransactions,
                  l10n.dataRetainedPeriod,
                ],
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildDataSection(
                icon: Icons.archive_outlined,
                iconColor: Colors.blue,
                title: l10n.dataRetainedPermanently,
                items: [
                  l10n.dataRetainedOrdersPermanent,
                  l10n.dataRetainedTransactionsPermanent,
                  l10n.dataRetainedAnonymizedStats,
                  l10n.dataRetainedPeriodPermanent,
                ],
                isDark: isDark,
              ),
              const SizedBox(height: 32),

              // Confirmation checkbox
              CheckboxListTile(
                value: _isConfirmed,
                onChanged: _isDeleting
                    ? null
                    : (val) {
                        setState(() => _isConfirmed = val ?? false);
                      },
                title: Text(
                  l10n.confirmDeleteAccount,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                activeColor: AppColors.mitsubishiRed,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConfirmed && !_isDeleting ? _deleteAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.deleteMyAccountPermanently,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Support contact
              Center(
                child: Text(
                  l10n.deleteAccountSupport,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 16, color: iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (!_isConfirmed) return;

    setState(() => _isDeleting = true);

    final success = await ref.read(authProvider.notifier).deleteAccount();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).accountDeletedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate to splash screen
        context.goNamed(AppRoute.splash);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorDeleteAccount),
            backgroundColor: AppColors.mitsubishiRed,
          ),
        );
        setState(() => _isDeleting = false);
      }
    }
  }
}
