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
  final String? kecamatan;
  final String? kelurahan;
  final String? notes;
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
    this.kecamatan,
    this.kelurahan,
    this.notes,
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

  /// Copy with new values
  Address copyWith({
    String? id,
    String? name,
    String? fullName,
    String? company,
    String? phone,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? kecamatan,
    String? kelurahan,
    String? notes,
    String? npwp,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
      notes: notes ?? this.notes,
      npwp: npwp ?? this.npwp,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
