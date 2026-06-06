import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/product.dart';

void main() {
  group('Product.fromJson', () {
    final json = {
      'id': 1,
      'name': 'FR-A840-2.2K-1 Inverter',
      'slug': 'fr-a840-2-2k-1-inverter',
      'sku': 'FR-A840-2.2K-1',
      'brandId': 1,
      'categoryId': 1,
      'brand': {'id': 1, 'name': 'Mitsubishi', 'slug': 'mitsubishi'},
      'category': {'id': 1, 'name': 'Inverter', 'slug': 'inverter'},
      'series': 'FR-A800',
      'subSeries': 'FR-A840',
      'variant': '2.2kW / 400V',
      'price': 15000000,
      'originalPrice': 18000000,
      'stock': 10,
      'version': 1,
      'unit': 'unit',
      'minOrder': 1,
      'descriptionId': 'Deskripsi inverter',
      'descriptionEn': 'Inverter description',
      'images': [
        {
          'id': 'img-1',
          'url': 'assets/images/products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg',
          'path': 'products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg',
          'is_primary': true,
          'sort_order': 0,
        },
      ],
      'isPublished': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-15T00:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final product = Product.fromJson(json as Map<String, dynamic>);

      expect(product.id, 1);
      expect(product.name, 'FR-A840-2.2K-1 Inverter');
      expect(product.slug, 'fr-a840-2-2k-1-inverter');
      expect(product.sku, 'FR-A840-2.2K-1');
      expect(product.brand.id, 1);
      expect(product.brand.name, 'Mitsubishi');
      expect(product.brand.slug, 'mitsubishi');
      expect(product.category.id, 1);
      expect(product.category.name, 'Inverter');
      expect(product.price, 15000000);
      expect(product.originalPrice, 18000000);
      expect(product.stock, 10);
      expect(product.version, 1);
      expect(product.unit, 'unit');
      expect(product.minOrder, 1);
      expect(product.descriptionId, 'Deskripsi inverter');
      expect(product.images.length, 1);
      expect(product.images.first.id, 'img-1');
      expect(product.images.first.url, 'assets/images/products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg');
      expect(product.images.first.path, 'products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg');
      expect(product.images.first.isPrimary, true);
      expect(product.images.first.sortOrder, 0);
      expect(product.primaryImageUrl, 'assets/images/products/mitsubishi/inverter/fr_a840_2_2k_1.jpeg');
      expect(product.isPublished, true);
    });

    test('parses price from int directly', () {
      final jsonWithIntPrice = Map<String, dynamic>.from(json);
      jsonWithIntPrice['price'] = 20000000;

      final product = Product.fromJson(jsonWithIntPrice);
      expect(product.price, 20000000);
    });

    test('isOutOfStock returns true when stock is 0', () {
      final jsonZeroStock = Map<String, dynamic>.from(json);
      jsonZeroStock['stock'] = 0;

      final product = Product.fromJson(jsonZeroStock);
      expect(product.isOutOfStock, true);
      expect(product.isLowStock, false);
    });

    test('isLowStock returns true when stock <= 5', () {
      final jsonLowStock = Map<String, dynamic>.from(json);
      jsonLowStock['stock'] = 3;

      final product = Product.fromJson(jsonLowStock);
      expect(product.isLowStock, true);
    });
  });
}
