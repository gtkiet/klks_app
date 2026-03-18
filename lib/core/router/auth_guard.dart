import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../config/app_routes.dart';

class AuthGuard {
  static Route<dynamic> guard({
    required BuildContext context,
    required Widget page,
    required bool requiresAuth,
  }) {
    final auth = context.read<AuthProvider>();

    /// 🔥 chưa xác định (Splash đang chạy)
    if (auth.status == AuthStatus.unknown) {
      return _buildRoute(const SizedBox());
    }

    /// 🔒 cần login nhưng chưa login
    if (requiresAuth && !auth.isLoggedIn) {
      return _buildRouteNamed(AppRoutes.login);
    }

    /// 🔒 đã login mà vào login/register
    if (!requiresAuth && auth.isLoggedIn) {
      return _buildRouteNamed(AppRoutes.main);
    }

    return _buildRoute(page);
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }

  static MaterialPageRoute _buildRouteNamed(String routeName) {
    return MaterialPageRoute(
      builder: (context) => Navigator(
        onGenerateRoute: (settings) {
          return AppRoutes.generateRoute(settings);
        },
      ),
      settings: RouteSettings(name: routeName),
    );
  }
}