/// routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/guards/auth_guard.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../layout/main_screen.dart';

import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,

    refreshListenable: AuthGuard.instance,

    // ================= REDIRECT =================
    redirect: (context, state) {
      final status = AuthGuard.instance.status;
      final location = state.matchedLocation;

      final isLogin = location == AppRoutes.login;
      final isSplash = location == AppRoutes.splash;

      /// 🔥 QUAN TRỌNG
      if (status == AuthStatus.unknown) {
        return isSplash ? null : AppRoutes.splash;
      }

      if (status == AuthStatus.unauthenticated) {
        if (isLogin) return null;
        return AppRoutes.login;
      }

      if (status == AuthStatus.authenticated) {
        if (isLogin || isSplash) {
          return AppRoutes.home;
        }
      }

      return null;
    },

    // ================= ROUTES =================
    routes: [
      /// SPLASH
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),

      /// LOGIN
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      /// 🔥 ROOT APP (SAU LOGIN)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => MainScreen(key: MainScreen.navigatorKey),
      ),

      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => MainScreen(key: MainScreen.navigatorKey),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Không tìm thấy trang: ${state.uri}')),
    ),
  );
}
