import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/feature_flags.dart';
import '../../l10n/app_localizations.dart';
import 'remembered_route_store.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/delete_account_screen.dart';
import '../../features/product_detail/product_detail_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/payment/payment_success_screen.dart';
import '../../features/payment/payment_pending_screen.dart';
import '../../features/order/order_detail_screen.dart';
import '../../features/order/orders_screen.dart';
import '../../features/shared/widgets/bottom_nav_bar.dart';
import '../../features/compare/compare_screen.dart';
import '../../features/home/widgets/compare_bar.dart';
import '../../features/address/edit_address_screen.dart';
import '../../features/shipping/shipping_screen.dart';
import '../../features/payment_methods/payment_methods_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/landing/landing_page_screen.dart';
import '../../providers/auth_provider.dart';
import '../../features/projects/projects_screen.dart';

/// GoRouter configuration for Otomasiku Marketplace
/// M2-2: Bottom Navigation Shell with StatefulShellRoute.indexedStack

// Route names (use these for context.goNamed())
abstract class AppRoute {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String resetPassword = 'resetPassword';
  static const String home = 'home';
  static const String search = 'search';
  static const String projects = 'projects';
  static const String profile = 'profile';
  static const String productDetail = 'productDetail';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String shipping = 'shipping';
  static const String payment = 'payment';
  static const String paymentSuccess = 'paymentSuccess';
  static const String paymentPending = 'paymentPending';
  static const String orderDetail = 'orderDetail';
  static const String compare = 'compare';
  static const String editAddress = 'editAddress';
  static const String paymentMethods = 'paymentMethods';
  static const String orders = 'orders';
  static const String editProfile = 'editProfile';
  static const String settings = 'settings';
  static const String deleteAccount = 'deleteAccount';
  static const String landing = 'landing';
}

// Root navigator key — used by routes outside the shell to avoid element tree conflicts
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// GoRouter instance with StatefulShellRoute for bottom navigation
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isSplash = state.matchedLocation == '/';

    final isAuthRoute =
        isSplash ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/reset-password' ||
        state.matchedLocation == '/landing';

    if (isAuthenticated && !isAuthRoute && state.name != null) {
      unawaited(RememberedRouteStore.instance.saveFromState(state));
    }

    // Splash decides whether to show landing content or restore the last route.
    if (isSplash) return null;

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }
    if (isAuthenticated && isAuthRoute) {
      return '/home';
    }
    return null;
  },
  routes: [
    // Splash
    GoRoute(
      path: '/',
      name: AppRoute.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: '/login',
      name: AppRoute.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: AppRoute.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: AppRoute.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      name: AppRoute.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // Landing Page (for unauthenticated users)
    GoRoute(
      path: '/landing',
      name: AppRoute.landing,
      builder: (context, state) => const LandingPageScreen(),
    ),

    if (!isProjectFeatureEnabled)
      GoRoute(
        path: '/projects',
        name: AppRoute.projects,
        redirect: (context, state) => '/home',
      ),

    // Bottom navigation shell with the currently enabled tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ShellScaffold(
          navigationShell: navigationShell,
          child: Scaffold(
            body: navigationShell,
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Global compare bar - appears on all pages when products are selected
                const CompareBar(),
                BottomNavBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => navigationShell.goBranch(index),
                ),
              ],
            ),
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: AppRoute.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Search tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              name: AppRoute.search,
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        if (isProjectFeatureEnabled)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/projects',
                name: AppRoute.projects,
                builder: (context, state) => const ProjectsScreen(),
              ),
            ],
          ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: AppRoute.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Edit Profile (outside shell)
    GoRoute(
      path: '/edit-profile',
      name: AppRoute.editProfile,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EditProfileScreen(),
    ),

    // Product detail (outside shell - standalone route)
    GoRoute(
      path: '/product/:id',
      name: AppRoute.productDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),

    // Cart (outside shell)
    GoRoute(
      path: '/cart',
      name: AppRoute.cart,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CartScreen(),
    ),

    // Checkout flow (outside shell)
    GoRoute(
      path: '/checkout',
      name: AppRoute.checkout,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/shipping',
      name: AppRoute.shipping,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ShippingScreen(),
    ),

    // Payment
    GoRoute(
      path: '/payment/:orderId',
      name: AppRoute.payment,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        final totalAmount =
            int.tryParse(state.uri.queryParameters['totalAmount'] ?? '0') ?? 0;
        return PaymentScreen(orderId: orderId, totalAmount: totalAmount);
      },
    ),
    GoRoute(
      path: '/payment-success/:orderId',
      name: AppRoute.paymentSuccess,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        final totalAmount =
            int.tryParse(state.uri.queryParameters['totalAmount'] ?? '0') ?? 0;
        return PaymentSuccessScreen(orderId: orderId, totalAmount: totalAmount);
      },
    ),
    GoRoute(
      path: '/payment-pending/:orderId',
      name: AppRoute.paymentPending,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        final totalAmount =
            int.tryParse(state.uri.queryParameters['totalAmount'] ?? '0') ?? 0;
        return PaymentPendingScreen(orderId: orderId, totalAmount: totalAmount);
      },
    ),

    // Orders list
    GoRoute(
      path: '/orders',
      name: AppRoute.orders,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OrdersScreen(),
    ),

    // Order detail
    GoRoute(
      path: '/order/:id',
      name: AppRoute.orderDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),

    // Compare
    GoRoute(
      path: '/compare',
      name: AppRoute.compare,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CompareScreen(),
    ),

    // Edit Address
    GoRoute(
      path: '/edit-address',
      name: AppRoute.editAddress,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final addressId = state.uri.queryParameters['addressId'];
        return EditAddressScreen(addressId: addressId);
      },
    ),

    // Payment Methods
    GoRoute(
      path: '/payment-methods',
      name: AppRoute.paymentMethods,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PaymentMethodsScreen(),
    ),

    // Settings
    GoRoute(
      path: '/settings',
      name: AppRoute.settings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/delete-account',
      name: AppRoute.deleteAccount,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DeleteAccountScreen(),
    ),
  ],
);

class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final Widget child;

  const _ShellScaffold({required this.navigationShell, required this.child});

  Future<void> _handleExitAttempt(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exitAppTitle),
        content: Text(l10n.exitAppMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
          return;
        }

        await _handleExitAttempt(context);
      },
      child: child,
    );
  }
}
