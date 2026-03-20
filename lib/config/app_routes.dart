import 'package:flutter/material.dart';

import '../features/profile/screens/change_password_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/residence/screens/residence_list_screen.dart';
import '../features/residence/screens/resident_detail_screen.dart';
import '../layout/main_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/profile/screens/edit_avatar_screen.dart';
import '../features/residence/screens/residence_member_screen.dart';

class AppRoutes {
  // =========================
  // AUTH + ROOT
  // =========================
  static const splash = '/splash';

  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";

  static const main = "/main";

  // =========================
  // TAB ROUTES (KHÔNG PUSH SCREEN)
  // =========================
  static const homeTab = "/tab/home";
  static const billTab = "/tab/bill";
  static const serviceTab = "/tab/service";
  static const communityTab = "/tab/community";
  static const profileTab = "/tab/profile";

  // =========================
  // PROFILE
  // =========================
  static const editAvatar = "/edit-avatar";
  static const editProfile = "/edit-profile";
  static const changePassword = "/change-password";

  // =========================
  // RESIDENCE
  // =========================
  static const residences = '/residences';
  static const residentDetail = '/resident-detail';
  static const residenceMembers = '/residence-members';

  // =========================
  // STATIC ROUTES
  // =========================
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),

    login: (context) => const LoginScreen(),

    register: (context) => const RegisterScreen(),

    forgotPassword: (context) => const ForgotPasswordScreen(),

    main: (context) => MainScreen(key: MainScreen.navigatorKey),

    editAvatar: (context) => const EditAvatarScreen(),

    changePassword: (context) => const ChangePasswordScreen(),

    residences: (context) => const ResidenceListScreen(),
  };

  // =========================
  // DYNAMIC ROUTES
  // =========================
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // =====================
      // TAB NAVIGATION
      // =====================
      case homeTab:
        MainScreen.switchTab(0);
        return _emptyRoute();

      case billTab:
        MainScreen.switchTab(1);
        return _emptyRoute();

      case serviceTab:
        MainScreen.switchTab(2);
        return _emptyRoute();

      case communityTab:
        MainScreen.switchTab(3);
        return _emptyRoute();

      case profileTab:
        MainScreen.switchTab(4);
        return _emptyRoute();

      // =====================
      // PROFILE
      // =====================
      case editProfile:
        final profile = settings.arguments as dynamic;

        if (profile == null) {
          return _errorRoute('Thiếu tham số profile');
        }

        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(profile: profile),
        );

      // =====================
      // RESIDENT DETAIL
      // =====================
      case residentDetail:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args == null ||
            args['userId'] == null ||
            args['quanHeCuTruId'] == null) {
          return _errorRoute('Thiếu tham số resident detail');
        }

        return MaterialPageRoute(
          builder: (_) => ResidentDetailScreen(
            userId: args['userId'],
            quanHeCuTruId: args['quanHeCuTruId'],
          ),
        );

      // =====================
      // RESIDENCE MEMBERS
      // =====================
      case residenceMembers:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args == null ||
            args['canHoId'] == null ||
            args['canHoName'] == null) {
          return _errorRoute('Thiếu tham số cho danh sách thành viên cư trú');
        }

        return MaterialPageRoute(
          builder: (_) => ResidenceMemberScreen(
            canHoId: args['canHoId'],
            canHoName: args['canHoName'],
          ),
        );

      default:
        return _errorRoute('Route không tồn tại: ${settings.name}');
    }
  }

  // =========================
  // EMPTY ROUTE (FOR TAB)
  // =========================
  static Route<dynamic> _emptyRoute() {
    return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
  }

  // =========================
  // ERROR ROUTE
  // =========================
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(
          child: Text(message, style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
