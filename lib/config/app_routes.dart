import 'package:flutter/material.dart';

import '../layout/main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/edit_avatar_screen.dart';

class AppRoutes {
  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";
  static const main = "/main";
  static const home = "/home";
  static const editAvatar = "/edit-avatar";

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),

    register: (context) => const RegisterScreen(),

    forgotPassword: (context) => const ForgotPasswordScreen(),

    main: (context) => const MainScreen(),

    home: (context) => const HomeScreen(),

    editAvatar: (context) => const EditAvatarScreen(),
  };
}
