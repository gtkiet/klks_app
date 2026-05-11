// lib/design/components/app_bar/app_top_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klks_app/design/tokens/colors.dart';
import 'package:klks_app/design/tokens/typography.dart';

/// PKK Resident - App Top Bar
///
/// Global AppBar that should be used across all screens.
/// Wraps Flutter's [AppBar] with design-system defaults.
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: AppTopBar(title: 'Dashboard'),
/// )
///
/// // With back button override
/// Scaffold(
///   appBar: AppTopBar(
///     title: 'Chi tiết hoá đơn',
///     leading: BackButton(onPressed: () => context.pop()),
///   ),
/// )
///
/// // With action buttons
/// Scaffold(
///   appBar: AppTopBar(
///     title: 'Thông báo',
///     actions: [
///       IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
///     ],
///   ),
/// )
/// ```
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.elevation,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double? elevation;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: elevation ?? 0,
      titleTextStyle: AppTypography.headline.copyWith(
        color: foregroundColor ?? AppColors.textPrimary,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
