import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/order_repository.dart';
import 'package:otomasiku_mobile/data/repositories/payment_repository.dart';

/// Contract-shaped response for GET /api/orders/:id
/// The API wraps data in { "order": {...}, "items": [...] }
Map<String, dynamic> _orderDetailResponse({
  Map<String, dynamic>? order,
  Object? items = _ItemsMode.defaultItems,
  Object? paymentProof = _sentinel,
}) => {
  'success': true,
  'data': {
    if (order != null)
      'order': order
    else
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
    if (items is! _ItemsMode)
      'items': items
    else if (items == _ItemsMode.defaultItems)
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
    if (!identical(paymentProof, _sentinel)) 'paymentProof': paymentProof,
  },
};

const _sentinel = Object();

enum _ItemsMode { defaultItems, omitField }

void main() {
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.com'));
  });

  group('Bug #1 — OrderRepositoryImpl.getOrderById parse path', () {
    test(
      'correctly parses order from nested data.order + data.items',
      () async {
        dio.httpClientAdapter = _MockAdapter(
          (_) => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: _orderDetailResponse(),
          ),
        );

        final repo = OrderRepositoryImpl(dio);
        final order = await repo.getOrderById(
          '5ce3ae29-5548-437a-9964-1a136efb812e',
        );

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
      },
    );

    test('tolerates null items by normalizing to an empty list', () async {
      dio.httpClientAdapter = _MockAdapter(
        (_) => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: _orderDetailResponse(items: null),
        ),
      );

      final repo = OrderRepositoryImpl(dio);
      final order = await repo.getOrderById(
        '5ce3ae29-5548-437a-9964-1a136efb812e',
      );

      expect(order.items, isEmpty);
    });

    test(
      'parses paymentProof even when the nested proof omits orderId',
      () async {
        dio.httpClientAdapter = _MockAdapter(
          (_) => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: _orderDetailResponse(
              paymentProof: {
                'id': 'proof-uuid',
                'imageUrl': 'https://example.com/proof.jpg',
                'bankName': 'BCA',
                'accountName': 'PT Otomasiku',
                'amount': '3000000',
                'status': 'approved',
                'rejectReason': null,
                'uploadedAt': '2026-06-06T10:05:00.000Z',
                'verifiedAt': '2026-06-06T10:10:00.000Z',
              },
            ),
          ),
        );

        final repo = OrderRepositoryImpl(dio);
        final order = await repo.getOrderById(
          '5ce3ae29-5548-437a-9964-1a136efb812e',
        );

        expect(order.paymentProof, isNotNull);
        expect(
          order.paymentProof!.orderId,
          '5ce3ae29-5548-437a-9964-1a136efb812e',
        );
      },
    );

    test('throws ORDER_NOT_READY when the order payload is missing', () async {
      dio.httpClientAdapter = _MockAdapter(
        (_) => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: {
            'success': true,
            'data': {'items': const <dynamic>[]},
          },
        ),
      );

      final repo = OrderRepositoryImpl(dio);

      expect(
        () => repo.getOrderById('5ce3ae29-5548-437a-9964-1a136efb812e'),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'ORDER_NOT_READY'),
        ),
      );
    });
  });

  group('Bug #1 — PaymentRepositoryImpl.getPaymentStatus parse path', () {
    test(
      'correctly parses order from nested data.order + data.items',
      () async {
        dio.httpClientAdapter = _MockAdapter(
          (_) => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: _orderDetailResponse(),
          ),
        );

        final repo = PaymentRepositoryImpl(dio);
        final order = await repo.getPaymentStatus(
          '5ce3ae29-5548-437a-9964-1a136efb812e',
        );

        expect(order.id, '5ce3ae29-5548-437a-9964-1a136efb812e');
        expect(order.orderNumber, 'OMA-20260606-0001');
        expect(order.paymentStatus, 'unpaid');
        expect(order.vaNumber, '1234567890');
        expect(order.items, isNotNull);
        expect(order.items!.length, 1);
      },
    );

    test('tolerates missing items by normalizing to an empty list', () async {
      dio.httpClientAdapter = _MockAdapter(
        (_) => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: _orderDetailResponse(items: _ItemsMode.omitField),
        ),
      );

      final repo = PaymentRepositoryImpl(dio);
      final order = await repo.getPaymentStatus(
        '5ce3ae29-5548-437a-9964-1a136efb812e',
      );

      expect(order.items, isEmpty);
    });

    test('throws ORDER_NOT_READY when the order payload is missing', () async {
      dio.httpClientAdapter = _MockAdapter(
        (_) => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: {
            'success': true,
            'data': {'items': const <dynamic>[]},
          },
        ),
      );

      final repo = PaymentRepositoryImpl(dio);

      expect(
        () => repo.getPaymentStatus('5ce3ae29-5548-437a-9964-1a136efb812e'),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'ORDER_NOT_READY'),
        ),
      );
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
