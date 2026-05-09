// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../guards/auth_guard.dart';
import 'main_screen.dart';

import '../../features/splash/screens/splash_screen.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';

import '../../features/home/screens/home_screen.dart';

import '../../features/thong_bao/screens/thong_bao_list_screen.dart';

import '../../features/tien_ich/screens/tien_ich_screen.dart';
import '../../features/tien_ich/dich_vu/screens/dich_vu_list_screen.dart';
import '../../features/tien_ich/sua_chua/screens/sua_chua_list_screen.dart';
import '../../features/tien_ich/thi_cong/screens/thi_cong_list_screen.dart';

import '../../features/cu_tru/quan_he/screens/cu_tru_list_screen.dart';

import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/profile_detail_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/change_avatar_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthGuard.instance,

    /// ================= REDIRECT =================
    redirect: (context, state) {
      final status = AuthGuard.instance.status;
      final location = state.matchedLocation;

      // final isLogin = location == '/login';
      final isAuthRoute = location.startsWith('/auth');
      final isSplash = location == '/splash';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      // if (status == AuthStatus.unauthenticated) {
      //   return isLogin ? null : '/login';
      // }
      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : '/auth/login';
      }

      // if (status == AuthStatus.authenticated) {
      //   if (isLogin || isSplash) return '/home';
      // }
      if (status == AuthStatus.authenticated) {
        if (isAuthRoute || isSplash) return '/home';
      }

      return null;
    },

    /// ================= ROUTES =================
    routes: [
      /// SPLASH
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),

      GoRoute(
        path: '/auth',
        redirect: (_, _) => '/auth/login',
        routes: [
          GoRoute(path: 'login', builder: (_, _) => const LoginScreen()),
          GoRoute(path: 'register', builder: (_, _) => const RegisterScreen()),
          GoRoute(
            path: 'forgot-password',
            builder: (_, _) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: 'reset-password/:username',
            builder: (_, state) => ResetPasswordScreen(
              username: state.pathParameters['username'] ?? '',
            ),
          ),
        ],
      ),

      /// 🔥 STATEFUL SHELL (BOTTOM NAV)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(shell: navigationShell);
        },
        branches: [
          /// ── 0: HOME ──
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),

          /// ── 1: THÔNG BÁO ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/thong-bao',
                builder: (_, _) => const ThongBaoListScreen(),
              ),
            ],
          ),

          /// ── 2: TIỆN ÍCH ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tien-ich',
                builder: (_, _) => const TienIchScreen(),
                routes: [
                  GoRoute(
                    path: 'dich-vu',
                    builder: (_, _) => const DichVuListScreen(),
                  ),
                  GoRoute(
                    path: 'sua-chua',
                    builder: (_, _) => const SuaChuaListScreen(),
                  ),
                  GoRoute(
                    path: 'thi-cong',
                    builder: (_, _) => const YeuCauThiCongListScreen(),
                  ),
                ],
              ),
            ],
          ),

          /// ── 3: CƯ TRÚ ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cu-tru',
                builder: (_, _) => const QuanHeCuTruListScreen(),
              ),
            ],
          ),

          /// ── 4: CÁ NHÂN ──
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
