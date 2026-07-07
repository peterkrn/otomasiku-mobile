import 'package:json_annotation/json_annotation.dart';
import '../core/utils/bigint_converter.dart';

part 'payment_proof.g.dart';

@JsonSerializable()
class PaymentProof {
  final String id;
  final String orderId;
  final String imageUrl;
  final String bankName;
  final String accountName;

  @BigIntStringConverter()
  final int amount;

  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectReason;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;

  const PaymentProof({
    required this.id,
    required this.orderId,
    required this.imageUrl,
    required this.bankName,
    required this.accountName,
    required this.amount,
    required this.status,
    this.rejectReason,
    required this.uploadedAt,
    this.verifiedAt,
  });

  factory PaymentProof.fromJson(Map<String, dynamic> json) =>
      _$PaymentProofFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentProofToJson(this);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
