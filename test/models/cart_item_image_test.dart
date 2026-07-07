import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/cart_item.dart';

void main() {
  group('Bug #4 — CartProductSnapshot parses imageUrl from contract', () {
    test('primaryImageUrl reads from JSON key "imageUrl"', () {
      final json = {
        'name': 'FR-D720S-0.4K-CHT',
        'price': '1500000',
        'imageUrl': 'https://storage.example.com/products/fr-d720s.jpg',
      };

      final snapshot = CartProductSnapshot.fromJson(json);

      expect(snapshot.primaryImageUrl, 'https://storage.example.com/products/fr-d720s.jpg');
    });

    test('primaryImageUrl defaults to empty string when imageUrl is null', () {
      final json = {
        'name': 'FR-D720S-0.4K-CHT',
        'price': '1500000',
        'imageUrl': null,
      };

      final snapshot = CartProductSnapshot.fromJson(json);

      expect(snapshot.primaryImageUrl, '');
    });
  });
}
