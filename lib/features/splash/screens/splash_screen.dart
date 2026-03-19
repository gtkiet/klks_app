import 'package:flutter/material.dart';

import '../../../config/app_routes.dart';
import '../../auth/services/auth_service.dart';

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
      final success = await _authService.tryAutoLogin();

      if (!mounted) return;

      if (success) {
        _goMain();
      } else {
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