import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const KLKSApp());
}

class KLKSApp extends StatelessWidget {
  const KLKSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KLKS Resident App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
