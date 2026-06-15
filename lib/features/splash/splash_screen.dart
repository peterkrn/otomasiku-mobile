import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/router/remembered_route_store.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../shared/widgets/otomasiku_brand_lockup.dart';

/// Simplified SplashScreen - shows only logo and loading spinner
/// Navigation logic:
/// - Authenticated users → Last viewed page or Home
/// - Unauthenticated users → LandingPage
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isRouting = false;
  bool _isDarkMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation();
    });
  }

  Future<void> _loadThemePreference() async {
    // Check if user has explicitly set dark mode in their profile
    final themeMode = ref.read(themeProvider);
    setState(() {
      _isDarkMode = themeMode == ThemeMode.dark;
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _handleNavigation() async {
    if (!mounted || _isRouting) return;

    // Wait for auth state to be bootstrapped
    final authState = ref.read(authProvider);
    if (!authState.isBootstrapped) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      _handleNavigation();
      return;
    }

    _isRouting = true;

    if (authState.isAuthenticated) {
      // Authenticated: Go to last viewed page or Home
      final rememberedRoute = await RememberedRouteStore.instance.read();
      if (!mounted) return;

      if (rememberedRoute != null) {
        context.goNamed(
          rememberedRoute.name,
          pathParameters: rememberedRoute.pathParameters,
          queryParameters: rememberedRoute.queryParameters,
        );
      } else {
        context.goNamed(AppRoute.home);
      }
    } else {
      // Unauthenticated: Go to LandingPage
      if (!mounted) return;
      context.goNamed(AppRoute.landing);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: OtomasikuBrandLockup(
                        vertical: true,
                        center: true,
                        logoSize: 88,
                        classicLogo: true,
                        spacing: 20,
                        titleStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3.2,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        taglineStyle: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: _isDarkMode
                              ? Colors.white.withValues(alpha: 0.64)
                              : Colors.black.withValues(alpha: 0.58),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Loading indicator
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.mitsubishiRed.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
