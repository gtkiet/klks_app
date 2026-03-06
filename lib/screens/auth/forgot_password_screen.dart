import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _contactController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── App Bar ──
            _buildAppBar(context),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Lock icon circle
                    Center(child: _buildIconCircle()),

                    const SizedBox(height: 36),

                    // Title
                    const Text(
                      'Quên mật khẩu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    const Text(
                      'Đừng lo lắng! Vui lòng nhập email hoặc số điện thoại đã đăng ký để nhận mã OTP khôi phục mật khẩu tài khoản Smart Living của bạn.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Field label
                    const Text(
                      'EMAIL HOẶC SỐ ĐIỆN THOẠI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Input field
                    _buildTextField(),
                    const SizedBox(height: 28),

                    // Submit button
                    _buildSendButton(),
                    const SizedBox(height: 40),

                    // Help section
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

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF111827),
              size: 24,
            ),
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
                letterSpacing: 1.0,
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
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular arrow
            Icon(
              Icons.lock_reset_rounded,
              size: 48,
              color: const Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _contactController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
        decoration: const InputDecoration(
          hintText: 'username@email.com',
          hintStyle: TextStyle(
            fontSize: 15,
            color: Color(0xFF9CA3AF),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Text(
              '@',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gửi mã xác nhận',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            'Bạn gặp khó khăn?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Liên hệ hỗ trợ
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  const Icon(
                    Icons.headset_mic_outlined,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Liên hệ hỗ trợ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),
            // Câu hỏi thường gặp
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Câu hỏi thường gặp',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}