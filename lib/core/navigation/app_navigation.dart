// lib/core/navigation/app_navigation.dart

import 'package:go_router/go_router.dart';

class AppNavigation {
  static StatefulNavigationShell? _shell;

  static void setShell(StatefulNavigationShell shell) {
    _shell = shell;
  }

  static void goTab(int index, {bool reset = true}) {
    _shell?.goBranch(index, initialLocation: reset);
  }

  static void goHome() => goTab(0);
  // static void goNotification() => goTab(1);
  static void goResidence() => goTab(1);
  static void goProfile() => goTab(2);
}
