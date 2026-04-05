// // lib/features/auth/screens/reset_password_screen.dart
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _usernameController = TextEditingController();
//   final _resetCodeController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _loading = false;

//   void _resetPassword() async {
//     setState(() => _loading = true);
//     try {
//       String result = await AuthService().resetPassword(
//         username: _usernameController.text,
//         resetCode: _resetCodeController.text,
//         newPassword: _newPasswordController.text,
//         confirmPassword: _confirmPasswordController.text,
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Password reset success: $result')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Reset Password')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextField(
//               controller: _resetCodeController,
//               decoration: const InputDecoration(labelText: 'Reset Code'),
//             ),
//             TextField(
//               controller: _newPasswordController,
//               decoration: const InputDecoration(labelText: 'New Password'),
//               obscureText: true,
//             ),
//             TextField(
//               controller: _confirmPasswordController,
//               decoration: const InputDecoration(labelText: 'Confirm Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             _loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ElevatedButton(
//                     onPressed: _resetPassword,
//                     child: const Text('Reset Password'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/features/auth/screens/reset_password_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design/pkk_design_system.dart';
import '../services/auth_service.dart';

// ─── Constants ────────────────────────────────────────────────────────────────
const int _kResendSeconds = 60;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email, // passed from ForgotPasswordScreen
  });

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // ── OTP ──────────────────────────────────────────────────────────────────
  final _otpController = TextEditingController();
  String? _otpError;

  // ── Password ──────────────────────────────────────────────────────────────
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _newPasswordError;
  String? _confirmPasswordError;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _loading = false;
  int _resendCountdown = _kResendSeconds;
  Timer? _timer;

  // ── Password rules ────────────────────────────────────────────────────────
  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase =>
      _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasNoSpace =>
      !_newPasswordController.text.contains(' ') &&
      _newPasswordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _newPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── Countdown ─────────────────────────────────────────────────────────────
  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = _kResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────
  void _resendOtp() async {
    if (_resendCountdown > 0) return;
    try {
      _startCountdown();
      _otpController.clear();
      await AuthService().forgotPassword(username: widget.email);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã gửi lại mã OTP')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Validate ──────────────────────────────────────────────────────────────
  bool _validate() {
    final otpErr = Validators.required(_otpController.text, field: 'Mã OTP');
    final newPassErr = Validators.newPassword(_newPasswordController.text);
    final confirmErr = Validators.confirmPassword(_newPasswordController.text)(
      _confirmPasswordController.text,
    );

    setState(() {
      _otpError = otpErr;
      _newPasswordError = newPassErr;
      _confirmPasswordError = confirmErr;
    });

    return otpErr == null && newPassErr == null && confirmErr == null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _resetPassword() async {
    if (!_validate()) return;

    setState(() => _loading = true);
    try {
      String result = await AuthService().resetPassword(
        username: widget.email,
        resetCode: _otpController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt lại mật khẩu thành công: $result')),
        );
        // Pop back to login
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Đặt lại mật khẩu',
        showBack: true,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const VGap.lg(),

                  // ── Hero icon ──────────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 38,
                      color: AppColors.primary,
                    ),
                  ),

                  const VGap.md(),

                  // ── Subtitle ───────────────────────────────────────────
                  Text(
                    'Vui lòng nhập mã xác thực đã được gửi đến email của bạn và thiết lập mật khẩu mới.',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),

                  const VGap.xl(),

                  // ── Email (readonly) ───────────────────────────────────
                  _buildFieldLabel('EMAIL CỦA BẠN'),
                  const VGap.xs(),
                  AppTextField(
                    hint: widget.email,
                    controller: TextEditingController(text: widget.email),
                    readOnly: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 4),
                      child: Icon(
                        Icons.email_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    suffixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(end: 4),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),

                  const VGap.lg(),

                  // ── OTP input ──────────────────────────────────────────
                  _buildFieldLabel('MÃ XÁC THỰC (OTP)'),
                  const VGap.xs(),
                  AppTextField(
                    hint: 'Nhập mã OTP',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    errorText: _otpError,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 4),
                      child: Icon(
                        Icons.pin_outlined,
                        size: 20,
                        color: AppColors.textDisabled,
                      ),
                    ),
                    onChanged: (_) {
                      if (_otpError != null) setState(() => _otpError = null);
                    },
                  ),

                  const VGap.sm(),

                  // ── Resend link ────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _resendCountdown == 0 ? _resendOtp : null,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Gửi lại mã (${_resendCountdown}s)'
                            : 'Gửi lại mã',
                        style: AppTextStyles.caption.copyWith(
                          color: _resendCountdown > 0
                              ? AppColors.primary
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: _resendCountdown == 0
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const VGap.lg(),

                  // ── New password ───────────────────────────────────────
                  _buildFieldLabel('MẬT KHẨU MỚI'),
                  const VGap.xs(),
                  AppTextField(
                    variant: AppTextFieldVariant.password,
                    hint: 'Nhập mật khẩu mới',
                    controller: _newPasswordController,
                    textInputAction: TextInputAction.next,
                    errorText: _newPasswordError,
                    onChanged: (_) {
                      if (_newPasswordError != null) {
                        setState(() => _newPasswordError = null);
                      }
                    },
                  ),

                  const VGap.md(),

                  // ── Confirm password ───────────────────────────────────
                  _buildFieldLabel('XÁC NHẬN MẬT KHẨU'),
                  const VGap.xs(),
                  AppTextField(
                    variant: AppTextFieldVariant.password,
                    hint: 'Nhập lại mật khẩu mới',
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmPasswordError,
                    onSubmitted: (_) => _resetPassword(),
                    onChanged: (_) {
                      if (_confirmPasswordError != null) {
                        setState(() => _confirmPasswordError = null);
                      }
                    },
                  ),

                  const VGap.lg(),

                  // ── Password rules card ────────────────────────────────
                  _buildPasswordRules(),

                  const VGap.xl(),

                  // ── Submit button ──────────────────────────────────────
                  PrimaryButton(
                    label: 'Xác nhận',
                    onPressed: _loading ? null : _resetPassword,
                    isLoading: _loading,
                  ),

                  const VGap.lg(),

                  // ── Back to login ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Quay lại ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                        child: Text(
                          'Đăng nhập',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const VGap.lg(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Password rules card ────────────────────────────────────────────────────
  Widget _buildPasswordRules() {
    final rules = [
      (label: 'Ít nhất 8 ký tự', met: _hasMinLength),
      (label: 'Có ít nhất 1 chữ hoa (A–Z)', met: _hasUppercase),
      (label: 'Có ít nhất 1 chữ số (0–9)', met: _hasDigit),
      (label: 'Không chứa khoảng trắng', met: _hasNoSpace),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUY ĐỊNH BẢO MẬT',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const VGap.sm(),
          ...rules.map(
            (r) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    r.met ? Icons.check_circle_rounded : Icons.circle_outlined,
                    size: 18,
                    color: r.met ? AppColors.primary : AppColors.textDisabled,
                  ),
                  const HGap.sm(),
                  Text(
                    r.label,
                    style: AppTextStyles.body.copyWith(
                      color: r.met
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field label ────────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
