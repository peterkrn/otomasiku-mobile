import '../../models/product.dart';

/// 10 dummy products for Milestone 2 UI development
/// Source: docs/DUMMY_PRODUCT_MAPPING_PLAN.md § 4
final List<Product> dummyProducts = [
  // 1. MIT-INV-001: FR-A820-0.4K-1 (HTML primary product)
  Product(
    id: 'MIT-INV-001',
    sku: 'FR-A820-0.4K-1',
    name: 'FR-A820-0.4K-1',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.inverter,
    series: 'FR-A800',
    description: 'Mitsubishi Inverter FR-A800 Series, 0.4kW, 200V, 3-phase',
    price: 5200000,
    stock: 24,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/inverter/fr-a820-0.4k.jpg',
    specifications: {
      'Power': '0.4 kW',
      'Voltage': '200V 3-phase',
      'Warranty': '1 year',
    },
  ),

  // 2. MIT-INV-002: FR-A820-2.2K-1 (Indent)
  Product(
    id: 'MIT-INV-002',
    sku: 'FR-A820-2.2K-1',
    name: 'FR-A820-2.2K-1',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.inverter,
    series: 'FR-A800',
    description: 'Mitsubishi Inverter FR-A800 Series, 2.2kW, 200V, 3-phase',
    price: 12500000,
    stock: null,
    stockStatus: StockStatus.leadTime,
    stockLeadTime: 'Indent 14 Hari',
    primaryImage: 'assets/images/products/inverter/fr-a820-2.2k.jpg',
    specifications: {
      'Power': '2.2 kW',
      'Voltage': '200V 3-phase',
      'Warranty': '1 year',
    },
  ),

  // 3. MIT-PLC-001: FX5U-32MT/ES
  Product(
    id: 'MIT-PLC-001',
    sku: 'FX5U-32MT/ES',
    name: 'FX5U-32MT/ES',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.plc,
    series: 'FX5',
    description: 'Mitsubishi PLC CPU 32 I/O, Transistor Output, 24VDC',
    price: 8800000,
    stock: 8,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/plc/fx5u-32mt-es.jpg',
    specifications: {
      'I/O': '32 points',
      'Output': 'Transistor',
      'Power': '24VDC',
      'Warranty': '1 year',
    },
  ),

  // 4. MIT-SRV-001: MR-J4-10B
  Product(
    id: 'MIT-SRV-001',
    sku: 'MR-J4-10B',
    name: 'MR-J4-10B',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.servo,
    series: 'MR-J4',
    description: 'Mitsubishi Servo Amplifier 100W, SSCNET III/H',
    price: 6800000,
    stock: 3,
    stockStatus: StockStatus.lowStock,
    primaryImage: 'assets/images/products/servo/mr-j4-10b.jpg',
    specifications: {
      'Power': '100W',
      'Interface': 'SSCNET III/H',
      'Warranty': '1 year',
    },
  ),

  // 5. DAN-INV-001: FC 302 131B0078
  Product(
    id: 'DAN-INV-001',
    sku: '131B0078',
    name: 'FC 302 131B0078',
    brand: ProductBrand.danfoss,
    category: ProductCategory.inverter,
    series: 'FC300',
    description: 'Danfoss VLT AutomationDrive, 1.5kW, 380-480V',
    price: 12500000,
    stock: 8,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/inverter/fc-302-1.5kw.jpg',
    specifications: {
      'Power': '1.5 kW',
      'Voltage': '380-480V',
      'Warranty': '2 years',
    },
  ),

  // 6. MIT-INV-003: FR-D720-0.75K
  Product(
    id: 'MIT-INV-003',
    sku: 'FR-D720-0.75K',
    name: 'FR-D720-0.75K',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.inverter,
    series: 'FR-D700',
    description: 'Mitsubishi Inverter FR-D700 Series, 0.75kW, 200V, 3-phase',
    price: 3200000,
    stock: 24,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/inverter/fr-d720-0.75k.jpg',
    specifications: {
      'Power': '0.75 kW',
      'Voltage': '200V 3-phase',
      'Warranty': '1 year',
    },
  ),

  // 7. MIT-PLC-002: FX3G-24MR/ES-A
  Product(
    id: 'MIT-PLC-002',
    sku: 'FX3G-24MR/ES-A',
    name: 'FX3G-24MR/ES-A',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.plc,
    series: 'FX3',
    description: 'Mitsubishi PLC CPU 24 I/O, Relay Output, 100-240VAC',
    price: 5800000,
    stock: 10,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/plc/fx3g-24mr-es.jpg',
    specifications: {
      'I/O': '24 points',
      'Output': 'Relay',
      'Power': '100-240VAC',
      'Warranty': '1 year',
    },
  ),

  // 8. MIT-HMI-001: GT2103-PMBDS
  Product(
    id: 'MIT-HMI-001',
    sku: 'GT2103-PMBDS',
    name: 'GT2103-PMBDS',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.hmi,
    series: 'GT2000',
    description: 'Mitsubishi HMI GOT2000, 3.8" TFT, 256 colors',
    price: 6500000,
    stock: 12,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/hmi/gt2103-pmbds.jpg',
    specifications: {
      'Display': '3.8" TFT',
      'Colors': '256',
      'Warranty': '1 year',
    },
  ),

  // 9. MIT-SRV-002: MR-J4-10A
  Product(
    id: 'MIT-SRV-002',
    sku: 'MR-J4-10A',
    name: 'MR-J4-10A',
    brand: ProductBrand.mitsubishi,
    category: ProductCategory.servo,
    series: 'MR-J4',
    description: 'Mitsubishi Servo Amplifier 100W, Standalone',
    price: 6200000,
    stock: 10,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/servo/mr-j4-10a.jpg',
    specifications: {
      'Power': '100W',
      'Type': 'Standalone',
      'Warranty': '1 year',
    },
  ),

  // 10. DAN-INV-002: FC 051 132F0003
  Product(
    id: 'DAN-INV-002',
    sku: '132F0003',
    name: 'FC 051 132F0003',
    brand: ProductBrand.danfoss,
    category: ProductCategory.inverter,
    series: 'FC51',
    description: 'Danfoss VLT Micro Drive, 0.75kW, 1-phase 200-240V',
    price: 3200000,
    stock: 25,
    stockStatus: StockStatus.inStock,
    primaryImage: 'assets/images/products/inverter/fc-051-0.75kw.jpg',
    specifications: {
      'Power': '0.75 kW',
      'Voltage': '1-phase 200-240V',
      'Warranty': '2 years',
    },
  ),
];
