import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/auth_form_fields.dart';
import '../../core/providers/auth_provider.dart';
import '../../../config/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(username: username, password: password);
      if (!mounted) return;

      if (response["isOk"] == true) {
        // ✅ Cập nhật trạng thái AuthProvider
        final authProvider = context.read<AuthProvider>();
        authProvider.setLoggedIn(true);

        // Chuyển đến màn hình chính
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        _showError(_extractError(response));
      }
    } catch (e) {
      _showError("Lỗi kết nối, vui lòng thử lại");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractError(dynamic response) {
    try {
      if (response["errors"] != null &&
          response["errors"] is List &&
          response["errors"].isNotEmpty) {
        return response["errors"][0]["description"] ?? "Đăng nhập thất bại";
      }
    } catch (_) {}
    return "Đăng nhập thất bại";
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text('Đăng nhập', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                AuthTextField(controller: _usernameController, hint: 'Tên đăng nhập'),
                const SizedBox(height: 16),
                AuthPasswordField(controller: _passwordController),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  text: 'Đăng nhập',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? '),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
                      child: const Text('Đăng ký', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}