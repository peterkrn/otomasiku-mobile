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

  @override
  Future<List<Product>> build() async {
    ref.watch(productFilterProvider);
    _page = 1;
    _hasMore = true;
    final filter = ref.read(productFilterProvider);
    final response =
        await ref.read(productRepositoryProvider).getProducts(filter.copyWith(page: 1));
    _hasMore = response.data.length < response.total;
    return response.data;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final filter = ref.read(productFilterProvider);
    _page++;
    try {
      final response =
          await ref.read(productRepositoryProvider).getProducts(filter.copyWith(page: _page));
      _hasMore = response.data.length < response.total;
      state = AsyncData([...state.value ?? [], ...response.data]);
    } catch (e, st) {
      _page--;
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    final filter = ref.read(productFilterProvider);
    try {
      final response =
          await ref.read(productRepositoryProvider).getProducts(filter.copyWith(page: 1));
      _hasMore = response.data.length < response.total;
      state = AsyncData(response.data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) {
  return ref.read(productRepositoryProvider).getProductById(id);
});
