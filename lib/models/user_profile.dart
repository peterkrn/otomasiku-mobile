/// User profile model for Otomasiku Marketplace
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? company;
  final String phone;
  final String? npwp;
  final DateTime? joinedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.company,
    required this.phone,
    this.npwp,
    this.joinedAt,
  });
}
