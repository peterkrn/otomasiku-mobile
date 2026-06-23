import '../../core/errors/app_exception.dart';
import '../../models/order.dart';

Order parseOrderDetailData(
  Map<String, dynamic> data, {
  required int statusCode,
}) {
  final rawOrder = data['order'];
  if (rawOrder is! Map) {
    throw ApiException(code: 'ORDER_NOT_READY', statusCode: statusCode);
  }

  final orderMap = Map<String, dynamic>.from(rawOrder);
  final rawItems = data['items'];

  if (rawItems == null) {
    orderMap['items'] = const <dynamic>[];
  } else if (rawItems is List) {
    orderMap['items'] = rawItems;
  } else {
    throw ApiException(code: 'INVALID_RESPONSE', statusCode: statusCode);
  }

  final paymentProof = data['paymentProof'];
  if (paymentProof is Map) {
    final proofMap = Map<String, dynamic>.from(paymentProof);
    proofMap['orderId'] ??= orderMap['id']?.toString();
    orderMap['paymentProof'] = proofMap;
  }

  return Order.fromJson(orderMap);
}
