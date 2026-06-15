import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/features/payment/payment_bank_options.dart';

void main() {
  test('paymentBankOptions includes common Indonesian banks and Lainnya', () {
    expect(paymentBankOptions, contains('BCA'));
    expect(paymentBankOptions, contains('Bank Mandiri'));
    expect(paymentBankOptions, contains('BRI'));
    expect(paymentBankOptions, contains(paymentBankOther));
  });

  test('paymentBankRequiresCustomName only returns true for Lainnya', () {
    expect(paymentBankRequiresCustomName('BCA'), isFalse);
    expect(paymentBankRequiresCustomName(paymentBankOther), isTrue);
  });
}
