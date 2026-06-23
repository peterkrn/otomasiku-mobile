import 'package:flutter/services.dart';

/// Formats Rupiah values for display and editable text fields.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const String _prefix = 'Rp. ';

  static String format(int amount) {
    final sign = amount < 0 ? '-' : '';
    final digits = amount.abs().toString();
    return '$sign$_prefix${_groupIntegerDigits(digits)}';
  }

  static String formatWithSymbol(int amount, String symbol) {
    final sign = amount < 0 ? '-' : '';
    final digits = amount.abs().toString();
    return '$sign$symbol ${_groupIntegerDigits(digits)}';
  }

  static String formatEditable(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9,]'), '');
    if (normalized.isEmpty) return '';

    final firstComma = normalized.indexOf(',');
    final integerPart = firstComma >= 0
        ? normalized.substring(0, firstComma)
        : normalized;
    final decimalPart = firstComma >= 0
        ? normalized.substring(firstComma + 1).replaceAll(',', '')
        : '';

    final safeInteger = integerPart.isEmpty ? '0' : integerPart;
    final groupedInteger = _groupIntegerDigits(safeInteger);

    if (firstComma >= 0) {
      return '$_prefix$groupedInteger,$decimalPart';
    }

    return '$_prefix$groupedInteger';
  }

  static int parse(String formatted) {
    final wholePart = formatted.split(',').first;
    final cleaned = wholePart.replaceAll(RegExp(r'[^0-9-]'), '');
    return cleaned.isEmpty ? 0 : int.parse(cleaned);
  }

  static String formatCompact(int amount) {
    if (amount >= 1000000000) {
      final value = amount / 1000000000;
      return '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)}M';
    } else if (amount >= 1000000) {
      final value = amount / 1000000;
      return '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)}jt';
    } else if (amount >= 1000) {
      final value = amount / 1000;
      return '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)}rb';
    } else {
      return '$amount';
    }
  }

  static String _groupIntegerDigits(String digits) {
    if (digits.length <= 4) return digits;

    final buffer = StringBuffer();
    final leadingLength = digits.length % 3 == 0 ? 3 : digits.length % 3;
    buffer.write(digits.substring(0, leadingLength));

    for (var i = leadingLength; i < digits.length; i += 3) {
      buffer.write('.');
      buffer.write(digits.substring(i, i + 3));
    }

    return buffer.toString();
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = CurrencyFormatter.formatEditable(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
