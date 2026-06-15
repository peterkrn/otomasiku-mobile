import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/data/repositories/payment_proof_repository.dart';
import 'package:otomasiku_mobile/features/payment/widgets/bukti_transfer_card.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/models/payment_proof.dart';
import 'package:otomasiku_mobile/providers/repository_providers.dart';

import '../../helpers/test_app.dart';

class _FakePaymentProofRepository implements PaymentProofRepository {
  @override
  Future<PaymentProof?> getProof(String orderId) async => null;

  @override
  Future<PaymentProof> uploadProof({
    required String orderId,
    required File imageFile,
    required String bankName,
    required String accountName,
    required int amount,
  }) {
    throw UnimplementedError();
  }
}

Order _order({int totalAmount = 250000}) {
  return Order(
    id: 'order-1',
    orderNumber: 'ORD-001',
    status: 'pending',
    paymentStatus: 'unpaid',
    totalAmount: totalAmount,
    createdAt: DateTime(2026, 6, 11),
    updatedAt: DateTime(2026, 6, 11),
  );
}

void main() {
  testWidgets('transfer amount is read-only for launch-safe proof upload', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentProofRepositoryProvider.overrideWithValue(
            _FakePaymentProofRepository(),
          ),
        ],
        child: TestApp(
          child: BuktiTransferCard(order: _order(), isDark: false),
        ),
      ),
    );

    final amountFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Transfer Amount',
    );
    final amountField = tester.widget<TextField>(amountFinder);
    expect(amountField.readOnly, isTrue);
  });
}
