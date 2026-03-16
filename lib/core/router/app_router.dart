import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';

/// GoRouter configuration for Otomasiku Marketplace
/// M2-1: Splash, Login & Register screens implemented

// Route names (use these for context.goNamed())
abstract class AppRoute {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String search = 'search';
  static const String productDetail = 'productDetail';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String shipping = 'shipping';
  static const String payment = 'payment';
  static const String paymentSuccess = 'paymentSuccess';
  static const String orderDetail = 'orderDetail';
  static const String profile = 'profile';
  static const String projects = 'projects';
  static const String compare = 'compare';
}

// GoRouter instance
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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

    // Main screens
    GoRoute(
      path: '/home',
      name: AppRoute.home,
      builder: (context, state) => const Scaffold(body: PlaceholderHome()),
    ),
    GoRoute(
      path: '/search',
      name: AppRoute.search,
      builder: (context, state) => const Scaffold(body: PlaceholderSearch()),
    ),

    // Product detail
    GoRoute(
      path: '/product/:id',
      name: AppRoute.productDetail,
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return Scaffold(body: PlaceholderProductDetail(productId: productId));
      },
    ),

    // Cart & Checkout
    GoRoute(
      path: '/cart',
      name: AppRoute.cart,
      builder: (context, state) => const Scaffold(body: PlaceholderCart()),
    ),
    GoRoute(
      path: '/checkout',
      name: AppRoute.checkout,
      builder: (context, state) => const Scaffold(body: PlaceholderCheckout()),
    ),
    GoRoute(
      path: '/shipping',
      name: AppRoute.shipping,
      builder: (context, state) => const Scaffold(body: PlaceholderShipping()),
    ),

    // Payment
    GoRoute(
      path: '/payment/:orderId',
      name: AppRoute.payment,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return Scaffold(body: PlaceholderPayment(orderId: orderId));
      },
    ),
    GoRoute(
      path: '/payment-success/:orderId',
      name: AppRoute.paymentSuccess,
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return Scaffold(body: PlaceholderPaymentSuccess(orderId: orderId));
      },
    ),

    // Order detail
    GoRoute(
      path: '/order/:id',
      name: AppRoute.orderDetail,
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return Scaffold(body: PlaceholderOrderDetail(orderId: orderId));
      },
    ),

    // Profile & Projects
    GoRoute(
      path: '/profile',
      name: AppRoute.profile,
      builder: (context, state) => const Scaffold(body: PlaceholderProfile()),
    ),
    GoRoute(
      path: '/projects',
      name: AppRoute.projects,
      builder: (context, state) => const Scaffold(body: PlaceholderProjects()),
    ),
    GoRoute(
      path: '/compare',
      name: AppRoute.compare,
      builder: (context, state) => const Scaffold(body: PlaceholderCompare()),
    ),
  ],
);

// Placeholder widgets (replace with real screens in M2-1 through M2-9)
class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Home / Product Catalog'));
}

class PlaceholderSearch extends StatelessWidget {
  const PlaceholderSearch({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Search'));
}

class PlaceholderProductDetail extends StatelessWidget {
  final String productId;
  const PlaceholderProductDetail({super.key, required this.productId});
  @override
  Widget build(BuildContext context) => Center(child: Text('Product Detail: $productId'));
}

class PlaceholderCart extends StatelessWidget {
  const PlaceholderCart({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Cart'));
}

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

class PlaceholderProfile extends StatelessWidget {
  const PlaceholderProfile({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Profile'));
}

class PlaceholderProjects extends StatelessWidget {
  const PlaceholderProjects({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Projects'));
}

class PlaceholderCompare extends StatelessWidget {
  const PlaceholderCompare({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Compare'));
}
