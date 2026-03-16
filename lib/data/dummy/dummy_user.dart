import '../../models/user_profile.dart';

/// Dummy user profile for Milestone 2 UI development
/// Source: docs/PLAN_MILESTONE_2.md § "Other Dummy Data Files"
final UserProfile dummyUser = UserProfile(
  id: 'user-001',
  email: 'stefani@ptautomasi.com',
  name: 'Peter',
  company: 'PT Otomasi Indonesia',
  phone: '+62 812 3456 7890',
  npwp: '01.234.567.8-901.000',
  joinedAt: DateTime(2024, 1, 15),
);
