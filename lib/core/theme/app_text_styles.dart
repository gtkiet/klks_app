// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _font = 'Roboto';

  static const TextTheme textThemeLight = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: _font,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontFamily: _font,
      color: AppColors.textPrimary,
    ),

    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: _font,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: _font,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: _font,
      color: AppColors.textSecondary,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: _font,
      color: Colors.white,
    ),
  );

  static const TextTheme textThemeDark = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: _font,
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontFamily: _font,
      color: AppColors.textPrimaryDark,
    ),

    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: _font,
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: _font,
      color: AppColors.textSecondaryDark,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: _font,
      color: AppColors.textSecondaryDark,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: _font,
      color: Colors.white,
    ),
  );
}
