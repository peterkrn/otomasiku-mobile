import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class StockBadge extends StatelessWidget {
  final int stock;
  final bool isOutOfStock;
  final bool isLowStock;

  const StockBadge({
    super.key,
    required this.stock,
    required this.isOutOfStock,
    required this.isLowStock,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String text;
    Color color;

    if (isOutOfStock) {
      text = l10n.stockEmpty;
      color = const Color(0xFFEF4444);
    } else if (isLowStock) {
      text = l10n.stockLow(stock);
      color = const Color(0xFFF59E0B);
    } else {
      text = l10n.stockUnit(stock);
      color = const Color(0xFF10B981);
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
