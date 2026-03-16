import '../../models/order.dart';

/// Dummy orders for Milestone 2 UI development
/// Source: docs/PLAN_MILESTONE_2.md § "Other Dummy Data Files"
/// 3 orders: (1) Sedang Diproses, (2) Dikirim, (3) Selesai
final List<Order> dummyOrders = [
  // Order 1: INV-2024-8XJ2M9 — Sedang Diproses
  Order(
    id: 'order-001',
    orderNumber: 'INV-2024-8XJ2M9',
    items: const [
      OrderItem(
        id: 'item-001',
        productId: 'MIT-INV-001',
        productName: 'FR-A820-0.4K-1',
        productImage: 'assets/images/products/inverter/fr-a820-0.4k.jpg',
        price: 5200000,
        quantity: 2,
      ),
      OrderItem(
        id: 'item-002',
        productId: 'MIT-PLC-001',
        productName: 'FX5U-32MT/ES',
        productImage: 'assets/images/products/plc/fx5u-32mt-es.jpg',
        price: 8800000,
        quantity: 1,
      ),
    ],
    status: OrderStatus.processing,
    subtotal: 19200000,
    shippingCost: 50000,
    tax: 1920000,
    discount: 0,
    total: 19250000,
    createdAt: DateTime(2024, 11, 15),
    paymentMethod: 'BCA Virtual Account',
    vaNumber: '8806081234567890',
    paymentDeadline: DateTime(2024, 11, 16, 23, 59, 59),
    shippingAddressName: 'Peter - PT Otomasi Indonesia',
    shippingAddressFull:
        'Jl. Sudirman Kav. 28-30, Jakarta Selatan, DKI Jakarta, 12920',
  ),

  // Order 2: INV-2024-7KP4L2 — Dikirim
  Order(
    id: 'order-002',
    orderNumber: 'INV-2024-7KP4L2',
    items: const [
      OrderItem(
        id: 'item-003',
        productId: 'MIT-SRV-001',
        productName: 'MR-J4-10B',
        productImage: 'assets/images/products/servo/mr-j4-10b.jpg',
        price: 6800000,
        quantity: 2,
      ),
    ],
    status: OrderStatus.shipped,
    subtotal: 13600000,
    shippingCost: 35000,
    tax: 1360000,
    discount: 500000,
    total: 14495000,
    createdAt: DateTime(2024, 10, 28),
    paymentMethod: 'BCA Virtual Account',
    vaNumber: '8806081234567891',
    paymentDeadline: DateTime(2024, 10, 29, 23, 59, 59),
    shippingAddressName: 'Peter - PT Otomasi Indonesia',
    shippingAddressFull:
        'Jl. Raya Bekasi Km.25 Cakung, Jakarta Timur, DKI Jakarta, 13910',
  ),

  // Order 3: INV-2024-5MN8R1 — Selesai
  Order(
    id: 'order-003',
    orderNumber: 'INV-2024-5MN8R1',
    items: const [
      OrderItem(
        id: 'item-004',
        productId: 'DAN-INV-001',
        productName: 'FC 302 131B0078',
        productImage: 'assets/images/products/inverter/fc-302-1.5kw.jpg',
        price: 12500000,
        quantity: 1,
      ),
      OrderItem(
        id: 'item-005',
        productId: 'MIT-HMI-001',
        productName: 'GT2103-PMBDS',
        productImage: 'assets/images/products/hmi/gt2103-pmbds.jpg',
        price: 6500000,
        quantity: 1,
      ),
    ],
    status: OrderStatus.delivered,
    subtotal: 19000000,
    shippingCost: 40000,
    tax: 1900000,
    discount: 0,
    total: 19040000,
    createdAt: DateTime(2024, 9, 10),
    paymentMethod: 'BCA Virtual Account',
    vaNumber: '8806081234567892',
    paymentDeadline: DateTime(2024, 9, 11, 23, 59, 59),
    shippingAddressName: 'Peter - PT Otomasi Indonesia',
    shippingAddressFull:
        'Jl. Sudirman Kav. 28-30, Jakarta Selatan, DKI Jakarta, 12920',
  ),
];
