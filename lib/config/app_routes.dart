import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';

import '../features/main/main_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/splash/screens/splash_screen.dart';
// import '../features/profile/screens/edit_avatar_screen.dart';

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
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case login:
        return _guard(settings, const LoginScreen(), requiresAuth: false);

      case register:
        return _guard(settings, const RegisterScreen(), requiresAuth: false);

      case forgotPassword:
        return _guard(settings, const ForgotPasswordScreen(), requiresAuth: false);

      case main:
        return _guard(settings, const MainScreen(), requiresAuth: true);

      case home:
        return _guard(settings, const HomeScreen(), requiresAuth: true);

      // case editAvatar:
      //   return _guard(settings, const EditAvatarScreen(), requiresAuth: true);

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
        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            /// 🔥 Splash handling
            if (auth.status == AuthStatus.unknown) {
              return const SplashScreen();
            }

            /// 🔒 Chưa login → redirect về login
            if (requiresAuth && !auth.isLoggedIn) {
              _redirect(context, login);
              return const SizedBox();
            }

            /// 🔒 Đã login → redirect về main
            if (!requiresAuth && auth.isLoggedIn) {
              _redirect(context, main);
              return const SizedBox();
            }

            return page;
          },
        );
      },
    );
  }

  // ================= REDIRECT HELPER =================
  static void _redirect(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        route,
        (route) => false,
      );
    });
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