import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VGap / HGap — ergonomic spacing widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Vertical spacing shorthand.
///
/// Example:
/// ```dart
/// Column(children: [
///   TextWidget(),
///   const VGap.md(),   // 16pt
///   OtherWidget(),
/// ])
/// ```
class VGap extends StatelessWidget {
  const VGap(this.size, {super.key});
  const VGap.xs({super.key}) : size = AppSpacing.xs;
  const VGap.sm({super.key}) : size = AppSpacing.sm;
  const VGap.md({super.key}) : size = AppSpacing.md;
  const VGap.lg({super.key}) : size = AppSpacing.lg;
  const VGap.xl({super.key}) : size = AppSpacing.xl;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// Horizontal spacing shorthand.
class HGap extends StatelessWidget {
  const HGap(this.size, {super.key});
  const HGap.xs({super.key}) : size = AppSpacing.xs;
  const HGap.sm({super.key}) : size = AppSpacing.sm;
  const HGap.md({super.key}) : size = AppSpacing.md;
  const HGap.lg({super.key}) : size = AppSpacing.lg;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size);
}