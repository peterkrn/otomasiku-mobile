import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(orderListProvider);
    final addressesAsync = ref.watch(addressListProvider);

    final orders = ordersAsync.valueOrNull ?? [];
    final totalOrders = orders.length;
    final completedOrders =
        orders.where((o) => isCompletedOrderStatus(o.status)).length;
    final processingOrders =
        orders.where((o) => isFulfillmentOrderStatus(o.status)).length;

    final addressCount = addressesAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoute.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserCard(l10n, ref),
            const SizedBox(height: 16),
            _buildStatsGrid(context, l10n, totalOrders, completedOrders, processingOrders),
            const SizedBox(height: 16),
            _buildMenuList(context, l10n, addressCount, ref),
            const SizedBox(height: 24),
            _buildLogoutButton(context, l10n, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(AppLocalizations l10n, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;

    final displayName = profile?.fullName ?? authState.name ?? 'User';
    final displayEmail = profile?.email ?? authState.email ?? '';
    final avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surfaceVariant,
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (profile?.companyName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile!.companyName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AppLocalizations l10n,
    int totalOrders,
    int completedOrders,
    int processingOrders,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '$totalOrders',
            l10n.orders,
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '$completedOrders',
            l10n.delivered,
            AppColors.success,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '$processingOrders',
            l10n.processing,
            Colors.orange,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color valueColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AppLocalizations l10n, int addressCount, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.assignment,
            iconColor: Colors.blue,
            title: l10n.myOrders,
            subtitle: l10n.orderHistory,
            onTap: () => context.pushNamed(AppRoute.orders),
          ),
          _buildDivider(context),
          _buildMenuItem(
            context,
            icon: Icons.location_on,
            iconColor: AppColors.mitsubishiRed,
            title: l10n.addressBook,
            subtitle: addressCount > 0
                ? '$addressCount alamat tersimpan'
                : l10n.noAddressSaved,
            onTap: () => context.pushNamed(AppRoute.shipping),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: isDark ? AppColors.darkBorder : AppColors.border,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context, l10n, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mitsubishiRed,
          side: BorderSide(
            color: AppColors.mitsubishiRed.withValues(alpha: isDark ? 0.4 : 0.3),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 18),
            const SizedBox(width: 8),
            Text(l10n.logout),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _LogoutDialog(l10n: l10n, ref: ref),
    );
  }
}

class _LogoutDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _LogoutDialog({required this.l10n, required this.ref});

  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.logout),
      content: _isLoading
          ? const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Sedang keluar...'),
              ],
            )
          : Text(widget.l10n.logoutConfirm),
      actions: _isLoading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(widget.l10n.cancel),
              ),
              TextButton(
                onPressed: _handleLogout,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mitsubishiRed,
                ),
                child: Text(widget.l10n.confirm),
              ),
            ],
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    await widget.ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pop(context);
    context.goNamed(AppRoute.splash);
  }
}
