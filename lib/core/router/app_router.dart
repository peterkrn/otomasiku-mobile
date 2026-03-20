import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/product_detail/product_detail_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../../features/payment/payment_success_screen.dart';
import '../../features/order/order_detail_screen.dart';
import '../../features/order/orders_screen.dart';
import '../../features/shared/widgets/bottom_nav_bar.dart';
import '../../features/compare/compare_screen.dart';
import '../../features/address/edit_address_screen.dart';
import '../../features/shipping/shipping_screen.dart';
import '../../features/payment_methods/payment_methods_screen.dart';
import '../../providers/auth_provider.dart';

/// GoRouter configuration for Otomasiku Marketplace
/// M2-2: Bottom Navigation Shell with StatefulShellRoute.indexedStack

// Route names (use these for context.goNamed())
abstract class AppRoute {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
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
  static const String orderDetail = 'orderDetail';
  static const String compare = 'compare';
  static const String editAddress = 'editAddress';
  static const String paymentMethods = 'paymentMethods';
  static const String orders = 'orders';
}

// GoRouter instance with StatefulShellRoute for bottom navigation
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  // M2 dummy auth redirect — in Milestone 3, integrate with Supabase Auth
  redirect: (context, state) {
    // Read auth state from Riverpod
    final container = ProviderScope.containerOf(context, listen: false);
    final isLoggedIn = container.read(authProvider).isLoggedIn;

    final isAuthRoute = state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // Not logged in + trying to access protected route → redirect to login
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }
    // Logged in + trying to access auth route → redirect to home
    if (isLoggedIn && isAuthRoute) {
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

    // Bottom navigation shell with 5 tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PopScope(
          canPop: false, // Always intercept back button
          onPopInvokedWithResult: (didPop, result) {
            if (navigationShell.currentIndex != 0) {
              // On non-home tab → go to home tab
              navigationShell.goBranch(0);
            } else {
              // On home tab → show exit confirmation dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar Aplikasi'),
                  content: const Text('Yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            }
          },
          child: Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(index),
            ),
          ),
        );
      },
      branches: [
        // Home tab
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
        // Projects tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              name: AppRoute.projects,
              builder: (context, state) => const ProjectsScreen(),
            ),
          ],
        ),
        // Cart tab (4th position)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              name: AppRoute.cart,
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        // Profile tab (5th position)
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

    // Product detail (outside shell - standalone route)
    GoRoute(
      path: '/product/:id',
      name: AppRoute.productDetail,
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),

    // Checkout flow (outside shell)
    GoRoute(
      path: '/checkout',
      name: AppRoute.checkout,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/shipping',
      name: AppRoute.shipping,
      builder: (context, state) => const ShippingScreen(),
    ),

    // Payment
    GoRoute(
      path: '/payment/:orderId',
      name: AppRoute.payment,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return PaymentScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/payment-success/:orderId',
      name: AppRoute.paymentSuccess,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return PaymentSuccessScreen(orderId: orderId);
      },
    ),

    // Orders list
    GoRoute(
      path: '/orders',
      name: AppRoute.orders,
      builder: (context, state) => const OrdersScreen(),
    ),

    // Order detail
    GoRoute(
      path: '/order/:id',
      name: AppRoute.orderDetail,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),

    // Compare
    GoRoute(
      path: '/compare',
      name: AppRoute.compare,
      builder: (context, state) => const CompareScreen(),
    ),

    // Edit Address
    GoRoute(
      path: '/edit-address',
      name: AppRoute.editAddress,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return EditAddressScreen(extra: extra);
      },
    ),

    // Payment Methods
    GoRoute(
      path: '/payment-methods',
      name: AppRoute.paymentMethods,
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
  ],
);

// Placeholder widgets (to be replaced in future phases)
class PlaceholderCheckout extends StatelessWidget {
  const PlaceholderCheckout({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Checkout'));
}

class PlaceholderShipping extends StatelessWidget {
  const PlaceholderShipping({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Shipping'));
}

class PlaceholderPayment extends StatelessWidget {
  final String orderId;
  const PlaceholderPayment({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => Center(child: Text('Payment: $orderId'));
}

class PlaceholderPaymentSuccess extends StatelessWidget {
  final String orderId;
  const PlaceholderPaymentSuccess({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => Center(child: Text('Payment Success: $orderId'));
}

class PlaceholderOrderDetail extends StatelessWidget {
  final String orderId;
  const PlaceholderOrderDetail({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => Center(child: Text('Order Detail: $orderId'));
}

class PlaceholderCompare extends StatelessWidget {
  const PlaceholderCompare({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Compare'));
}
