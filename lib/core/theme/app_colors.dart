// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Prevenir instanciación
  AppColors._();

  // ========================================
  // LIGHT THEME COLORS
  // ========================================
  static const Color lightPrimary = Color(0xFF00E5FF); // Indigo
  static const Color lightSecondary = Color(0xFFF02193); // Amber
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFEF4444);
  // Text colors
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFF000000);
  static const Color lightOnBackground = Color(0xFF1F2937);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // ========================================
  // DARK THEME COLORS
  // ========================================
  static const Color darkPrimary = Color(0xFF00E5FF); // Lighter Indigo
  static const Color darkSecondary = Color(0xFFF02193); // Lighter Amber
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkError = Color(0xFFF87171);

  // Text colors
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFF9FAFB);
  static const Color darkOnSurface = Color(0xFFF9FAFB);
  static const Color darkOnError = Color(0xFF000000);

  // ========================================
  // SEMANTIC COLORS (compartidos)
  // ========================================
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ========================================
  // GRADIENTS
  // ========================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightPrimary, lightSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
