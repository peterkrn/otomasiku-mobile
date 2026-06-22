import 'package:flutter/material.dart';

import '../../core/constants/branding.dart';
import 'otomasiku_logo.dart';

class OtomasikuBrandLockup extends StatelessWidget {
  const OtomasikuBrandLockup({
    super.key,
    this.vertical = false,
    this.showTagline = true,
    this.center = false,
    this.logoSize = 48,
    this.spacing = 12,
    this.titleStyle,
    this.taglineStyle,
    this.titleMaxLines = 1,
    this.taglineMaxLines,
  });

  final bool vertical;
  final bool showTagline;
  final bool center;
  final double logoSize;
  final double spacing;
  final TextStyle? titleStyle;
  final TextStyle? taglineStyle;
  final int titleMaxLines;
  final int? taglineMaxLines;

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          OtomasikuLogo(size: logoSize),
          SizedBox(height: spacing),
          _BrandTextBlock(
            center: center,
            showTagline: showTagline,
            titleStyle: titleStyle,
            taglineStyle: taglineStyle,
            titleMaxLines: titleMaxLines,
            taglineMaxLines: taglineMaxLines ?? 3,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OtomasikuLogo(size: logoSize),
        SizedBox(width: spacing),
        Flexible(
          child: _BrandTextBlock(
            center: false,
            showTagline: showTagline,
            titleStyle: titleStyle,
            taglineStyle: taglineStyle,
            titleMaxLines: titleMaxLines,
            taglineMaxLines: taglineMaxLines ?? 2,
          ),
        ),
      ],
    );
  }
}

class _BrandTextBlock extends StatelessWidget {
  const _BrandTextBlock({
    required this.center,
    required this.showTagline,
    required this.titleStyle,
    required this.taglineStyle,
    required this.titleMaxLines,
    required this.taglineMaxLines,
  });

  final bool center;
  final bool showTagline;
  final TextStyle? titleStyle;
  final TextStyle? taglineStyle;
  final int titleMaxLines;
  final int taglineMaxLines;

  @override
  Widget build(BuildContext context) {
    final textAlign = center ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          otomasikuAppTitle,
          textAlign: textAlign,
          maxLines: titleMaxLines,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            otomasikuMarketplaceTagline,
            textAlign: textAlign,
            maxLines: taglineMaxLines,
            overflow: TextOverflow.ellipsis,
            style: taglineStyle,
          ),
        ],
      ],
    );
  }
}
