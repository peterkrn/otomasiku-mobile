import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../models/address.dart';
import '../../../models/cart_item.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../../shared/widgets/product_image.dart' as product_image;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _notesController = TextEditingController();
  bool _termsAccepted = false;
  bool _atmExpanded = false;
  bool _mbankingExpanded = false;
  bool _klikbcaExpanded = false;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await ref.read(addressRepositoryProvider).getAddresses();
      final defaultAddr = addresses.where((a) => a.isDefault).isNotEmpty
          ? addresses.firstWhere((a) => a.isDefault)
          : addresses.firstOrNull;
      if (defaultAddr != null && mounted) {
        setState(() => _selectedAddressId = defaultAddr.id);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartItems = ref.watch(selectedCartItemsListProvider);
    final subtotal = cartItems.fold(0, (sum, item) => sum + item.productSnapshot.price * item.quantity);
    final totalItems = cartItems.fold(0, (sum, item) => sum + item.quantity);
    final createOrderState = ref.watch(createOrderStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              context, l10n, cartItems, totalItems, subtotal,
              discount, tax, total, createOrderState, isDark,
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : _buildBottomBar(context, l10n, total, createOrderState.isLoading, isDark),
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
    CreateOrderState createOrderState,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context,
            title: l10n.orderSummary,
            trailing: l10n.itemCount(cartItems.length),
            isDark: isDark,
            child: Column(
              children: cartItems.asMap().entries
                  .map((entry) => _buildCheckoutItem(
                        context, l10n, entry.value, entry.key, cartItems.length, isDark))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            context,
            title: l10n.shippingAddress,
            trailing: l10n.edit,
            isDark: isDark,
            onTrailingTap: () async {
              final result = await context.pushNamed(AppRoute.shipping);
              if (result != null && mounted) {
                setState(() => _selectedAddressId = result as String?);
              }
            },
            child: _AddressSelector(
              selectedAddressId: _selectedAddressId,
              onAddressSelected: (id) => setState(() => _selectedAddressId = id),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            context,
            title: l10n.paymentMethod,
            isDark: isDark,
            child: _buildPaymentMethod(l10n, isDark),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            context,
            title: l10n.shipping,
            isDark: isDark,
            child: _buildShippingOption(l10n, isDark),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            context,
            title: l10n.paymentSummary,
            isDark: isDark,
            child: _buildPaymentSummary(
              l10n, totalItems, subtotal, discount, tax, total, isDark,
            ),
          ),
          const SizedBox(height: 100),
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
    final snapshot = item.productSnapshot;
    final totalPrice = snapshot.price * item.quantity;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              child: product_image.ProductNetworkImage(
                imageUrl: snapshot.primaryImageUrl,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        snapshot.name,
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
                      onTap: () => _removeItem(item.id),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      CurrencyFormatter.format(totalPrice),
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

  Widget _buildPaymentMethod(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
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
            'Pilih Transfer \u2192 BCA Virtual Account',
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
            'Pilih Transfer Dana \u2192 Transfer ke BCA Virtual Account',
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
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
        _buildSummaryRow(l10n.subtotal, CurrencyFormatter.format(subtotal), isDark),
        _buildSummaryRow(
          l10n.volumeDiscountLabel,
          discount > 0 ? '- ${CurrencyFormatter.format(discount)}' : CurrencyFormatter.format(0),
          isDark,
          valueColor: discount > 0 ? AppColors.success : null,
        ),
        _buildSummaryRow(l10n.shippingCost, l10n.freeShipping, isDark, valueColor: AppColors.success),
        _buildSummaryRow(l10n.taxLabel, CurrencyFormatter.format(tax), isDark),
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

  Widget _buildBottomBar(
    BuildContext context,
    AppLocalizations l10n,
    int total,
    bool isCreating,
    bool isDark,
  ) {
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
                onPressed: isCreating ? null : () => _createInvoice(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
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

  void _removeItem(String cartItemId) {
    ref.read(cartProvider.notifier).removeItem(cartItemId);
    final cartState = ref.read(cartProvider);
    final removedItem = cartState.items.where((i) => i.id == cartItemId).toList();
    if (removedItem.isNotEmpty) {
      final selectedIds = ref.read(selectedCartItemsProvider);
      final newSelected = Set<String>.from(selectedIds)..remove(removedItem.first.productId);
      ref.read(selectedCartItemsProvider.notifier).state = newSelected;
    }
  }

  int _calculateDiscount(List<CartItem> items) {
    return 0;
  }

  Future<void> _createInvoice(AppLocalizations l10n) async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAcceptTerms),
          backgroundColor: AppColors.mitsubishiRed,
        ),
      );
      return;
    }

    if (_selectedAddressId == null) {
      AppToast.show(context, 'Silakan pilih alamat pengiriman', isError: true, bottomOffset: 100);
      return;
    }

    final errorMsg = l10n.errorGeneric;

    try {
      final result = await createOrder(
        ref,
        addressId: _selectedAddressId!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await ref.read(cartProvider.notifier).clearCart();
      ref.read(selectedCartItemsProvider.notifier).state = {};

      if (!context.mounted) return;
      context.pushNamed(AppRoute.payment, pathParameters: {'orderId': result.orderId});
    } on Exception catch (e) {
      if (!context.mounted) return;
      final message = e.toString();
      AppToast.show(
        context,
        message.contains('INSUFFICIENT_STOCK') ? 'Stok tidak mencukupi. Silakan periksa kembali keranjang Anda.' : errorMsg,
        isError: true,
        bottomOffset: 100,
      );
    }
  }
}

class _AddressSelector extends ConsumerWidget {
  final String? selectedAddressId;
  final ValueChanged<String> onAddressSelected;
  final bool isDark;

  const _AddressSelector({
    required this.selectedAddressId,
    required this.onAddressSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addressesAsync = FutureProvider<List<Address>>((ref) {
      return ref.read(addressRepositoryProvider).getAddresses();
    });

    final addresses = ref.watch(addressesAsync);

    return addresses.when(
      data: (addresses) {
        if (addresses.isEmpty) {
          return GestureDetector(
            onTap: () => context.pushNamed(AppRoute.editAddress),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.mitsubishiRed,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_location, color: AppColors.mitsubishiRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.noAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mitsubishiRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final selected = addresses.firstWhere(
          (a) => a.id == selectedAddressId,
          orElse: () => addresses.first,
        );

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
                child: Icon(Icons.location_on, color: AppColors.mitsubishiRed, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        selected.recipient,
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
                          selected.label,
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
                    '${selected.street}\n${selected.city}, ${selected.province} ${selected.postalCode}\n${selected.phone}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.deliveryNotes,
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
      },
      loading: () => const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Text(
        'Gagal memuat alamat',
        style: TextStyle(color: AppColors.mitsubishiRed),
      ),
    );
  }
}
