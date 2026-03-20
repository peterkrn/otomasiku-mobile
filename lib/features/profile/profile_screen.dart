import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../data/dummy/dummy_orders.dart';
import '../../models/order.dart';

/// Profile screen showing user info, stats, and menu options
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Calculate order stats
    final totalOrders = dummyOrders.length;
    final completedOrders = dummyOrders.where((o) => o.status == OrderStatus.delivered).length;
    final processingOrders = dummyOrders.where((o) =>
      o.status == OrderStatus.processing || o.status == OrderStatus.shipped).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Settings placeholder
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User card
            _buildUserCard(l10n),
            const SizedBox(height: 16),

            // Stats grid
            _buildStatsGrid(l10n, totalOrders, completedOrders, processingOrders),
            const SizedBox(height: 16),

            // Menu list
            _buildMenuList(context, l10n),
            const SizedBox(height: 24),

            // Logout button
            _buildLogoutButton(context, l10n, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(AppLocalizations l10n) {
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: ClipOval(
              child: Container(
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'johndoe@otomasiku.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    AppLocalizations l10n,
    int totalOrders,
    int completedOrders,
    int processingOrders,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '$totalOrders',
            l10n.orders,
            AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '$completedOrders',
            l10n.delivered,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '$processingOrders',
            l10n.processing,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.assignment,
            iconColor: Colors.blue,
            title: l10n.myOrders,
            subtitle: l10n.orderHistory,
            onTap: () => context.pushNamed(AppRoute.orders),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.location_on,
            iconColor: AppColors.mitsubishiRed,
            title: l10n.addressBook,
            subtitle: '2 alamat tersimpan',
            onTap: () => context.pushNamed(AppRoute.shipping),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.credit_card,
            iconColor: AppColors.success,
            title: l10n.paymentMethods,
            subtitle: l10n.bcaVirtualAccount,
            onTap: () => context.pushNamed(AppRoute.paymentMethods),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.headset_mic,
            iconColor: Colors.purple,
            title: l10n.helpCenter,
            subtitle: 'Hubungi tim teknis',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
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
                color: iconColor.withValues(alpha: 0.1),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 68, endIndent: 16);
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context, l10n, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mitsubishiRed,
          side: BorderSide(color: const Color(0xFFE7192D).withValues(alpha: 0.3)),
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
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(ctx);
              context.goNamed(AppRoute.splash);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mitsubishiRed,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}