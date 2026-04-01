import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoirly/core/theme/app_colors.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = ColorScheme(
    brightness: brightness,
    primary: isDark ? const Color(0xFFBFC0BF) : AppColors.primary,
    onPrimary: isDark ? const Color(0xFF1C1C1C) : AppColors.onPrimary,
    primaryContainer:
        isDark ? const Color(0xFF2E3230) : AppColors.primaryContainer,
    onPrimaryContainer:
        isDark ? const Color(0xFFD5D6D5) : AppColors.primaryDim,
    secondary: isDark ? const Color(0xFF9CA382) : AppColors.secondary,
    onSecondary: isDark ? const Color(0xFF1A1C14) : AppColors.onSecondary,
    secondaryContainer:
        isDark ? const Color(0xFF343B2E) : AppColors.secondaryContainer,
    onSecondaryContainer:
        isDark ? const Color(0xFFDDE4C8) : AppColors.onSecondaryContainer,
    error: AppColors.error,
    onError: Colors.white,
    surface: isDark ? const Color(0xFF121412) : AppColors.surface,
    onSurface: isDark ? const Color(0xFFE2E6E4) : AppColors.onSurface,
    onSurfaceVariant:
        isDark ? const Color(0xFF9DA39F) : AppColors.onSurfaceVariant,
    surfaceContainerHighest:
        isDark ? const Color(0xFF2A2F2D) : AppColors.surfaceContainerHighest,
    surfaceContainerLowest:
        isDark ? const Color(0xFF0D0F0E) : AppColors.surfaceContainerLowest,
    outline: isDark ? const Color(0xFF5C6360) : AppColors.outlineVariant,
    outlineVariant:
        isDark ? const Color(0xFF3D4441) : AppColors.outlineVariant,
    surfaceContainerLow:
        isDark ? const Color(0xFF1E221F) : AppColors.surfaceContainerLow,
    surfaceContainerHigh:
        isDark ? const Color(0xFF252A27) : AppColors.surfaceContainerHigh,
    tertiary: isDark ? const Color(0xFFD4C4B4) : AppColors.tertiary,
    onTertiary: isDark ? const Color(0xFF1A1510) : AppColors.onSecondary,
  );

  final textTheme = TextTheme(
    headlineLarge: GoogleFonts.newsreader(
      fontSize: 40,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: base.onSurface,
    ),
    headlineMedium: GoogleFonts.newsreader(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: base.onSurface,
    ),
    titleLarge: GoogleFonts.manrope(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      color: base.onSurface,
    ),
    titleMedium: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: base.onSurface,
    ),
    bodyLarge: GoogleFonts.newsreader(
      fontSize: 20,
      height: 1.7,
      color: base.onSurface,
    ),
    bodyMedium: GoogleFonts.newsreader(
      fontSize: 18,
      height: 1.6,
      color: base.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: base.onSurface,
    ),
    labelSmall: GoogleFonts.manrope(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 2,
      color: base.onSurfaceVariant,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: base.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: base.surface.withValues(alpha: 0.85),
      foregroundColor: base.onSurface,
      titleTextStyle: GoogleFonts.newsreader(
        fontSize: 22,
        fontStyle: FontStyle.italic,
        color: base.onSurface,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: base.secondary,
      foregroundColor: base.onSecondary,
      elevation: 8,
      shape: const CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: base.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
