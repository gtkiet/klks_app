import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppCard
// ─────────────────────────────────────────────────────────────────────────────

/// Base card container matching the design spec:
/// - 16pt border radius
/// - White background
/// - Subtle Level-1 elevation shadow
///
/// Use this as the building block for billing items, service rows,
/// and dashboard sections.
///
/// Example — basic wrapping card:
/// ```dart
/// AppCard(
///   child: Column(children: [...]),
/// )
/// ```
///
/// Example — tappable card:
/// ```dart
/// AppCard(
///   onTap: () => Navigator.push(...),
///   child: Text('Open detail'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius,
    this.shadows,
    this.border,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;

  /// Optional tap handler. When non-null, an [InkWell] ripple is shown.
  final VoidCallback? onTap;

  /// Inner padding. Defaults to [AppSpacing.cardPadding] on all sides.
  final EdgeInsetsGeometry? padding;

  /// Background colour override. Defaults to [AppColors.surface].
  final Color? color;

  /// Border radius override. Defaults to [AppSpacing.radiusCard].
  final BorderRadius? borderRadius;

  /// Shadow list override. Defaults to [AppShadows.low].
  final List<BoxShadow>? shadows;

  /// Optional border (e.g. for utility-status highlighted cards).
  final BoxBorder? border;

  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(AppSpacing.radiusCard);

    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: radius,
        boxShadow: shadows ?? AppShadows.low,
        border: border,
      ),
      clipBehavior: clipBehavior,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                splashColor: AppColors.primary.withValues(alpha: 0.06),
                highlightColor: AppColors.primary.withValues(alpha: 0.04),
                child: _paddedChild(),
              ),
            )
          : _paddedChild(),
    );
  }

  Widget _paddedChild() => Padding(
        padding: padding ??
            const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// UtilityCard
// ─────────────────────────────────────────────────────────────────────────────

/// A coloured "utility status" card (e.g. Electricity billing card)
/// with a dark gradient overlay and white text.
///
/// Example:
/// ```dart
/// UtilityCard(
///   backgroundImage: AssetImage('assets/electricity_bg.jpg'),
///   title: 'Electricity',
///   subtitle: '75% of monthly budget',
///   progress: 0.75,
/// )
/// ```
class UtilityCard extends StatelessWidget {
  const UtilityCard({
    super.key,
    required this.title,
    this.subtitle,
    this.progress,
    this.backgroundImage,
    this.backgroundColor,
    this.trailing,
    this.onTap,
  }) : assert(
          backgroundImage != null || backgroundColor != null,
          'Provide either a backgroundImage or a backgroundColor.',
        );

  final String title;
  final String? subtitle;

  /// 0.0 – 1.0 progress value shown as a linear bar.
  final double? progress;

  final ImageProvider? backgroundImage;
  final Color? backgroundColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      color: backgroundColor ?? AppColors.primary,
      child: Stack(
        children: [
          // Background image layer
          if (backgroundImage != null)
            Positioned.fill(
              child: Image(
                image: backgroundImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),

          // Gradient scrim
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.headline
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white70),
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ProgressBar(value: progress!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ServiceCard  (list-item style — icon + title + subtitle + chevron)
// ─────────────────────────────────────────────────────────────────────────────

/// A compact list-item card for service navigation rows (e.g. Help Centre,
/// Payment History).
///
/// Example:
/// ```dart
/// ServiceCard(
///   icon: Icons.receipt_long_outlined,
///   title: 'Payment History',
///   subtitle: 'View all transactions',
///   onTap: () => _openHistory(),
/// )
/// ```
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Defaults to [AppColors.primary].
  final Color? iconColor;

  /// Defaults to a translucent primary tint.
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor ??
                  AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.primary,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.subhead),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),

          // Trailing widget or default chevron
          trailing ??
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textDisabled,
              ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: simple progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        children: [
          // Track
          Container(
            height: 4,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
          // Fill
          Container(
            height: 4,
            width: constraints.maxWidth * value.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
        ],
      ),
    );
  }
}