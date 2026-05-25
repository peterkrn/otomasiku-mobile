import '../../models/address.dart';

final List<Address> dummyAddresses = [
  Address(
    id: 'addr-001',
    label: 'Utama',
    recipient: 'Peter',
    phone: '+62 812 3456 7890',
    street: 'Jl. Sudirman Kav. 28-30',
    city: 'Jakarta Selatan',
    province: 'DKI Jakarta',
    postalCode: '12920',
    isDefault: true,
    createdAt: DateTime(2024, 1, 1),
  ),

  Address(
    id: 'addr-002',
    label: 'Gudang',
    recipient: 'Peter',
    phone: '+62 812 3456 7890',
    street: 'Jl. Raya Bekasi Km.25 Cakung',
    city: 'Jakarta Timur',
    province: 'DKI Jakarta',
    postalCode: '13910',
    isDefault: false,
    createdAt: DateTime(2024, 1, 1),
  ),
];
