import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textMainLight,
        secondary: AppColors.primary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(bodyColor: AppColors.textMainLight, displayColor: AppColors.textMainLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textMainLight),
      ),
      iconTheme: const IconThemeData(color: AppColors.textMainLight),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textMainDark,
        secondary: AppColors.primary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(bodyColor: AppColors.textMainDark, displayColor: AppColors.textMainDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textMainDark),
      ),
      iconTheme: const IconThemeData(color: AppColors.textMainDark),
    );
  }
}
