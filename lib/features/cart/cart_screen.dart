import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_item_shimmer.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartState = ref.read(cartProvider);
      if (cartState.items.isEmpty && !cartState.isLoading) {
        ref.read(cartProvider.notifier).loadCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;
    final selectedIds = ref.watch(selectedCartItemsProvider);
    final allSelected = cartItems.isNotEmpty && selectedIds.length == cartItems.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedItems = cartItems.where((item) => selectedIds.contains(item.productId)).toList();
    final subtotal = selectedItems.fold(0, (sum, item) => sum + item.productSnapshot.price * item.quantity);
    final totalItems = selectedItems.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(l10n.cart),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: cartState.isLoading
          ? const CartItemShimmer()
          : cartItems.isEmpty
              ? _buildEmptyState(context, l10n, isDark)
              : _buildCartList(
                  context,
                  l10n,
                  cartItems,
                  selectedIds,
                  allSelected,
                  subtotal,
                  totalItems,
                  isDark,
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
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
          const SizedBox(height: 8),
          Text(
            l10n.noCartItems,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () => context.goNamed(AppRoute.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mitsubishiRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.cartStartShopping),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    AppLocalizations l10n,
    List<CartItem> cartItems,
    Set<String> selectedIds,
    bool allSelected,
    int subtotal,
    int totalItems,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          color: isDark ? AppColors.darkSurface : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _toggleSelectAll(cartItems, allSelected),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: allSelected ? AppColors.mitsubishiRed : (isDark ? AppColors.darkBorder : AppColors.border),
                      width: 2,
                    ),
                    color: allSelected ? AppColors.mitsubishiRed : Colors.transparent,
                  ),
                  child: allSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _toggleSelectAll(cartItems, allSelected),
                child: Text(
                  l10n.selectAll,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${selectedIds.length}/${cartItems.length} item',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.divider),
        Expanded(
          child: Container(
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: isDark ? AppColors.darkBorder : AppColors.divider,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final isSelected = selectedIds.contains(item.productId);
                return CartItemCard(
                  item: item,
                  isSelected: isSelected,
                  isDark: isDark,
                  onSelectionChanged: (selected) => _toggleItemSelection(item.productId, selected),
                  onQuantityChanged: (newQty) {
                    ref.read(cartProvider.notifier).updateQuantity(
                          item.id,
                          newQty,
                        );
                  },
                  onRemove: () => _showRemoveConfirmation(context, l10n, item),
                );
              },
            ),
          ),
        ),
        Container(
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
                      "${l10n.subtotal} (${l10n.itemCount(totalItems)})",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      totalItems == 0 ? '-' : CurrencyFormatter.format(subtotal),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedIds.isEmpty
                        ? () => AppToast.show(context, l10n.noItemSelected, isError: true, bottomOffset: 160)
                        : () => context.pushNamed(AppRoute.checkout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mitsubishiRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.mitsubishiRed.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      l10n.continueToCheckout,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleSelectAll(List<CartItem> cartItems, bool allSelected) {
    final notifier = ref.read(selectedCartItemsProvider.notifier);
    if (allSelected) {
      notifier.state = {};
    } else {
      notifier.state = cartItems.map((item) => item.productId).toSet();
    }
  }

  void _toggleItemSelection(String productId, bool selected) {
    final notifier = ref.read(selectedCartItemsProvider.notifier);
    final current = Set<String>.from(notifier.state);
    if (selected) {
      current.add(productId);
    } else {
      current.remove(productId);
    }
    notifier.state = current;
  }

  void _showRemoveConfirmation(
    BuildContext context,
    AppLocalizations l10n,
    CartItem item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cartRemoveTitle),
        content: Text(l10n.cartRemoveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(item.id);
              _toggleItemSelection(item.productId, false);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mitsubishiRed,
            ),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }
}
