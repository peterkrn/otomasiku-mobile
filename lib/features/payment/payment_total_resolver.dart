import '../../models/order.dart';

int resolvePaymentDisplayTotal({
  required Order order,
  required int routedTotalAmount,
}) {
  if (routedTotalAmount > 0 &&
      order.status == 'pending' &&
      order.paymentStatus == 'unpaid' &&
      order.totalAmount != routedTotalAmount) {
    return routedTotalAmount;
  }

  return order.totalAmount > 0 ? order.totalAmount : routedTotalAmount;
}
