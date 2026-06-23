import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/product_repository.dart';
import 'package:otomasiku_mobile/features/compare/compare_screen.dart';
import 'package:otomasiku_mobile/l10n/app_localizations.dart';
import 'package:otomasiku_mobile/models/product.dart';
import 'package:otomasiku_mobile/providers/compare_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

class _CompareTestApp extends StatelessWidget {
  const _CompareTestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CompareScreen(),
    );
  }
}

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.products);

  final List<Product> products;

  @override
  Future<List<Brand>> getBrands() async => const [];

  @override
  Future<List<Category>> getCategories() async => const [];

  @override
  Future<Product> getProductById(String id) async {
    return products.firstWhere((product) => product.idString == id);
  }

  @override
  Future<ProductListResponse> getProducts(ProductFilter filter) async {
    return ProductListResponse(
      data: products,
      total: products.length,
      page: filter.page,
      pageSize: filter.pageSize,
    );
  }
}

Product _product(int id) {
  return Product(
    id: id,
    name: 'Long Compare Product $id With Industrial Specs',
    slug: 'long-compare-product-$id',
    brandId: 1,
    categoryId: 1,
    series: 'Q Series $id',
    variant: 'Input / Output Module $id',
    price: 4700000 + (id * 100000),
    stock: 10 + id,
    version: 1,
    unit: 'pcs',
    minOrder: 1,
    isPublished: true,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
    brandObj: const Brand(id: 1, name: 'Mitsubishi Electric', slug: 'mitsubishi'),
    categoryObj: const Category(id: 1, name: 'PLC', slug: 'plc'),
    images: const [
      ProductImage(
        id: 'image-1',
        url: 'assets/images/logo.png',
        isPrimary: true,
        sortOrder: 0,
      ),
    ],
  );
}

void main() {
  testWidgets('compare screen renders on a narrow phone width without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final products = List.generate(2, (index) => _product(index + 1));
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          _FakeProductRepository(products),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(compareProvider.notifier).toggle('1');
    await container.read(compareProvider.notifier).toggle('2');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _CompareTestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Long Compare Product 1 With Industrial Specs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compare screen supports more than two products', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final products = List.generate(4, (index) => _product(index + 1));
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          _FakeProductRepository(products),
        ),
      ],
    );
    addTearDown(container.dispose);

    for (final product in products) {
      container.read(compareProvider.notifier).toggle(product.idString);
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _CompareTestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Long Compare Product 4 With Industrial Specs'), findsOneWidget);
    expect(container.read(compareProvider).count, 4);
    expect(tester.takeException(), isNull);
  });
}
