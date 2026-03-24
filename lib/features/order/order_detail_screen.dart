import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../models/order.dart';
import '../../../data/dummy/dummy_orders.dart';

/// Order detail screen showing order status, items, and shipping info
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final order = _getOrder();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.orderDetail)),
        body: Center(child: Text(l10n.orderNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          onPressed: () => context.goNamed(AppRoute.orders),
        ),
        title: Column(
          children: [
            Text(l10n.orderDetail),
            Text(
              order.orderNumber,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _shareOrder(context, l10n),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            context.goNamed(AppRoute.orders);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusBanner(order, l10n),
              const SizedBox(height: 16),
              _buildTimelineSection(order, l10n, isDark),
              const SizedBox(height: 16),
              _buildItemsSection(order, l10n, isDark),
              const SizedBox(height: 16),
              _buildShippingInfoSection(order, l10n, isDark),
              const SizedBox(height: 16),
              _buildActionButtons(context, l10n, isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Order? _getOrder() {
    try {
      return dummyOrders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return dummyOrders.first;
    }
  }

  Widget _buildStatusBanner(Order order, AppLocalizations l10n) {
    final statusInfo = _getStatusInfo(order.status, l10n);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusInfo.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderStatus,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusInfo.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      statusInfo.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.estimatedDelivery(_getEstimatedDelivery(order)),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusInfo.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(Order order, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statusHistory,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            icon: Icons.check,
            label: l10n.paymentReceived,
            subtitle: _formatDate(order.createdAt),
            isCompleted: true,
            isFirst: true,
            isDark: isDark,
          ),
          _buildTimelineItem(
            icon: Icons.inventory_2,
            label: l10n.processing,
            subtitle: order.status == OrderStatus.processing ||
                order.status == OrderStatus.shipped ||
                order.status == OrderStatus.delivered
                ? _formatDate(order.createdAt.add(const Duration(hours: 2)))
                : l10n.processingSubtitle,
            isCompleted: order.status == OrderStatus.processing ||
                order.status == OrderStatus.shipped ||
                order.status == OrderStatus.delivered,
            isCurrent: order.status == OrderStatus.processing,
            isDark: isDark,
          ),
          _buildTimelineItem(
            icon: Icons.local_shipping,
            label: l10n.shipped,
            subtitle: order.status == OrderStatus.shipped ||
                order.status == OrderStatus.delivered
                ? _formatDate(order.createdAt.add(const Duration(days: 1)))
                : l10n.shippedSubtitle,
            isCompleted: order.status == OrderStatus.shipped ||
                order.status == OrderStatus.delivered,
            isCurrent: order.status == OrderStatus.shipped,
            isDark: isDark,
          ),
          _buildTimelineItem(
            icon: Icons.check_circle,
            label: l10n.delivered,
            subtitle: order.status == OrderStatus.delivered
                ? _formatDate(order.createdAt.add(const Duration(days: 3)))
                : '',
            isCompleted: order.status == OrderStatus.delivered,
            isCurrent: order.status == OrderStatus.delivered,
            isLast: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String subtitle,
    bool isCompleted = false,
    bool isCurrent = false,
    bool isFirst = false,
    bool isLast = false,
    bool isDark = false,
  }) {
    Color dotColor;
    if (isCurrent) {
      dotColor = AppColors.mitsubishiRed;
    } else if (isCompleted) {
      dotColor = AppColors.success;
    } else {
      dotColor = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? dotColor : (isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isCurrent
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                          : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(Order order, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderedItems,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildOrderItem(item, isDark)),
          Divider(height: 24, color: isDark ? AppColors.darkBorder : AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.total,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
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
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 56,
              height: 56,
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              child: Image.asset(
                item.productImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.inventory_2,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
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
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} unit × ${CurrencyFormatter.format(item.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(item.totalPrice),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoSection(Order order, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shippingInfo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shippingAddress,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${order.shippingAddressName}\n${order.shippingAddressFull}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.trackingNote,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => AppToast.show(context, l10n.comingSoon, isError: false),
            icon: const Icon(Icons.receipt_long),
            label: Text(l10n.downloadInvoice),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => AppToast.show(context, l10n.comingSoon, isError: false),
            icon: const Icon(Icons.headset_mic),
            label: Text(l10n.contactSupport),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _shareOrder(BuildContext context, AppLocalizations l10n) {
    AppToast.show(context, l10n.shareOrder, isError: false);
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _getEstimatedDelivery(Order order) {
    if (order.status == OrderStatus.delivered) {
      return 'Selesai';
    }
    final deliveryDate = order.createdAt.add(const Duration(days: 3));
    final deliveryDateEnd = order.createdAt.add(const Duration(days: 5));
    return '${deliveryDate.day}-${deliveryDateEnd.day} ${_getMonthName(deliveryDate.month)} ${deliveryDate.year}';
  }

  _StatusInfo _getStatusInfo(OrderStatus status, AppLocalizations l10n) {
    switch (status) {
      case OrderStatus.processing:
        return _StatusInfo(
          label: l10n.processing,
          icon: Icons.inventory_2,
          colors: [Colors.blue.shade500, Colors.blue.shade600],
        );
      case OrderStatus.shipped:
        return _StatusInfo(
          label: l10n.shipped,
          icon: Icons.local_shipping,
          colors: [Colors.orange.shade500, Colors.orange.shade600],
        );
      case OrderStatus.delivered:
        return _StatusInfo(
          label: l10n.delivered,
          icon: Icons.check_circle,
          colors: [AppColors.success, AppColors.success.withGreen(180)],
        );
      default:
        return _StatusInfo(
          label: l10n.processing,
          icon: Icons.inventory_2,
          colors: [Colors.blue.shade500, Colors.blue.shade600],
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final IconData icon;
  final List<Color> colors;

  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.colors,
  });
}