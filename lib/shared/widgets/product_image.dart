import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

enum _ImageVariant { card, detail }

class ProductNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? categorySlug;
  final _ImageVariant _variant;

  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.categorySlug,
  }) : _variant = _ImageVariant.card;

  /// Gallery / detail variant: shows an error tile with retry on tap.
  const ProductNetworkImage.detail({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.categorySlug,
  }) : _variant = _ImageVariant.detail;

  @override
  State<ProductNetworkImage> createState() => _ProductNetworkImageState();
}

class _ProductNetworkImageState extends State<ProductNetworkImage> {
  // Bump to force CachedNetworkImage to retry the URL.
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.imageUrl.startsWith('assets/')) {
      return Image.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isDark),
      );
    }

    return CachedNetworkImage(
      key: ValueKey('${widget.imageUrl}_$_retryKey'),
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => Container(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
      ),
      errorWidget: (context, url, error) => widget._variant == _ImageVariant.detail
          ? _buildDetailError(context, isDark, url)
          : _buildPlaceholder(isDark),
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

  Widget _buildDetailError(BuildContext context, bool isDark, String url) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => setState(() => _retryKey++),
      child: Container(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.errorImageLoad,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    url,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Icon(
                Icons.refresh,
                size: 18,
                color: AppColors.mitsubishiRed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _iconForCategory {
    return switch (widget.categorySlug) {
      'inverter' => Icons.bolt,
      'plc' => Icons.memory,
      'hmi' => Icons.desktop_mac,
      'servo' => Icons.settings,
      _ => Icons.inventory_2,
    };
  }
}
