import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/compare_provider.dart';
import '../../data/dummy/dummy_products.dart';

/// Product Detail Screen - shows full product information
/// Matches ui-otomasiku-marketplace/product-detail.html
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _quantity = 1;
  bool _isAddingToCart = false;
  int? _selectedTierMin; // Track selected tier minimum quantity

  Product? _product;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProduct();
  }

  void _loadProduct() {
    // Find product from dummy data
    _product = dummyProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => dummyProducts.first,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final product = _product;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.productDetail)),
        body: Center(child: Text(l10n.noProducts)),
      );
    }

    final cartQuantity = ref.watch(
      cartProvider.select((s) => s.getQuantityForProduct(product.id)),
    );
    final isInCompare = ref.watch(
      compareProvider.select((s) => s.isInCompare(product.id)),
    );
    final displayStock = product.stock != null
        ? (product.stock! - cartQuantity)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoute.home);
            }
          },
        ),
        title: Text(l10n.productDetail),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          // Compare button
          IconButton(
            onPressed: () => _handleCompare(product, l10n),
            icon: Icon(
              Icons.balance,
              color: isInCompare ? AppColors.mitsubishiRed : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image section
            _buildImageSection(product, l10n),

            // Product info section
            _buildProductInfo(product, l10n, displayStock),

            // Tiered pricing section
            _buildTieredPricing(product, l10n),

            // Tabs section
            _buildTabs(product, l10n),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(product, l10n, displayStock),
    );
  }

  Widget _buildImageSection(Product product, AppLocalizations l10n) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: AppColors.surfaceVariant,
                child: Image.asset(
                  product.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          _getCategoryIcon(product.category),
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                      );
                    },
                  ),
              ),
            ),
          ),
          // Badges
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                if (product.stockStatus == StockStatus.inStock)
                  _buildBadge(l10n.newArrival, AppColors.mitsubishiRed),
                const SizedBox(width: 8),
                _buildStockBadge(product, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStockBadge(Product product, AppLocalizations l10n) {
    String text;
    Color color;

    switch (product.stockStatus) {
      case StockStatus.inStock:
        text = l10n.stockReady;
        color = Colors.green;
        break;
      case StockStatus.lowStock:
        text = l10n.stockLow(product.stock ?? 0);
        color = Colors.orange;
        break;
      case StockStatus.outOfStock:
        text = l10n.stockEmpty;
        color = AppColors.mitsubishiRed;
        break;
      case StockStatus.leadTime:
        text = product.stockLeadTime ?? l10n.stockIndent;
        color = Colors.blue;
        break;
    }

    return _buildBadge(text, color);
  }

  Widget _buildProductInfo(
    Product product,
    AppLocalizations l10n,
    int? displayStock,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Description
          if (product.description != null)
            Text(
              product.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 16),
          // Stock info card
          if (product.stockStatus == StockStatus.inStock && displayStock != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warehouse,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.unitsAvailable(displayStock),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          l10n.readyToShip('1-2 hari kerja'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Price section
          const Divider(height: 1),
          const SizedBox(height: 16),
          Text(
            l10n.pricePerUnit,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(product.price),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mitsubishiRed,
                ),
              ),
              if (product.hasDiscount && product.originalPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.format(product.originalPrice!),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTieredPricing(Product product, AppLocalizations l10n) {
    // Calculate tier prices (simplified for M2)
    final tierPrice1 = product.price; // 1-5 units
    final tierPrice2 = product.hasDiscount ? product.price : (product.price * 0.92).round(); // 6-10 units (8% discount)
    final savings = tierPrice1 - tierPrice2;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tieredPricing,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Tier 1: 1-5 units (current)
          GestureDetector(
            onTap: () => _selectTier(1, 1, l10n),
            child: _buildPriceTier(
              '1 - 5 Unit',
              l10n.priceNormal,
              tierPrice1,
              isSelected: _quantity >= 1 && _quantity <= 5,
            ),
          ),
          const SizedBox(height: 8),
          // Tier 2: 6-10 units (best deal)
          GestureDetector(
            onTap: () => _selectTier(6, 6, l10n),
            child: _buildPriceTier(
              '6 - 10 Unit',
              l10n.volumeDiscount(CurrencyFormatter.format(savings)),
              tierPrice2,
              isBestDeal: true,
              isSelected: _quantity >= 6 && _quantity <= 10,
            ),
          ),
          const SizedBox(height: 8),
          // Tier 3: 11+ units (RFQ)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '11+ Unit',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.contactSales,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showRFQDialog(product, l10n),
                  child: Text(
                    l10n.rfq,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
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

  void _selectTier(int minQty, int defaultQty, AppLocalizations l10n) {
    setState(() {
      _selectedTierMin = minQty;
      _quantity = defaultQty;
    });
  }

  Widget _buildPriceTier(
    String range,
    String subtitle,
    int price, {
    bool isBestDeal = false,
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBestDeal ? Colors.green.shade50 : AppColors.surfaceVariant,
        border: Border.all(
          color: isSelected
              ? AppColors.mitsubishiRed
              : (isBestDeal ? Colors.green.shade200 : Colors.transparent),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        range,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isBestDeal ? Colors.green.shade800 : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isBestDeal ? Colors.green.shade600 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBestDeal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Best Deal',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            CurrencyFormatter.format(price),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isBestDeal ? Colors.green.shade700 : AppColors.mitsubishiRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Product product, AppLocalizations l10n) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.mitsubishiRed,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.mitsubishiRed,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: l10n.specifications),
              Tab(text: l10n.documents),
              Tab(text: l10n.compatible),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSpecsTab(product, l10n),
                _buildDocsTab(l10n),
                _buildCompatTab(product, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsTab(Product product, AppLocalizations l10n) {
    final specs = product.specifications ?? {};

    if (specs.isEmpty) {
      return Center(
        child: Text(
          l10n.noProducts,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: specs.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                entry.value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocsTab(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildDocItem(
          'Datasheet ${l10n.specifications}',
          'PDF • 2.4 MB',
          Icons.picture_as_pdf,
          Colors.red,
          l10n,
        ),
        const SizedBox(height: 12),
        _buildDocItem(
          'Manual Instalasi',
          'PDF • 5.1 MB',
          Icons.menu_book,
          Colors.blue,
          l10n,
        ),
      ],
    );
  }

  Widget _buildDocItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                const Icon(Icons.download, size: 14),
                const SizedBox(width: 4),
                Text(l10n.download),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatTab(Product product, AppLocalizations l10n) {
    // Find compatible products from dummy data
    final compatProducts = dummyProducts
        .where((p) => p.id != product.id)
        .take(3)
        .toList();

    if (compatProducts.isEmpty) {
      return Center(
        child: Text(
          l10n.noProducts,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.compatibleWith(product.name),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...compatProducts.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildCompatItem(p, l10n),
        )),
      ],
    );
  }

  Widget _buildCompatItem(Product compatProduct, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showCompatOptions(compatProduct, l10n),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  compatProduct.primaryImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      _getCategoryIcon(compatProduct.category),
                      size: 20,
                      color: AppColors.textSecondary,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compatProduct.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_categoryToString(compatProduct.category)} • ${_brandToString(compatProduct.brand)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Cocok',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompatOptions(Product compatProduct, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product preview
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      compatProduct.primaryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getCategoryIcon(compatProduct.category),
                          size: 28,
                          color: AppColors.textSecondary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compatProduct.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(compatProduct.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mitsubishiRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // View Product button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pushNamed(
                    AppRoute.productDetail,
                    pathParameters: {'id': compatProduct.id},
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.mitsubishiRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.viewProduct,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mitsubishiRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Add to Cart button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(cartProvider.notifier).addItem(
                    CartItem(
                      id: DateTime.now().toString(),
                      product: compatProduct,
                      quantity: 1,
                    ),
                  );
                  AppToast.show(
                    context,
                    l10n.addedToCart(compatProduct.name),
                    isError: false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.addToCart,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    Product product,
    AppLocalizations l10n,
    int? displayStock,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity controls
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final minQty = _selectedTierMin ?? 1;
                      if (_quantity > minQty) {
                        setState(() => _quantity--);
                      } else if (_quantity == minQty && minQty > 1) {
                        // Show error - can't go below minimum
                        AppToast.show(
                          context,
                          l10n.minQuantityTier(minQty),
                          isError: true,
                        );
                      }
                    },
                    icon: const Icon(Icons.remove),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 48),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (displayStock == null || _quantity < displayStock) {
                        setState(() => _quantity++);
                      }
                    },
                    icon: const Icon(Icons.add),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 48),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Save to project button
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _saveToProject(product, l10n),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.bookmark_border, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            // Add to cart button
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: _isAddingToCart ? null : () => _addToCart(product, l10n),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isAddingToCart ? Colors.green : AppColors.mitsubishiRed,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Icon(
                  _isAddingToCart ? Icons.check : Icons.shopping_cart_outlined,
                  size: 20,
                  color: _isAddingToCart ? Colors.green : AppColors.mitsubishiRed,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Buy now button
            Expanded(
              child: ElevatedButton(
                onPressed: () => _buyNow(product, l10n, displayStock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.buy,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCompare(Product product, AppLocalizations l10n) {
    final result = ref.read(compareProvider.notifier).toggle(product.id);
    if (!result) {
      AppToast.show(context, l10n.compareMaxError, isError: true);
    } else {
      AppToast.show(context, l10n.addedToCompare, isError: false);
    }
  }

  void _addToCart(Product product, AppLocalizations l10n) {
    setState(() => _isAddingToCart = true);

    ref.read(cartProvider.notifier).addItem(
      CartItem(
        id: DateTime.now().toString(),
        product: product,
        quantity: _quantity,
      ),
    );

    AppToast.show(
      context,
      l10n.addedToCart(product.name),
      isError: false,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    });
  }

  void _buyNow(Product product, AppLocalizations l10n, int? displayStock) {
    // Check stock
    if (displayStock != null && _quantity > displayStock) {
      AppToast.show(
        context,
        l10n.insufficientStock(displayStock),
        isError: true,
      );
      return;
    }

    // Add to cart and navigate to checkout
    ref.read(cartProvider.notifier).addItem(
      CartItem(
        id: DateTime.now().toString(),
        product: product,
        quantity: _quantity,
      ),
    );

    context.pushNamed(AppRoute.checkout);
  }

  void _saveToProject(Product product, AppLocalizations l10n) {
    // Show dialog to select project (placeholder)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveToProject),
        content: TextField(
          decoration: InputDecoration(
            hintText: l10n.project,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppToast.show(
                context,
                l10n.savedToProject('Project 1'),
                isError: false,
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showRFQDialog(Product product, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.rfqTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.rfqQuantity,
                hintText: l10n.rfqMinQuantity(11),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.rfqCompanyName,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  AppToast.show(context, l10n.rfqSent, isError: false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.rfqSubmit,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    return switch (category) {
      ProductCategory.inverter => Icons.bolt,
      ProductCategory.plc => Icons.memory,
      ProductCategory.hmi => Icons.desktop_mac,
      ProductCategory.servo => Icons.settings,
    };
  }

  String _categoryToString(ProductCategory category) {
    return switch (category) {
      ProductCategory.inverter => 'Inverter',
      ProductCategory.plc => 'PLC',
      ProductCategory.hmi => 'HMI',
      ProductCategory.servo => 'Servo',
    };
  }

  String _brandToString(ProductBrand brand) {
    return switch (brand) {
      ProductBrand.mitsubishi => 'Mitsubishi',
      ProductBrand.danfoss => 'Danfoss',
    };
  }
}