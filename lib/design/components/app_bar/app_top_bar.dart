// lib/design/components/app_bar/app_top_bar.dart

import 'package:flutter/material.dart';

// import 'package:klks_app/design/tokens/colors.dart';
import 'package:klks_app/design/tokens/typography.dart';

/// PKK Resident - App Top Bar
///
/// Global AppBar that should be used across all screens.
/// Wraps Flutter's [AppBar] with design-system defaults.
///
/// FIX: Đã bỏ các config trùng lặp với [AppBarTheme] trong [AppTheme]:
///   - `systemOverlayStyle` → đã set trong AppBarTheme, không cần lặp lại
///   - `elevation` → đã set 0 trong AppBarTheme
///   - `backgroundColor` → đã set AppColors.surface trong AppBarTheme
///   - `foregroundColor` → đã set AppColors.textPrimary trong AppBarTheme
/// Chỉ giữ lại những gì cần override per-instance.
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
///
/// // Override màu (e.g. transparent AppBar trên hero image)
/// AppTopBar(
///   title: 'Detail',
///   backgroundColor: Colors.transparent,
///   foregroundColor: AppColors.textOnPrimary,
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
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  /// Override màu nền — chỉ dùng khi cần khác với AppBarTheme (e.g. transparent).
  final Color? backgroundColor;

  /// Override màu foreground — tự động adjust titleTextStyle theo.
  final Color? foregroundColor;

  final bool centerTitle;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    // Chỉ override titleTextStyle nếu foregroundColor được truyền vào,
    // ngược lại để AppBarTheme.titleTextStyle tự apply.
    final titleStyle = foregroundColor != null
        ? AppTypography.headline.copyWith(color: foregroundColor)
        : null;

    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      // Chỉ pass khi có override — null để AppBarTheme tự apply default.
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      titleTextStyle: titleStyle,
    );
  }
}