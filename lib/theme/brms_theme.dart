import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Monochrome design tokens and typography for CSU-Aparri BRMS Desktop/Web.
class BrmsColors {
  const BrmsColors._();

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFEDEEF1);
  static const Color surfaceContainerHighest = Color(0xFFE2E8F0);

  static const Color primary = Color(0xFF0F172A);
  static const Color primaryContainer = Color(0xFF1E293B);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color secondary = Color(0xFF64748B);
  static const Color outline = Color(0xFF94A3B8);
  static const Color outlineVariant = Color(0xFFE2E8F0);

  static const Color barDark = Color(0xFF1E293B);
  static const Color barMedium = Color(0xFF475569);
  static const Color barMuted = Color(0xFF64748B);
  static const Color barLight = Color(0xFF94A3B8);

  static const Color statusActiveDot = Color(0xFF059669);
  static const Color error = Color(0xFFBA1A1A);
}

class BrmsTheme {
  const BrmsTheme._();

  static ThemeData light() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BrmsColors.background,
      colorScheme: const ColorScheme.light(
        primary: BrmsColors.primary,
        onPrimary: BrmsColors.onPrimary,
        primaryContainer: BrmsColors.primaryContainer,
        secondary: BrmsColors.secondary,
        surface: BrmsColors.surface,
        onSurface: BrmsColors.onSurface,
        onSurfaceVariant: BrmsColors.onSurfaceVariant,
        outline: BrmsColors.outline,
        outlineVariant: BrmsColors.outlineVariant,
        error: BrmsColors.error,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: BrmsColors.onSurface,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BrmsColors.onSurface,
          letterSpacing: -0.2,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: BrmsColors.onSurface,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: BrmsColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: BrmsColors.onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: BrmsColors.secondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: BrmsColors.secondary,
          letterSpacing: 0.4,
        ),
      ),
      dividerColor: BrmsColors.outlineVariant,
    );
  }

  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color color = BrmsColors.onSurface,
    double? letterSpacing,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle heading({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = BrmsColors.onSurface,
    double? letterSpacing,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
