import '../config/env_config.dart';

// lib/core/constants/bca_config.dart
/// BCA Developer API Sandbox configuration
/// M2 mini backend — BCA Sandbox only
class BcaConfig {
  BcaConfig._();

  static String get miniBackendBaseUrl => EnvConfig.apiBaseUrl;

  // VA expiry duration (24 hours from creation)
  static const Duration vaExpiry = Duration(hours: 24);

  // API endpoints (miniBackendBaseUrl already includes /api)
  static String get createVaEndpoint => '$miniBackendBaseUrl/payment/create-va';
  static String get vaStatusEndpoint => '$miniBackendBaseUrl/payment/status';
  static String get vaCallbackEndpoint => '$miniBackendBaseUrl/payment/callback';
}
