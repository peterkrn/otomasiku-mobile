import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/product_repository.dart';
import 'package:otomasiku_mobile/models/product.dart';
import 'package:otomasiku_mobile/providers/catalog_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

void main() {
  group('brandsProvider', () {
    test('fetches and returns brands list', () async {
      final mockRepo = _MockProductRepository();
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final brands = await container.read(brandsProvider.future);

      expect(brands, hasLength(2));
      expect(brands.first.slug, 'mitsubishi');
      expect(mockRepo.getBrandsCalls, 1);
    });

    test('does not re-fetch on second read (cached)', () async {
      final mockRepo = _MockProductRepository();
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(brandsProvider.future);
      await container.read(brandsProvider.future);

      expect(mockRepo.getBrandsCalls, 1);
    });
  });

  group('categoriesProvider', () {
    test('fetches and returns categories list', () async {
      final mockRepo = _MockProductRepository();
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final categories = await container.read(categoriesProvider.future);

      expect(categories, hasLength(2));
      expect(categories.first.slug, 'inverter');
      expect(mockRepo.getCategoriesCalls, 1);
    });
  });

  group('filter slug resolution', () {
    test('brandSlugForId returns correct slug', () async {
      final mockRepo = _MockProductRepository();
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(brandsProvider.future);

      final slug = container.read(brandSlugForIdProvider(1));
      expect(slug, 'mitsubishi');
    });

    test('categorySlugForId returns correct slug', () async {
      final mockRepo = _MockProductRepository();
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(categoriesProvider.future);

      final slug = container.read(categorySlugForIdProvider(1));
      expect(slug, 'inverter');
    });

    test('returns empty string for unknown id', () async {
      final mockRepo = _MockProductRepository();
      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(brandsProvider.future);

      final slug = container.read(brandSlugForIdProvider(999));
      expect(slug, '');
    });
  });
}

class _MockProductRepository implements ProductRepository {
  int getBrandsCalls = 0;
  int getCategoriesCalls = 0;

  @override
  Future<List<Brand>> getBrands() async {
    getBrandsCalls++;
    return [
      const Brand(id: 1, name: 'Mitsubishi', slug: 'mitsubishi'),
      const Brand(id: 2, name: 'Danfoss', slug: 'danfoss'),
    ];
  }

  @override
  Future<List<Category>> getCategories() async {
    getCategoriesCalls++;
    return [
      const Category(id: 1, name: 'Inverter', slug: 'inverter'),
      const Category(id: 2, name: 'PLC', slug: 'plc'),
    ];
  }

  @override
  Future<ProductListResponse> getProducts(ProductFilter filter) async =>
      const ProductListResponse(data: [], total: 0, page: 1, pageSize: 20);

  @override
  Future<Product> getProductById(String id) async => throw UnimplementedError();
}
