import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';
import 'package:otomasiku_mobile/data/repositories/payment_repository.dart';

/// Contract-shaped response for GET /api/orders/:id
/// The API wraps data in { "order": {...}, "items": [...] }
Map<String, dynamic> _orderDetailResponse() => {
      'success': true,
      'data': {
        'order': {
          'id': '5ce3ae29-5548-437a-9964-1a136efb812e',
          'orderNumber': 'OMA-20260606-0001',
          'userId': 'user-uuid',
          'addressId': 'addr-uuid',
          'subtotal': '3000000',
          'shippingCost': '0',
          'totalAmount': '3000000',
          'status': 'pending',
          'paymentStatus': 'unpaid',
          'vaNumber': '1234567890',
          'vaExpiresAt': '2026-06-07T10:00:00.000Z',
          'resiNumber': null,
          'shippedAt': null,
          'deliveredAt': null,
          'notes': 'Pack carefully',
          'adminNotes': null,
          'createdAt': '2026-06-06T10:00:00.000Z',
          'updatedAt': '2026-06-06T10:00:00.000Z',
        },
        'items': [
          {
            'id': 'item-uuid',
            'productId': 42,
            'productName': 'FR-D720S-0.4K-CHT',
            'quantity': 2,
            'unitPrice': '1500000',
            'subtotal': '3000000',
          },
        ],
      },
    };

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.com'));
  });

  group('Bug #1 — OrderRepositoryImpl.getOrderById parse path', () {
    test('correctly parses order from nested data.order + data.items', () async {
      dio.httpClientAdapter = _MockAdapter((_) => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: _orderDetailResponse(),
          ));

      final repo = OrderRepositoryImpl(dio);
      final order = await repo.getOrderById('5ce3ae29-5548-437a-9964-1a136efb812e');

      expect(order.id, '5ce3ae29-5548-437a-9964-1a136efb812e');
      expect(order.orderNumber, 'OMA-20260606-0001');
      expect(order.totalAmount, 3000000);
      expect(order.status, 'pending');
      expect(order.paymentStatus, 'unpaid');
      expect(order.vaNumber, '1234567890');
      expect(order.items, isNotNull);
      expect(order.items!.length, 1);
      expect(order.items!.first.productName, 'FR-D720S-0.4K-CHT');
      expect(order.items!.first.quantity, 2);
      expect(order.items!.first.unitPrice, 1500000);
    });
  });

  group('Bug #1 — PaymentRepositoryImpl.getPaymentStatus parse path', () {
    test('correctly parses order from nested data.order + data.items', () async {
      dio.httpClientAdapter = _MockAdapter((_) => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: _orderDetailResponse(),
          ));

      final repo = PaymentRepositoryImpl(dio);
      final order = await repo.getPaymentStatus('5ce3ae29-5548-437a-9964-1a136efb812e');

      expect(order.id, '5ce3ae29-5548-437a-9964-1a136efb812e');
      expect(order.orderNumber, 'OMA-20260606-0001');
      expect(order.paymentStatus, 'unpaid');
      expect(order.vaNumber, '1234567890');
      expect(order.items, isNotNull);
      expect(order.items!.length, 1);
    });
  });
}

class _MockAdapter implements HttpClientAdapter {
  final Response Function(RequestOptions) _handler;

  _MockAdapter(this._handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = _handler(options);
    final body = utf8.encode(jsonEncode(response.data));
    return ResponseBody.fromBytes(
      body,
      response.statusCode!,
      headers: {
        'content-type': [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
