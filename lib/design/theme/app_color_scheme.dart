// lib/design/theme/app_color_scheme.dart

import 'package:flutter/material.dart';

import 'package:klks_app/design/tokens/colors.dart';

/// PKK Resident - Color Scheme
///
/// Wraps [AppColors] tokens into Flutter's [ColorScheme].
/// Used by [AppTheme] to build [ThemeData].
abstract final class AppColorScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.primaryLight,
    surfaceTint: AppColors.primary,
  );

  // Dark theme scaffold — extend later when dark mode is required.
  // static const ColorScheme dark = ColorScheme( ... );
}
