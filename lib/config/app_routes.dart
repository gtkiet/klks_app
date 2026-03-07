import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
// import '../screens/auth/reset_password.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";
  static const home = "/home";
  static const resetPassword = "/reset-password";

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),

    register: (context) => const RegisterScreen(),

    forgotPassword: (context) => const ForgotPasswordScreen(),

    // resetPassword: (context) {
    //   final username = ModalRoute.of(context)!.settings.arguments as String;

    //   return ResetPasswordScreen(username: username);
    // },

    home: (context) => const HomeScreen(),
  };
}
