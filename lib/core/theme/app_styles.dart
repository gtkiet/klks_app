// lib/core/theme/app_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_constants.dart';

class AppStyles {
  AppStyles._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surfaceLight,
    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
    border: Border.all(color: AppColors.border),
  );

  static BoxDecoration cardDark = BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
    border: Border.all(color: AppColors.borderDark),
  );
}