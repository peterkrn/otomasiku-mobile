import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/order.dart';

void main() {
  group('Bug #5 — Order model parses all contract fields', () {
    test('parses subtotal, shippingCost, shippedAt, deliveredAt, adminNotes', () {
      final json = {
        'id': 'order-uuid',
        'orderNumber': 'OMA-20260606-0001',
        'status': 'shipped',
        'paymentStatus': 'paid',
        'totalAmount': '3000000',
        'subtotal': '2800000',
        'shippingCost': '200000',
        'vaNumber': '1234567890',
        'vaExpiresAt': '2026-06-07T10:00:00.000Z',
        'addressId': 'addr-uuid',
        'shippedAt': '2026-06-08T09:00:00.000Z',
        'deliveredAt': null,
        'adminNotes': 'Shipped via JNE',
        'notes': null,
        'resiNumber': 'JNE123456',
        'createdAt': '2026-06-06T10:00:00.000Z',
        'updatedAt': '2026-06-08T09:00:00.000Z',
        'items': [],
      };

      final order = Order.fromJson(json);

      expect(order.subtotal, 2800000);
      expect(order.shippingCost, 200000);
      expect(order.shippedAt, DateTime.utc(2026, 6, 8, 9));
      expect(order.deliveredAt, isNull);
      expect(order.adminNotes, 'Shipped via JNE');
    });

    test('handles null optional fields gracefully', () {
      final json = {
        'id': 'order-uuid',
        'orderNumber': 'OMA-20260606-0001',
        'status': 'pending',
        'paymentStatus': 'unpaid',
        'totalAmount': '1500000',
        'createdAt': '2026-06-06T10:00:00.000Z',
        'updatedAt': '2026-06-06T10:00:00.000Z',
      };

      final order = Order.fromJson(json);

      expect(order.subtotal, isNull);
      expect(order.shippingCost, isNull);
      expect(order.shippedAt, isNull);
      expect(order.deliveredAt, isNull);
      expect(order.adminNotes, isNull);
    });
  });
}
