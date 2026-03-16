import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart' as model;
import '../data/dummy/dummy_products.dart' as dummy_products;

/// Provider for managing product list and filters
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});

/// Product filter options (matches ProductCategory enum from model)
enum FilterCategory {
  all,
  inverter,
  plc,
  servo,
  hmi,
}

/// Product state
class ProductState {
  final List<model.Product> allProducts;
  final List<model.Product> filteredProducts;
  final FilterCategory selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const ProductState({
    required this.allProducts,
    required this.filteredProducts,
    this.selectedCategory = FilterCategory.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<model.Product>? allProducts,
    List<model.Product>? filteredProducts,
    FilterCategory? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Product notifier
class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(const ProductState(allProducts: [], filteredProducts: [])) {
    loadProducts();
  }

  /// Load products from dummy data (M2 only)
  void loadProducts() {
    state = state.copyWith(
      allProducts: dummy_products.dummyProducts,
      filteredProducts: dummy_products.dummyProducts,
    );
  }

  /// Filter by category
  void setCategory(FilterCategory category) {
    List<model.Product> filtered = state.allProducts;

    if (category != FilterCategory.all) {
      // Map FilterCategory to model.ProductCategory
      final targetCategory = _mapFilterToProductCategory(category);
      filtered = state.allProducts
          .where((p) => p.category == targetCategory)
          .toList();
    }

    state = state.copyWith(
      selectedCategory: category,
      filteredProducts: _applySearch(filtered, state.searchQuery),
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredProducts: _applySearch(state.allProducts, query),
    );
  }

  /// Get product by ID
  model.Product? getProductById(String id) {
    try {
      return state.allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Apply search filter
  List<model.Product> _applySearch(List<model.Product> products, String query) {
    if (query.isEmpty) {
      return products;
    }

    final lowerQuery = query.toLowerCase();
    return products.where((p) {
      final nameMatch = p.name.toLowerCase().contains(lowerQuery);
      final descMatch = p.description?.toLowerCase().contains(lowerQuery) ?? false;
      return nameMatch || descMatch;
    }).toList();
  }

  /// Map FilterCategory to model.ProductCategory
  model.ProductCategory _mapFilterToProductCategory(FilterCategory filter) {
    switch (filter) {
      case FilterCategory.inverter:
        return model.ProductCategory.inverter;
      case FilterCategory.plc:
        return model.ProductCategory.plc;
      case FilterCategory.servo:
        return model.ProductCategory.servo;
      case FilterCategory.hmi:
        return model.ProductCategory.hmi;
      case FilterCategory.all:
        throw Exception('Cannot map "all" to a specific category');
    }
  }
}
