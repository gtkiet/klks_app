// lib/design/shared/widgets/display/app_badge.dart

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppBadge  (count overlay — e.g. "3" on bell icon)
// ─────────────────────────────────────────────────────────────────────────────

/// Overlays a red counter pill on top of [child].
/// Hides automatically when [count] == 0.
///
/// Example:
/// ```dart
/// AppBadge(
///   count: _unreadCount,
///   child: const Icon(Icons.notifications_outlined),
/// )
/// ```
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.showDot = false,
    this.color,
  });

  final Widget child;

  /// Count displayed inside the badge. Values > 99 render as "99+".
  final int count;

  /// When `true`, always shows a small dot regardless of [count].
  final bool showDot;

  /// Badge background colour. Defaults to [AppColors.error].
  final Color? color;

  bool get _visible => count > 0 || showDot;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: showDot && count == 0
              ? _DotBadge(color: color)
              : _CountBadge(count: count, color: color),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, this.color});

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'BeVietnamPro',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DotBadge extends StatelessWidget {
  const _DotBadge({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color ?? AppColors.error,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
    );
  }
}
