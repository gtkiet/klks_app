// lib/design/shared/widgets/feedback/status_badge.dart

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StatusBadge
// ─────────────────────────────────────────────────────────────────────────────

enum BadgeStatus { completed, pending, highPriority, info, custom }

/// A pill-shaped status label matching the design spec badges.
///
/// Example:
/// ```dart
/// StatusBadge(status: BadgeStatus.completed)
/// StatusBadge(status: BadgeStatus.pending)
/// StatusBadge(status: BadgeStatus.highPriority)
/// ```
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.label,
    this.color,
    this.backgroundColor,
  });

  final BadgeStatus status;

  /// Custom label — overrides the default status label.
  final String? label;

  /// Used only when [status] == [BadgeStatus.custom].
  final Color? color;
  final Color? backgroundColor;

  String get _defaultLabel => switch (status) {
    BadgeStatus.completed => 'COMPLETED',
    BadgeStatus.pending => 'PENDING',
    BadgeStatus.highPriority => 'HIGH PRIORITY',
    BadgeStatus.info => 'INFO',
    BadgeStatus.custom => label ?? '',
  };

  Color get _textColor => switch (status) {
    BadgeStatus.completed => AppColors.success,
    BadgeStatus.pending => AppColors.warning,
    BadgeStatus.highPriority => AppColors.error,
    BadgeStatus.info => AppColors.primary,
    BadgeStatus.custom => color ?? AppColors.textPrimary,
  };

  Color get _bgColor => switch (status) {
    BadgeStatus.completed => AppColors.successSurface,
    BadgeStatus.pending => AppColors.warningSurface,
    BadgeStatus.highPriority => AppColors.errorSurface,
    BadgeStatus.info => AppColors.primary.withValues(alpha: 0.10),
    BadgeStatus.custom => backgroundColor ?? AppColors.inputFill,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label ?? _defaultLabel,
        style: AppTextStyles.caption.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppConfirmDialog
// ─────────────────────────────────────────────────────────────────────────────

/// Standard confirmation dialog matching the design spec:
/// - White surface, 16pt border radius.
/// - "Cancel" (outline) + "Proceed" (primary) button row.
///
/// Example:
/// ```dart
/// AppConfirmDialog.show(
///   context: context,
///   title: 'Confirm Action?',
///   message: 'This action cannot be undone. Are you sure you want to proceed?',
///   onConfirm: _doDelete,
/// );
/// ```
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Proceed',
    this.onCancel,
    required this.onConfirm,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;

  /// When `true` the confirm button uses [AppColors.error] background.
  final bool isDestructive;

  /// Convenience helper — shows the dialog and returns whether the user
  /// confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Proceed',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(title, style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.sm),

            // Body
            Text(message, style: AppTextStyles.bodySecondary),
            const SizedBox(height: AppSpacing.lg),

            // Actions row
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        onCancel ?? () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.divider,
                        width: 1.5,
                      ),
                      foregroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCard,
                        ),
                      ),
                      minimumSize: const Size(0, AppSpacing.buttonHeight),
                    ),
                    child: Text(
                      cancelLabel,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive
                          ? AppColors.error
                          : AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCard,
                        ),
                      ),
                      minimumSize: const Size(0, AppSpacing.buttonHeight),
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
