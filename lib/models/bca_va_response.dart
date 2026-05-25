import 'package:json_annotation/json_annotation.dart';

part 'bca_va_response.g.dart';

@JsonSerializable()
class BcaVaResponse {
  final String vaNumber;
  final DateTime expiryDate;
  final String status;
  final int amount;

  const BcaVaResponse({
    required this.vaNumber,
    required this.expiryDate,
    required this.status,
    required this.amount,
  });

  factory BcaVaResponse.fromJson(Map<String, dynamic> json) =>
      _$BcaVaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BcaVaResponseToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isActive => !isExpired && status == 'ACTIVE';
}
