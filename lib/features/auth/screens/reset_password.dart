import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({super.key, required this.username});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPassController =
      TextEditingController();
  final TextEditingController _confirmPassController =
      TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Password strength
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumberOrSpecial = false;

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

    // VALIDATE
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
      );

      if (!mounted) return;

      if (result["isOk"] == true) {
        _showSuccess("Đổi mật khẩu thành công");

        await Future.delayed(const Duration(milliseconds: 300));

        Navigator.pushReplacementNamed(context, "/login");
      } else {
        _showError(
          result["errors"]?[0]?["description"] ??
              "Có lỗi xảy ra",
        );
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

    setState(() {
      _hasMinLength = p.length >= 8;
      _hasUppercase = p.contains(RegExp(r'[A-Z]'));
      _hasNumberOrSpecial =
          p.contains(RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]'));

      final score =
          (_hasMinLength ? 1 : 0) +
          (_hasUppercase ? 1 : 0) +
          (_hasNumberOrSpecial ? 1 : 0);

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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Back
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _otpController,
                      hintText: 'Nhập OTP',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 18),

                    _buildLabel('Mật khẩu mới'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _newPassController,
                      hintText: 'Nhập mật khẩu mới',
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),

                    const SizedBox(height: 18),

                    _buildLabel('Xác nhận mật khẩu'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPassController,
                      hintText: 'Nhập lại mật khẩu',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),

                    const SizedBox(height: 20),

                    if (_newPassController.text.isNotEmpty)
                      _buildPasswordRequirements(),

                    const SizedBox(height: 32),

                    _buildSubmitButton(),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildLockedField(String value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(value),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hintText),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : handleResetPassword,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Cập nhật mật khẩu'),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Độ mạnh: $_strengthLabel",
            style: TextStyle(color: _strengthColor)),
      ],
    );
  }
}
