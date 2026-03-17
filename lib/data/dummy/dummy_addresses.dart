import '../../models/address.dart';

/// Dummy addresses for Milestone 2 UI development
/// Source: docs/PLAN_MILESTONE_2.md § "Other Dummy Data Files"
final List<Address> dummyAddresses = [
  // Primary address - Sudirman Jakarta
  Address(
    id: 'addr-001',
    name: 'Utama',
    fullName: 'John Doe',
    company: 'Otomasi Indonesia',
    phone: '+62 812 3456 7890',
    address: 'Jl. Sudirman Kav. 28-30',
    city: 'Jakarta Selatan',
    province: 'DKI Jakarta',
    postalCode: '12920',
    npwp: '01.234.567.8-901.000',
    isDefault: true,
  ),

  // Secondary address - Gudang Bekasi
  Address(
    id: 'addr-002',
    name: 'Gudang',
    fullName: 'John Doe',
    company: 'Otomasi Indonesia',
    phone: '+62 812 3456 7890',
    address: 'Jl. Raya Bekasi Km.25 Cakung',
    city: 'Jakarta Timur',
    province: 'DKI Jakarta',
    postalCode: '13910',
    npwp: '01.234.567.8-901.000',
    isDefault: false,
  ),
];
