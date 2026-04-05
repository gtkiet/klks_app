// lib/design/shared/widgets/buttons/secondary_button.dart

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SecondaryButton
// ─────────────────────────────────────────────────────────────────────────────

/// A neutral, grey-filled button for secondary / non-destructive actions.
///
/// Example:
/// ```dart
/// SecondaryButton(
///   label: 'Huỷ',
///   onPressed: Navigator.of(context).pop,
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
    this.height = AppSpacing.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.inputFill,
          disabledBackgroundColor: AppColors.inputFill,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          overlayColor: AppColors.secondary.withValues(alpha: 0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.xs)],
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: onPressed == null
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OutlineButton
// ─────────────────────────────────────────────────────────────────────────────

/// A blue-border, transparent-background button for secondary-but-branded actions.
///
/// Example:
/// ```dart
/// OutlineButton(
///   label: 'Xem chi tiết',
///   onPressed: _viewDetail,
/// )
/// ```
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.borderColor,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final double height;

  /// Defaults to [AppColors.primary].
  final Color? borderColor;

  /// Defaults to [AppColors.primary].
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;
    final isDisabled = onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          disabledForegroundColor: AppColors.textDisabled,
          side: BorderSide(
            color: isDisabled ? AppColors.divider : effectiveBorderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          overlayColor: effectiveBorderColor.withValues(alpha: 0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.xs)],
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isDisabled ? AppColors.textDisabled : effectiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
