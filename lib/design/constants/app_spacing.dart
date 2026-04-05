// lib/design/constants/app_spacing.dart

/// PKK Resident — Spacing system.
/// Based on an 8pt grid. Always use these constants; never use
/// raw numeric literals for spacing in the widget tree.
abstract final class AppSpacing {
  // ─── Base unit ────────────────────────────────────────────────────────────
  static const double unit = 8.0;

  // ─── Incremental steps ────────────────────────────────────────────────────
  /// 4pt  — Micro gap (icon ↔ label, tight lists).
  static const double xs = 4.0;

  /// 8pt  — Small gap.
  static const double sm = 8.0;

  /// 16pt — Standard padding / medium gap.
  static const double md = 16.0;

  /// 24pt — Wide padding / large gap.
  static const double lg = 24.0;

  /// 32pt — Section separation.
  static const double xl = 32.0;

  /// 48pt — Hero / splash whitespace.
  static const double xxl = 48.0;

  // ─── Named semantic shortcuts ─────────────────────────────────────────────
  /// Horizontal screen edge padding.
  static const double screenHorizontal = 16.0;

  /// Vertical screen edge padding (top / bottom).
  static const double screenVertical = 24.0;

  /// Inner card padding.
  static const double cardPadding = 16.0;

  /// Gap between cards in a list.
  static const double cardGap = 12.0;

  /// Gap between form fields.
  static const double fieldGap = 16.0;

  // ─── Border radii ─────────────────────────────────────────────────────────
  /// 12pt — Input fields.
  static const double radiusInput = 12.0;

  /// 16pt — Cards, large buttons.
  static const double radiusCard = 16.0;

  /// 24pt — Chips, badges, small pills.
  static const double radiusPill = 24.0;

  /// Fully circular (FABs, avatar).
  static const double radiusCircle = 999.0;

  // ─── Elevation shadow blurs ───────────────────────────────────────────────
  /// Level 1 — Subtle card elevation.
  static const double elevationLow = 4.0;

  /// Level 2 — Floating elements (sticky buttons, modals).
  static const double elevationFloat = 12.0;

  // ─── Component heights ────────────────────────────────────────────────────
  static const double buttonHeight = 48.0;
  static const double inputHeight = 52.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
}