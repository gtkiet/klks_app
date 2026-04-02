// lib/design/constants/app_colors.dart

import 'package:flutter/material.dart';

/// PKK Resident — Central color palette.
/// All values sourced directly from the "Indigo Vista" design system.
/// Never use raw hex literals outside this file.
abstract final class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────────────
  /// #0052CC — Primary blue. Buttons, active nav, focused borders.
  static const Color primary = Color(0xFF0052CC);

  /// Slightly lighter tint used for pressed/ripple overlays.
  static const Color primaryLight = Color(0xFF1A6FE0);

  /// Dark variant for pressed states.
  static const Color primaryDark = Color(0xFF003E9C);

  // ─── Neutrals ─────────────────────────────────────────────────────────────
  /// #525F73 — Inactive icons, secondary text.
  static const Color secondary = Color(0xFF525F73);

  /// #FFFFFF — Card and component backgrounds.
  static const Color surface = Color(0xFFFFFFFF);

  /// #F7F9FC — Base screen background.
  static const Color background = Color(0xFFF7F9FC);

  /// Subtle divider / input fill background.
  static const Color inputFill = Color(0xFFF1F4F9);

  /// Divider lines.
  static const Color divider = Color(0xFFE0E6EF);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1E25);
  static const Color textSecondary = Color(0xFF525F73);
  static const Color textDisabled = Color(0xFFADB5C4);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  /// #2E7D32 — "Đã thanh toán", "Hoàn thành".
  static const Color success = Color(0xFF2E7D32);
  static const Color successSurface = Color(0xFFE8F5E9);

  /// #F57C00 — "Chờ xử lý", pending states.
  static const Color warning = Color(0xFFF57C00);
  static const Color warningSurface = Color(0xFFFFF3E0);

  /// #BA1A1A — Validation errors, failed payments.
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorSurface = Color(0xFFFFEDED);

  // ─── Overlay helpers ──────────────────────────────────────────────────────
  static const Color scrim = Color(0x66000000);
  static const Color shimmerBase = Color(0xFFE8ECF2);
  static const Color shimmerHighlight = Color(0xFFF5F7FA);
}