import '../../models/order.dart';

enum PaymentProofViewState {
  uploadRequired,
  pendingReview,
  approved,
  rejected,
  expired,
}

PaymentProofViewState resolvePaymentProofViewState(Order order) {
  final paymentStatus = order.paymentStatus.toLowerCase();
  final proof = order.paymentProof;

  if (paymentStatus == 'paid' || proof?.isApproved == true) {
    return PaymentProofViewState.approved;
  }

  if (paymentStatus == 'expired') {
    return PaymentProofViewState.expired;
  }

  if (proof?.isRejected == true) {
    return PaymentProofViewState.rejected;
  }

  if (proof?.isPending == true) {
    return PaymentProofViewState.pendingReview;
  }

  return PaymentProofViewState.uploadRequired;
}

bool canUploadPaymentProof(Order order) {
  final state = resolvePaymentProofViewState(order);
  return state == PaymentProofViewState.uploadRequired ||
      state == PaymentProofViewState.rejected;
}

bool shouldStopPaymentPolling(Order order) {
  final state = resolvePaymentProofViewState(order);
  return state == PaymentProofViewState.approved ||
      state == PaymentProofViewState.rejected ||
      state == PaymentProofViewState.expired;
}
