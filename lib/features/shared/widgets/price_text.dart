import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

/// Displays a price using the app's currency format.
/// Uses int only — never double for money.
/// Default style: Mitsubishi Red, bold, 16px.
class PriceText extends StatelessWidget {
  final int price;
  final TextStyle? style;

  const PriceText({
    super.key,
    required this.price,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = CurrencyFormatter.format(price);

    return Text(
      formatted,
      style: style ?? const TextStyle(
        color: Color(0xFFE7192D),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
