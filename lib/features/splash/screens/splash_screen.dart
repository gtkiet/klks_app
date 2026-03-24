/// features/splash/screens/splash_screen.dart

import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppLoading()),
    );
  }
}