/// Address model for Otomasiku Marketplace
class Address {
  final String id;
  final String name;
  final String fullName;
  final String? company;
  final String phone;
  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String? npwp;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.fullName,
    this.company,
    required this.phone,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    this.npwp,
    required this.isDefault,
  });

  /// Get full address as single string
  String get fullAddress {
    final parts = [address, city, province, postalCode];
    if (company != null) {
      parts.insert(0, company!);
    }
    return parts.join(', ');
  }

  /// Get label for address selector
  String get fullLabel => '$name - $fullAddress';
}
