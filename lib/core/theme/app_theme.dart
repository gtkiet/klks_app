// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_constants.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ───────────────── LIGHT ─────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Times New Roman',

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
      ),

      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTextStyles.textThemeLight,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.divider),
    );
  }

  // ───────────────── DARK ─────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
      ),

      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTextStyles.textThemeDark,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.borderDark),
    );
  }
}
