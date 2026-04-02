// lib/design/constants/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// PKK Resident — Typography system.
/// Typeface: Be Vietnam Pro (Google Fonts).
/// All sizes and weights taken directly from the "Indigo Vista" spec.
abstract final class AppTextStyles {
  // ─── Internal font family constant ────────────────────────────────────────
  static const String _font = 'BeVietnamPro';

  // ─── Scale ────────────────────────────────────────────────────────────────

  /// Display / Hero — 30px Bold.
  /// Splash screen, large welcome headers.
  static const TextStyle display = TextStyle(
    fontFamily: _font,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Headline — 18px Bold.
  /// Section titles, AppBar titles.
  static const TextStyle headline = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Subhead — 14px SemiBold.
  /// Sub-labels, card titles.
  static const TextStyle subhead = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Body — 14px Regular.
  /// Standard content, descriptions.
  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Body — 14px Regular in secondary colour.
  static TextStyle get bodySecondary =>
      body.copyWith(color: AppColors.textSecondary);

  /// Caption — 12px Medium.
  /// Timestamps, metadata, micro-copy.
  static const TextStyle caption = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Button label — 14px SemiBold, used inside buttons.
  static const TextStyle button = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
  );

  /// Error / helper text below inputs — 12px Regular.
  static const TextStyle inputHelper = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.error,
  );

  // ─── Convenience modifiers ────────────────────────────────────────────────
  /// Returns [base] coloured white — e.g. for text on primary buttons.
  static TextStyle onPrimary(TextStyle base) =>
      base.copyWith(color: AppColors.textOnPrimary);

  /// Returns [base] coloured with the primary brand blue.
  static TextStyle primaryColored(TextStyle base) =>
      base.copyWith(color: AppColors.primary);
}