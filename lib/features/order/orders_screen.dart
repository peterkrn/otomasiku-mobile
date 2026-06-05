import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../l10n/app_localizations.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../shared/widgets/app_error_view.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _scrollController = ScrollController();
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(orderListProvider.notifier).loadMore();
    }
  }

  List<Order> _getFilteredOrders(List<Order> allOrders) {
    switch (_currentFilter) {
      case 'process':
        return allOrders
            .where((o) => o.status == 'processing' || o.status == 'shipped')
            .toList();
      case 'selesai':
        return allOrders.where((o) => o.status == 'done').toList();
      default:
        return allOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(orderListProvider);
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
        child: ordersAsync.when(
          data: (orders) => _buildOrderList(l10n, orders, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.read(orderListProvider.notifier).refresh(),
          ),
        ),
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

  Widget _buildOrderList(AppLocalizations l10n, List<Order> allOrders, bool isDark) {
    final orders = _getFilteredOrders(allOrders);

    if (orders.isEmpty) {
      return _buildEmptyState(l10n, isDark);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(orderListProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderCard(context, l10n, orders[index], isDark),
          );
        },
      ),
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
    final statusInfo = _getStatusInfo(order.status, l10n);
    final totalQty = order.items?.fold(0, (sum, item) => sum + item.quantity) ?? 0;
    final isProcessing = order.status == 'processing' || order.status == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                    color: statusInfo.bgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
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
                    color: statusInfo.bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusInfo.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: (order.items ?? []).take(2).toList().asMap().entries.map((entry) {
                final item = entry.value;
                return SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName}  \u00d7${item.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.subtotal),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalQty item \u00b7 Total',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextTertiary : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(order.totalAmount),
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
                      '\u2713 Selesai',
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

  _StatusInfo _getStatusInfo(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return _StatusInfo(
          label: l10n.paymentWaiting,
          icon: Icons.access_time,
          color: const Color(0xFFEA580C),
          bgColor: const Color(0xFFFFF7ED),
        );
      case 'processing':
      case 'confirmed':
        return _StatusInfo(
          label: l10n.processing,
          icon: Icons.inventory_2,
          color: Colors.blue,
          bgColor: Colors.blue.withValues(alpha: 0.1),
        );
      case 'shipped':
        return _StatusInfo(
          label: l10n.shipped,
          icon: Icons.local_shipping,
          color: Colors.purple,
          bgColor: Colors.purple.withValues(alpha: 0.1),
        );
      case 'done':
        return _StatusInfo(
          label: l10n.delivered,
          icon: Icons.check_circle,
          color: const Color(0xFF16A34A),
          bgColor: const Color(0xFFF0FDF4),
        );
      case 'cancelled':
        return _StatusInfo(
          label: l10n.cancelled,
          icon: Icons.cancel,
          color: AppColors.mitsubishiRed,
          bgColor: AppColors.mitsubishiRed.withValues(alpha: 0.1),
        );
      default:
        return _StatusInfo(
          label: l10n.processing,
          icon: Icons.inventory_2,
          color: Colors.blue,
          bgColor: Colors.blue.withValues(alpha: 0.1),
        );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _StatusInfo {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
