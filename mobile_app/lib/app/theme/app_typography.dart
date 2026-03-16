import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Color bodyColor, Color secondaryColor) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: bodyColor,
        letterSpacing: -1.8,
        height: 0.96,
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: bodyColor,
        letterSpacing: -1.2,
        height: 0.98,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: bodyColor,
        letterSpacing: -0.7,
        height: 1.05,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: bodyColor,
        letterSpacing: -0.4,
        height: 1.08,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: bodyColor,
        letterSpacing: -0.2,
        height: 1.15,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: bodyColor,
        letterSpacing: -0.1,
        height: 1.18,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        height: 1.6,
        fontWeight: FontWeight.w500,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 1.58,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: bodyColor,
        height: 1.15,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: bodyColor,
        height: 1.1,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: secondaryColor,
        height: 1.0,
      ),
    );
  }

  static TextTheme light() =>
      textTheme(AppColors.textPrimary, AppColors.textSecondary);

  static TextTheme dark() =>
      textTheme(AppColors.darkText, AppColors.darkTextSecondary);
}
