import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/product_repository.dart';
import '../models/product.dart';
import 'repository_providers.dart';

final productFilterProvider = StateProvider<ProductFilter>((ref) => const ProductFilter());

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(ProductListNotifier.new);

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  DateTime? _lastFetchedAt;
  ProductFilter? _lastFilter;

  static const _ttl = Duration(minutes: 5);

  @override
  Future<List<Product>> build() async {
    final filter = ref.watch(productFilterProvider);

    // Re-fetch if filter changed or no data yet
    final filterChanged = _lastFilter != filter;
    if (!filterChanged && _lastFetchedAt != null) {
      final age = DateTime.now().difference(_lastFetchedAt!);
      if (age < _ttl && state.hasValue) {
        return state.requireValue;
      }
    }

    _page = 1;
    _hasMore = true;
    _lastFilter = filter;
    try {
      final response =
          await ref.read(productRepositoryProvider).getProducts(filter.copyWith(page: 1));
      _hasMore = response.data.length < response.total;
      _lastFetchedAt = DateTime.now();
      return response.data;
    } catch (e) {
      // On transient error, keep last good data if available (error shown inline)
      if (state.hasValue && state.requireValue.isNotEmpty) {
        return state.requireValue;
      }
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    final filter = ref.read(productFilterProvider);
    _page++;
    try {
      final response =
          await ref.read(productRepositoryProvider).getProducts(filter.copyWith(page: _page));
      final accumulated = <Product>[...state.value ?? [], ...response.data];
      _hasMore = accumulated.length < response.total;
      state = AsyncData(accumulated);
    } catch (e, st) {
      _page--;
      state = AsyncError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _lastFetchedAt = null;
    _page = 1;
    _hasMore = true;
    final filter = ref.read(productFilterProvider);
    try {
      final response =
          await ref.read(productRepositoryProvider).getProducts(filter.copyWith(page: 1));
      _hasMore = response.data.length < response.total;
      _lastFetchedAt = DateTime.now();
      state = AsyncData(response.data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Returns product from list cache if available, otherwise fetches from API.
final productDetailProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  // Check list cache first to avoid extra API call
  final listState = ref.read(productListProvider);
  if (listState.hasValue) {
    final cached = listState.requireValue.where((p) => p.idString == id).firstOrNull;
    if (cached != null) return cached;
  }
  return ref.read(productRepositoryProvider).getProductById(id);
});
