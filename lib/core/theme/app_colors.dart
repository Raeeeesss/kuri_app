import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Deep Kerala Green palette
  static const Color primary = Color(0xFF0D5C3A); // Deep Kerala Green
  static const Color primaryDark = Color(0xFF073D26);
  static const Color primaryLight = Color(0xFF168052);
  static const Color primarySurface = Color(0xFFE8F5E9);

  // Accent / Gold
  static const Color accent = Color(0xFFDAA520);
  static const Color accentLight = Color(0xFFFFF8E7);

  // Neutrals
  static const Color background = Color(0xFFF8FAF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF3F6F4);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status & State
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = Color(0xFF0D5C3A);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
