import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppShimmer  (pure Flutter, no external package required)
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] with an animated shimmer sweep.
/// Use [AppShimmerBox] / [AppShimmerCard] for the most common skeleton shapes.
///
/// Example — wrapping custom content:
/// ```dart
/// AppShimmer(
///   child: Row(children: [
///     AppShimmerBox(width: 48, height: 48, radius: 24),
///     const SizedBox(width: 12),
///     Column(children: [
///       AppShimmerBox(width: 140, height: 14),
///       AppShimmerBox(width: 80, height: 12),
///     ]),
///   ]),
/// )
/// ```
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;

  /// When `false`, renders [child] without any animation (pass-through).
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: [
                (_anim.value - 0.5).clamp(0.0, 1.0),
                _anim.value.clamp(0.0, 1.0),
                (_anim.value + 0.5).clamp(0.0, 1.0),
              ],
              transform: _SlideTransform(_anim.value),
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

/// A simple rectangular shimmer placeholder.
///
/// [radius] defaults to [AppSpacing.radiusInput].
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius,
  });

  final double width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius:
            BorderRadius.circular(radius ?? AppSpacing.radiusInput),
      ),
    );
  }
}

/// A full card-shaped shimmer placeholder matching [AppCard] dimensions.
class AppShimmerCard extends StatelessWidget {
  const AppShimmerCard({
    super.key,
    this.height = 90,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
    );
  }
}

/// A typical list-item shimmer: circular avatar + two text lines.
class AppShimmerListTile extends StatelessWidget {
  const AppShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Avatar
            AppShimmerBox(
                width: 44, height: 44, radius: AppSpacing.radiusCircle),
            const SizedBox(width: AppSpacing.md),
            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(
                    width: double.infinity,
                    height: 14,
                    radius: AppSpacing.radiusPill,
                  ),
                  const SizedBox(height: 6),
                  AppShimmerBox(
                    width: 120,
                    height: 12,
                    radius: AppSpacing.radiusPill,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal GradientTransform helper
// ─────────────────────────────────────────────────────────────────────────────

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.slidePercent);
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * slidePercent,
      0,
      0,
    );
  }
}