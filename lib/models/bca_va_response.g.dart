// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bca_va_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BcaVaResponse _$BcaVaResponseFromJson(Map<String, dynamic> json) =>
    BcaVaResponse(
      vaNumber: json['vaNumber'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$BcaVaResponseToJson(BcaVaResponse instance) =>
    <String, dynamic>{
      'vaNumber': instance.vaNumber,
      'expiryDate': instance.expiryDate.toIso8601String(),
      'status': instance.status,
      'amount': instance.amount,
    };
