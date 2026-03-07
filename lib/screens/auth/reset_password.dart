import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({super.key, required this.username});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Password strength
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumberOrSpecial = false;

  /// 0 = none, 1 = weak, 2 = medium, 3 = strong
  int _strengthLevel = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _newPassController.addListener(_evaluatePassword);
  }

  Future<void> handleResetPassword() async {
    final result = await AuthService.resetPassword(
      username: widget.username,
      resetCode: _otpController.text,
      newPassword: _newPassController.text,
    );

    if (_otpController.text.isEmpty || _newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    if (result["isOk"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công")));

      Navigator.pushReplacementNamed(context, "/login");
    } else {
      final error = result["errors"][0]["description"];

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _evaluatePassword() {
    final p = _newPassController.text;
    setState(() {
      _hasMinLength = p.length >= 8;
      _hasUppercase = p.contains(RegExp(r'[A-Z]'));
      _hasNumberOrSpecial = p.contains(RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]'));

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

  @override
  void dispose() {
    _otpController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

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
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF111827),
                    size: 24,
                  ),
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

                    // Icon
                    Center(child: _buildIconCircle()),
                    const SizedBox(height: 28),

                    // Title
                    const Text(
                      'Đặt lại mật khẩu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    const Text(
                      'Vui lòng nhập mật khẩu mới để tiếp tục.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tên đăng nhập (locked)
                    _buildLabel('Tên đăng nhập'),
                    const SizedBox(height: 8),
                    _buildLockedField(widget.username),
                    const SizedBox(height: 18),

                    // Mã xác nhận
                    _buildLabel('Mã xác nhận'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _otpController,
                      hintText: 'Nhập mã xác nhận từ email',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    // Mật khẩu mới
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

                    // Xác nhận mật khẩu
                    _buildLabel('Xác nhận mật khẩu'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPassController,
                      hintText: 'Nhập lại mật khẩu mới',
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 20),

                    // Password requirements box
                    if (_newPassController.text.isNotEmpty)
                      _buildPasswordRequirements(),

                    const SizedBox(height: 32),

                    // Submit button
                    _buildSubmitButton(),
                    const SizedBox(height: 16),

                    // Cancel
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, "/login"),
                      child: const Center(
                        child: Text(
                          'Hủy và quay lại đăng nhập',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
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

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildIconCircle() {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: Color(0xFFDDE3F5),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.lock_reset_rounded,
          color: Color(0xFF2563EB),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildLockedField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
            ),
          ),
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YÊU CẦU MẬT KHẨU:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementRow(_hasMinLength, 'Ít nhất 8 ký tự'),
          const SizedBox(height: 8),
          _buildRequirementRow(_hasUppercase, 'Có ít nhất 1 chữ hoa'),
          const SizedBox(height: 8),
          _buildRequirementRow(
            _hasNumberOrSpecial,
            'Có ít nhất 1 chữ số hoặc ký tự đặc biệt',
          ),
          const SizedBox(height: 14),

          // Strength bar
          Row(
            children: [
              const Text(
                'Độ mạnh mật khẩu',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              if (_strengthLabel.isNotEmpty)
                Text(
                  _strengthLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _strengthColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _strengthLevel / 3,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(bool met, String label) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? const Color(0xFF10B981) : Colors.transparent,
            border: Border.all(
              color: met ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
              width: 1.5,
            ),
          ),
          child: met
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: met ? const Color(0xFF111827) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Cập nhật mật khẩu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
