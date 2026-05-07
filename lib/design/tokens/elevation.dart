// lib/design/tokens/elevation.dart

import 'package:flutter/material.dart';

/// PKK Resident - Elevation / Shadow Design Tokens
///
/// Usage:
/// ```dart
/// boxShadow: AppElevation.level1
/// ```

abstract final class AppElevation {
  // ─── Level 1 — Low ────────────────────────────────────────────────────────
  /// Used for cards on light backgrounds. Subtle depth.
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0D000000), // ~5% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x08000000), // ~3% black
      blurRadius: 1,
      offset: Offset(0, 0),
    ),
  ];

  // ─── Level 2 — Floating ────────────────────────────────────────────────────
  /// Used for sticky buttons, modals, bottom sheets.
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  // ─── Level 3 — Overlay ────────────────────────────────────────────────────
  /// Used for dialogs and overlays.
  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x29000000), blurRadius: 32, offset: Offset(0, 8)),
  ];

  // ─── Material elevation values (for ThemeData) ────────────────────────────
  static const double cardElevation = 1.0;
  static const double dialogElevation = 6.0;
  static const double bottomNavElevation = 8.0;
}
