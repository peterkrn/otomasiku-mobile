import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats app-wide rupiah values with Rp. prefix', () {
      expect(CurrencyFormatter.format(99), 'Rp. 99');
      expect(CurrencyFormatter.format(999), 'Rp. 999');
      expect(CurrencyFormatter.format(9999), 'Rp. 9999');
      expect(CurrencyFormatter.format(99999), 'Rp. 99.999');
      expect(CurrencyFormatter.format(999999), 'Rp. 999.999');
      expect(CurrencyFormatter.format(9999999), 'Rp. 9.999.999');
    });
  });

  group('CurrencyFormatter editable helpers', () {
    test('formats editable values with optional decimals', () {
      expect(CurrencyFormatter.formatEditable('99999999,99'), 'Rp. 99.999.999,99');
      expect(CurrencyFormatter.formatEditable('9999999'), 'Rp. 9.999.999');
    });

    test('parse strips rupiah formatting and ignores decimal fraction', () {
      expect(CurrencyFormatter.parse('Rp. 9.999.999,99'), 9999999);
      expect(CurrencyFormatter.parse('Rp. 99.999'), 99999);
    });
  });

  group('RupiahInputFormatter', () {
    test('formats text as user types', () {
      const formatter = RupiahInputFormatter();
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '999999'),
      );

      expect(result.text, 'Rp. 999.999');
      expect(result.selection.baseOffset, result.text.length);
    });
  });
}
