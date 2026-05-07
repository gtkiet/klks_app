// lib/design/tokens/colors.dart

import 'package:flutter/material.dart';

/// PKK Resident - Color Design Tokens
///
/// Single source of truth for all colors in the application.
/// Never use [Colors.xxx] directly in UI code — always reference this class.
///
/// Usage:
/// ```dart
/// import 'package:pkk_resident/design/design.dart';
/// color: AppColors.primary,
/// ```

abstract final class AppColors {
  // ─── Brand / Primary ───────────────────────────────────────────────────────
  /// Main brand color. Used for primary buttons, active nav icons, focused inputs.
  static const Color primary = Color(0xFF0052CC);

  /// Darker shade for pressed / hover states.
  static const Color primaryDark = Color(0xFF003D99);

  /// Lighter tint for splash / ripple.
  static const Color primaryLight = Color(0xFFE6EEFF);

  // ─── Secondary / Neutral ───────────────────────────────────────────────────
  /// Used for inactive icons, secondary text, and dividers.
  static const Color secondary = Color(0xFF525F73);

  /// Light variant for secondary backgrounds.
  static const Color secondaryLight = Color(0xFFEBEDF0);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  /// Positive actions, "Đã thanh toán", "Hoàn thành" statuses.
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  /// "Chờ xử lý", "Pending" warnings.
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);

  /// Validation errors, "Thanh toán thất bại".
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFFEDEA);

  // ─── Surfaces ──────────────────────────────────────────────────────────────
  /// Main card and screen background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Base screen background — provides contrast with cards.
  static const Color background = Color(0xFFF7F9FC);

  /// Input field default fill.
  static const Color inputFill = Color(0xFFF0F2F5);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF525F73);
  static const Color textDisabled = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Border ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFDEE2E6);
  static const Color borderFocused = Color(0xFF0052CC);
  static const Color borderError = Color(0xFFBA1A1A);

  // ─── Overlay ───────────────────────────────────────────────────────────────
  static const Color scrim = Color(0x99000000);
  static const Color divider = Color(0xFFF0F2F5);
}
