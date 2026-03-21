import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../widgets/widgets.dart';
import 'reset_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      _showError("Vui lòng nhập tên đăng nhập");
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final response = await _authService.forgotPassword(username: username);

      if (!mounted) return;

      if (response["isOk"] == true) {
        _showSuccess("OTP đã gửi tới email");

        await Future.delayed(const Duration(milliseconds: 300));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(username: username),
          ),
        );
      } else {
        _showError(response["errors"]?[0]?["description"] ?? "Có lỗi xảy ra");
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Lỗi kết nối");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Center(child: _buildIconCircle()),
                    const SizedBox(height: 36),

                    const Text(
                      'Quên mật khẩu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Đừng lo lắng! Vui lòng nhập tên đăng nhập để nhận OTP.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    const LabelText(text: 'TÊN ĐĂNG NHẬP'),
                    const SizedBox(height: 10),

                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Nhập tên đăng nhập',
                      keyboardType: TextInputType.text,
                      inputFormatters: null,
                    ),
                    const SizedBox(height: 28),

                    PrimaryButton(
                      label: 'Gửi mã xác nhận',
                      onPressed: _sendRequest,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                    SecondaryButton(
                      label: 'Quay lại',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── UI ─────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SMART LIVING',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCircle() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFFDDE3F5),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        size: 48,
        color: Color(0xFF2563EB),
      ),
    );
  }
}
