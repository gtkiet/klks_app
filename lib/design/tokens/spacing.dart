// lib/design/tokens/spacing.dart

import 'package:flutter/material.dart';

/// PKK Resident - Spacing Design Tokens
///
/// Based on an 8pt grid system as specified in TDS.
/// Always use these constants instead of raw numbers.
///
/// Usage:
/// ```dart
/// Padding(padding: EdgeInsets.all(AppSpacing.md))
/// SizedBox(height: AppSpacing.lg)
/// ```
abstract final class AppSpacing {
  // ─── Base Scale ────────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  // FIX: Thêm sm2 = 12.0 để insetV12 không hardcode số thô.
  // 12pt nằm ngoài 8pt grid nhưng phổ biến trong input/button padding —
  // đặt tên rõ ràng hơn là để magic number rải rác trong code.
  static const double sm2 = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ─── Semantic Aliases ──────────────────────────────────────────────────────
  /// Standard screen horizontal padding.
  static const double screenHorizontal = md; // 16pt

  /// Wide screen horizontal padding (e.g., section headers).
  static const double screenHorizontalWide = lg; // 24pt

  /// Standard gap between list items.
  static const double gapSmall = sm; // 8pt

  /// Standard gap between sections / cards.
  static const double gapMedium = md; // 16pt

  /// Large gap for layout separation.
  static const double gapLarge = lg; // 24pt

  // ─── Insets (EdgeInsets helpers) ───────────────────────────────────────────
  static const EdgeInsets insetAll4 = EdgeInsets.all(xs);
  static const EdgeInsets insetAll8 = EdgeInsets.all(sm);
  static const EdgeInsets insetAll16 = EdgeInsets.all(md);
  static const EdgeInsets insetAll24 = EdgeInsets.all(lg);

  static const EdgeInsets insetH16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets insetH24 = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets insetV8 = EdgeInsets.symmetric(vertical: sm);
  // FIX: Dùng token sm2 thay vì hardcode 12.
  static const EdgeInsets insetV12 = EdgeInsets.symmetric(vertical: sm2);
  static const EdgeInsets insetV16 = EdgeInsets.symmetric(vertical: md);

  /// Standard card inner padding.
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Button inner padding — tall hit area for accessibility.
  /// vertical: 14pt là ngoại lệ có chủ đích (hit area ≥ 52pt total height).
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );

  /// Input field inner padding.
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 14,
  );
}