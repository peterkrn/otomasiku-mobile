import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/address.dart';
import '../../models/order.dart';
import '../../providers/address_provider.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return orderAsync.when(
      data: (order) => _buildScreen(context, ref, l10n, order, isDark),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.orderDetail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.orderDetail)),
        body: Center(child: Text(l10n.orderNotFound)),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, WidgetRef ref, AppLocalizations l10n, Order order, bool isDark) {
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
              _buildStatusHistorySection(context, ref, l10n, order.id, isDark),
              const SizedBox(height: 16),
              _buildItemsSection(order, l10n, isDark),
              const SizedBox(height: 16),
              _buildShippingInfoSection(order, l10n, isDark, ref),
              const SizedBox(height: 16),
              _buildActionButtons(context, l10n, isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(Order order, AppLocalizations l10n) {
    final statusInfo = _getStatusInfo(order.status, l10n);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusInfo.gradientColors,
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

  Widget _buildStatusHistorySection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String orderId,
    bool isDark,
  ) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final historyAsync = ref.watch(orderStatusHistoryProvider(orderId));
    final currentStatus = orderAsync.valueOrNull?.status ?? '';

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
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return _buildStaticTimeline(currentStatus, l10n, isDark);
              }
              return Column(
                children: history.asMap().entries.map((entry) {
                  final isLast = entry.key == history.length - 1;
                  return _buildTimelineItem(
                    icon: Icons.check,
                    label: _getStatusLabel(entry.value.status, l10n),
                    subtitle: _formatDate(entry.value.changedAt),
                    isCompleted: true,
                    isLast: isLast,
                    isDark: isDark,
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _buildStaticTimeline(currentStatus, l10n, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticTimeline(String currentStatus, AppLocalizations l10n, bool isDark) {
    final statuses = ['pending', 'confirmed', 'processing', 'shipped', 'done'];
    final currentStatusIndex = statuses.indexOf(currentStatus);
    if (currentStatusIndex < 0) return const SizedBox.shrink();

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentStatusIndex;
        final isCurrent = index == currentStatusIndex;
        final isLast = index == statuses.length - 1;

        return _buildTimelineItem(
          icon: isCurrent ? Icons.circle : (isCompleted ? Icons.check : Icons.circle_outlined),
          label: _getStatusLabel(status, l10n),
          subtitle: '',
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLast: isLast,
          isDark: isDark,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String subtitle,
    bool isCompleted = false,
    bool isCurrent = false,
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
          ...?order.items?.map((item) => _buildOrderItem(item, isDark)),
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
                CurrencyFormatter.format(order.totalAmount),
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
              child: Icon(
                Icons.inventory_2,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
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
                  '${item.quantity} unit \u00d7 ${CurrencyFormatter.format(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(item.subtotal),
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

  Widget _buildShippingInfoSection(Order order, AppLocalizations l10n, bool isDark, WidgetRef ref) {
    Address? address;
    if (order.shippingAddress == null && order.addressId != null) {
      final addresses = ref.watch(addressListProvider).valueOrNull ?? [];
      try {
        address = addresses.firstWhere((a) => a.id == order.addressId);
      } catch (_) {}
    }

    final orderAddr = order.shippingAddress;
    final String recipient;
    final String street;
    final String cityLine;
    final String phone;

    if (orderAddr != null) {
      recipient = orderAddr.recipient;
      street = orderAddr.street;
      cityLine = '${orderAddr.city}, ${orderAddr.province} ${orderAddr.postalCode}';
      phone = orderAddr.phone;
    } else if (address != null) {
      recipient = address.recipient;
      street = address.street;
      cityLine = '${address.city}, ${address.province} ${address.postalCode}';
      phone = address.phone;
    } else {
      recipient = '';
      street = '';
      cityLine = '';
      phone = '';
    }

    final hasAddress = recipient.isNotEmpty;

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
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 20, color: AppColors.mitsubishiRed),
              const SizedBox(width: 8),
              Text(
                l10n.shippingInfo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasAddress) ...[
            _buildShippingRow(
              Icons.person_outline,
              recipient,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildShippingRow(
              Icons.location_on_outlined,
              '$street\n$cityLine',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildShippingRow(
              Icons.phone_outlined,
              phone,
              isDark,
            ),
          ] else
            Text(
              '-',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.divider),
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

  Widget _buildShippingRow(IconData icon, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.mitsubishiRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.mitsubishiRed),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
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
    if (order.status == 'done') {
      return 'Selesai';
    }
    final deliveryDate = order.createdAt.add(const Duration(days: 3));
    final deliveryDateEnd = order.createdAt.add(const Duration(days: 5));
    return '${deliveryDate.day}-${deliveryDateEnd.day} ${_getMonthName(deliveryDate.month)} ${deliveryDate.year}';
  }

  _StatusInfo _getStatusInfo(String status, AppLocalizations l10n) {
    switch (status) {
      case 'processing':
        return _StatusInfo(
          label: l10n.processing,
          icon: Icons.inventory_2,
          gradientColors: [Colors.blue.shade500, Colors.blue.shade600],
        );
      case 'shipped':
        return _StatusInfo(
          label: l10n.shipped,
          icon: Icons.local_shipping,
          gradientColors: [Colors.orange.shade500, Colors.orange.shade600],
        );
      case 'done':
        return _StatusInfo(
          label: l10n.delivered,
          icon: Icons.check_circle,
          gradientColors: [AppColors.success, AppColors.success.withGreen(180)],
        );
      default:
        return _StatusInfo(
          label: l10n.processing,
          icon: Icons.inventory_2,
          gradientColors: [Colors.blue.shade500, Colors.blue.shade600],
        );
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return l10n.paymentWaiting;
      case 'confirmed':
        return l10n.processing;
      case 'processing':
        return l10n.processing;
      case 'shipped':
        return l10n.shipped;
      case 'done':
        return l10n.delivered;
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}

class _StatusInfo {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;

  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.gradientColors,
  });
}
