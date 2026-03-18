import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';

import '../features/main/main_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/profile/screens/edit_avatar_screen.dart';

class AppRoutes {
  // ================= ROUTE NAMES =================
  static const splash = '/splash';

  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";

  static const main = "/main";
  static const home = "/home";

  static const editAvatar = "/edit-avatar";

  // ================= ROUTE GENERATOR =================
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      /// ===== PUBLIC =====
      case splash:
        return _guard(
          settings,
          const SplashScreen(),
          requiresAuth: false,
        );

      case login:
        return _guard(
          settings,
          const LoginScreen(),
          requiresAuth: false,
        );

      case register:
        return _guard(
          settings,
          const RegisterScreen(),
          requiresAuth: false,
        );

      case forgotPassword:
        return _guard(
          settings,
          const ForgotPasswordScreen(),
          requiresAuth: false,
        );

      /// ===== PROTECTED =====
      case main:
        return _guard(
          settings,
          const MainScreen(),
          requiresAuth: true,
        );

      case home:
        return _guard(
          settings,
          const HomeScreen(),
          requiresAuth: true,
        );

      case editAvatar:
        return _guard(
          settings,
          const EditAvatarScreen(),
          requiresAuth: true,
        );

      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
          settings,
        );
    }
  }

  // ================= AUTH GUARD =================
  static Route _guard(
    RouteSettings settings,
    Widget page, {
    required bool requiresAuth,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final auth = context.read<AuthProvider>();

        /// 🔥 Trạng thái chưa xác định (Splash đang xử lý)
        if (auth.status == AuthStatus.unknown) {
          return const SplashScreen();
        }

        /// 🔒 Chưa login mà vào route protected
        if (requiresAuth && !auth.isLoggedIn) {
          return const LoginScreen();
        }

        /// 🔒 Đã login mà vào login/register
        if (!requiresAuth && auth.isLoggedIn) {
          return const MainScreen();
        }

        return page;
      },
    );
  }

  // ================= HELPER =================
  static MaterialPageRoute _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}