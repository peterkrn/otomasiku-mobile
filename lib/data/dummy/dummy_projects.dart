import '../../models/project.dart';

/// Dummy projects for Milestone 2 UI development
/// Source: docs/PLAN_MILESTONE_2.md § "Other Dummy Data Files"
/// 2 projects: Maintenance Conveyor, Upgrade CNC
final List<Project> dummyProjects = [
  // Project 1: Maintenance Line Conveyor 3
  Project(
    id: 'proj-001',
    name: 'Maintenance Line Conveyor 3',
    description: 'Replacement parts for conveyor line maintenance',
    items: const [
      ProjectItem(
        id: 'pitem-001',
        productId: 'MIT-INV-001',
        productName: 'FR-A820-0.4K-1',
        productImage: 'assets/images/products/inverter/fr-a820-0.4k.jpg',
        price: 5200000,
        quantity: 3,
      ),
      ProjectItem(
        id: 'pitem-002',
        productId: 'MIT-PLC-001',
        productName: 'FX5U-32MT/ES',
        productImage: 'assets/images/products/plc/fx5u-32mt-es.jpg',
        price: 8800000,
        quantity: 2,
      ),
      ProjectItem(
        id: 'pitem-003',
        productId: 'MIT-SRV-001',
        productName: 'MR-J4-10B',
        productImage: 'assets/images/products/servo/mr-j4-10b.jpg',
        price: 6800000,
        quantity: 4,
      ),
      ProjectItem(
        id: 'pitem-004',
        productId: 'MIT-HMI-001',
        productName: 'GT2103-PMBDS',
        productImage: 'assets/images/products/hmi/gt2103-pmbds.jpg',
        price: 6500000,
        quantity: 2,
      ),
    ],
    createdAt: DateTime(2024, 10, 1),
    deadline: DateTime(2024, 12, 31),
    status: ProjectStatus.active,
  ),

  // Project 2: Upgrade Panel CNC-01
  Project(
    id: 'proj-002',
    name: 'Upgrade Panel CNC-01',
    description: 'Control panel upgrade for CNC machine',
    items: const [
      ProjectItem(
        id: 'pitem-005',
        productId: 'DAN-INV-001',
        productName: 'FC 302 131B0078',
        productImage: 'assets/images/products/inverter/fc-302-1.5kw.jpg',
        price: 12500000,
        quantity: 2,
      ),
      ProjectItem(
        id: 'pitem-006',
        productId: 'MIT-PLC-002',
        productName: 'FX3G-24MR/ES-A',
        productImage: 'assets/images/products/plc/fx3g-24mr-es.jpg',
        price: 5800000,
        quantity: 3,
      ),
      ProjectItem(
        id: 'pitem-007',
        productId: 'MIT-SRV-002',
        productName: 'MR-J4-10A',
        productImage: 'assets/images/products/servo/mr-j4-10a.jpg',
        price: 6200000,
        quantity: 2,
      ),
    ],
    createdAt: DateTime(2024, 9, 15),
    deadline: DateTime(2024, 11, 30),
    status: ProjectStatus.planning,
  ),
];
