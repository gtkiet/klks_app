// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';

import '../../features/cu_tru/screens/cu_tru_list_screen.dart';
import '../../features/dich_vu/screens/dich_vu_list_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

import '../../features/home/screens/home_screen.dart';

import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/profile_detail_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/change_avatar_screen.dart';

import '../guards/auth_guard.dart';
import 'main_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthGuard.instance,

    /// ================= REDIRECT =================
    redirect: (context, state) {
      final status = AuthGuard.instance.status;
      final location = state.matchedLocation;

      final isLogin = location == '/login';
      final isSplash = location == '/splash';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        return isLogin ? null : '/login';
      }

      if (status == AuthStatus.authenticated) {
        if (isLogin || isSplash) return '/home';
      }

      return null;
    },

    /// ================= ROUTES =================
    routes: [
      /// SPLASH
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),

      /// LOGIN
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

      /// 🔥 STATEFUL SHELL (BOTTOM NAV)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(shell: navigationShell);
        },
        branches: [
          /// ================= HOME TAB =================
          StatefulShellBranch(
            routes: [
              /// HOME
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
              GoRoute(path: '/dich-vu', builder: (_, _) => const DichVuListScreen(),),
            ],
          ),

          /// ================= RESIDENCE TAB =================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cu-tru',
                builder: (_, _) => const QuanHeCuTruListScreen(),
              ),
            ],
          ),

          /// ================= PROFILE TAB =================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, _) => const ProfileDetailScreen(),
                  ),
                  GoRoute(
                    path: 'change-password',
                    builder: (_, _) => const ChangePasswordScreen(),
                  ),
                  GoRoute(
                    path: 'change-avatar',
                    builder: (_, _) => const ChangeAvatarScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    /// ================= ERROR =================
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Không tìm thấy: ${state.uri}'))),
  );
}

// /// TEMP
// class _PlaceholderScreen extends StatelessWidget {
//   final String title;

//   const _PlaceholderScreen({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text(title));
//   }
// }
