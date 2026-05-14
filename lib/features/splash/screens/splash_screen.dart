// lib/features/splash/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:klks_app/core/guards/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AuthGuard.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1656B8), // xanh giống ảnh
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Logo
            Container(
              width: 160,
              height: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'PKK Resident',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Hệ thống quản lý chung cư thông minh',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const Spacer(),

            // Indicator (3 chấm)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: index == 1 ? 1 : 0.4),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Bottom text
            const Text(
              'PREMIUM SMART LIVING EXPERIENCE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
