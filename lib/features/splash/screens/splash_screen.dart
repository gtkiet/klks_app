import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../config/app_routes.dart';
import '../../../core/storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorage _storage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final refreshToken = await _storage.getRefreshToken();

      /// ❌ Không có token → login
      if (refreshToken == null) {
        _goLogin();
        return;
      }

      /// 🔄 Gọi refresh
      final success = await _refreshToken(refreshToken);

      if (success) {
        _goMain();
      } else {
        await _storage.clearTokens();
        _goLogin();
      }
    } catch (e) {
      _goLogin();
    }
  }

  /// =========================
  /// 🔄 REFRESH TOKEN
  /// =========================
  Future<bool> _refreshToken(String refreshToken) async {
    try {
      final url =
          Uri.parse("${ApiConfig.baseUrl}/api/auth/refresh-token");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      final data = jsonDecode(response.body);

      if (data["isOk"] == true) {
        final accessToken = data["result"]["accessToken"];
        final newRefreshToken = data["result"]["refreshToken"];

        await _storage.saveTokens(
          accessToken: accessToken,
          refreshToken: newRefreshToken,
        );

        return true;
      }
    } catch (e) {}

    return false;
  }

  /// =========================
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
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}