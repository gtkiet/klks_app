// lib/design/components/errors/error_display.dart
//
// Widget báo lỗi dùng chung — nhận vào AppException hoặc String.
//
// Cách dùng trong screen:
//
//   // 1. Inline (trong body)
//   if (state.error != null)
//     ErrorDisplay(error: state.error!, onRetry: _load)
//
//   // 2. Full-screen (thay toàn bộ body khi lần đầu load thất bại)
//   ErrorDisplay.fullScreen(error: state.error!, onRetry: _load)
//
//   // 3. Snackbar (gọi từ BLoC listener / controller)
//   ErrorDisplay.showSnackBar(context, error: state.error!)
//
//   // 4. Dialog
//   ErrorDisplay.showDialog(context, error: state.error!)

import 'package:flutter/material.dart';

import 'package:klks_app/core/network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Config (chỉnh một chỗ, ảnh hưởng toàn bộ app)
// ─────────────────────────────────────────────────────────────────────────────

class _Cfg {
  static const retryLabel = 'Thử lại';
  static const closeLabel = 'Đóng';

  // Icon theo loại lỗi
  static IconData iconFor(ErrorType type) => switch (type) {
        ErrorType.network => Icons.wifi_off_rounded,
        ErrorType.unauthorized => Icons.lock_outline_rounded,
        ErrorType.server => Icons.cloud_off_rounded,
        ErrorType.validation => Icons.info_outline_rounded,
        ErrorType.unknown => Icons.error_outline_rounded,
      };

  // Màu nhấn theo loại lỗi (dùng colorScheme để tự adapt dark/light)
  static Color colorFor(BuildContext ctx, ErrorType type) {
    final cs = Theme.of(ctx).colorScheme;
    return switch (type) {
      ErrorType.unauthorized => cs.secondary,
      ErrorType.validation => cs.tertiary,
      _ => cs.error,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model nội bộ
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorInfo {
  final String message;
  final List<String> details;
  final ErrorType type;

  const _ErrorInfo({
    required this.message,
    required this.details,
    required this.type,
  });

  factory _ErrorInfo.from(dynamic error) {
    if (error is AppException) {
      return _ErrorInfo(
        message: error.message,
        details: error.messages ?? [],
        type: error.type,
      );
    }
    return _ErrorInfo(
      message: error?.toString() ?? 'Có lỗi xảy ra',
      details: [],
      type: ErrorType.unknown,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// Widget báo lỗi đa năng.
///
/// - `error` nhận [AppException], [String], hoặc bất kỳ [Object] nào.
/// - `onRetry` hiện nút "Thử lại" khi được cung cấp.
/// - `compact` thu nhỏ thành dạng banner 1 dòng (dùng trong list / form).
class ErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final bool compact;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  // ── Static convenience constructors ───────────────────────────────────────

  /// Full-screen error (dùng làm body của Scaffold khi load lần đầu thất bại).
  factory ErrorDisplay.fullScreen({
    required dynamic error,
    VoidCallback? onRetry,
  }) =>
      _FullScreenError(error: error, onRetry: onRetry);

  /// Hiện SnackBar lỗi.
  static void showSnackBar(
    BuildContext context, {
    required dynamic error,
    VoidCallback? onRetry,
  }) {
    final info = _ErrorInfo.from(error);
    final color = _Cfg.colorFor(context, info.type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_Cfg.iconFor(info.type), color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  info.message,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: onRetry != null
              ? SnackBarAction(
                  label: _Cfg.retryLabel,
                  textColor: Colors.white70,
                  onPressed: onRetry,
                )
              : null,
        ),
      );
  }

  /// Hiện Dialog lỗi (blocking — dùng khi action thất bại và cần xác nhận).
  static Future<void> showDialog(
    BuildContext context, {
    required dynamic error,
    VoidCallback? onRetry,
  }) {
    final info = _ErrorInfo.from(error);
    final color = _Cfg.colorFor(context, info.type);

    return showAdaptiveDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        icon: Icon(_Cfg.iconFor(info.type), color: color, size: 32),
        title: const Text('Có lỗi xảy ra'),
        content: _ErrorBody(info: info, showDetails: true),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onRetry();
              },
              child: const Text(_Cfg.retryLabel),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(_Cfg.closeLabel),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final info = _ErrorInfo.from(error);

    if (compact) return _CompactError(info: info, onRetry: onRetry);

    return _CardError(info: info, onRetry: onRetry);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VARIANTS
// ─────────────────────────────────────────────────────────────────────────────

/// Dạng card — dùng trong body khi có dữ liệu cũ hiển thị xung quanh.
class _CardError extends StatelessWidget {
  final _ErrorInfo info;
  final VoidCallback? onRetry;

  const _CardError({required this.info, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final color = _Cfg.colorFor(context, info.type);
    // final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_Cfg.iconFor(info.type), color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: _ErrorBody(info: info),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            Divider(height: 1, color: color.withValues(alpha: 0.2)),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(_Cfg.retryLabel),
              style: TextButton.styleFrom(
                foregroundColor: color,
                minimumSize: const Size.fromHeight(40),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dạng banner compact — 1 dòng, dùng trong form / list item.
class _CompactError extends StatelessWidget {
  final _ErrorInfo info;
  final VoidCallback? onRetry;

  const _CompactError({required this.info, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final color = _Cfg.colorFor(context, info.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(_Cfg.iconFor(info.type), color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info.message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Icon(Icons.refresh_rounded, color: color, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen error (riêng class để factory constructor có thể trả về).
class _FullScreenError extends ErrorDisplay {
  const _FullScreenError({required super.error, super.onRetry})
      : super(compact: false);

  @override
  Widget build(BuildContext context) {
    final info = _ErrorInfo.from(error);
    final color = _Cfg.colorFor(context, info.type);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_Cfg.iconFor(info.type), color: color, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              info.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (info.details.length > 1) ...[
              const SizedBox(height: 8),
              _ErrorBody(info: info, showDetails: true),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(_Cfg.retryLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR BODY  (message + detail list)
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final _ErrorInfo info;
  final bool showDetails;

  const _ErrorBody({required this.info, this.showDetails = false});

  @override
  Widget build(BuildContext context) {
    final color = _Cfg.colorFor(context, info.type);
    final textTheme = Theme.of(context).textTheme;

    // Nếu details == [message] (server trả về 1 lỗi duy nhất) thì không lặp lại
    final hasDetails = showDetails &&
        info.details.length > 1 &&
        !(info.details.length == 1 && info.details.first == info.message);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          info.message,
          style: textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        if (hasDetails) ...[
          const SizedBox(height: 6),
          ...info.details.map(
            (d) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      d,
                      style: textTheme.bodySmall?.copyWith(
                        color: color.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}