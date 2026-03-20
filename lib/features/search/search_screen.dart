import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/dummy/dummy_products.dart';
import '../../../models/product.dart';
import '../../../providers/compare_provider.dart';

/// Search screen with filters, sort, and product list
class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // Active filters
  final Set<String> _activeFilters = {};

  // Sort option
  String _sortBy = 'relevance';

  // Filter keys (for logic)
  static const _categoryKeys = ['inverter', 'servo', 'plc', 'hmi'];
  static const _brandKeys = ['mitsubishi', 'danfoss'];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts() {
    var products = dummyProducts.toList();

    // Filter by search query
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      products = products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.sku.toLowerCase().contains(query) ||
            p.series.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category
    final activeCategories = _activeFilters
        .where((f) => _categoryKeys.contains(f))
        .toList();
    if (activeCategories.isNotEmpty) {
      products = products.where((p) {
        final catName = p.category.name.toLowerCase();
        return activeCategories.contains(catName);
      }).toList();
    }

    // Filter by stock
    if (_activeFilters.contains('ready-stock')) {
      products = products.where((p) => p.stockStatus == StockStatus.inStock).toList();
    }
    if (_activeFilters.contains('indent')) {
      products = products.where((p) => p.stockStatus == StockStatus.leadTime).toList();
    }

    // Filter by brand
    final activeBrands = _activeFilters
        .where((f) => _brandKeys.contains(f))
        .toList();
    if (activeBrands.isNotEmpty) {
      products = products.where((p) {
        final brandName = p.brand.name.toLowerCase();
        return activeBrands.contains(brandName);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'price-low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-high':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name-asc':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name-desc':
        products.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return products;
  }

  String _getFilterLabel(String filterKey, AppLocalizations l10n) {
    switch (filterKey) {
      case 'inverter': return l10n.inverter;
      case 'servo': return l10n.servo;
      case 'plc': return l10n.plc;
      case 'hmi': return l10n.hmi;
      case 'ready-stock': return l10n.stockReady;
      case 'indent': return l10n.stockIndent;
      case 'mitsubishi': return l10n.mitsubishi;
      case 'danfoss': return l10n.danfoss;
      case 'daya-kecil': return '≤ 2.2 kW';
      case 'daya-menengah': return '3.7–15 kW';
      case 'daya-besar': return '≥ 18.5 kW';
      default: return filterKey;
    }
  }

  void _removeFilter(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
    });
  }

  void _openFilterSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        activeFilters: _activeFilters,
        categories: [
          ('inverter', l10n.inverter),
          ('servo', l10n.servo),
          ('plc', l10n.plc),
          ('hmi', l10n.hmi),
        ],
        stockOptions: [
          ('ready-stock', l10n.stockReady),
          ('indent', l10n.stockIndent),
        ],
        brands: [
          ('mitsubishi', l10n.mitsubishi),
          ('danfoss', l10n.danfoss),
        ],
        powerRanges: [
          ('daya-kecil', '≤ 2.2 kW'),
          ('daya-menengah', '3.7–15 kW'),
          ('daya-besar', '≥ 18.5 kW'),
        ],
        onApply: (filters) {
          setState(() {
            _activeFilters.clear();
            _activeFilters.addAll(filters);
          });
        },
      ),
    );
  }

  void _addToCompare(Product product) {
    final success = ref.read(compareProvider.notifier).toggle(product.id);
    if (!success) {
      AppToast.show(context, 'Maksimal 3 produk untuk dibandingkan', isError: true);
    } else {
      AppToast.show(context, 'Ditambahkan ke perbandingan', isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final products = _getFilteredProducts();
    final compareState = ref.watch(compareProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Icon(Icons.cancel, color: AppColors.textTertiary, size: 20),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // Active filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'Filter aktif:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  if (_activeFilters.isEmpty)
                    Text(
                      'Tidak ada filter aktif',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiary,
                      ),
                    )
                  else
                    ..._activeFilters.map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(_getFilterLabel(f, l10n), () => _removeFilter(f)),
                        )),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _openFilterSheet(l10n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mitsubishiRed.withValues(alpha: 0.05),
                        border: Border.all(color: AppColors.mitsubishiRed.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 12, color: AppColors.mitsubishiRed),
                          const SizedBox(width: 4),
                          Text(
                            'Tambah Filter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mitsubishiRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results count & sort
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ditemukan ${products.length} produk',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      isDense: true,
                      items: const [
                        DropdownMenuItem(value: 'relevance', child: Text('Relevansi')),
                        DropdownMenuItem(value: 'price-low', child: Text('Harga Terendah')),
                        DropdownMenuItem(value: 'price-high', child: Text('Harga Tertinggi')),
                        DropdownMenuItem(value: 'name-asc', child: Text('Nama A-Z')),
                        DropdownMenuItem(value: 'name-desc', child: Text('Nama Z-A')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _sortBy = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index]);
                    },
                  ),
          ),
        ],
      ),
      // Compare bar
      bottomNavigationBar: compareState.count > 0
          ? _buildCompareBar(compareState.count)
          : null,
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mitsubishiRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mitsubishiRed,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.cancel, size: 16, color: AppColors.mitsubishiRed),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.productDetail,
          pathParameters: {'id': product.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 96,
                  height: 96,
                  color: AppColors.surfaceVariant,
                  child: Image.asset(
                    product.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      _getCategoryIcon(product.category),
                      size: 32,
                      color: AppColors.textTertiary,
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
                    // Stock badge
                    _buildStockBadge(product),
                    const SizedBox(height: 4),
                    // Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Description
                    Text(
                      '${product.brand == ProductBrand.mitsubishi ? 'Mitsubishi' : 'Danfoss'} ${product.category.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mitsubishiRed,
                      ),
                    ),
                  ],
                ),
              ),
              // Compare button
              IconButton(
                onPressed: () => _addToCompare(product),
                icon: const Icon(Icons.balance, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(Product product) {
    String label;
    Color bgColor;
    Color textColor;

    switch (product.stockStatus) {
      case StockStatus.inStock:
        label = '${product.stock} Unit Tersedia';
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case StockStatus.lowStock:
        label = 'Sisa ${product.stock} Unit';
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case StockStatus.leadTime:
        label = 'Indent ${product.stockLeadTime ?? '7-14 Hari'}';
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case StockStatus.outOfStock:
        label = 'Habis';
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              size: 28,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada produk ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci atau filter',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareBar(int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.mitsubishiRed,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Produk dipilih'),
          const Spacer(),
          TextButton(
            onPressed: () => ref.read(compareProvider.notifier).clear(),
            child: Text('Hapus', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => context.pushNamed(AppRoute.compare),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mitsubishiRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Bandingkan'),
          ),
        ],
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
}

// Filter Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  final Set<String> activeFilters;
  final List<(String, String)> categories;
  final List<(String, String)> stockOptions;
  final List<(String, String)> brands;
  final List<(String, String)> powerRanges;
  final void Function(Set<String>) onApply;

  const _FilterBottomSheet({
    required this.activeFilters,
    required this.categories,
    required this.stockOptions,
    required this.brands,
    required this.powerRanges,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late Set<String> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Set.from(widget.activeFilters);
  }

  void _toggleFilter(String key) {
    setState(() {
      if (_selectedFilters.contains(key)) {
        _selectedFilters.remove(key);
      } else {
        _selectedFilters.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.addFilter,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori Produk
                  _buildFilterSection(l10n.filterCategory, widget.categories),
                  const SizedBox(height: 20),

                  // Ketersediaan Stok
                  _buildFilterSection(l10n.filterAvailability, widget.stockOptions),
                  const SizedBox(height: 20),

                  // Brand
                  _buildFilterSection(l10n.brand, widget.brands),
                  const SizedBox(height: 20),

                  // Rentang Daya
                  _buildFilterSection(l10n.filterPower, widget.powerRanges),
                  const SizedBox(height: 20),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_selectedFilters);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mitsubishiRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.applyFilter),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<(String, String)> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = _selectedFilters.contains(opt.$1);
            return GestureDetector(
              onTap: () => _toggleFilter(opt.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mitsubishiRed.withValues(alpha: 0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.mitsubishiRed : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected ? AppColors.mitsubishiRed : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}