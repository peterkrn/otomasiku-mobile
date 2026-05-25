import 'package:flutter/material.dart';

/// Brand and UI colors for Otomasiku Marketplace
abstract class AppColors {
  AppColors._();

  // Brand Colors
  static const Color mitsubishiRed = Color(0xFFE7192D);
  static const Color danfossBlue = Color(0xFF005A8C);
  static const Color bcaBlue = Color(0xFF0066AE);

  // Light Mode Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Dark Mode Colors (matching website dark-mode.css)
  static const Color darkBackground = Color(0xFF111111);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF262626);
  static const Color darkTextPrimary = Color(0xFFE5E5E5);
  static const Color darkTextSecondary = Color(0xFFA3A3A3);
  static const Color darkTextTertiary = Color(0xFF737373);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF262626);

  // Dark mode colored tints (for category cards, etc.)
  static const Color darkGreenTint = Color(0xFF0A1F0D);
  static const Color darkBlueTint = Color(0xFF0A1220);
  static const Color darkRedTint = Color(0xFF1F0A0A);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
