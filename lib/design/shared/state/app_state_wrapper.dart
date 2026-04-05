// lib/design/shared/state/app_state_wrapper.dart

import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../widgets/feedback/app_loading_indicator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppStateWrapper — handles loading / error / empty / data states
// ─────────────────────────────────────────────────────────────────────────────

/// Generic widget that renders one of four states:
/// **loading → error → empty → data**.
///
/// Example:
/// ```dart
/// AppStateWrapper<List<Bill>>(
///   isLoading: _loading,
///   error: _error,
///   isEmpty: _bills.isEmpty,
///   emptyMessage: 'No bills yet',
///   builder: (_) => BillList(bills: _bills),
/// )
/// ```
class AppStateWrapper<T> extends StatelessWidget {
  const AppStateWrapper({
    super.key,
    required this.isLoading,
    required this.builder,
    this.error,
    this.isEmpty = false,
    this.emptyMessage,
    this.emptyIcon,
    this.onRetry,
    this.loadingWidget,
  });

  final bool isLoading;
  final bool isEmpty;
  final Object? error;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context) builder;

  /// Optional custom loading widget (defaults to [AppLoadingIndicator]).
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const AppLoadingIndicator(
            padding: EdgeInsets.all(AppSpacing.xl),
          );
    }

    if (error != null) {
      return _ErrorView(error: error!, onRetry: onRetry);
    }

    if (isEmpty) {
      return _EmptyView(
        message: emptyMessage ?? 'Không có dữ liệu',
        icon: emptyIcon,
      );
    }

    return builder(context);
  }
}

// ─── Private sub-views ───────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Đã xảy ra lỗi',
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              error.toString(),
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Thử lại'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 56,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}