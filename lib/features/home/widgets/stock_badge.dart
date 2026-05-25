import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product.dart';

/// Displays stock status badge for product cards.
/// Matches actual StockStatus enum: inStock, lowStock, outOfStock, leadTime
class StockBadge extends StatelessWidget {
  final StockStatus status;
  final int? stockCount;
  final String? leadTime;

  const StockBadge({
    super.key,
    required this.status,
    this.stockCount,
    this.leadTime,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String text;
    Color color;

    switch (status) {
      case StockStatus.inStock:
        if (stockCount != null && stockCount! >= 5) {
          text = l10n.stockUnit(stockCount!);
          color = const Color(0xFF10B981); // Green
        } else {
          text = l10n.stockLow(stockCount ?? 0);
          color = const Color(0xFFF59E0B); // Orange
        }
        break;
      case StockStatus.lowStock:
        text = l10n.stockLow(stockCount ?? 0);
        color = const Color(0xFFF59E0B); // Orange
        break;
      case StockStatus.outOfStock:
        text = l10n.stockEmpty;
        color = const Color(0xFFEF4444); // Red
        break;
      case StockStatus.leadTime:
        text = leadTime ?? l10n.stockIndent;
        color = const Color(0xFFF59E0B); // Orange
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
