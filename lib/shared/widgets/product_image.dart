import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ProductNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? categorySlug;

  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.categorySlug,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isDark),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(isDark),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          _iconForCategory,
          size: 32,
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
        ),
      ),
    );
  }

  IconData get _iconForCategory {
    return switch (categorySlug) {
      'inverter' => Icons.bolt,
      'plc' => Icons.memory,
      'hmi' => Icons.desktop_mac,
      'servo' => Icons.settings,
      _ => Icons.inventory_2,
    };
  }
}
