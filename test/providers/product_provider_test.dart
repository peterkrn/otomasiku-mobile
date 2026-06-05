import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/product_repository.dart';
import 'package:otomasiku_mobile/models/product.dart';
import 'package:otomasiku_mobile/providers/product_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

Product _product(int id) => Product(
      id: id,
      name: 'Product $id',
      slug: 'product-$id',
      brandId: 1,
      categoryId: 1,
      price: 1000000,
      stock: 10,
      version: 1,
      unit: 'unit',
      minOrder: 1,
      isPublished: true,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  group('ProductListNotifier caching', () {
    late _MockProductRepository mockRepo;

    setUp(() {
      mockRepo = _MockProductRepository();
    });

    ProviderContainer createContainer() => ProviderContainer(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );

    test('fetches products on first build', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final products = await container.read(productListProvider.future);

      expect(products, hasLength(2));
      expect(mockRepo.getProductsCalls, 1);
    });

    test('does not re-fetch within TTL when filter unchanged', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // First read
      await container.read(productListProvider.future);
      expect(mockRepo.getProductsCalls, 1);

      // Second read immediately — should use cache
      await container.read(productListProvider.future);
      expect(mockRepo.getProductsCalls, 1);
    });

    test('refresh() always re-fetches regardless of TTL', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(productListProvider.future);
      expect(mockRepo.getProductsCalls, 1);

      await container.read(productListProvider.notifier).refresh();
      expect(mockRepo.getProductsCalls, 2);
    });

    test('re-fetches when filter changes', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(productListProvider.future);
      expect(mockRepo.getProductsCalls, 1);

      // Change filter
      container.read(productFilterProvider.notifier).state =
          const ProductFilter(search: 'inverter');

      await container.read(productListProvider.future);
      expect(mockRepo.getProductsCalls, 2);
    });
  });


  group('ProductListNotifier _hasMore — cumulative count', () {
    test('stops loading when cumulative count reaches total', () async {
      // 3 total items across 2 pages (pageSize 2). After page 2, loaded=3 >= total=3 → no more.
      final mockRepo = _MockProductRepository()
        ..pageResponses = [
          ProductListResponse(
              data: [_product(1), _product(2)], total: 3, page: 1, pageSize: 2),
          ProductListResponse(
              data: [_product(3)], total: 3, page: 2, pageSize: 2),
        ];

      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      // Build
      final page1 = await container.read(productListProvider.future);
      expect(page1, hasLength(2));

      // loadMore — should load page 2
      await container.read(productListProvider.notifier).loadMore();
      final page2 = container.read(productListProvider).requireValue;
      expect(page2, hasLength(3));

      // loadMore again — _hasMore should be false, no extra API call
      final callsBefore = mockRepo.getProductsCalls;
      await container.read(productListProvider.notifier).loadMore();
      expect(mockRepo.getProductsCalls, callsBefore); // no extra call
    });

    test('does not stop early when last page has fewer items than pageSize', () async {
      // 5 total, pageSize 3. Page 1 = 3 items, page 2 = 2 items.
      // Bug: page-length check would see 2 < 5 = true and keep going.
      // Fix: cumulative 5 >= 5 = false → stops correctly.
      final mockRepo = _MockProductRepository()
        ..pageResponses = [
          ProductListResponse(
              data: [_product(1), _product(2), _product(3)], total: 5, page: 1, pageSize: 3),
          ProductListResponse(
              data: [_product(4), _product(5)], total: 5, page: 2, pageSize: 3),
        ];

      final container = ProviderContainer(
        overrides: [productRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(productListProvider.future);
      await container.read(productListProvider.notifier).loadMore();

      final callsBefore = mockRepo.getProductsCalls;
      await container.read(productListProvider.notifier).loadMore(); // should not call
      expect(mockRepo.getProductsCalls, callsBefore);
      expect(container.read(productListProvider).requireValue, hasLength(5));
    });
  });


  group('productDetailProvider cache lookup', () {
    late _MockProductRepository mockRepo;

    setUp(() {
      mockRepo = _MockProductRepository();
    });

    ProviderContainer createContainer() => ProviderContainer(
          overrides: [
            productRepositoryProvider.overrideWithValue(mockRepo),
          ],
        );

    test('returns product from list cache without API call', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Load list first
      await container.read(productListProvider.future);
      final apiCallsAfterList = mockRepo.getByIdCalls;

      // Now get detail for product already in list
      final detail = await container.read(productDetailProvider('1').future);

      expect(detail.id, 1);
      // Should not have made an additional getById call
      expect(mockRepo.getByIdCalls, apiCallsAfterList);
    });

    test('fetches from API when product not in list cache', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Don't load list — go straight to detail for unknown product
      final detail = await container.read(productDetailProvider('99').future);

      expect(detail.id, 99);
      expect(mockRepo.getByIdCalls, 1);
    });
  });
}

class _MockProductRepository implements ProductRepository {
  int getProductsCalls = 0;
  int getByIdCalls = 0;

  // Override per-call responses for pagination tests
  List<ProductListResponse>? pageResponses;
  int _pageCallIndex = 0;

  @override
  Future<ProductListResponse> getProducts(ProductFilter filter) async {
    getProductsCalls++;
    if (pageResponses != null) {
      final resp = pageResponses![_pageCallIndex.clamp(0, pageResponses!.length - 1)];
      _pageCallIndex++;
      return resp;
    }
    return ProductListResponse(
      data: [_product(1), _product(2)],
      total: 2,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    getByIdCalls++;
    return _product(int.parse(id));
  }

  @override
  Future<List<Brand>> getBrands() async => [];

  @override
  Future<List<Category>> getCategories() async => [];
}
