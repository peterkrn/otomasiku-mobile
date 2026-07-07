import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:otomasiku_mobile/core/auth/auth_service.dart';
import 'package:otomasiku_mobile/core/auth/token_storage.dart';
import 'package:otomasiku_mobile/core/router/app_router.dart';
import 'package:otomasiku_mobile/data/repositories/auth_repository.dart';
import 'package:otomasiku_mobile/data/repositories/cart_repository.dart';
import 'package:otomasiku_mobile/data/repositories/product_repository.dart';
import 'package:otomasiku_mobile/data/repositories/profile_repository.dart';
import 'package:otomasiku_mobile/features/product_detail/product_detail_screen.dart';
import 'package:otomasiku_mobile/l10n/app_localizations.dart';
import 'package:otomasiku_mobile/models/cart_item.dart';
import 'package:otomasiku_mobile/models/product.dart';
import 'package:otomasiku_mobile/models/user_profile.dart';
import 'package:otomasiku_mobile/providers/auth_provider.dart';
import 'package:otomasiku_mobile/providers/cart_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Session, User;

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

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/products/42',
    routes: [
      GoRoute(
        path: '/products/:id',
        name: AppRoute.productDetail,
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout',
        name: AppRoute.checkout,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Checkout Placeholder'))),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home Placeholder'))),
      ),
    ],
  );
}

Product _product() => Product(
  id: 42,
  name: 'FR-D720S-0.4K-CHT',
  slug: 'fr-d720s-0-4k-cht',
  sku: 'SKU-42',
  brandId: 1,
  categoryId: 1,
  price: 1500000,
  stock: 10,
  version: 1,
  unit: 'pcs',
  minOrder: 1,
  descriptionId: 'Industrial inverter',
  descriptionEn: 'Industrial inverter',
  isPublished: true,
  createdAt: DateTime.utc(2026, 6, 1),
  updatedAt: DateTime.utc(2026, 6, 1),
  images: const [
    ProductImage(
      id: 'img-1',
      url: 'assets/images/placeholder.png',
      isPrimary: true,
      sortOrder: 0,
    ),
  ],
);

class _FakeProductRepository implements ProductRepository {
  @override
  Future<List<Brand>> getBrands() async => const [];

  @override
  Future<List<Category>> getCategories() async => const [];

  @override
  Future<Product> getProductById(String id) async => _product();

  @override
  Future<ProductListResponse> getProducts(ProductFilter filter) async {
    return ProductListResponse(
      data: [_product()],
      total: 1,
      page: filter.page,
      pageSize: filter.pageSize,
    );
  }
}

class _DelayedCartRepository implements CartRepository {
  static const persistedCartItemId = '11111111-1111-4111-8111-111111111111';

  @override
  Future<CartItem> addItem({
    required String productId,
    required int quantity,
    required String idempotencyKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return CartItem(
      id: persistedCartItemId,
      productId: productId,
      quantity: quantity,
      productSnapshot: const CartProductSnapshot(
        name: 'FR-D720S-0.4K-CHT',
        price: 1500000,
        primaryImageUrl: '',
      ),
      createdAt: DateTime.utc(2026, 6, 1),
    );
  }

  @override
  Future<void> clearCart() async {}

  @override
  Future<CartResponse> getCart() async =>
      const CartResponse(items: [], totalItems: 0);

  @override
  Future<void> removeItem(String cartItemId) async {}

  @override
  Future<CartItem> updateItem({
    required String cartItemId,
    required int quantity,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeAuthService implements AuthService {
  _FakeAuthService(this._session);

  final Session? _session;
  final StreamController<AuthStateChangePayload> _authStateController =
      StreamController<AuthStateChangePayload>.broadcast();

  @override
  Stream<AuthStateChangePayload> get authStateChanges =>
      _authStateController.stream;

  @override
  Session? get currentSession => _session;

  @override
  bool get isAuthenticated => _session != null;

  @override
  Future<AuthResult> login(String email, String password) async {
    return const AuthResult(status: AuthResultStatus.failure);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshSession() async => false;

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String? fullName,
  ) async {
    return const AuthResult(status: AuthResultStatus.failure);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    return const AuthResult(status: AuthResultStatus.failure);
  }

  @override
  Future<AuthResult> deleteAccount() async {
    return const AuthResult(status: AuthResultStatus.success);
  }

  Future<void> dispose() async {
    await _authStateController.close();
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> bootstrap() async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getProfile() {
    throw UnimplementedError();
  }

  @override
  Future<void> registerDeviceToken(String fcmToken) async {}

  @override
  Future<void> removeDeviceToken(String fcmToken) async {}

  @override
  Future<String> uploadAvatar(File imageFile) {
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> updateProfile(ProfileInput input) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount() async {}
}

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearFcmToken() async {}

  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getFcmToken() async => null;

  @override
  Future<bool> getRememberMe() async => true;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveFcmToken(String token) async {}

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}

  @override
  Future<void> setRememberMe(bool value) async {}
}

Session _testSession() {
  return Session(
    accessToken: 'header.payload.signature',
    refreshToken: 'refresh-token',
    tokenType: 'bearer',
    user: const User(
      id: 'user-001',
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{'full_name': 'Test User'},
      aud: 'authenticated',
      email: 'test@otomasi.com',
      createdAt: '2026-06-12T00:00:00.000Z',
    ),
  );
}

void main() {
  testWidgets(
    'buy now keeps the persisted cart item ID selected after add-to-cart resolves',
    (tester) async {
      final authService = _FakeAuthService(_testSession());
      addTearDown(authService.dispose);
      final authRepository = _FakeAuthRepository();
      final profileRepository = _FakeProfileRepository();
      final tokenStorage = _FakeTokenStorage();
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(_FakeProductRepository()),
          cartRepositoryProvider.overrideWithValue(_DelayedCartRepository()),
          authServiceProvider.overrideWithValue(authService),
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              authService,
              authRepository,
              profileRepository,
              tokenStorage,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(authProvider.notifier).state = const AuthState(
        isAuthenticated: true,
        isBootstrapped: true,
        userId: 'user-001',
        email: 'test@otomasi.com',
        name: 'Test User',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _RouterTestApp(router: _buildRouter()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Buy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      expect(find.text('Checkout Placeholder'), findsOneWidget);

      final selectedIds = container.read(selectedCartItemsProvider);
      expect(selectedIds, {_DelayedCartRepository.persistedCartItemId});
      expect(selectedIds.single.startsWith('local-'), isFalse);
      expect(
        container.read(cartProvider).items.single.id,
        _DelayedCartRepository.persistedCartItemId,
      );
    },
  );
}
