import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:otomasiku_mobile/core/router/app_router.dart';
import 'package:otomasiku_mobile/data/repositories/address_repository.dart';
import 'package:otomasiku_mobile/data/repositories/cart_repository.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';
import 'package:otomasiku_mobile/data/repositories/product_repository.dart';
import 'package:otomasiku_mobile/features/checkout/checkout_screen.dart';
import 'package:otomasiku_mobile/l10n/app_localizations.dart';
import 'package:otomasiku_mobile/models/address.dart';
import 'package:otomasiku_mobile/models/cart_item.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/models/product.dart';
import 'package:otomasiku_mobile/providers/cart_provider.dart';
import 'package:otomasiku_mobile/providers/product_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

class _HomeCatalogProbe extends ConsumerWidget {
  const _HomeCatalogProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    return Scaffold(
      body: Center(
        child: Text('Products: ${productsAsync.valueOrNull?.length ?? 0}'),
      ),
    );
  }
}

GoRouter _buildCheckoutRouter() {
  return GoRouter(
    initialLocation: '/checkout',
    routes: [
      GoRoute(
        path: '/checkout',
        name: AppRoute.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/payment/:orderId',
        name: AppRoute.payment,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Payment Placeholder'))),
      ),
      GoRoute(
        path: '/cart',
        name: AppRoute.cart,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Cart Placeholder'))),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        builder: (context, state) => const _HomeCatalogProbe(),
      ),
      GoRoute(
        path: '/shipping',
        name: AppRoute.shipping,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Shipping Placeholder'))),
      ),
    ],
  );
}

Product _product() => Product(
  id: 42,
  name: 'FR-D720S-0.4K-CHT',
  slug: 'fr-d720s-0-4k-cht',
  brandId: 1,
  categoryId: 1,
  price: 1500000,
  stock: 10,
  version: 1,
  unit: 'pcs',
  minOrder: 1,
  isPublished: true,
  createdAt: DateTime.utc(2026, 6, 1),
  updatedAt: DateTime.utc(2026, 6, 1),
);

CartItem _cartItem() => CartItem(
  id: 'item-1',
  productId: '42',
  quantity: 2,
  productSnapshot: const CartProductSnapshot(
    name: 'FR-D720S-0.4K-CHT',
    price: 1500000,
    primaryImageUrl: '',
  ),
  createdAt: DateTime.utc(2026, 6, 1),
);

Address _address() => Address(
  id: 'addr-1',
  label: 'Warehouse',
  recipient: 'Test User',
  phone: '081234567890',
  street: 'Jl. Industri No. 1',
  city: 'Jakarta',
  province: 'DKI Jakarta',
  postalCode: '12345',
  isDefault: true,
  createdAt: DateTime.utc(2026, 6, 1),
);

class _FakeProductRepository implements ProductRepository {
  int getProductsCalls = 0;

  @override
  Future<List<Brand>> getBrands() async => const [];

  @override
  Future<List<Category>> getCategories() async => const [];

  @override
  Future<Product> getProductById(String id) async => _product();

  @override
  Future<ProductListResponse> getProducts(ProductFilter filter) async {
    getProductsCalls++;
    return ProductListResponse(
      data: [_product()],
      total: 1,
      page: filter.page,
      pageSize: filter.pageSize,
    );
  }
}

class _FakeCartRepository implements CartRepository {
  @override
  Future<CartItem> addItem({
    required String productId,
    required int quantity,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearCart() async {}

  @override
  Future<CartResponse> getCart() async {
    return CartResponse(items: [_cartItem()], totalItems: 2);
  }

  @override
  Future<void> removeItem(String cartItemId) async {}

  @override
  Future<CartItem> updateItem({
    required String cartItemId,
    required int quantity,
  }) {
    throw UnimplementedError();
  }
}

class _FakeAddressRepository implements AddressRepository {
  @override
  Future<Address> createAddress(AddressInput input) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAddress(String id) async {}

  @override
  Future<Address> getAddressById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Address>> getAddresses() async => [_address()];

  @override
  Future<Address> updateAddress(String id, AddressInput input) {
    throw UnimplementedError();
  }
}

class _FakeOrderRepository implements OrderRepository {
  @override
  Future<void> confirmReceived(String orderId) async {}

  @override
  Future<CreateOrderResult> createOrder({
    required String addressId,
    required List<String> cartItemIds,
    String? notes,
    required String idempotencyKey,
  }) async {
    return const CreateOrderResult(
      orderId: 'order-1',
      orderNumber: 'ORD-001',
      totalAmount: 3000000,
    );
  }

  @override
  Future<Order> getOrderById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<OrderListResponse> getOrders({int page = 1, int pageSize = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<List<OrderStatusHistory>> getStatusHistory(String orderId) async =>
      const [];
}

void main() {
  testWidgets(
    'successful checkout invalidates the cached product list before returning to catalog',
    (tester) async {
      final productRepository = _FakeProductRepository();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(productRepository),
          cartRepositoryProvider.overrideWithValue(_FakeCartRepository()),
          addressRepositoryProvider.overrideWithValue(_FakeAddressRepository()),
          orderRepositoryProvider.overrideWithValue(_FakeOrderRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(productListProvider.future);
      expect(productRepository.getProductsCalls, 1);

      await container.read(cartProvider.notifier).loadCart();
      container.read(selectedCartItemsProvider.notifier).state = {'item-1'};

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _RouterTestApp(router: _buildCheckoutRouter()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create Invoice & Pay'));
      await tester.tap(find.text('Create Invoice & Pay'));
      await tester.pumpAndSettle();

      final router = GoRouter.of(
        tester.element(find.text('Payment Placeholder')),
      );
      router.goNamed(AppRoute.home);
      await tester.pumpAndSettle();

      expect(productRepository.getProductsCalls, 2);
      expect(container.read(cartProvider).items, isEmpty);
      expect(container.read(selectedCartItemsProvider), isEmpty);
    },
  );
}
