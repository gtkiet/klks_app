// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_ext.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/guards/auth_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      AuthGuard.instance.setAuthenticated();
      context.go(AppRoutes.home);
    } on AppException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Đã có lỗi xảy ra');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText.body(message, style: TextStyle(color: colors.onError)),
        backgroundColor: colors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxWidth = 480.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  decoration: context.isDark
                      ? AppStyles.cardDark.copyWith(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : AppStyles.card,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSpacing.h24,
                      _buildLoginHeader(),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: _LoginForm(
                          formKey: _formKey,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          isLoading: _isLoading,
                          onLogin: _handleLogin,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/app_icon.png', width: 48, height: 48, semanticLabel: 'App Logo'),
            AppSpacing.w12,
            Flexible(child: AppText.title('PKK - Chung cư thông minh')),
          ],
        ),
        AppSpacing.h16,
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/login_img.jpg',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.h24,
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.title('Chào mừng bạn đến với PKK'),
          AppSpacing.h8,
          AppText.body('Trải nghiệm không gian sống hiện đại và an toàn'),
          AppSpacing.h24,

          AppInputField(
            controller: usernameController,
            label: 'Tên đăng nhập',
            hint: 'Nhập tên đăng nhập',
            prefix: Icon(Icons.person),
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.required(v, field: 'Tên đăng nhập'),
          ),
          AppSpacing.h16,

          AppPasswordField(
            controller: passwordController,
            label: 'Mật khẩu',
            prefix: const Icon(Icons.lock),
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.required(v, field: 'Mật khẩu'),
            onFieldSubmitted: (_) => onLogin(),
          ),
          AppSpacing.h16,

          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => context.go(AppRoutes.forgotPassword),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: AppText.body('Quên mật khẩu?', style: TextStyle(fontWeight: FontWeight.w600, color: colors.primary)),
              ),
            ),
          ),
          AppSpacing.h16,

          AppButton(
            text: 'Đăng nhập',
            loading: isLoading,
            onPressed: isLoading ? null : onLogin,
            type: AppButtonType.primary,
          ),
          AppSpacing.h20,

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.body('Chưa có tài khoản? ', style: TextStyle(color: colors.onBackground.withOpacity(0.6))),
              GestureDetector(
                onTap: () => context.go(AppRoutes.register),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AppText.body('Đăng ký', style: TextStyle(fontWeight: FontWeight.w600, color: colors.primary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}