import 'package:flutter/material.dart';

import '../../../config/app_routes.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/services/profile_service.dart';
// import '../../../core/storage/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // 1️⃣ Thử auto-login + refresh token
      final authResult = await _authService.tryAutoLogin();

      if (!mounted) return;

      if (authResult["success"] == true) {
        // 2️⃣ Lấy profile info để sync session
        final profile = await ProfileService.getProfile();

        if (profile != null) {
          // profile info đã cập nhật session
          _goMain();
        } else {
          // không lấy được profile → logout
          await _authService.logout();
          _goLogin();
        }
      } else {
        // chưa login hoặc refresh thất bại
        _goLogin();
      }
    } catch (_) {
      _goLogin();
    }
  }

  void _goMain() {
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  void _goLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}