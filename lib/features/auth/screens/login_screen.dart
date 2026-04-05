// // lib/features/auth/screens/login_screen.dart

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../../../core/guards/auth_guard.dart';

// import '../services/auth_service.dart';

// import '../models/user_model.dart';

// import 'register_screen.dart';
// import 'forgot_password_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _loading = false;

//   void _login() async {
//     setState(() => _loading = true);
//     try {
//       UserModel user = await AuthService().login(
//         username: _usernameController.text,
//         password: _passwordController.text,
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login success: ${user.fullName}')),
//         );
//         AuthGuard.instance.setAuthenticated();
//         context.go('/home');
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

//   void _goToRegister() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const RegisterScreen()),
//     );
//   }

//   void _goToForgotPassword() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(onPressed: _login, child: const Text('Login')),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: _goToRegister,
//                   child: const Text('Register'),
//                 ),
//                 TextButton(
//                   onPressed: _goToForgotPassword,
//                   child: const Text('Forgot Password?'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/guards/auth_guard.dart';
import '../../../design/pkk_design_system.dart';

import '../services/auth_service.dart';

import '../models/user_model.dart';

import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final emailErr = Validators.email(_emailController.text);
    final passErr = Validators.required(_passwordController.text, field: 'Mật khẩu');
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  void _login() async {
    if (!_validate()) return;

    setState(() => _loading = true);
    try {
      UserModel user = await AuthService().login(
        username: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xin chào, ${user.fullName}!')),
        );
        AuthGuard.instance.setAuthenticated();
        context.go('/home');
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

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: 'Đăng nhập', centerTitle: true),
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

              // ── Logo ────────────────────────────────────────────────────
              _buildLogo(),

              const VGap.lg(),

              // ── Login image ──────────────────────────────────────────────
              Image.asset(
                'assets/images/login_img.jpg',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(height: 180),
              ),

              const VGap.lg(),

              // ── Email field ─────────────────────────────────────────────
              _buildFieldLabel('EMAIL'),
              const VGap.xs(),
              AppTextField(
                variant: AppTextFieldVariant.text,
                hint: 'username@gmail.com',
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
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),

              const VGap.md(),

              // ── Password field ──────────────────────────────────────────
              _buildFieldLabel('MẬT KHẨU'),
              const VGap.xs(),
              AppTextField(
                variant: AppTextFieldVariant.password,
                hint: '••••••••',
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                errorText: _passwordError,
                prefixIcon: const Padding(
                  padding: EdgeInsetsDirectional.only(start: 4),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: AppColors.textDisabled,
                  ),
                ),
                onSubmitted: (_) => _login(),
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),

              const VGap.sm(),

              // ── Forgot password ─────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _goToForgotPassword,
                  child: Text(
                    'Quên mật khẩu?',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const VGap.xl(),

              // ── Login button ────────────────────────────────────────────
              PrimaryButton(
                label: _loading ? 'Đang xử lý...' : 'Đăng nhập',
                onPressed: _loading ? null : _login,
                isLoading: _loading,
              ),

              const VGap.lg(),

              // ── Register link ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToRegister,
                    child: Text(
                      'Đăng ký ngay',
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

            // ── Footer pinned at bottom ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                '© 2026 PKK RESIDENT SYSTEM',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
    );
  }

  // ── Logo widget ────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        boxShadow: AppShadows.low,
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          // Replace with your actual logo widget:
          // child: Image.asset('assets/images/app_icon.png')
          // or: child: const AppIconWidget()
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