// lib/design/theme/app_text_theme.dart

import 'package:flutter/material.dart';

import 'package:klks_app/design/tokens/typography.dart';
import 'package:klks_app/design/tokens/colors.dart';

/// PKK Resident - Text Theme
///
/// Maps [AppTypography] tokens to Flutter's [TextTheme].
/// Applied to [ThemeData.textTheme] so all Text widgets inherit correct styles.
abstract final class AppTextTheme {
  static TextTheme get light =>
      const TextTheme(
        // ── Display ────────────────────────────────────────────────────────
        displayLarge: AppTypography.display,
        displayMedium: AppTypography.display,
        displaySmall: AppTypography.display,

        // ── Headline ───────────────────────────────────────────────────────
        headlineLarge: AppTypography.headline,
        headlineMedium: AppTypography.headline,
        headlineSmall: AppTypography.subhead,

        // ── Title ──────────────────────────────────────────────────────────
        // FIX: titleLarge đổi từ headline → subhead.
        // Flutter dùng titleLarge cho ListTile.title, NavigationDrawer header,
        // v.v. — 18px Bold quá nặng cho các context đó.
        // AppBar title được override riêng trong AppBarTheme.titleTextStyle
        // nên không bị ảnh hưởng bởi thay đổi này.
        titleLarge: AppTypography.subhead,
        titleMedium: AppTypography.subhead,
        titleSmall: AppTypography.subhead,

        // ── Body ───────────────────────────────────────────────────────────
        bodyLarge: AppTypography.bodyMedium,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.captionSmall,

        // ── Label ──────────────────────────────────────────────────────────
        labelLarge: AppTypography.buttonLabel,
        labelMedium: AppTypography.caption,
        labelSmall: AppTypography.captionSmall,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );
}