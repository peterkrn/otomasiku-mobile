import 'package:intl/intl.dart';

/// Formats integer Rupiah values to Indonesian currency string
/// Example: 19800000 → "Rp 19.800.000"
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _format = NumberFormat('#,##0', 'id_ID');

  /// Format price in Rupiah (input is in integer, e.g., 19800000)
  /// Output: "Rp 19.800.000" (with space between Rp and number)
  static String format(int amount) {
    final formatted = _format.format(amount).replaceAll(',', '.');
    return 'Rp $formatted';
  }

  /// Format price with custom symbol
  static String formatWithSymbol(int amount, String symbol) {
    final formatted = _format.format(amount).replaceAll(',', '.');
    return '$symbol $formatted';
  }

  /// Parse string back to int (for input fields)
  static int parse(String formatted) {
    // Remove all non-digit characters except minus
    final cleaned = formatted.replaceAll(RegExp(r'[^0-9-]'), '');
    return cleaned.isEmpty ? 0 : int.parse(cleaned);
  }

  /// Format price in compact form (e.g., 145000000 → "145jt")
  static String formatCompact(int amount) {
    if (amount >= 1000000000) {
      // Billions - use "M" for miliar
      final value = amount / 1000000000;
      return '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)}M';
    } else if (amount >= 1000000) {
      // Millions - use "jt" for juta
      final value = amount / 1000000;
      return '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)}jt';
    } else if (amount >= 1000) {
      // Thousands - use "rb" for ribu
      final value = amount / 1000;
      return '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)}rb';
    } else {
      return '$amount';
    }
  }
}
