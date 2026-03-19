import 'package:flutter/material.dart';

import '../../../config/app_routes.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/services/profile_service.dart';
import '../../../models/user_profile.dart';

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
    _initSplash();
  }

  Future<void> _initSplash() async {
    try {
      // 🔹 1️⃣ Thử auto-login / refresh token
      final authResult = await _authService.tryAutoLogin();

      if (!mounted) return;

      if (authResult["success"] == true) {
        // 🔹 2️⃣ Lấy profile để sync session
        UserProfile? profile;
        try {
          profile = await ProfileService.getProfile().timeout(
            const Duration(seconds: 10),
            onTimeout: () => null,
          );
        } catch (e, st) {
          debugPrint('Profile fetch error: $e\n$st');
          profile = null;
        }

        if (!mounted) return;

        if (profile != null) {
          // ✅ Profile load thành công → đi MainScreen
          _goMain();
        } else {
          // ⚠️ Profile load thất bại → logout và đi Login
          await _authService.logout();
          _goLogin();
        }
      } else {
        // ❌ Auto-login thất bại → đi Login
        _goLogin();
      }
    } catch (e, st) {
      debugPrint('Splash init error: $e\n$st');
      _goLogin();
    }
  }

  void _goMain() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}