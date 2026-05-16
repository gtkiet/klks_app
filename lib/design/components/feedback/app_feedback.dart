// lib/design/components/feedback/app_feedback.dart

import 'package:flutter/material.dart';

import 'package:klks_app/design/tokens/colors.dart';
import 'package:klks_app/design/tokens/typography.dart';
import 'package:klks_app/design/tokens/radius.dart';
import 'package:klks_app/design/foundations/constants.dart';
import 'package:klks_app/design/components/buttons/app_button.dart';

/// Badge display variants.
enum AppBadgeVariant { success, warning, error, info }

/// PKK Resident - Status Badge
///
/// Compact label for statuses like "Đã thanh toán", "Pending", etc.
///
/// Usage:
/// ```dart
/// AppStatusBadge(label: 'Completed', variant: AppBadgeVariant.success)
/// AppStatusBadge(label: 'Pending',   variant: AppBadgeVariant.warning)
/// AppStatusBadge(label: 'High Priority', variant: AppBadgeVariant.error)
/// ```
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.info,
  });

  final String label;
  final AppBadgeVariant variant;

  Color get _bgColor => switch (variant) {
    AppBadgeVariant.success => AppColors.successLight,
    AppBadgeVariant.warning => AppColors.warningLight,
    AppBadgeVariant.error => AppColors.errorLight,
    AppBadgeVariant.info => AppColors.primaryLight,
  };

  Color get _textColor => switch (variant) {
    AppBadgeVariant.success => AppColors.success,
    AppBadgeVariant.warning => AppColors.warning,
    AppBadgeVariant.error => AppColors.error,
    AppBadgeVariant.info => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _bgColor, borderRadius: AppRadius.badge),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.captionSmall.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Confirm Dialog ────────────────────────────────────────────────────────────

/// PKK Resident - Confirm Dialog
///
/// Standard two-action confirmation dialog.
///
/// Usage:
/// ```dart
/// final confirmed = await AppConfirmDialog.show(
///   context,
///   title: 'Confirm Action?',
///   message: 'This action cannot be undone.',
///   confirmLabel: 'Proceed',
///   cancelLabel: 'Cancel',
/// );
/// if (confirmed == true) { ... }
///
/// // Destructive action
/// final confirmed = await AppConfirmDialog.show(
///   context,
///   title: 'Xoá tài khoản?',
///   message: 'Hành động này không thể hoàn tác.',
///   isDangerous: true,
/// );
/// ```
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Xác nhận',
    this.cancelLabel = 'Huỷ',
    this.isDangerous = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// If true, confirm button renders as [AppButtonVariant.danger] (red).
  final bool isDangerous;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Huỷ',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDangerous: isDangerous,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      // FIX: Dùng AppButton thay vì ElevatedButton trực tiếp để đồng nhất
      // với design system. isDangerous map sang AppButtonVariant.danger.
      actions: [
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.outline,
          expanded: false,
          height: 40,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          variant: isDangerous
              ? AppButtonVariant.danger
              : AppButtonVariant.primary,
          expanded: false,
          height: 40,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

// ─── Loading Indicator ────────────────────────────────────────────────────────

/// PKK Resident - App Loading Indicator
///
/// Centered spinner overlay — wraps content during async operations.
///
/// Usage:
/// ```dart
/// AppLoadingIndicator(isLoading: _isLoading, child: content)
/// ```
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // FIX: Dùng Positioned.fill để overlay fill toàn bộ Stack.
        // ColoredBox không tự stretch — nếu không có Positioned.fill thì
        // overlay chỉ wrap theo size của Center widget bên trong.
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0x66FFFFFF),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: AppConstants.spinnerStrokeWidth,
                ),
              ),
            ),
          ),
      ],
    );
  }
}