// ═══════════════════════════════════════════════════════════════════════════
// lib/features/auth/screens/login_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:klks_app/design/design.dart';

import '../services/auth_service.dart';

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
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      await _authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xxl.verticalSpace,
              AppSpacing.xl.verticalSpace,

              // ── Logo ────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppElevation.level2,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.apartment_rounded,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              AppSpacing.lg.verticalSpace,

              // ── Heading ─────────────────────────────────────────────────
              Text(
                'Đăng nhập',
                style: AppTypography.display.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.xs.verticalSpace,

              Text(
                'Chào mừng bạn quay trở lại',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.xl.verticalSpace,

              // ── Error banner ─────────────────────────────────────────────
              if (_errorText != null) ...[
                ErrorDisplay(error: _errorText, compact: true),
                AppSpacing.md.verticalSpace,
              ],

              // ── Username field ───────────────────────────────────────────
              AppTextField(
                label: 'TÊN ĐĂNG NHẬP',
                hint: 'Nhập tên đăng nhập',
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),

              AppSpacing.md.verticalSpace,

              // ── Password field ───────────────────────────────────────────
              AppTextField.password(
                label: 'MẬT KHẨU',
                controller: _passwordController,
              ),

              AppSpacing.sm.verticalSpace,

              // ── Forgot password ──────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/auth/forgot-password'),
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

              // ── Login button ─────────────────────────────────────────────
              AppButton(
                label: 'Đăng nhập',
                isLoading: _loading,
                onPressed: _loading ? null : _login,
              ),

              AppSpacing.lg.verticalSpace,

              // ── Register link ────────────────────────────────────────────
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
                    onTap: () => context.push('/auth/register'),
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

              // ── Footer ───────────────────────────────────────────────────
              Text(
                '© 2026 PKK RESIDENT SYSTEM',
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textDisabled,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.md.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
