import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../widgets/widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({super.key, required this.username});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isLoading = false;

  // Password strength
  int _strengthLevel = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _newPassController.addListener(_evaluatePassword);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ================= HANDLE RESET =================
  Future<void> handleResetPassword() async {
    final otp = _otpController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (otp.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    if (newPass != confirmPass) {
      _showError("Mật khẩu xác nhận không khớp");
      return;
    }

    if (_strengthLevel < 2) {
      _showError("Mật khẩu quá yếu");
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final result = await _authService.resetPassword(
        username: widget.username,
        resetCode: otp,
        newPassword: newPass,
        confirmPassword: confirmPass,
      );

      if (!mounted) return;

      if (result["isOk"] == true) {
        _showSuccess("Đổi mật khẩu thành công");
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        _showError(result["errors"]?[0]?["description"] ?? "Có lỗi xảy ra");
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Lỗi kết nối");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= PASSWORD CHECK =================
  void _evaluatePassword() {
    final p = _newPassController.text;

    final hasMinLength = p.length >= 8;
    final hasUppercase = p.contains(RegExp(r'[A-Z]'));
    final hasNumberOrSpecial = p.contains(
      RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]'),
    );

    final score =
        (hasMinLength ? 1 : 0) +
        (hasUppercase ? 1 : 0) +
        (hasNumberOrSpecial ? 1 : 0);

    setState(() {
      if (p.isEmpty) {
        _strengthLevel = 0;
        _strengthLabel = '';
        _strengthColor = Colors.transparent;
      } else if (score == 1) {
        _strengthLevel = 1;
        _strengthLabel = 'Yếu';
        _strengthColor = const Color(0xFFEF4444);
      } else if (score == 2) {
        _strengthLevel = 2;
        _strengthLabel = 'Trung bình';
        _strengthColor = const Color(0xFFF59E0B);
      } else {
        _strengthLevel = 3;
        _strengthLabel = 'Mạnh';
        _strengthColor = const Color(0xFF10B981);
      }
    });
  }

  // ================= HELPERS =================
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Center(child: _buildIconCircle()),
                    const SizedBox(height: 28),

                    const Text(
                      'Đặt lại mật khẩu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 32),

                    const LabelText(text: 'Tên đăng nhập'),
                    const SizedBox(height: 6),
                    _buildLockedField(widget.username),
                    const SizedBox(height: 18),

                    const LabelText(text: 'Mã xác nhận'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      controller: _otpController,
                      hintText: 'Nhập OTP',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    const LabelText(text: 'Mật khẩu mới'),
                    const SizedBox(height: 6),
                    PasswordField(
                      controller: _newPassController,
                      hintText: 'Nhập mật khẩu mới',
                    ),
                    const SizedBox(height: 18),

                    const LabelText(text: 'Xác nhận mật khẩu'),
                    const SizedBox(height: 6),
                    PasswordField(
                      controller: _confirmPassController,
                      hintText: 'Nhập lại mật khẩu',
                    ),
                    const SizedBox(height: 20),

                    if (_newPassController.text.isNotEmpty)
                      _buildPasswordRequirements(),
                    const SizedBox(height: 32),

                    SubmitButton(
                      isLoading: _isLoading,
                      onPressed: handleResetPassword,
                      label: 'Cập nhật mật khẩu',
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

  // ================= WIDGETS =================
  Widget _buildIconCircle() {
    return Container(
      width: 96,
      height: 96,
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

  Widget _buildLockedField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(value),
    );
  }

  Widget _buildPasswordRequirements() {
    return Text(
      "Độ mạnh: $_strengthLabel",
      style: TextStyle(color: _strengthColor, fontWeight: FontWeight.w500),
    );
  }
}
