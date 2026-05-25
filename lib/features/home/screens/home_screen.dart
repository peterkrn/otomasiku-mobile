import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_card.dart';

/// Home screen with product catalog grid.
/// Matches HTML mockup: header with logo + cart + profile,
/// search bar, filter chips, hero banner, product grid.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  FilterCategory _selectedCategory = FilterCategory.all;

  @override
  void initState() {
    super.initState();
    // Load products on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productState = ref.watch(productProvider);
    final cartCount = ref.watch(
      cartProvider.select((state) => state.totalItems),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mitsubishiRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [_Diamond(), _Diamond()],
                    ),
                    _Diamond(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MITSUBISHI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Electric',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Cart icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                onPressed: () => context.pushNamed(AppRoute.cart),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.mitsubishiRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        cartCount > 99 ? '99+' : '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Profile avatar
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context.goNamed(AppRoute.profile),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.mitsubishiRed,
                child: const Text(
                  'JD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(child: _buildSearchBar(context, isDark)),
          // Filter chips
          SliverToBoxAdapter(child: _buildFilterChips(isDark)),
          // Hero banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const HeroBanner(),
            ),
          ),
          // Product grid header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.productCatalog,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Product grid
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: productState.filteredProducts.isEmpty
                ? _buildEmptyState(l10n, isDark)
                : _buildProductGrid(productState),
          ),
          // Bottom padding for navigation
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: TextField(
        style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle: TextStyle(color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
          prefixIcon: Icon(Icons.search, color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
          filled: true,
          fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          ref.read(productProvider.notifier).setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(label: 'Semua', category: FilterCategory.all, isDark: isDark),
            const SizedBox(width: 8),
            _buildFilterChip(label: 'Inverter', category: FilterCategory.inverter, isDark: isDark),
            const SizedBox(width: 8),
            _buildFilterChip(label: 'PLC', category: FilterCategory.plc, isDark: isDark),
            const SizedBox(width: 8),
            _buildFilterChip(label: 'Servo', category: FilterCategory.servo, isDark: isDark),
            const SizedBox(width: 8),
            _buildFilterChip(label: 'HMI', category: FilterCategory.hmi, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required FilterCategory category,
    required bool isDark,
  }) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        ref.read(productProvider.notifier).setCategory(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mitsubishiRed
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.mitsubishiRed,
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductState productState) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildAnimatedProductCard(
          product: productState.filteredProducts[index],
          index: index,
        ),
        childCount: productState.filteredProducts.length,
      ),
    );
  }

  Widget _buildAnimatedProductCard({
    required Product product,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(product.id),
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      child: ProductCard(
        key: ValueKey('card-${product.id}'),
        product: product,
      ),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(
                l10n.noProducts,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785, // 45 degrees
      child: Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.all(0.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
