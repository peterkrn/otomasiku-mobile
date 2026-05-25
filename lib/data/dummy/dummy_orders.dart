import '../../models/order.dart';

final List<Order> dummyOrders = [
  Order(
    id: 'order-001',
    orderNumber: 'INV-2024-8XJ2M9',
    items: const [
      OrderItem(
        productId: 'MIT-INV-001',
        productName: 'FR-A820-0.4K-1',
        quantity: 2,
        unitPrice: 5200000,
        subtotal: 10400000,
      ),
      OrderItem(
        productId: 'MIT-PLC-001',
        productName: 'FX5U-32MT/ES',
        quantity: 1,
        unitPrice: 8800000,
        subtotal: 8800000,
      ),
    ],
    status: 'processing',
    paymentStatus: 'unpaid',
    totalAmount: 19250000,
    vaNumber: '8806081234567890',
    vaExpiresAt: DateTime(2024, 11, 16, 23, 59, 59),
    shippingAddress: const OrderAddress(
      recipient: 'Peter - PT Otomasi Indonesia',
      phone: '',
      street: 'Jl. Sudirman Kav. 28-30',
      city: 'Jakarta Selatan',
      province: 'DKI Jakarta',
      postalCode: '12920',
    ),
    createdAt: DateTime(2024, 11, 15),
    updatedAt: DateTime(2024, 11, 15),
  ),

  Order(
    id: 'order-002',
    orderNumber: 'INV-2024-7KP4L2',
    items: const [
      OrderItem(
        productId: 'MIT-SRV-001',
        productName: 'MR-J4-10B',
        quantity: 2,
        unitPrice: 6800000,
        subtotal: 13600000,
      ),
    ],
    status: 'shipped',
    paymentStatus: 'paid',
    totalAmount: 14495000,
    vaNumber: '8806081234567891',
    vaExpiresAt: DateTime(2024, 10, 29, 23, 59, 59),
    shippingAddress: const OrderAddress(
      recipient: 'Peter - PT Otomasi Indonesia',
      phone: '',
      street: 'Jl. Raya Bekasi Km.25 Cakung',
      city: 'Jakarta Timur',
      province: 'DKI Jakarta',
      postalCode: '13910',
    ),
    createdAt: DateTime(2024, 10, 28),
    updatedAt: DateTime(2024, 10, 28),
  ),

  Order(
    id: 'order-003',
    orderNumber: 'INV-2024-5MN8R1',
    items: const [
      OrderItem(
        productId: 'DAN-INV-001',
        productName: 'FC 302 131B0078',
        quantity: 1,
        unitPrice: 12500000,
        subtotal: 12500000,
      ),
      OrderItem(
        productId: 'MIT-HMI-001',
        productName: 'GT2103-PMBDS',
        quantity: 1,
        unitPrice: 6500000,
        subtotal: 6500000,
      ),
    ],
    status: 'done',
    paymentStatus: 'paid',
    totalAmount: 19040000,
    vaNumber: '8806081234567892',
    vaExpiresAt: DateTime(2024, 9, 11, 23, 59, 59),
    shippingAddress: const OrderAddress(
      recipient: 'Peter - PT Otomasi Indonesia',
      phone: '',
      street: 'Jl. Sudirman Kav. 28-30',
      city: 'Jakarta Selatan',
      province: 'DKI Jakarta',
      postalCode: '12920',
    ),
    createdAt: DateTime(2024, 9, 10),
    updatedAt: DateTime(2024, 9, 10),
  ),
];
