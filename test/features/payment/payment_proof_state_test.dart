import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/features/payment/payment_proof_state.dart';
import 'package:otomasiku_mobile/models/order.dart';
import 'package:otomasiku_mobile/models/payment_proof.dart';

Order _order({
  String paymentStatus = 'unpaid',
  PaymentProof? paymentProof,
}) {
  return Order(
    id: 'order-1',
    orderNumber: 'ORD-001',
    status: 'pending',
    paymentStatus: paymentStatus,
    totalAmount: 250000,
    createdAt: DateTime(2026, 6, 11),
    updatedAt: DateTime(2026, 6, 11),
    paymentProof: paymentProof,
  );
}

PaymentProof _proof({
  String status = 'pending',
  String? rejectReason,
}) {
  return PaymentProof(
    id: 'proof-1',
    orderId: 'order-1',
    imageUrl: 'https://example.com/proof.jpg',
    bankName: 'BCA',
    accountName: 'Peter',
    amount: 250000,
    status: status,
    rejectReason: rejectReason,
    uploadedAt: DateTime(2026, 6, 11),
    verifiedAt: status == 'pending' ? null : DateTime(2026, 6, 11, 12),
  );
}

void main() {
  group('resolvePaymentProofViewState', () {
    test('returns uploadRequired when order is unpaid and proof is missing', () {
      expect(
        resolvePaymentProofViewState(_order()),
        PaymentProofViewState.uploadRequired,
      );
    });

    test('returns pendingReview when proof is pending', () {
      expect(
        resolvePaymentProofViewState(_order(paymentProof: _proof())),
        PaymentProofViewState.pendingReview,
      );
    });

    test('returns approved when proof is approved', () {
      expect(
        resolvePaymentProofViewState(
          _order(paymentProof: _proof(status: 'approved')),
        ),
        PaymentProofViewState.approved,
      );
    });

    test('returns approved when payment status is paid even without proof', () {
      expect(
        resolvePaymentProofViewState(_order(paymentStatus: 'paid')),
        PaymentProofViewState.approved,
      );
    });

    test('returns rejected when proof is rejected', () {
      expect(
        resolvePaymentProofViewState(
          _order(
            paymentProof: _proof(
              status: 'rejected',
              rejectReason: 'Nominal tidak sesuai',
            ),
          ),
        ),
        PaymentProofViewState.rejected,
      );
    });

    test('returns expired when payment status is expired', () {
      expect(
        resolvePaymentProofViewState(_order(paymentStatus: 'expired')),
        PaymentProofViewState.expired,
      );
    });
  });

  group('payment proof helpers', () {
    test('canUploadPaymentProof allows fresh uploads and re-uploads', () {
      expect(canUploadPaymentProof(_order()), isTrue);
      expect(
        canUploadPaymentProof(
          _order(paymentProof: _proof(status: 'rejected', rejectReason: 'Blur')),
        ),
        isTrue,
      );
    });

    test('canUploadPaymentProof blocks pending and approved proofs', () {
      expect(
        canUploadPaymentProof(_order(paymentProof: _proof(status: 'pending'))),
        isFalse,
      );
      expect(
        canUploadPaymentProof(_order(paymentStatus: 'paid')),
        isFalse,
      );
    });

    test('shouldStopPaymentPolling stops on terminal states only', () {
      expect(shouldStopPaymentPolling(_order()), isFalse);
      expect(
        shouldStopPaymentPolling(_order(paymentProof: _proof(status: 'pending'))),
        isFalse,
      );
      expect(
        shouldStopPaymentPolling(_order(paymentStatus: 'paid')),
        isTrue,
      );
      expect(
        shouldStopPaymentPolling(
          _order(paymentProof: _proof(status: 'rejected', rejectReason: 'Blur')),
        ),
        isTrue,
      );
      expect(
        shouldStopPaymentPolling(_order(paymentStatus: 'expired')),
        isTrue,
      );
    });
  });
}
