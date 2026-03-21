import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../../../widgets/widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ProfileService _service = ProfileService();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    if (newPassword != confirmPassword) {
      _showError("Mật khẩu xác nhận không khớp");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _service.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      if (res["isOk"] == true) {
        _showSuccess("Đổi mật khẩu thành công");
        Navigator.pop(context, true);
      } else {
        _showError(res["errors"]?[0]?["description"] ?? "Có lỗi xảy ra");
      }
    } catch (_) {
      _showError("Lỗi kết nối, vui lòng thử lại");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ================= UI HELPERS =================
  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text("Đổi mật khẩu")),

      /// ===== BODY =====
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// ===== HEADER =====
                const Text(
                  "Bảo mật tài khoản",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Vui lòng nhập mật khẩu cũ và mật khẩu mới để tiếp tục",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                /// ===== CARD FORM =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      /// OLD PASSWORD
                      LabelText(text: "Mật khẩu hiện tại"),
                      const SizedBox(height: 8),
                      PasswordField(
                        controller: _oldPasswordController,
                        hintText: "Nhập mật khẩu hiện tại",
                      ),
                      const SizedBox(height: 20),

                      /// NEW PASSWORD
                      LabelText(text: "Mật khẩu mới"),
                      const SizedBox(height: 8),
                      PasswordField(
                        controller: _newPasswordController,
                        hintText: "Nhập mật khẩu mới",
                      ),
                      const SizedBox(height: 20),

                      /// CONFIRM PASSWORD
                      LabelText(text: "Xác nhận mật khẩu"),
                      const SizedBox(height: 8),
                      PasswordField(
                        controller: _confirmPasswordController,
                        hintText: "Nhập lại mật khẩu mới",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // space for button
              ],
            ),
          ),

          /// ===== LOADING =====
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),

      /// ===== STICKY BUTTON =====
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: PrimaryButton(
          label: "Đổi mật khẩu",
          onPressed: _submit,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}
