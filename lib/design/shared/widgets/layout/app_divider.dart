import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppDivider
// ─────────────────────────────────────────────────────────────────────────────

/// A styled horizontal divider that respects the design token colours.
///
/// Example:
/// ```dart
/// const AppDivider()                        // full-width
/// const AppDivider(indent: AppSpacing.md)   // indented
/// ```
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = 1,
    this.color,
    this.height,
  });

  final double indent;
  final double endIndent;
  final double thickness;
  final Color? color;

  /// Total vertical space the divider occupies. Defaults to [thickness].
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? thickness,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? AppColors.divider,
    );
  }
}
