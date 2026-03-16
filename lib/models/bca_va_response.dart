/// BCA Virtual Account response model
/// Source: BCA Developer API Sandbox response format
/// Used for M2 payment flow only
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

  /// Parse from JSON response
  factory BcaVaResponse.fromJson(Map<String, dynamic> json) {
    return BcaVaResponse(
      vaNumber: json['va_number'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      status: json['status'] as String,
      amount: json['amount'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'va_number': vaNumber,
      'expiry_date': expiryDate.toIso8601String(),
      'status': status,
      'amount': amount,
    };
  }

  /// Check if VA is expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Check if VA is still active
  bool get isActive => !isExpired && status == 'ACTIVE';
}
