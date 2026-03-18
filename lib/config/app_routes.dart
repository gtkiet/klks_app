import 'package:flutter/material.dart';

import '../layout/main_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/profile/screens/edit_avatar_screen.dart';

class AppRoutes {
  static const splash = '/splash';

  static const login = "/login";
  static const register = "/register";
  static const forgotPassword = "/forgot-password";
  
  static const main = "/main";
  static const home = "/home";
  
  static const editAvatar = "/edit-avatar";

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    
    login: (context) => const LoginScreen(),

    register: (context) => const RegisterScreen(),

    forgotPassword: (context) => const ForgotPasswordScreen(),

    main: (context) => const MainScreen(),

    home: (context) => const HomeScreen(),

    editAvatar: (context) => const EditAvatarScreen(),
  };
}
