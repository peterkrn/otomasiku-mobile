import 'package:flutter_dotenv/flutter_dotenv.dart';

// lib/core/constants/bca_config.dart
/// BCA Developer API Sandbox configuration
/// M2 mini backend — BCA Sandbox only
/// This URL points to the Railway-deployed mini Express backend
/// Switch to production URL in Milestone 3 when full backend is ready
class BcaConfig {
  BcaConfig._();

  static String get miniBackendBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://otomasiku-backend-staging.up.railway.app/api';

  // VA expiry duration (24 hours from creation)
  static const Duration vaExpiry = Duration(hours: 24);

  // API endpoints
  static String get createVaEndpoint => '$miniBackendBaseUrl/api/payment/create-va';
  static String get vaStatusEndpoint => '$miniBackendBaseUrl/api/payment/status';
  static String get vaCallbackEndpoint => '$miniBackendBaseUrl/api/payment/callback';
}
