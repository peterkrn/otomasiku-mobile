import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/compare_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project.dart';
import '../../shared/widgets/product_image.dart' as product_image;
import 'widgets/product_bottom_bar.dart';
import 'widgets/tiered_pricing_widget.dart';

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
  int? _selectedTierMin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return productAsync.when(
      data: (product) => _buildProductScreen(product, l10n, isDark),
      loading: () => _buildLoadingScreen(l10n, isDark),
      error: (error, _) => _buildErrorScreen(l10n, isDark),
    );
  }

  Widget _buildLoadingScreen(AppLocalizations l10n, bool isDark) {
    return Scaffold(
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
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.mitsubishiRed,
        ),
      ),
    );
  }

  Widget _buildErrorScreen(AppLocalizations l10n, bool isDark) {
    return Scaffold(
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
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.mitsubishiRed),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingProductDetail,
              style: TextStyle(fontSize: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(productDetailProvider(widget.productId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mitsubishiRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductScreen(Product product, AppLocalizations l10n, bool isDark) {
    final isInCompare = ref.watch(
      compareProvider.select((s) => s.isInCompare(product.idString)),
    );
    final displayStock = product.stock;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
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
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _handleCompare(product, l10n),
            icon: Icon(
              Icons.balance,
              color: isInCompare ? AppColors.mitsubishiRed : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(product, l10n, isDark),
            _buildProductInfo(product, l10n, displayStock, isDark),
            TieredPricingWidget(
              product: product,
              quantity: _quantity,
              onTierSelected: (minQty) => setState(() {
                _selectedTierMin = minQty;
                _quantity = minQty;
              }),
              onRfqTap: () => _showRFQDialog(product, l10n),
              isDark: isDark,
            ),
            _buildTabs(product, l10n, isDark),
          ],
        ),
      ),
      bottomNavigationBar: ProductBottomBar(
        quantity: _quantity,
        displayStock: displayStock,
        selectedTierMin: _selectedTierMin,
        isAddingToCart: _isAddingToCart,
        onDecrement: () => setState(() => _quantity--),
        onIncrement: () => setState(() => _quantity++),
        onSaveToProject: () => _saveToProject(product, l10n),
        onAddToCart: () => _addToCart(product, l10n),
        onBuyNow: () => _buyNow(product, l10n, displayStock),
        isDark: isDark,
      ),
    );
  }

  Widget _buildImageSection(Product product, AppLocalizations l10n, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
child: product_image.ProductNetworkImage(
  imageUrl: product.primaryImageUrl,
  categorySlug: product.category.slug,
),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                if (product.isOutOfStock) _buildBadge(l10n.stockEmpty, const Color(0xFFEF4444)),
                if (product.isLowStock) _buildBadge(l10n.stockLow(product.stock), const Color(0xFFF59E0B)),
                if (!product.isOutOfStock && !product.isLowStock)
                  _buildBadge(l10n.stockUnit(product.stock), const Color(0xFF10B981)),
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

  Widget _buildProductInfo(
    Product product,
    AppLocalizations l10n,
    int displayStock,
    bool isDark,
  ) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.brand.name,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (displayStock > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.green.withValues(alpha: 0.15) : Colors.green.shade50,
                border: Border.all(color: isDark ? Colors.green.withValues(alpha: 0.4) : Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade100,
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
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.divider),
          const SizedBox(height: 16),
          Text(
            l10n.pricePerUnit,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
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

  Widget _buildTabs(Product product, AppLocalizations l10n, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.mitsubishiRed,
            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            indicatorColor: AppColors.mitsubishiRed,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: l10n.description),
              Tab(text: l10n.documents),
              Tab(text: l10n.compatible),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(product, l10n, isDark),
                _buildDocsTab(l10n, isDark),
                _buildCompatTab(product, l10n, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(Product product, AppLocalizations l10n, bool isDark) {
    final description = Localizations.localeOf(context).languageCode == 'id'
        ? (product.descriptionId ?? product.descriptionEn)
        : (product.descriptionEn ?? product.descriptionId);

    if (description == null || description.isEmpty) {
      return Center(
        child: Text(
          l10n.noProducts,
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDocsTab(AppLocalizations l10n, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildDocItem(
          'Datasheet ${l10n.specifications}',
          'PDF • 2.4 MB',
          Icons.picture_as_pdf,
          Colors.red,
          l10n,
          isDark,
        ),
        const SizedBox(height: 12),
        _buildDocItem(
          'Manual Instalasi',
          'PDF • 5.1 MB',
          Icons.menu_book,
          Colors.blue,
          l10n,
          isDark,
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
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : null,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

  Widget _buildCompatTab(Product product, AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_outlined,
            size: 48,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.comingSoon,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCompare(Product product, AppLocalizations l10n) {
    final result = ref.read(compareProvider.notifier).toggle(product.idString);
    if (!result) {
      AppToast.show(context, l10n.compareMaxError, isError: true, bottomOffset: 160);
    } else {
      AppToast.show(context, l10n.addedToCompare, isError: false, bottomOffset: 160);
    }
  }

  void _addToCart(Product product, AppLocalizations l10n) {
    if (!ref.read(authProvider).isAuthenticated) {
      AppToast.show(context, 'Anda belum login. Silakan login terlebih dahulu.', isError: true, bottomOffset: 100);
      return;
    }
    setState(() => _isAddingToCart = true);

    ref.read(cartProvider.notifier).addItem(
      product.idString,
      _quantity,
      snapshot: CartProductSnapshot(
        name: product.name,
        price: product.price,
        primaryImageUrl: product.primaryImageUrl,
      ),
    );

    AppToast.show(
      context,
      l10n.addedToCart(product.name),
      isError: false,
      bottomOffset: 100,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    });
  }

  void _buyNow(Product product, AppLocalizations l10n, int displayStock) {
    if (!ref.read(authProvider).isAuthenticated) {
      AppToast.show(context, 'Anda belum login. Silakan login terlebih dahulu.', isError: true, bottomOffset: 100);
      return;
    }
    if (_quantity > displayStock) {
      AppToast.show(
        context,
        l10n.insufficientStock(displayStock),
        isError: true,
        bottomOffset: 100,
      );
      return;
    }

    ref.read(cartProvider.notifier).addItem(
      product.idString,
      _quantity,
      snapshot: CartProductSnapshot(
        name: product.name,
        price: product.price,
        primaryImageUrl: product.primaryImageUrl,
      ),
    );
    ref.read(selectedCartItemsProvider.notifier).state = {product.idString};

    context.pushNamed(AppRoute.checkout);
  }

  void _saveToProject(Product product, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SaveToProjectSheet(
        product: product,
        quantity: _quantity,
        ref: ref,
      ),
    );
  }

  void _showRFQDialog(Product product, AppLocalizations l10n) {
    WhatsAppHelper.openRfq(productName: product.name, quantity: '$_quantity');
  }
}

class _SaveToProjectSheet extends ConsumerStatefulWidget {
  final Product product;
  final int quantity;
  final WidgetRef ref;

  const _SaveToProjectSheet({
    required this.product,
    required this.quantity,
    required this.ref,
  });

  @override
  ConsumerState<_SaveToProjectSheet> createState() => _SaveToProjectSheetState();
}

class _SaveToProjectSheetState extends ConsumerState<_SaveToProjectSheet> {
  final _newProjectController = TextEditingController();
  bool _showNewProjectField = false;

  @override
  void dispose() {
    _newProjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = ref.watch(projectProvider).projects;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.saveToProject,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty && !_showNewProjectField)
            Center(
              child: Column(
                children: [
                  Icon(Icons.folder_outlined, size: 48, color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text(l10n.noProjects, style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          if (!_showNewProjectField && projects.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: projects.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final project = projects[index];
                  return ListTile(
                    onTap: () => _addToProject(project, l10n),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.mitsubishiRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.folder, color: AppColors.mitsubishiRed, size: 20),
                    ),
                    title: Text(
                      project.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${project.itemCount} item',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.add_circle_outline, color: AppColors.mitsubishiRed),
                  );
                },
              ),
            ),
          if (_showNewProjectField) ...[
            TextField(
              controller: _newProjectController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.projectName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.mitsubishiRed, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _newProjectController.text.trim();
                  if (name.isEmpty) return;
                  ref.read(projectProvider.notifier).createProject(name);
                  final newProject = ref.read(projectProvider).projects.last;
                  _addToProject(newProject, l10n);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.createProject, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          if (!_showNewProjectField) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showNewProjectField = true),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.createProject),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mitsubishiRed,
                  side: const BorderSide(color: AppColors.mitsubishiRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addToProject(Project project, AppLocalizations l10n) {
    final item = ProjectItem(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      productId: widget.product.idString,
      productName: widget.product.name,
      productImage: widget.product.primaryImageUrl,
      price: widget.product.price,
      quantity: widget.quantity,
    );
    ref.read(projectProvider.notifier).addItemToProject(project.id, item);
    Navigator.pop(context);
    AppToast.show(
      context,
      l10n.savedToProject(project.name),
      isError: false,
      bottomOffset: 100,
    );
  }
}
