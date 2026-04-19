import 'package:flutter/material.dart';

/// GateFlow brand color palette.
///
/// Central source of truth so every screen feels like one product.
/// Previously these values were hardcoded (0xFF0C3451, 0xFFF7C530, etc.)
/// across 30+ files.
class GateFlowColors {
  GateFlowColors._();

  static const Color brandPrimary = Color(0xFF0C3451);
  static const Color brandPrimaryDark = Color(0xFF092842);
  static const Color brandPrimarySoft = Color(0xFF1A3C6E);
  static const Color brandAccent = Color(0xFFF7C530);

  static const Color surface = Color(0xFFF5F7FA);
  static const Color surfaceElevated = Colors.white;
  static const Color divider = Color(0xFFF0F2F5);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color textTertiary = Color(0xFF8A94A6);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFB8C00);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF2177C1);

  static const Color pending = Color(0xFFFFF3E0);
  static const Color pendingText = Color(0xFFFB8C00);
  static const Color approved = Color(0xFFE8F5E9);
  static const Color approvedText = Color(0xFF22C55E);
  static const Color rejected = Color(0xFFFEE2E2);
  static const Color rejectedText = Color(0xFFEF4444);
}
