import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

/// Splash screen for Otomasiku Marketplace
/// Matches ui-otomasiku-marketplace/index.html
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeUpAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeUpAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Auto navigate to login after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(AppRoute.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a1a1a),
                  Color(0xFF0f0f0f),
                  Color(0xFF2a2a2a),
                ],
              ),
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeUpAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Mitsubishi logo with 3-diamond grid
                  _buildMitsubishiLogo(),

                  const SizedBox(height: 24),

                  // OTOMASIKU branding
                  const Text(
                    'OTOMASIKU',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Industrial Solutions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Distributor badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mitsubishiRed.withValues(alpha:0.1),
                      border: Border.all(
                        color: AppColors.mitsubishiRed.withValues(alpha:0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Distributor Resmi Indonesia',
                      style: TextStyle(
                        color: AppColors.mitsubishiRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Stats cards
                  _buildStatsCards(),

                  const SizedBox(height: 24),

                  // Brand partners
                  _buildBrandPartners(),

                  const SizedBox(height: 32),

                  // CTA Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(AppRoute.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mitsubishiRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.mitsubishiRed.withValues(alpha:0.4),
                        ),
                        child: const Text(
                          'Jelajahi Katalog',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMitsubishiLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.mitsubishiRed,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.mitsubishiRed.withValues(alpha:0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DiamondGridPainter(),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.08),
            border: Border.all(
              color: Colors.white.withValues(alpha:0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('5000+', 'Produk Tersedia'),
                _buildStatItem('24 Jam', 'Pengiriman'),
                _buildStatItem('BCA VA', 'Pembayaran', isRed: true),
                _buildStatItem('100%', 'Original'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool isRed = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isRed ? AppColors.mitsubishiRed : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha:0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBrandPartners() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Official Partner:',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha:0.4),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'MITSUBISHI',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'DANFOSS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the 3-diamond Mitsubishi logo
class _DiamondGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final diamondSize = size.width / 6;

    // Top diamond
    _drawDiamond(
      canvas,
      Offset(size.width / 2, diamondSize),
      diamondSize * 0.8,
      paint,
    );

    // Bottom left diamond
    _drawDiamond(
      canvas,
      Offset(size.width / 2 - diamondSize, diamondSize * 2),
      diamondSize * 0.8,
      paint,
    );

    // Bottom right diamond
    _drawDiamond(
      canvas,
      Offset(size.width / 2 + diamondSize, diamondSize * 2),
      diamondSize * 0.8,
      paint,
    );
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final halfSize = size / 2;

    path.moveTo(center.dx, center.dy - halfSize); // Top
    path.lineTo(center.dx + halfSize, center.dy); // Right
    path.lineTo(center.dx, center.dy + halfSize); // Bottom
    path.lineTo(center.dx - halfSize, center.dy); // Left
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
