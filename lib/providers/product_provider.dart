import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart' as model;
import '../data/dummy/dummy_products.dart' as dummy_products;

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});

enum FilterCategory {
  all,
  inverter,
  plc,
  servo,
  hmi,
}

class ProductState {
  final List<model.Product> allProducts;
  final List<model.Product> filteredProducts;
  final FilterCategory selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final int filterVersion; // Increment on filter change to trigger stagger animation

  const ProductState({
    required this.allProducts,
    required this.filteredProducts,
    this.selectedCategory = FilterCategory.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.filterVersion = 0,
  });

  ProductState copyWith({
    List<model.Product>? allProducts,
    List<model.Product>? filteredProducts,
    FilterCategory? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    String? error,
    int? filterVersion,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterVersion: filterVersion ?? this.filterVersion,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(const ProductState(allProducts: [], filteredProducts: [])) {
    loadProducts();
  }

  void loadProducts() {
    state = state.copyWith(
      allProducts: dummy_products.dummyProducts,
      filteredProducts: dummy_products.dummyProducts,
    );
  }

  void setCategory(FilterCategory category) {
    List<model.Product> filtered = state.allProducts;

    if (category != FilterCategory.all) {
      final targetSlug = _mapFilterToCategorySlug(category);
      filtered = state.allProducts
          .where((p) => p.category.slug == targetSlug)
          .toList();
    }

    state = state.copyWith(
      selectedCategory: category,
      filteredProducts: _applySearch(filtered, state.searchQuery),
      filterVersion: state.filterVersion + 1, // Trigger animation rebuild
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredProducts: _applySearch(state.allProducts, query),
    );
  }

  model.Product? getProductById(String id) {
    try {
      return state.allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<model.Product> _applySearch(List<model.Product> products, String query) {
    if (query.isEmpty) {
      return products;
    }

    final lowerQuery = query.toLowerCase();
    return products.where((p) {
      final nameMatch = p.name.toLowerCase().contains(lowerQuery);
      final descMatch = p.descriptionId?.toLowerCase().contains(lowerQuery) ?? false;
      return nameMatch || descMatch;
    }).toList();
  }

  String _mapFilterToCategorySlug(FilterCategory filter) {
    switch (filter) {
      case FilterCategory.inverter:
        return 'inverter';
      case FilterCategory.plc:
        return 'plc';
      case FilterCategory.servo:
        return 'servo';
      case FilterCategory.hmi:
        return 'hmi';
      case FilterCategory.all:
        throw Exception('Cannot map "all" to a specific category');
    }
  }
}
