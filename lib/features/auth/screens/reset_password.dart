import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_form_fields.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({super.key, required this.username});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

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
  Future<void> handleResetPassword(AuthProvider auth) async {
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

    final result = await auth.resetPassword(
      username: widget.username,
      resetCode: otp,
      newPassword: newPass,
      confirmPassword: confirmPass,
    );

    if (!mounted) return;

    if (result.isOk) {
      _showSuccess("Đổi mật khẩu thành công");
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      _showError(result.message);
    }
  }

  // ================= PASSWORD CHECK =================
  void _evaluatePassword() {
    final p = _newPassController.text;

    bool hasMinLength = p.length >= 8;
    bool hasUppercase = p.contains(RegExp(r'[A-Z]'));
    bool hasNumberOrSpecial = p.contains(RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]'));

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
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
                        _buildLabel('Tên đăng nhập'),
                        const SizedBox(height: 8),
                        _buildLockedField(widget.username),
                        const SizedBox(height: 18),
                        _buildLabel('Mã xác nhận'),
                        AuthTextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          hint: 'Nhập OTP',
                          validator: (v) => AuthValidators.required(v, "OTP"),
                        ),
                        const SizedBox(height: 18),
                        _buildLabel('Nhập mật khẩu mới'),
                        AuthPasswordField(
                          controller: _newPassController,
                          validator: AuthValidators.password,
                        ),
                        const SizedBox(height: 18),
                        _buildLabel('Xác nhận mật khẩu'),
                        AuthPasswordField(
                          controller: _confirmPassController,
                          validator: AuthValidators.password,
                        ),
                        const SizedBox(height: 20),
                        if (_newPassController.text.isNotEmpty)
                          _buildPasswordRequirements(),
                        const SizedBox(height: 32),
                        AuthPrimaryButton(
                          text: 'Cập nhật mật khẩu',
                          isLoading: auth.isLoading,
                          onPressed: () => handleResetPassword(auth),
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
      },
    );
  }

  // ================= WIDGET HELPERS =================
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

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w500));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Độ mạnh: $_strengthLabel",
          style: TextStyle(color: _strengthColor),
        ),
      ],
    );
  }
}
