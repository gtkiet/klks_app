// lib/design/shared/widgets/buttons/primary_button.dart

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

/// A full-width, brand-blue button for primary actions (Login, Pay, Confirm).
///
/// States handled internally:
/// - **Default** — solid [AppColors.primary] fill.
/// - **Pressed** — 0.7 opacity via Flutter's built-in splash.
/// - **Loading** — replaces label with a [CircularProgressIndicator].
/// - **Disabled** — greyed out, non-interactive.
///
/// Example:
/// ```dart
/// PrimaryButton(
///   label: 'Thanh toán',
///   onPressed: _handlePay,
///   isLoading: _isProcessing,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.buttonHeight,
  });

  /// Button label text.
  final String label;

  /// Callback invoked on tap. Pass `null` to render as disabled.
  final VoidCallback? onPressed;

  /// When `true` the label is replaced by a loading spinner.
  final bool isLoading;

  /// Optional leading icon placed before [label].
  final Widget? icon;

  /// Explicit width override. Defaults to `double.infinity` (full-width).
  final double? width;

  /// Height override. Defaults to [AppSpacing.buttonHeight] (48pt).
  final double height;

  bool get _isDisabled => onPressed == null && !isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isDisabled ? AppColors.inputFill : AppColors.primary,
          disabledBackgroundColor:
              isLoading ? AppColors.primary : AppColors.inputFill,
          foregroundColor: AppColors.textOnPrimary,
          disabledForegroundColor: isLoading
              ? AppColors.textOnPrimary
              : AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          // Pressed opacity handled by overlayColor
          overlayColor: Colors.white.withValues(alpha: 0.15),
        ),
        child: isLoading ? _buildLoader() : _buildLabel(),
      ),
    );
  }

  Widget _buildLabel() {
    final textWidget = Text(
      label,
      style: AppTextStyles.button.copyWith(
        color: _isDisabled ? AppColors.textDisabled : AppColors.textOnPrimary,
      ),
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: AppSpacing.xs),
        textWidget,
      ],
    );
  }

  Widget _buildLoader() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
      ),
    );
  }
}