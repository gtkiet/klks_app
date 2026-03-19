import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_form_fields.dart';
import '../validators/auth_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  final _genderOptions = ['Nam', 'Nữ', 'Khác'];

  int _getGenderId() {
    switch (_selectedGender) {
      case 'Nam':
        return 1;
      case 'Nữ':
        return 2;
      case 'Khác':
        return 3;
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _getGenderId() == 0) {
      _showError("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      idCard: _idController.text.trim(),
      dob: _selectedDate,
      genderId: _getGenderId(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, "success");
    } else if (authProvider.error != null) {
      _showError(authProvider.error!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Tên đăng nhập'),
                      AuthTextField(
                        controller: _usernameController,
                        hint: 'Nhập tên đăng nhập',
                        validator: (v) =>
                            AuthValidators.required(v, "Tên đăng nhập"),
                      ),

                      _buildLabel('Họ'),
                      AuthTextField(
                        controller: _lastNameController,
                        hint: 'Nhập họ',
                        validator: (v) => AuthValidators.required(v, "Họ"),
                      ),

                      _buildLabel('Tên'),
                      AuthTextField(
                        controller: _firstNameController,
                        hint: 'Nhập tên',
                        validator: (v) => AuthValidators.required(v, "Tên"),
                      ),

                      _buildLabel('Ngày sinh'),
                      AuthDatePicker(
                        initialValue: _selectedDate,
                        onPick: (d) => setState(() => _selectedDate = d),
                        validator: (v) =>
                            v == null ? "Vui lòng chọn ngày sinh" : null,
                      ),

                      _buildLabel('Giới tính'),
                      AuthDropdown(
                        initialValue: _selectedGender,
                        items: _genderOptions,
                        hint: 'Chọn giới tính',
                        onChanged: (v) => setState(() => _selectedGender = v),
                        validator: (v) =>
                            v == null ? "Vui lòng chọn giới tính" : null,
                      ),

                      _buildLabel('Số CMND/CCCD'),
                      AuthTextField(
                        controller: _idController,
                        hint: 'Nhập số CMND/CCCD',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        validator: (v) =>
                            AuthValidators.required(v, "CMND/CCCD"),
                      ),

                      _buildLabel('Số điện thoại'),
                      AuthTextField(
                        controller: _phoneController,
                        hint: 'Nhập số điện thoại',
                        validator: AuthValidators.phone,
                      ),

                      _buildLabel('Email'),
                      AuthTextField(
                        controller: _emailController,
                        hint: 'example@gmail.com',
                        validator: AuthValidators.email,
                      ),

                      _buildLabel('Địa chỉ'),
                      AuthTextField(
                        controller: _addressController,
                        hint: 'Ví dụ: A-1205',
                        validator: (v) => AuthValidators.required(v, "Địa chỉ"),
                      ),

                      _buildLabel('Mật khẩu'),
                      AuthPasswordField(
                        controller: _passwordController,
                        validator: AuthValidators.password,
                      ),

                      const SizedBox(height: 32),
                      AuthPrimaryButton(
                        text: 'Đăng ký',
                        isLoading: authProvider.isLoading,
                        onPressed: _onRegister,
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Đã có tài khoản? ',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Đăng ký tài khoản',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
      ),
    );
  }
}
