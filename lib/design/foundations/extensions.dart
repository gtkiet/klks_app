// lib/design/foundations/extensions.dart

import 'package:flutter/material.dart';
import '../tokens/colors.dart';

/// PKK Resident - Extension helpers
///
/// Provides convenient accessors on [BuildContext] and common types.
///
/// Usage:
/// ```dart
/// context.colorScheme.primary
/// context.textTheme.bodyMedium
/// 16.0.verticalSpace
/// ```

// ─── BuildContext extensions ──────────────────────────────────────────────────
extension AppContextExtensions on BuildContext {
  /// Access the resolved [ColorScheme] from context.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access the resolved [TextTheme] from context.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// True if keyboard is visible.
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
}

// ─── SizedBox helpers ─────────────────────────────────────────────────────────
extension DoubleSpacingExtension on double {
  /// ```dart
  /// 16.0.verticalSpace  // SizedBox(height: 16)
  /// ```
  SizedBox get verticalSpace => SizedBox(height: this);

  /// ```dart
  /// 16.0.horizontalSpace  // SizedBox(width: 16)
  /// ```
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension IntSpacingExtension on int {
  SizedBox get verticalSpace => SizedBox(height: toDouble());
  SizedBox get horizontalSpace => SizedBox(width: toDouble());
}

// ─── Text style helpers ───────────────────────────────────────────────────────
extension TextStyleColorExtension on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle get primary => copyWith(color: AppColors.primary);
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);
  TextStyle get error => copyWith(color: AppColors.error);
  TextStyle get disabled => copyWith(color: AppColors.textDisabled);
  TextStyle get onPrimary => copyWith(color: AppColors.textOnPrimary);
}