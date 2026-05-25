import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/address.dart';

void main() {
  group('Address.fromJson', () {
    final json = {
      'id': 'addr-001',
      'label': 'Kantor',
      'recipient': 'Peter',
      'phone': '08123456789',
      'street': 'Jl. Sudirman No. 123',
      'city': 'Jakarta',
      'province': 'DKI Jakarta',
      'postalCode': '12345',
      'isDefault': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final address = Address.fromJson(json as Map<String, dynamic>);

      expect(address.id, 'addr-001');
      expect(address.label, 'Kantor');
      expect(address.recipient, 'Peter');
      expect(address.phone, '08123456789');
      expect(address.street, 'Jl. Sudirman No. 123');
      expect(address.city, 'Jakarta');
      expect(address.province, 'DKI Jakarta');
      expect(address.postalCode, '12345');
      expect(address.isDefault, true);
    });
  });
}
