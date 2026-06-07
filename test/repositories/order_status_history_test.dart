import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';

void main() {
  group('Bug #3 — OrderStatusHistory.fromJson matches contract', () {
    test('parses snake_case fields from API contract', () {
      final json = {
        'id': 'hist-uuid-1',
        'orderId': 'order-uuid-1',
        'from_status': 'none',
        'to_status': 'pending',
        'changed_by': 'user-uuid',
        'note': 'Order created',
        'created_at': '2026-06-06T10:00:00.000Z',
      };

      final history = OrderStatusHistory.fromJson(json);

      expect(history.fromStatus, 'none');
      expect(history.toStatus, 'pending');
      expect(history.changedBy, 'user-uuid');
      expect(history.note, 'Order created');
      expect(history.createdAt, DateTime.utc(2026, 6, 6, 10));
    });

    test('handles null optional fields', () {
      final json = {
        'id': 'hist-uuid-2',
        'orderId': 'order-uuid-1',
        'from_status': 'pending',
        'to_status': 'processing',
        'changed_by': null,
        'note': null,
        'created_at': '2026-06-06T11:00:00.000Z',
      };

      final history = OrderStatusHistory.fromJson(json);

      expect(history.fromStatus, 'pending');
      expect(history.toStatus, 'processing');
      expect(history.changedBy, isNull);
      expect(history.note, isNull);
    });
  });
}
