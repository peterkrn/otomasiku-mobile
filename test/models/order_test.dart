import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/order.dart';

void main() {
  group('Order status contract', () {
    test('matches backend completion and timeline statuses', () {
      expect(isCompletedOrderStatus('done'), isTrue);
      expect(isCompletedOrderStatus('delivered'), isFalse);
      expect(isFulfillmentOrderStatus('processing'), isTrue);
      expect(isFulfillmentOrderStatus('shipped'), isTrue);
      expect(isFulfillmentOrderStatus('pending'), isFalse);
      expect(orderTimelineStatuses, ['pending', 'processing', 'shipped', 'done']);
    });
  });

  group('Order.fromJson', () {
    final json = {
      'id': 'order-001',
      'orderNumber': 'INV-2026-0001',
      'status': 'processing',
      'paymentStatus': 'unpaid',
      'totalAmount': '15000000',
      'vaNumber': '1234567890',
      'vaExpiresAt': '2026-01-16T10:00:00.000Z',
      'shippingAddress': {
        'recipient': 'Peter',
        'phone': '08123456789',
        'street': 'Jl. Sudirman No. 123',
        'city': 'Jakarta',
        'province': 'DKI Jakarta',
        'postalCode': '12345',
      },
      'items': [
        {
          'productId': 'prod-001',
          'productName': 'FR-A840-2.2K-1 Inverter',
          'quantity': 1,
          'unitPrice': '15000000',
          'subtotal': '15000000',
        },
      ],
      'notes': 'Tolong dikirim pagi hari',
      'resiNumber': null,
      'createdAt': '2026-01-15T10:00:00.000Z',
      'updatedAt': '2026-01-15T10:00:00.000Z',
    };

    test('parses all fields correctly', () {
      final order = Order.fromJson(json as Map<String, dynamic>);

      expect(order.id, 'order-001');
      expect(order.orderNumber, 'INV-2026-0001');
      expect(order.status, 'processing');
      expect(order.paymentStatus, 'unpaid');
      expect(order.totalAmount, 15000000);
      expect(order.vaNumber, '1234567890');
      expect(order.notes, 'Tolong dikirim pagi hari');
      expect(order.items!.length, 1);
      expect(order.items!.first.productName, 'FR-A840-2.2K-1 Inverter');
      expect(order.items!.first.unitPrice, 15000000);
      expect(order.items!.first.subtotal, 15000000);
      expect(order.shippingAddress!.recipient, 'Peter');
      expect(order.shippingAddress!.city, 'Jakarta');
    });
  });
}
