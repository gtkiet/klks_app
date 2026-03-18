import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_routes.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();

    /// 🔥 chỉ gọi đúng 1 chỗ
    await auth.init();

    if (!mounted) return;

    /// 🔥 luôn đi main → guard sẽ xử lý tiếp
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}