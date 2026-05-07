// lib/design/components/buttons/app_button.dart

import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../foundations/constants.dart';

/// Button variants matching TDS specification.
enum AppButtonVariant { primary, secondary, outline }

/// PKK Resident - App Button
///
/// Unified button component supporting all TDS variants and states.
///
/// Usage:
/// ```dart
/// // Primary action button (full width)
/// AppButton(
///   label: 'Thanh toán',
///   onPressed: _handlePay,
/// )
///
/// // Secondary
/// AppButton(
///   label: 'Huỷ',
///   variant: AppButtonVariant.secondary,
///   onPressed: _handleCancel,
/// )
///
/// // Outline
/// AppButton(
///   label: 'Xem chi tiết',
///   variant: AppButtonVariant.outline,
///   onPressed: _handleView,
/// )
///
/// // Loading state
/// AppButton(
///   label: 'Đang xử lý...',
///   isLoading: true,
///   onPressed: null,
/// )
///
/// // Inline (not full-width)
/// AppButton(
///   label: 'OK',
///   expanded: false,
///   onPressed: _confirm,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.expanded = true,
    this.height = 52.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// If true, shows a spinner and disables interaction.
  final bool isLoading;

  /// Optional icon displayed to the left of the label.
  final IconData? leadingIcon;

  /// If true, button stretches to full available width.
  final bool expanded;

  /// Button height. Defaults to 52pt per TDS.
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !isLoading;

    Widget child = _ButtonContent(
      label: label,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      variant: variant,
      isDisabled: isDisabled,
    );

    Widget button = switch (variant) {
      AppButtonVariant.primary => _PrimaryButton(
        onPressed: isLoading ? null : onPressed,
        height: height,
        child: child,
      ),
      AppButtonVariant.secondary => _SecondaryButton(
        onPressed: isLoading ? null : onPressed,
        height: height,
        child: child,
      ),
      AppButtonVariant.outline => _OutlineButton(
        onPressed: isLoading ? null : onPressed,
        height: height,
        child: child,
      ),
    };

    return expanded
        ? SizedBox(width: double.infinity, child: button)
        : IntrinsicWidth(child: button);
  }
}

// ─── Internal variants ────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.onPressed,
    required this.height,
    required this.child,
  });
  final VoidCallback? onPressed;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(
            minimumSize: Size(0, height),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.secondaryLight,
            disabledForegroundColor: AppColors.textDisabled,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? AppColors.textOnPrimary.withAlpha(30)
                  : null,
            ),
          ),
      child: child,
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.onPressed,
    required this.height,
    required this.child,
  });
  final VoidCallback? onPressed;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, height),
        backgroundColor: AppColors.secondaryLight,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.secondaryLight,
        disabledForegroundColor: AppColors.textDisabled,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      child: child,
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.onPressed,
    required this.height,
    required this.child,
  });
  final VoidCallback? onPressed;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, height),
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textDisabled,
        side: BorderSide(
          color: onPressed == null ? AppColors.border : AppColors.primary,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.variant,
    required this.isDisabled,
    this.leadingIcon,
  });

  final String label;
  final bool isLoading;
  final IconData? leadingIcon;
  final AppButtonVariant variant;
  final bool isDisabled;

  Color get _spinnerColor => switch (variant) {
    AppButtonVariant.primary => AppColors.textOnPrimary,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppConstants.spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: AppConstants.spinnerStrokeWidth,
              valueColor: AlwaysStoppedAnimation(_spinnerColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.buttonLabel),
        ],
      );
    }

    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.buttonLabel),
        ],
      );
    }

    return Text(label, style: AppTypography.buttonLabel);
  }
}
