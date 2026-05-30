import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';

class _BannerData {
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String? categorySlug;

  const _BannerData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.categorySlug,
  });
}

class HeroBanner extends ConsumerStatefulWidget {
  const HeroBanner({super.key});

  @override
  ConsumerState<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends ConsumerState<HeroBanner> {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  static const _banners = [
    _BannerData(
      badge: 'New Arrival',
      title: 'Melsec iQ-R Series',
      subtitle: 'Next-generation PLC dengan performa tinggi untuk industri 4.0',
      gradient: [Color(0xFF1e293b), Color(0xFF0f172a), AppColors.mitsubishiRed],
      categorySlug: 'plc',
    ),
    _BannerData(
      badge: 'Best Seller',
      title: 'FR-E800 Series',
      subtitle: 'Inverter compact dengan fitur IoT built-in untuk efisiensi energi',
      gradient: [Color(0xFF1e3a5f), Color(0xFF0d253f), Color(0xFF005A8C)],
      categorySlug: 'inverter',
    ),
    _BannerData(
      badge: 'Promo',
      title: 'GOT2000 Series',
      subtitle: 'HMI touchscreen dengan visualisasi data real-time',
      gradient: [Color(0xFF2d1b4e), Color(0xFF1a0f2e), Color(0xFF7c3aed)],
      categorySlug: 'hmi',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _kMiddlePage);
    _startAutoSlide();
  }

  static const _kMiddlePage = 1000;

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index % _banners.length),
            itemBuilder: (context, index) => _buildBannerCard(_banners[index % _banners.length]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.mitsubishiRed
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(_BannerData banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  banner.badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                banner.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                banner.subtitle,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _onBannerTap(banner),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lihat Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onBannerTap(_BannerData banner) {
    // Try to find a matching product from the loaded list
    final productsAsync = ref.read(productListProvider);
    if (productsAsync.hasValue) {
      final products = productsAsync.requireValue;
      Product? match;
      if (banner.categorySlug != null) {
        match = products.where((p) => p.category.slug == banner.categorySlug).firstOrNull;
      }
      if (match != null) {
        context.pushNamed(AppRoute.productDetail, pathParameters: {'id': match.idString});
        return;
      }
    }
    // Fallback: navigate to search with category filter
    if (banner.categorySlug != null) {
      ref.read(productFilterProvider.notifier).state = ref.read(productFilterProvider).copyWith(
        category: banner.categorySlug,
      );
    }
    context.go('/search');
  }
}
