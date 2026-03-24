import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/cart_item.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../data/dummy/dummy_addresses.dart';

/// Checkout screen showing order summary, shipping, payment
/// Accessible from Cart screen via "Lanjut ke Checkout" button
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _poController = TextEditingController();
  bool _termsAccepted = false;
  bool _atmExpanded = false;
  bool _mbankingExpanded = false;
  bool _klikbcaExpanded = false;

  @override
  void dispose() {
    _poController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartItems = ref.watch(selectedCartItemsListProvider);
    final subtotal = cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    final totalItems = cartItems.fold(0, (sum, item) => sum + item.quantity);
    final defaultAddress = dummyAddresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => dummyAddresses.first,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate discount (simplified for M2)
    final discount = _calculateDiscount(cartItems);
    final afterDiscount = subtotal - discount;
    final tax = (afterDiscount * 0.11).round();
    final total = afterDiscount + tax;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.checkout),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(l10n, isDark)
          : _buildCheckoutContent(
              context,
              l10n,
              cartItems,
              totalItems,
              subtotal,
              discount,
              tax,
              total,
              defaultAddress,
              isDark,
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : _buildBottomBar(context, l10n, total, isDark),
    );
  }

  Widget _buildEmptyCart(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyCart,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.goNamed(AppRoute.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.cartStartShopping),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutContent(
    BuildContext context,
    AppLocalizations l10n,
    List<CartItem> cartItems,
    int totalItems,
    int subtotal,
    int discount,
    int tax,
    int total,
    defaultAddress,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Section
          _buildSectionCard(
            context,
            title: l10n.orderSummary,
            trailing: l10n.itemCount(cartItems.length),
            isDark: isDark,
            child: Column(
              children: cartItems.asMap().entries
                  .map((entry) => _buildCheckoutItem(
                        context,
                        l10n,
                        entry.value,
                        entry.key,
                        cartItems.length,
                        isDark,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Shipping Address Section
          _buildSectionCard(
            context,
            title: l10n.shippingAddress,
            trailing: l10n.edit,
            isDark: isDark,
            onTrailingTap: () => context.pushNamed(AppRoute.shipping),
            child: _buildAddressCard(defaultAddress, l10n, isDark),
          ),
          const SizedBox(height: 12),

          // Payment Method Section
          _buildSectionCard(
            context,
            title: l10n.paymentMethod,
            isDark: isDark,
            child: _buildPaymentMethod(l10n, isDark),
          ),
          const SizedBox(height: 12),

          // Shipping Section
          _buildSectionCard(
            context,
            title: l10n.shipping,
            isDark: isDark,
            child: _buildShippingOption(l10n, isDark),
          ),
          const SizedBox(height: 12),

          // Payment Summary Section
          _buildSectionCard(
            context,
            title: l10n.paymentSummary,
            isDark: isDark,
            child: _buildPaymentSummary(
              l10n,
              totalItems,
              subtotal,
              discount,
              tax,
              total,
              isDark,
            ),
          ),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    String? trailing,
    VoidCallback? onTrailingTap,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              if (trailing != null)
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Text(
                    trailing,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mitsubishiRed,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckoutItem(
    BuildContext context,
    AppLocalizations l10n,
    CartItem item,
    int index,
    int totalItems,
    bool isDark,
  ) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.divider,
            width: index < totalItems - 1 ? 1 : 0,
          ),
        ),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              child: Image.asset(
                product.primaryImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  _getCategoryIcon(product.category),
                  size: 28,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(product.id),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.description ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity display (read-only in checkout)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mitsubishiRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(dynamic address, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.location_on,
              color: AppColors.mitsubishiRed,
              size: 20,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    address.fullName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bcaBlue.withValues(alpha: 0.2) : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      address.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.bcaBlue : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${address.company}\n${address.address}\n${address.city}, ${address.postalCode}\n${address.phone}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              // PO Number input
              Text(
                l10n.companyPO,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _poController,
                style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.poPlaceholder,
                  hintStyle: TextStyle(color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.mitsubishiRed),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        // BCA VA selected
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bcaBlue.withValues(alpha: 0.2) : const Color(0xFFE3F2FD),
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
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.bankTransfer,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        // Payment instructions header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.paymentHowTo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
        // Expandable payment methods
        _buildExpandableInstruction(
          icon: Icons.account_balance,
          title: 'via ATM BCA',
          expanded: _atmExpanded,
          onTap: () => setState(() => _atmExpanded = !_atmExpanded),
          steps: [
            'Masukkan kartu ATM dan PIN Anda',
            'Pilih menu Transfer',
            'Pilih Ke Rekening BCA Virtual Account',
            'Masukkan nomor VA yang diberikan',
            'Masukkan nominal sesuai tagihan lalu konfirmasi',
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildExpandableInstruction(
          icon: Icons.phone_android,
          title: 'via BCA Mobile / myBCA',
          expanded: _mbankingExpanded,
          onTap: () => setState(() => _mbankingExpanded = !_mbankingExpanded),
          steps: [
            'Buka aplikasi BCA Mobile atau myBCA',
            'Login dengan PIN / biometrik',
            'Pilih Transfer → BCA Virtual Account',
            'Masukkan nomor VA yang diberikan',
            'Cek detail dan konfirmasi pembayaran',
          ],
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildExpandableInstruction(
          icon: Icons.language,
          title: 'via KlikBCA Internet Banking',
          expanded: _klikbcaExpanded,
          onTap: () => setState(() => _klikbcaExpanded = !_klikbcaExpanded),
          steps: [
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

  Widget _buildExpandableInstruction({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required List<String> steps,
    required bool isDark,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
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
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
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
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}. ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

  Widget _buildShippingOption(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mitsubishiRed.withValues(alpha: 0.15) : AppColors.mitsubishiRed.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.mitsubishiRed, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mitsubishiRed, width: 4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.standardShipping,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  l10n.shippingEstimate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            l10n.freeShipping,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(
    AppLocalizations l10n,
    int totalItems,
    int subtotal,
    int discount,
    int tax,
    int total,
    bool isDark,
  ) {
    return Column(
      children: [
        _buildSummaryRow(
          l10n.subtotal,
          CurrencyFormatter.format(subtotal),
          isDark,
        ),
        _buildSummaryRow(
          l10n.volumeDiscountLabel,
          discount > 0 ? '- ${CurrencyFormatter.format(discount)}' : CurrencyFormatter.format(0),
          isDark,
          valueColor: discount > 0 ? AppColors.success : null,
        ),
        _buildSummaryRow(
          l10n.shippingCost,
          l10n.freeShipping,
          isDark,
          valueColor: AppColors.success,
        ),
        _buildSummaryRow(
          l10n.taxLabel,
          CurrencyFormatter.format(tax),
          isDark,
        ),
        Divider(height: 24, color: isDark ? AppColors.darkBorder : AppColors.divider),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.totalPayment,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              CurrencyFormatter.format(total),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.mitsubishiRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Terms checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() => _termsAccepted = value ?? false);
                },
                activeColor: AppColors.mitsubishiRed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _termsAccepted = !_termsAccepted);
                },
                child: Text(
                  l10n.termsAgree,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n, int total, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mitsubishiRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _createInvoice(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.createInvoiceAndPay,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.receipt_long, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(String productId) {
    ref.read(cartProvider.notifier).removeItem(productId);
    // Also remove from selection
    final selectedIds = ref.read(selectedCartItemsProvider);
    final newSelected = Set<String>.from(selectedIds)..remove(productId);
    ref.read(selectedCartItemsProvider.notifier).state = newSelected;
  }

  int _calculateDiscount(List<CartItem> items) {
    int totalDiscount = 0;
    for (final item in items) {
      if (item.product.hasDiscount && item.product.originalPrice != null) {
        totalDiscount += (item.product.originalPrice! - item.product.price) * item.quantity;
      }
    }
    return totalDiscount;
  }

  void _createInvoice(AppLocalizations l10n) {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAcceptTerms),
          backgroundColor: AppColors.mitsubishiRed,
        ),
      );
      return;
    }

    // For M2, just navigate to payment placeholder
    context.pushNamed(AppRoute.payment, pathParameters: {'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch}'});
  }

  IconData _getCategoryIcon(ProductCategory category) {
    return switch (category) {
      ProductCategory.inverter => Icons.bolt,
      ProductCategory.plc => Icons.memory,
      ProductCategory.hmi => Icons.desktop_mac,
      ProductCategory.servo => Icons.settings,
    };
  }
}