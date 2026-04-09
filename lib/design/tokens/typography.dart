import 'package:flutter/material.dart';

/// PKK Resident - Typography Design Tokens
///
/// All text styles use [Be Vietnam Pro] as per TDS specification.
/// Make sure the font is declared in pubspec.yaml:
///
/// ```yaml
/// fonts:
///   - family: Be Vietnam Pro
///     fonts:
///       - asset: assets/fonts/BeVietnamPro-Regular.ttf
///       - asset: assets/fonts/BeVietnamPro-Medium.ttf    weight: 500
///       - asset: assets/fonts/BeVietnamPro-SemiBold.ttf  weight: 600
///       - asset: assets/fonts/BeVietnamPro-Bold.ttf      weight: 700
/// ```
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTypography.headline)
/// ```
abstract final class AppTypography {
  static const String _fontFamily = 'Be Vietnam Pro';

  // ─── Display / Hero ────────────────────────────────────────────────────────
  /// 30px Bold — Splash screen and large welcome headers.
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.27, // ~38px line-height
    letterSpacing: -0.5,
  );

  // ─── Headline ──────────────────────────────────────────────────────────────
  /// 18px Bold — Section titles and AppBar titles.
  static const TextStyle headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.33, // ~24px
    letterSpacing: -0.2,
  );

  // ─── Subhead ───────────────────────────────────────────────────────────────
  /// 14px SemiBold — Sub-labels and card titles.
  static const TextStyle subhead = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43, // ~20px
  );

  // ─── Body ──────────────────────────────────────────────────────────────────
  /// 14px Regular — Standard content and descriptions.
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.57, // ~22px
  );

  /// 14px Medium — Slightly emphasized body text.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.57,
  );

  // ─── Caption ───────────────────────────────────────────────────────────────
  /// 12px Medium — Timestamps, metadata, micro-copy.
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5, // ~18px
    letterSpacing: 0.1,
  );

  /// 12px Regular — Smallest informational text.
  static const TextStyle captionSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Button Label ──────────────────────────────────────────────────────────
  /// 14px SemiBold — Used inside buttons and interactive labels.
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
  );

  // ─── Input ─────────────────────────────────────────────────────────────────
  /// 14px Regular — Input field value and placeholder.
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );
}
