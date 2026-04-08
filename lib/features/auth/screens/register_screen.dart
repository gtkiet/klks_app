// // lib/features/auth/screens/register_screen.dart
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../models/user_model.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();
//   bool _loading = false;

//   void _register() async {
//     setState(() => _loading = true);
//     try {
//       UserModel user = await AuthService().register(
//         email: _emailController.text,
//         password: _passwordController.text,
//         confirmPassword: _confirmController.text,
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Register success: ${user.fullName}')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             TextField(
//               controller: _confirmController,
//               decoration: const InputDecoration(labelText: 'Confirm Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: _register,
//                     child: const Text('Register'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';

import '../../../design/pkk_design_system.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final emailErr = Validators.email(_emailController.text);
    final passErr = Validators.newPassword(_passwordController.text);
    final confirmErr = Validators.confirmPassword(_passwordController.text)(
      _confirmController.text,
    );

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
    });

    return emailErr == null && passErr == null && confirmErr == null;
  }

  void _register() async {
    if (!_validate()) return;

    setState(() => _loading = true);
    try {
      UserModel user = await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thành công: ${user.fullName}')),
        );
        Navigator.of(context).pop();
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
      appBar: AppTopBar(title: 'ĐĂNG KÝ', showBack: true, centerTitle: true),
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

                  // ── Logo ──────────────────────────────────────────────────
                  _buildLogo(),

                  const VGap.lg(),

                  // ── Heading ───────────────────────────────────────────────
                  Text(
                    'Tạo tài khoản mới',
                    style: AppTextStyles.display,
                    textAlign: TextAlign.center,
                  ),

                  const VGap.sm(),

                  Text(
                    'Vui lòng nhập thông tin để bắt đầu hành trình cùng PKK',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),

                  const VGap.xl(),

                  // ── Email ─────────────────────────────────────────────────
                  _buildFieldLabel('EMAIL'),
                  const VGap.xs(),
                  AppTextField(
                    hint: 'example@gmail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: _emailError,
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 4),
                      child: Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: AppColors.textDisabled,
                      ),
                    ),
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),

                  const VGap.md(),

                  // ── Password ──────────────────────────────────────────────
                  _buildFieldLabel('MẬT KHẨU'),
                  const VGap.xs(),
                  AppTextField(
                    variant: AppTextFieldVariant.password,
                    hint: 'Nhập mật khẩu',
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    errorText: _passwordError,
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 4),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AppColors.textDisabled,
                      ),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),

                  const VGap.md(),

                  // ── Confirm password ──────────────────────────────────────
                  _buildFieldLabel('XÁC NHẬN MẬT KHẨU'),
                  const VGap.xs(),
                  AppTextField(
                    variant: AppTextFieldVariant.password,
                    hint: 'Nhập lại mật khẩu',
                    controller: _confirmController,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmError,
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 4),
                      child: Icon(
                        Icons.history_rounded,
                        size: 20,
                        color: AppColors.textDisabled,
                      ),
                    ),
                    onSubmitted: (_) => _register(),
                    onChanged: (_) {
                      if (_confirmError != null) {
                        setState(() => _confirmError = null);
                      }
                    },
                  ),

                  const VGap.xl(),

                  // ── Register button ───────────────────────────────────────
                  PrimaryButton(
                    label: 'Đăng ký',
                    onPressed: _loading ? null : _register,
                    isLoading: _loading,
                  ),

                  const VGap.lg(),

                  // ── Login link ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
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

  Widget _buildLogo() {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: AppShadows.low,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Image.asset(
          'assets/icons/app_icon.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.apartment_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
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
