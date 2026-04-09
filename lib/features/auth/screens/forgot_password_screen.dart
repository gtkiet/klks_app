// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService.instance;
  final _usernameController = TextEditingController();
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    try {
      String result = await _authService.forgotPassword(
        username: _usernameController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Reset code sent: $result')));
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
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Send Reset Code'),
                  ),
          ],
        ),
      ),
    );
  }
}
