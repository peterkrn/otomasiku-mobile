import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../shared/widgets/otomasiku_brand_lockup.dart';

/// Modern Landing Page for Otomasiku
/// Dark hero aesthetic with gradient overlays and glassmorphism
/// Clean, purposeful design without AI slop
class LandingPageScreen extends ConsumerStatefulWidget {
  const LandingPageScreen({super.key});

  @override
  ConsumerState<LandingPageScreen> createState() => _LandingPageScreenState();
}

class _LandingPageScreenState extends ConsumerState<LandingPageScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _heroScale;

  late List<AnimationController> _statControllers;
  late List<Animation<double>> _statAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _heroSlide = Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _heroController,
            curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _heroScale = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Trust card animations
    _statControllers = List.generate(4, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
    });

    _statAnimations = _statControllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    }).toList();

    _heroController.forward();

    for (var i = 0; i < _statControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 600 + (i * 80)), () {
        if (mounted) _statControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    for (var controller in _statControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF1A1A1A),
                  Color(0xFF0F0F0F),
                ],
              ),
            ),
          ),

          // Subtle pattern overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 0.8,
                colors: [
                  AppColors.mitsubishiRed.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: AnimatedBuilder(
                animation: _heroController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _heroFade,
                    child: SlideTransition(
                      position: _heroSlide,
                      child: ScaleTransition(
                        scale: _heroScale,
                        child: Column(
                          children: [
                            // Top Navigation
                            _buildTopBar(locale, l10n),

                            const SizedBox(height: 40),

                            // Hero Section
                            _buildHeroSection(l10n),

                            const SizedBox(height: 48),

                            // Trust Section with glassmorphism
                            _buildTrustSection(l10n),

                            const SizedBox(height: 40),

                            // Brand Partners
                            _buildBrandPartners(l10n),

                            const SizedBox(height: 48),

                            // CTA Section
                            _buildCTASection(context, l10n),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Locale locale, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OtomasikuBrandLockup(
              logoSize: 40,
              classicLogo: true,
              showTagline: false,
              titleStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Language Toggle
          _buildLanguageToggle(locale, l10n),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(Locale locale, AppLocalizations l10n) {
    final isIndonesian = locale.languageCode == 'id';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 112),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                  const SizedBox(width: 10),
                  _buildLanguageOption(
                    l10n.landingLanguageLabelId,
                    isIndonesian,
                  ),
                  const SizedBox(width: 6),
                  _buildLanguageOption(
                    l10n.landingLanguageLabelEn,
                    !isIndonesian,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.mitsubishiRed.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          color: Colors.white.withValues(alpha: active ? 0.96 : 0.6),
        ),
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Official Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mitsubishiRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.mitsubishiRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.mitsubishiRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.landingHeroBadge,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mitsubishiRed.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                OtomasikuBrandLockup(
                  vertical: true,
                  center: true,
                  logoSize: isCompact ? 76 : 88,
                  classicLogo: false,
                  spacing: 18,
                  titleStyle: GoogleFonts.inter(
                    fontSize: isCompact ? 34 : 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 1,
                    color: Colors.white,
                  ),
                  taglineStyle: GoogleFonts.inter(
                    fontSize: isCompact ? 13 : 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.66),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.landingHeadline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isCompact ? 24 : 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.landingSubheadline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isCompact ? 14 : 15,
                    height: 1.75,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrustSection(AppLocalizations l10n) {
    final trustItems = [
      (
        l10n.landingTrustOriginalTitle,
        l10n.landingTrustOriginalBody,
        Icons.verified_outlined,
      ),
      (
        l10n.landingTrustB2bPriceTitle,
        l10n.landingTrustB2bPriceBody,
        Icons.business_center_outlined,
      ),
      (
        l10n.landingTrustCompetitiveTitle,
        l10n.landingTrustCompetitiveBody,
        Icons.local_offer_outlined,
      ),
      (
        l10n.landingTrustVerificationTitle,
        l10n.landingTrustVerificationBody,
        Icons.verified_user_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 520
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            final items = trustItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return SizedBox(
                width: cardWidth,
                child: _buildAnimatedTrustItem(
                  index,
                  item.$1,
                  item.$2,
                  item.$3,
                ),
              );
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.landingTrustSectionTitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.landingTrustSectionSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(spacing: 12, runSpacing: 12, children: items),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedTrustItem(
    int index,
    String title,
    String body,
    IconData icon,
  ) {
    return AnimatedBuilder(
      animation: _statAnimations[index],
      builder: (context, child) {
        final animationValue = _statAnimations[index].value;
        final opacity = animationValue.clamp(0.0, 1.0).toDouble();

        return Transform.translate(
          offset: Offset(0, 18 * (1 - opacity)),
          child: Transform.scale(
            scale: 0.94 + (animationValue * 0.06),
            child: Opacity(
              opacity: opacity,
              child: _buildTrustItem(title, body, icon),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrustItem(String title, String body, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.mitsubishiRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.mitsubishiRed.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPartners(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            l10n.landingBrandTitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              l10n.landingBrandSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.64),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildBrandLogo('MITSUBISHI'),
              _buildBrandLogo('DANFOSS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.landingFooterTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.landingFooterSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.7,
              color: Colors.white.withValues(alpha: 0.66),
            ),
          ),
          const SizedBox(height: 24),
          // Primary CTA - Login
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mitsubishiRed.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.goNamed(AppRoute.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mitsubishiRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(60),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.login,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary CTA - Browse Catalog
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.goNamed(AppRoute.home),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.grid_view,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  Text(
                    l10n.landingViewCatalog,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Contact Admin
          TextButton.icon(
            onPressed: () => WhatsAppHelper.openRfq(),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            icon: Icon(
              Icons.headset_mic_outlined,
              size: 18,
              color: Colors.white.withValues(alpha: 0.58),
            ),
            label: Text(
              l10n.landingContactAdmin,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.58),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
