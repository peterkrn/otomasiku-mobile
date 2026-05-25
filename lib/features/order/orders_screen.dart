import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/dummy/dummy_orders.dart';
import '../../../models/order.dart';

/// Orders list screen showing all user orders with filter tabs
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _currentFilter = 'all';

  List<Order> _getFilteredOrders() {
    switch (_currentFilter) {
      case 'process':
        return dummyOrders
            .where((o) =>
                o.status == OrderStatus.processing ||
                o.status == OrderStatus.shipped)
            .toList();
      case 'selesai':
        return dummyOrders.where((o) => o.status == OrderStatus.delivered).toList();
      default:
        return dummyOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          onPressed: () => context.goNamed(AppRoute.profile),
        ),
        title: Text(l10n.myOrders),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
            child: Row(
              children: [
                _buildTab('all', 'Semua', isDark),
                _buildTab('process', 'Diproses', isDark),
                _buildTab('selesai', 'Selesai', isDark),
              ],
            ),
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            context.goNamed(AppRoute.profile);
          }
        },
        child: _buildOrderList(l10n, isDark),
      ),
    );
  }

  Widget _buildTab(String filter, String label, bool isDark) {
    final isActive = _currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.mitsubishiRed : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.mitsubishiRed : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(AppLocalizations l10n, bool isDark) {
    final orders = _getFilteredOrders();

    if (orders.isEmpty) {
      return _buildEmptyState(l10n, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(context, l10n, orders[index], isDark),
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 36,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noOrders,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.goNamed(AppRoute.home),
            child: Text(
              l10n.cartStartShopping,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mitsubishiRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    AppLocalizations l10n,
    Order order,
    bool isDark,
  ) {
    final isProcessing = order.status == OrderStatus.processing ||
        order.status == OrderStatus.shipped;

    final totalQty = order.items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ========== HEADER ==========
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFF9FAFB))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isProcessing
                        ? (isDark ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFFFFF7ED))
                        : (isDark ? AppColors.success.withValues(alpha: 0.2) : const Color(0xFFF0FDF4)),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isProcessing ? Icons.access_time : Icons.check,
                    color: isProcessing ? const Color(0xFFEA580C) : const Color(0xFF16A34A),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextTertiary : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isProcessing
                        ? (isDark ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFFFFF7ED))
                        : (isDark ? AppColors.success.withValues(alpha: 0.2) : const Color(0xFFF0FDF4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isProcessing ? 'Diproses' : 'Selesai',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isProcessing ? const Color(0xFFEA580C) : const Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ========== ITEMS - SELALU 2 BARIS DENGAN TINGGI TETAP ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Baris 1 - SELALU ADA
                SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.items.isNotEmpty
                              ? '${order.items[0].productName}  ×${order.items[0].quantity}'
                              : '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Text(
                        order.items.isNotEmpty
                            ? CurrencyFormatter.format(order.items[0].totalPrice)
                            : '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Baris 2 - SELALU ADA
                SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.items.length > 1
                              ? '${order.items[1].productName}  ×${order.items[1].quantity}'
                              : '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Text(
                        order.items.length > 1
                            ? CurrencyFormatter.format(order.items[1].totalPrice)
                            : '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ========== FOOTER ==========
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalQty item · Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextTertiary : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(order.total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mitsubishiRed,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isProcessing)
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF16A34A)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '✓ Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                if (isProcessing) const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.pushNamed(AppRoute.orderDetail, pathParameters: {'id': order.id}),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}