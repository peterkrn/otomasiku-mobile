import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/cart_item.dart';

void main() {
  group('CartItem.fromJson', () {
    final json = {
      'id': 'cart-item-001',
      'productId': 'prod-001',
      'quantity': 2,
      'productSnapshot': {
        'name': 'FR-A840-2.2K-1 Inverter',
        'price': '15000000',
        'primaryImageUrl': 'assets/images/products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg',
      },
      'createdAt': '2026-01-15T10:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final item = CartItem.fromJson(json as Map<String, dynamic>);

      expect(item.id, 'cart-item-001');
      expect(item.productId, 'prod-001');
      expect(item.quantity, 2);
      expect(item.productSnapshot.name, 'FR-A840-2.2K-1 Inverter');
      expect(item.productSnapshot.price, 15000000);
    });
  });
}
