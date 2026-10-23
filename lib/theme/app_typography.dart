import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Skala tipografi aplikasi (font Poppins).
///
/// Hierarchy: display > title > sectionTitle > cardTitle > body > label.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme() {
    final base = GoogleFonts.poppinsTextTheme();
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 11,
        color: AppColors.textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        color: AppColors.textSecondary,
      ),
    );
  }
}
