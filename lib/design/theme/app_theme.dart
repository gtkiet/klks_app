// lib/design/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:klks_app/design/tokens/colors.dart';
import 'package:klks_app/design/tokens/radius.dart';
import 'package:klks_app/design/tokens/elevation.dart';
import 'package:klks_app/design/tokens/spacing.dart';
import 'package:klks_app/design/tokens/typography.dart';

import 'app_color_scheme.dart';
import 'app_text_theme.dart';

/// PKK Resident - Main Theme
///
/// Entry point for all theme configuration.
///
/// Usage in main.dart:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   // darkTheme: AppTheme.dark,  // when ready
/// )
/// ```
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.light,
    textTheme: AppTextTheme.light,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Be Vietnam Pro',

    // ── AppBar ───────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: AppTypography.headline.copyWith(
        color: AppColors.textPrimary,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    ),

    // ── Bottom Navigation Bar ─────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
      type: BottomNavigationBarType.fixed,
      elevation: AppElevation.bottomNavElevation,
      selectedLabelStyle: AppTypography.captionSmall,
      unselectedLabelStyle: AppTypography.captionSmall,
    ),

    // ── Elevated Button ───────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.secondaryLight,
        disabledForegroundColor: AppColors.textDisabled,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(double.infinity, 52),
        shape: AppRadius.buttonShape,
        textStyle: AppTypography.buttonLabel,
      ),
    ),

    // ── Outlined Button ───────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
        padding: AppSpacing.buttonPadding,
        minimumSize: const Size(double.infinity, 52),
        shape: AppRadius.buttonShape,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTypography.buttonLabel,
      ),
    ),

    // ── Text Button ───────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: AppSpacing.buttonPadding,
        textStyle: AppTypography.buttonLabel,
      ),
    ),

    // ── Input Decoration ──────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: AppSpacing.inputPadding,
      hintStyle: AppTypography.input.copyWith(color: AppColors.textDisabled),
      errorStyle: AppTypography.captionSmall.copyWith(color: AppColors.error),
      border: OutlineInputBorder(
        borderRadius: AppRadius.inputField,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputField,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputField,
        borderSide: const BorderSide(
          color: AppColors.borderFocused,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputField,
        borderSide: const BorderSide(color: AppColors.borderError, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputField,
        borderSide: const BorderSide(color: AppColors.borderError, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputField,
        borderSide: BorderSide.none,
      ),
    ),

    // ── Card ─────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: AppElevation.cardElevation,
      shadowColor: const Color(0x0D000000),
      // FIX: surfaceTint transparent để card không bị nhuộm màu primary
      // khi Material3 tự apply elevation tint.
      surfaceTintColor: Colors.transparent,
      shape: AppRadius.cardShape,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    // ── Dialog ────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppElevation.dialogElevation,
      // FIX: surfaceTint transparent — tương tự card.
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      titleTextStyle: AppTypography.headline.copyWith(
        color: AppColors.textPrimary,
      ),
      contentTextStyle: AppTypography.body.copyWith(
        color: AppColors.textSecondary,
      ),
    ),

    // ── Chip ──────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.inputFill,
      selectedColor: AppColors.primaryLight,
      // FIX: Thêm disabledColor để chip disabled có màu nhất quán.
      disabledColor: AppColors.secondaryLight,
      labelStyle: AppTypography.caption,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: const StadiumBorder(),
    ),

    // ── Divider ───────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // ── Progress Indicator ────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    // ── Snack Bar ─────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.body.copyWith(color: AppColors.surface),
      // FIX: Thêm actionTextColor để SnackBar action button có màu đúng.
      actionTextColor: AppColors.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonSmall),
      behavior: SnackBarBehavior.floating,
    ),
  );
}