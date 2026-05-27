import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../providers/address_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import 'widgets/address_selector.dart';
import 'widgets/checkout_bottom_bar.dart';
import 'widgets/checkout_order_item.dart';
import 'widgets/checkout_payment_method_section.dart';
import 'widgets/checkout_payment_summary.dart';
import 'widgets/checkout_section_card.dart';
import 'widgets/checkout_shipping_option.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _notesController = TextEditingController();
  bool _termsAccepted = false;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartIfEmpty();
      _loadAddresses();
    });
  }

  Future<void> _loadCartIfEmpty() async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) {
      await ref.read(cartProvider.notifier).loadCart();
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await ref.read(addressListProvider.future);
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
    final subtotal = cartItems.fold(
        0, (sum, item) => sum + item.productSnapshot.price * item.quantity);
    final totalItems =
        cartItems.fold(0, (sum, item) => sum + item.quantity);
    final createOrderState = ref.watch(orderCreateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final discount = _calculateDiscount(cartItems);
    final afterDiscount = subtotal - discount;
    final tax = (afterDiscount * 0.11).round();
    final total = afterDiscount + tax;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.checkout),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor:
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(l10n, isDark)
          : _buildBody(context, l10n, cartItems, totalItems, subtotal,
              discount, tax, total, isDark),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : CheckoutBottomBar(
              total: total,
              isCreating: createOrderState.isLoading,
              onPay: () => _createInvoice(l10n),
              isDark: isDark,
            ),
    );
  }

  Widget _buildEmptyCart(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(l10n.emptyCart,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.goNamed(AppRoute.home),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mitsubishiRed,
                foregroundColor: Colors.white),
            child: Text(l10n.cartStartShopping),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    List items,
    int totalItems,
    int subtotal,
    int discount,
    int tax,
    int total,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckoutSectionCard(
            title: l10n.orderSummary,
            trailing: l10n.itemCount(items.length),
            isDark: isDark,
            child: Column(
              children: items.asMap().entries
                  .map((entry) => CheckoutOrderItem(
                        item: entry.value,
                        index: entry.key,
                        totalItems: items.length,
                        onRemove: () => _removeItem(entry.value.id),
                        isDark: isDark,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          CheckoutSectionCard(
            title: l10n.shippingAddress,
            trailing: l10n.edit,
            isDark: isDark,
            onTrailingTap: () async {
              final result = await context.pushNamed(AppRoute.shipping);
              if (result != null && mounted) {
                setState(() => _selectedAddressId = result as String?);
              }
            },
            child: AddressSelector(
              selectedAddressId: _selectedAddressId,
              onAddressSelected: (id) =>
                  setState(() => _selectedAddressId = id),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 12),
          CheckoutSectionCard(
            title: l10n.paymentMethod,
            isDark: isDark,
            child: CheckoutPaymentMethodSection(isDark: isDark),
          ),
          const SizedBox(height: 12),
          CheckoutSectionCard(
            title: l10n.shipping,
            isDark: isDark,
            child: CheckoutShippingOption(isDark: isDark),
          ),
          const SizedBox(height: 12),
          CheckoutSectionCard(
            title: l10n.paymentSummary,
            isDark: isDark,
            child: CheckoutPaymentSummary(
              totalItems: totalItems,
              subtotal: subtotal,
              discount: discount,
              tax: tax,
              total: total,
              termsAccepted: _termsAccepted,
              onTermsChanged: (v) => setState(() => _termsAccepted = v),
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _removeItem(String cartItemId) {
    final cartState = ref.read(cartProvider);
    final item = cartState.items.firstWhere((i) => i.id == cartItemId);
    ref.read(cartProvider.notifier).removeItem(cartItemId);
    final selected = Set<String>.from(ref.read(selectedCartItemsProvider))
      ..remove(item.productId);
    ref.read(selectedCartItemsProvider.notifier).state = selected;
  }

  int _calculateDiscount(List items) => 0;

  Future<void> _createInvoice(AppLocalizations l10n) async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.pleaseAcceptTerms),
        backgroundColor: AppColors.mitsubishiRed,
      ));
      return;
    }

    if (_selectedAddressId == null) {
      AppToast.show(context, 'Silakan pilih alamat pengiriman',
          isError: true, bottomOffset: 100);
      return;
    }

    final errorMsg = l10n.errorGeneric;

    try {
      final result = await ref.read(orderCreateProvider.notifier).createOrder(
            addressId: _selectedAddressId!,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          );

      if (!context.mounted) return;
      await ref.read(cartProvider.notifier).clearCart();
      ref.read(selectedCartItemsProvider.notifier).state = {};
      context.pushNamed(AppRoute.payment,
          pathParameters: {'orderId': result.orderId});
    } on Exception catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        e.toString().contains('INSUFFICIENT_STOCK')
            ? 'Stok tidak mencukupi. Silakan periksa kembali keranjang Anda.'
            : errorMsg,
        isError: true,
        bottomOffset: 100,
      );
    }
  }
}
