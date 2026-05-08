// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/guards/auth_guard.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
// import 'register_screen.dart';
// import 'forgot_password_screen.dart';

import '../../../design/design.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService.instance;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    try {
      UserModel user = await _authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login success: ${user.fullName}')),
        );
        AuthGuard.instance.setAuthenticated();
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToRegister() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const RegisterScreen()),
    // );
    context.push('/auth/register');
  }

  void _goToForgotPassword() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    // );
    context.push('/auth/forgot-password');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.xxl.verticalSpace,

              // ── Logo ────────────────────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppElevation.level1,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.apartment_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              AppSpacing.lg.verticalSpace,

              // ── Welcome text ────────────────────────────────────────────────
              Text(
                'Chào mừng bạn quay trở lại với PKK',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.xl.verticalSpace,

              // ── Email field ─────────────────────────────────────────────────
              AppTextField(
                label: 'EMAIL',
                hint: 'username@gmail.com',
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),

              AppSpacing.md.verticalSpace,

              // ── Password field ──────────────────────────────────────────────
              AppTextField.password(
                label: 'MẬT KHẨU',
                controller: _passwordController,
              ),

              AppSpacing.sm.verticalSpace,

              // ── Forgot password ─────────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Quên mật khẩu?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              AppSpacing.lg.verticalSpace,

              // ── Login button ────────────────────────────────────────────────
              AppButton(
                label: _loading ? 'Đang xử lý...' : 'Đăng nhập',
                isLoading: _loading,
                onPressed: _loading ? null : _login,
              ),

              AppSpacing.lg.verticalSpace,

              // ── Register link ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToRegister,
                    child: Text(
                      'Đăng ký ngay',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.xxl.verticalSpace,

              // ── Footer ───────────────────────────────────────────────────────
              Text(
                '© 2026 PKK RESIDENT SYSTEM',
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textDisabled,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
