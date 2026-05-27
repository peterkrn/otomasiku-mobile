import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'repository_providers.dart';

final brandsProvider = AsyncNotifierProvider<_BrandsNotifier, List<Brand>>(_BrandsNotifier.new);

class _BrandsNotifier extends AsyncNotifier<List<Brand>> {
  @override
  Future<List<Brand>> build() =>
      ref.read(productRepositoryProvider).getBrands();
}

final categoriesProvider =
    AsyncNotifierProvider<_CategoriesNotifier, List<Category>>(_CategoriesNotifier.new);

class _CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() =>
      ref.read(productRepositoryProvider).getCategories();
}

/// Returns the slug for a brand ID, or '' if not loaded yet.
final brandSlugForIdProvider = Provider.family<String, int>((ref, brandId) {
  final brands = ref.watch(brandsProvider).valueOrNull ?? [];
  return brands.where((b) => b.id == brandId).map((b) => b.slug).firstOrNull ?? '';
});

/// Returns the slug for a category ID, or '' if not loaded yet.
final categorySlugForIdProvider = Provider.family<String, int>((ref, categoryId) {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  return categories.where((c) => c.id == categoryId).map((c) => c.slug).firstOrNull ?? '';
});
