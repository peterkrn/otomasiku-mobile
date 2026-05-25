import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/models/user_profile.dart';

void main() {
  group('UserProfile.fromJson', () {
    final json = {
      'id': 'user-001',
      'email': 'peter@otomasi.com',
      'role': 'customer',
      'fullName': 'Peter',
      'phone': '08123456789',
      'companyName': 'PT Otomasi Indonesia',
      'avatarUrl': null,
    };

    test('parses all fields correctly', () {
      final profile = UserProfile.fromJson(json as Map<String, dynamic>);

      expect(profile.id, 'user-001');
      expect(profile.email, 'peter@otomasi.com');
      expect(profile.role, 'customer');
      expect(profile.fullName, 'Peter');
      expect(profile.phone, '08123456789');
      expect(profile.companyName, 'PT Otomasi Indonesia');
      expect(profile.avatarUrl, isNull);
    });
  });
}
