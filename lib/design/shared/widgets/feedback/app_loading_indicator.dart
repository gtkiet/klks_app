import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppLoadingIndicator — inline spinner
// ─────────────────────────────────────────────────────────────────────────────

/// A centred circular progress indicator styled to the design system.
///
/// Drop-in replacement for [CircularProgressIndicator] that always uses
/// [AppColors.primary] and the correct stroke width.
///
/// Example:
/// ```dart
/// if (_isLoading) const AppLoadingIndicator()
/// else MyContent()
/// ```
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 32.0,
    this.strokeWidth = 3.0,
    this.color,
    this.padding,
  });

  final double size;
  final double strokeWidth;

  /// Defaults to [AppColors.primary].
  final Color? color;

  /// Optional padding around the indicator.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );

    if (padding != null) {
      indicator = Padding(padding: padding!, child: indicator);
    }

    return Center(child: indicator);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppFullScreenLoader — overlay loader
// ─────────────────────────────────────────────────────────────────────────────

/// An opaque/semi-transparent full-screen loader overlay.
/// Place it at the top of a [Stack] and toggle visibility.
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     MyScreen(),
///     if (_isBusy) const AppFullScreenLoader(),
///   ],
/// )
/// ```
class AppFullScreenLoader extends StatelessWidget {
  const AppFullScreenLoader({
    super.key,
    this.message,
    this.opacity = 0.6,
  });

  /// Optional message below the spinner.
  final String? message;

  /// Background scrim opacity.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: opacity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            boxShadow: AppShadows.floating,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoadingIndicator(size: 40),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  message!,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
