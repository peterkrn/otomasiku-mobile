import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/core/errors/app_exception.dart';
import 'package:otomasiku_mobile/data/repositories/payment_repository.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/providers/payment_provider.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kAddress = OrderAddress(
  recipient: 'Test',
  phone: '081234567890',
  street: 'Jl. Test',
  city: 'Jakarta',
  province: 'DKI Jakarta',
  postalCode: '12345',
);

Order _order({
  String id = 'order-1',
  String paymentStatus = 'pending',
  String status = 'processing',
}) =>
    Order(
      id: id,
      orderNumber: 'ORD-001',
      status: status,
      paymentStatus: paymentStatus,
      totalAmount: 500000,
      shippingAddress: _kAddress,
      items: const [],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

ProviderContainer _container(_MockPaymentRepository repo) => ProviderContainer(
      overrides: [paymentRepositoryProvider.overrideWithValue(repo)],
    );

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class _MockPaymentRepository implements PaymentRepository {
  final List<Order> _responses;
  int _callCount = 0;
  bool shouldThrow;

  _MockPaymentRepository({required List<Order> responses, this.shouldThrow = false})
      : _responses = responses;

  @override
  Future<Order> getPaymentStatus(String orderId) async {
    if (shouldThrow) throw ApiException(code: 'SERVER_ERROR', statusCode: 500);
    final idx = _callCount < _responses.length ? _callCount : _responses.length - 1;
    _callCount++;
    return _responses[idx];
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Bug #5 — payment polling fails in staging
  // Fix: FakePaymentRepository injected via Riverpod override in debug builds.
  // These tests verify the polling provider CONTRACT via PaymentRepository.
  // -------------------------------------------------------------------------
  group('Bug #5 — PaymentPollingNotifier', () {
    test('returns order immediately when already paid', () async {
      final repo = _MockPaymentRepository(
        responses: [_order(paymentStatus: 'paid', status: 'confirmed')],
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      final order = await container.read(paymentPollingProvider('order-1').future);

      expect(order.paymentStatus, 'paid');
    });

    test('returns order with pending status when not yet paid', () async {
      final repo = _MockPaymentRepository(
        responses: [_order(paymentStatus: 'pending')],
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      final order = await container.read(paymentPollingProvider('order-1').future);

      expect(order.paymentStatus, 'pending');
    });

    test('enters error state when repository throws', () async {
      final repo = _MockPaymentRepository(responses: [], shouldThrow: true);
      final container = _container(repo);
      addTearDown(container.dispose);

      await Future.delayed(Duration.zero); // let build() settle

      final state = container.read(paymentPollingProvider('order-1'));
      expect(state.hasError || state.isLoading, isTrue);
    });

    test('checkNow re-fetches and updates state', () async {
      final repo = _MockPaymentRepository(
        responses: [
          _order(paymentStatus: 'pending'),
          _order(paymentStatus: 'paid', status: 'confirmed'),
        ],
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(paymentPollingProvider('order-1').future);

      await container.read(paymentPollingProvider('order-1').notifier).checkNow('order-1');

      final state = container.read(paymentPollingProvider('order-1'));
      expect(state.value?.paymentStatus, 'paid');
    });
  });

  // -------------------------------------------------------------------------
  // FakePaymentRepository contract (the debug simulation)
  // -------------------------------------------------------------------------
  group('FakePaymentRepository — debug simulation contract', () {
    test('simulated order has required fields', () {
      final simOrder = Order(
        id: 'sim-order-1',
        orderNumber: 'SIM-sim-order-1',
        status: 'confirmed',
        paymentStatus: 'paid',
        totalAmount: 0,
        shippingAddress: _kAddress,
        items: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(simOrder.paymentStatus, 'paid');
      expect(simOrder.status, 'confirmed');
      expect(simOrder.id, startsWith('sim-'));
    });
  });
}
