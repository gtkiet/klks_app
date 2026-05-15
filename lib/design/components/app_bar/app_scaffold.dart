// lib/design/components/app_bar/app_scaffold.dart

import 'package:flutter/material.dart';

import 'package:klks_app/design/tokens/colors.dart';

import 'app_top_bar.dart';

/// PKK Resident - App Scaffold
///
/// Wraps [Scaffold] with design-system defaults.
/// Ensures consistent background color and safe-area handling.
///
/// Usage:
/// ```dart
/// // With app bar (title required)
/// AppScaffold(
///   title: 'Dashboard',
///   body: MyContent(),
/// )
///
/// // With custom app bar
/// AppScaffold(
///   appBar: AppTopBar(title: 'Custom', actions: [...]),
///   body: MyContent(),
/// )
///
/// // Without app bar (e.g. splash, onboarding)
/// AppScaffold(
///   showAppBar: false,
///   body: SplashContent(),
/// )
/// ```
///
/// FIX: Làm rõ behavior của [showAppBar]:
///   - `showAppBar: true` + `appBar != null`  → dùng custom appBar
///   - `showAppBar: true` + `title != null`   → tự tạo AppTopBar
///   - `showAppBar: true` + cả hai đều null   → assert trong debug, không render appBar
///   - `showAppBar: false`                    → không render appBar, bỏ qua title
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.appBar,
    this.showAppBar = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.leading,
    this.actions,
  }) : assert(
         !showAppBar || appBar != null || title != null,
         'AppScaffold: showAppBar=true nhưng không có title lẫn appBar. '
         'Truyền vào title, appBar, hoặc set showAppBar=false.',
       );

  final String? title;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showAppBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? resolvedAppBar;

    if (showAppBar) {
      resolvedAppBar =
          appBar ??
          (title != null
              ? AppTopBar(title: title!, leading: leading, actions: actions)
              : null);
      // null ở đây chỉ xảy ra trong release build khi assert bị bỏ qua —
      // behavior: scaffold render không có app bar, tương tự showAppBar=false.
    }

    return Scaffold(
      appBar: resolvedAppBar,
      backgroundColor: backgroundColor ?? AppColors.background,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}