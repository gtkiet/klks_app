// lib/design/constants/app_shadows.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// PKK Resident — Shadow / elevation tokens.
abstract final class AppShadows {
  /// Level 1 — subtle lift for cards on light backgrounds.
  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x14000000), // ~8 % black
      blurRadius: AppSpacing.elevationLow,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 2 — floating elements (sticky buttons, modals, sheets).
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1F000000), // ~12 % black
      blurRadius: AppSpacing.elevationFloat,
      offset: Offset(0, 4),
    ),
  ];

  /// Focused input glow — blue tint matching [AppColors.primary].
  static final List<BoxShadow> inputFocus = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.18),
      blurRadius: 6,
      offset: const Offset(0, 0),
    ),
  ];
}