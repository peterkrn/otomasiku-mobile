const String paymentBankOther = 'Lainnya';

const List<String> paymentBankOptions = [
  'BCA',
  'Bank Mandiri',
  'BRI',
  'BNI',
  'CIMB Niaga',
  'PermataBank',
  'Bank Danamon',
  'Bank Syariah Indonesia',
  paymentBankOther,
];

bool paymentBankRequiresCustomName(String bankName) {
  return bankName == paymentBankOther;
}
