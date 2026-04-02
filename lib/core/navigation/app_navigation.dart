// lib/core/navigation/app_navigation.dart

import 'package:go_router/go_router.dart';

class AppNavigation {
  static StatefulNavigationShell? _shell;

  static void setShell(StatefulNavigationShell shell) {
    _shell = shell;
  }

  /// 👉 Switch tab (fix bottom bar sync)
  static void goTab(int index, {bool reset = false}) {
    _shell?.goBranch(index, initialLocation: reset);
  }

  static void goHome() => goTab(0);
  static void goNotification() => goTab(1);
  static void goProfile() => goTab(2);
}
