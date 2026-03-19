import 'package:flutter/material.dart';

import '../features/residence/screens/residence_list_screen.dart';
import '../features/residence/screens/resident_detail_screen.dart';
import '../layout/main_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/profile/screens/edit_avatar_screen.dart';
import '../features/residence/screens/residence_member_screen.dart';

class AppRoutes {
  static const splash = '/splash';

  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";

  static const main = "/main";
  static const home = "/home";

  static const editAvatar = "/edit-avatar";

  static const residences = '/residences';
  static const residentDetail = '/resident-detail';
  static const residenceMembers = '/residence-members';

  /// Static routes (không cần params)
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),

    login: (context) => const LoginScreen(),

    register: (context) => const RegisterScreen(),

    forgotPassword: (context) => const ForgotPasswordScreen(),

    main: (context) => const MainScreen(),

    home: (context) => const HomeScreen(),

    editAvatar: (context) => const EditAvatarScreen(),

    residences: (context) => const ResidenceListScreen(),
  };

  /// Dynamic routes (có params)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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

      case residenceMembers: // route mới
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

  /// Fallback error route
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
