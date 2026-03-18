import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'reset_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _usernameController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final username = _usernameController.text.trim();

    // 🔒 Validate
    if (username.isEmpty) {
      _showError("Vui lòng nhập tên đăng nhập");
      return;
    }

    // 🔽 Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final response = await _authService.forgotPassword(
        username: username,
      );

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
        _showError(
          response["errors"]?[0]?["description"] ??
              "Có lỗi xảy ra",
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Lỗi kết nối");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
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
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

                    const Text(
                      'TÊN ĐĂNG NHẬP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(),
                    const SizedBox(height: 28),

                    _buildSendButton(),
                    const SizedBox(height: 40),

                    _buildHelpSection(),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 7),
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

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _usernameController,
        enabled: !_isLoading,
        decoration: const InputDecoration(
          hintText: 'Nhập tên đăng nhập',
          prefixIcon: Icon(Icons.person_outline),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    'Gửi mã xác nhận',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward),
                ],
              ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Column(
      children: const [
        Text(
          'Bạn gặp khó khăn?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}