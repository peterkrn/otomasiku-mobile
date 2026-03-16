/// Project model for B2B customers who buy in bulk for specific projects
/// Source: PLAN_MILESTONE_2.md § "Other Dummy Data Files"
class Project {
  final String id;
  final String name;
  final String? description;
  final List<ProjectItem> items;
  final DateTime createdAt;
  final DateTime? deadline;
  final ProjectStatus status;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.items,
    required this.createdAt,
    this.deadline,
    required this.status,
  });

  /// Total project value
  int get totalValue => items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Total number of items in project
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Project copyWith({
    String? id,
    String? name,
    String? description,
    List<ProjectItem>? items,
    DateTime? createdAt,
    DateTime? deadline,
    ProjectStatus? status,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
    );
  }
}

/// Individual item in a project
class ProjectItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int price;
  final int quantity;

  const ProjectItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
  });

  /// Total price for this item
  int get totalPrice => price * quantity;
}

/// Project status
enum ProjectStatus {
  planning,
  active,
  completed,
  onHold,
}
