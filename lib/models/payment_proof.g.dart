// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentProof _$PaymentProofFromJson(Map<String, dynamic> json) => PaymentProof(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      imageUrl: json['imageUrl'] as String,
      bankName: json['bankName'] as String,
      accountName: json['accountName'] as String,
      amount: const BigIntStringConverter().fromJson(json['amount']),
      status: json['status'] as String,
      rejectReason: json['rejectReason'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
    );

Map<String, dynamic> _$PaymentProofToJson(PaymentProof instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'imageUrl': instance.imageUrl,
      'bankName': instance.bankName,
      'accountName': instance.accountName,
      'amount': const BigIntStringConverter().toJson(instance.amount),
      'status': instance.status,
      'rejectReason': instance.rejectReason,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
    };
