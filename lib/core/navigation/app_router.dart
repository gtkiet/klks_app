// lib/core/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:klks_app/core/guards/auth_guard.dart';
import 'package:klks_app/design/design.dart';
import 'main_screen.dart';

import 'package:klks_app/features/splash/screens/splash_screen.dart';

import 'package:klks_app/features/auth/screens/login_screen.dart';
import 'package:klks_app/features/auth/screens/register_screen.dart';
import 'package:klks_app/features/auth/screens/forgot_password_screen.dart';
import 'package:klks_app/features/auth/screens/reset_password_screen.dart';

import 'package:klks_app/features/home/screens/home_screen.dart';
import 'package:klks_app/features/dich_vu/phan_anh/screens/phan_anh_list_screen.dart';
import 'package:klks_app/features/dich_vu/khao_sat/screens/khao_sat_list_screen.dart';

import 'package:klks_app/features/thong_bao/screens/thong_bao_list_screen.dart';
import 'package:klks_app/features/thong_bao/screens/thong_bao_detail_screen.dart';

import 'package:klks_app/features/dich_vu/screens/tien_ich_screen.dart';
import 'package:klks_app/features/dich_vu/tien_ich/screens/dich_vu_list_screen.dart';
import 'package:klks_app/features/dich_vu/sua_chua/screens/sua_chua_list_screen.dart';
import 'package:klks_app/features/dich_vu/thi_cong/screens/thi_cong_list_screen.dart';
import 'package:klks_app/features/dich_vu/hoa_don/screens/hoa_don_list_screen.dart';

import 'package:klks_app/features/cu_tru/quan_he/screens/cu_tru_list_screen.dart';
import 'package:klks_app/features/cu_tru/quan_he/screens/cu_tru_detail_screen.dart';

import 'package:klks_app/features/profile/screens/profile_screen.dart';
import 'package:klks_app/features/profile/screens/profile_detail_screen.dart';
import 'package:klks_app/features/profile/screens/change_password_screen.dart';
import 'package:klks_app/features/profile/screens/change_avatar_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthGuard.instance,

    /// ================= REDIRECT =================
    redirect: (context, state) {
      final status = AuthGuard.instance.status;
      final location = state.uri.path;

      final isAuthRoute = location.startsWith('/auth');
      final isSplash = location == '/splash';

      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (status == AuthStatus.unauthenticated) {
        if (isAuthRoute) return null;
        return '/auth/login';
      }

      if (status == AuthStatus.authenticated) {
        if (isAuthRoute || isSplash) return '/home';
      }

      return null;
    },

    /// ================= ROUTES =================
    routes: [
      /// SPLASH
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),

      /// AUTH
      /// FIX: Bỏ builder SizedBox.shrink() thừa — redirect xử lý hết rồi.
      /// Dùng redirect thẳng xuống /auth/login thay vì render widget rỗng.
      GoRoute(
        path: '/auth',
        redirect: (_, state) {
          if (state.uri.path == '/auth') return '/auth/login';
          return null;
        },
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
              username: state.pathParameters['username']!,
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
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, state) {
                      final extra = state.extra as ThongBaoDetailArgs;
                      return ThongBaoDetailScreen(item: extra.item);
                    },
                  ),
                ],
              ),
            ],
          ),

          /// ── 2: TIỆN ÍCH ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dich-vu',
                builder: (_, _) => const TienIchScreen(),
                routes: [
                  GoRoute(
                    path: 'tien-ich',
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
                  GoRoute(
                    path: 'hoa-don',
                    builder: (_, _) => HoaDonListScreen(),
                  ),
                  GoRoute(
                    path: 'phan-anh',
                    builder: (_, _) => const PhanAnhListScreen(),
                  ),
                  GoRoute(
                    path: 'khao-sat',
                    builder: (_, _) => const KhaoSatListScreen(),
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
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, state) {
                      final extra = state.extra as CuTruDetailArgs;
                      return CuTruDetailScreen(
                        item: extra.item,
                        initialMode: extra.initialMode,
                      );
                    },
                  ),
                ],
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
    // FIX: Dùng AppScaffold thay vì Scaffold trần để nhất quán với design system.
    errorBuilder: (context, state) => AppScaffold(
      title: 'Không tìm thấy trang',
      body: Center(
        child: Text(
          'Không tìm thấy: ${state.uri}',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    ),
  );
}
