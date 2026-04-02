import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTopBar  (implements PreferredSizeWidget for use inside Scaffold.appBar)
// ─────────────────────────────────────────────────────────────────────────────

/// Global top app bar matching the "Indigo Vista" design spec:
/// - White background, no elevation in default state.
/// - 18px Bold headline title.
/// - Optional leading back/menu icon.
/// - Optional list of action icons.
///
/// Example — screen title only:
/// ```dart
/// Scaffold(
///   appBar: AppTopBar(title: 'Dashboard'),
/// )
/// ```
///
/// Example — back button + actions:
/// ```dart
/// AppTopBar(
///   title: 'Payment Detail',
///   showBack: true,
///   actions: [
///     IconButton(icon: const Icon(Icons.share_outlined), onPressed: _share),
///   ],
/// )
/// ```
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.bottom,
    this.backgroundColor,
  });

  final String title;

  /// When `true` a back arrow is shown (uses [onBack] or
  /// `Navigator.maybePop` as fallback).
  final bool showBack;
  final VoidCallback? onBack;

  /// Fully custom leading widget (overrides [showBack]).
  final Widget? leading;

  /// Action widgets displayed at the trailing end.
  final List<Widget>? actions;

  final bool centerTitle;

  /// Optional bottom widget (e.g. a [TabBar]).
  final PreferredSizeWidget? bottom;

  final Color? backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(
        AppSpacing.appBarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && showBack) {
      resolvedLeading = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.textPrimary,
        onPressed: onBack ?? () => Navigator.maybePop(context),
        tooltip: 'Back',
      );
    }

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: const Color(0x14000000),
      automaticallyImplyLeading: false,
      leading: resolvedLeading,
      centerTitle: centerTitle,
      titleSpacing: resolvedLeading != null ? 0 : AppSpacing.md,
      title: Text(title, style: AppTextStyles.headline),
      actions: actions,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
