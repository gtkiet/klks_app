// lib/features/auth/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _authService = AuthService.instance;
  final _usernameController = TextEditingController();
  final _resetCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  void _resetPassword() async {
    setState(() => _loading = true);
    try {
      String result = await _authService.resetPassword(
        username: _usernameController.text,
        resetCode: _resetCodeController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset success: $result')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _resetCodeController,
              decoration: const InputDecoration(labelText: 'Reset Code'),
            ),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text('Reset Password'),
                  ),
          ],
        ),
      ),
    );
  }
}
