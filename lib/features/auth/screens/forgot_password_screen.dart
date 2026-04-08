// // lib/features/auth/screens/forgot_password_screen.dart
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _usernameController = TextEditingController();
//   bool _loading = false;

//   void _submit() async {
//     setState(() => _loading = true);
//     try {
//       String result = await AuthService().forgotPassword(
//         username: _usernameController.text,
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Reset code sent: $result')));
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
//       appBar: AppBar(title: const Text('Forgot Password')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             const SizedBox(height: 16),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _submit,
//                     child: const Text('Send Reset Code'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/features/auth/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';

import '../../../design/pkk_design_system.dart';

import '../services/auth_service.dart';

import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService.instance;
  final _emailController = TextEditingController();
  String? _emailError;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validate() {
    final err = Validators.email(_emailController.text);
    setState(() => _emailError = err);
    return err == null;
  }

  void _submit() async {
    if (!_validate()) return;

    setState(() => _loading = true);
    try {
      await _authService.forgotPassword(
        username: _emailController.text,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: _emailController.text),
          ),
        );
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
        title: 'Quên mật khẩu',
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
                  const VGap.xl(),

                  // ── Hero icon ────────────────────────────────────────────
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),

                  const VGap.lg(),

                  // ── Heading ──────────────────────────────────────────────
                  Text(
                    'Tìm lại tài khoản',
                    style: AppTextStyles.display,
                    textAlign: TextAlign.center,
                  ),

                  const VGap.sm(),

                  Text(
                    'Chúng tôi sẽ gửi mã xác thực để đặt lại mật khẩu. Vui lòng nhập email đăng ký của bạn.',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),

                  const VGap.xl(),

                  // ── Email field ──────────────────────────────────────────
                  _buildFieldLabel('ĐỊA CHỈ EMAIL'),
                  const VGap.xs(),
                  AppTextField(
                    hint: 'example@resident.pkk',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    errorText: _emailError,
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 4),
                      child: Icon(
                        Icons.email_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),

                  const VGap.lg(),

                  // ── Submit button ────────────────────────────────────────
                  PrimaryButton(
                    label: 'Gửi mã OTP  →',
                    onPressed: _loading ? null : _submit,
                    isLoading: _loading,
                  ),

                  const VGap.xl(),

                  // ── Security notice card ─────────────────────────────────
                  AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInput,
                            ),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const HGap.md(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bảo mật tài khoản',
                                style: AppTextStyles.subhead,
                              ),
                              const VGap.xs(),
                              Text(
                                'Hãy đảm bảo bạn không chia sẻ mã OTP cho bất kỳ ai, kể cả nhân viên quản lý tòa nhà.',
                                style: AppTextStyles.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const VGap.xl(),

                  // ── Back to login link ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bạn đã nhớ lại mật khẩu? ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Đăng nhập ngay',
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

          // ── Support bar pinned at bottom ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CẦN HỖ TRỢ?',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const VGap.xs(),
                    Text('Liên hệ Ban quản lý', style: AppTextStyles.subhead),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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