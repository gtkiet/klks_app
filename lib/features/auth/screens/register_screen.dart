import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_form_fields.dart';
import '../../core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../config/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedDate == null ||
        _selectedGender == null) {
      _showError("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        idCard: _idController.text.trim(),
        dob: _selectedDate!.toIso8601String(),
        gioiTinhId: _getGenderId(),
        address: _addressController.text.trim(),
      );

      if (!mounted) return;

      if (response["isOk"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công. Vui lòng đăng nhập.")),
        );

        // Trở về màn hình login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        _showError(_extractError(response));
      }
    } catch (e) {
      _showError("Lỗi kết nối, vui lòng thử lại");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractError(dynamic response) {
    try {
      if (response["errors"] != null &&
          response["errors"] is List &&
          response["errors"].isNotEmpty) {
        return response["errors"][0]["description"] ?? "Đăng ký thất bại";
      }
    } catch (_) {}
    return "Đăng ký thất bại";
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),

              _buildLabel('Tên đăng nhập'),
              AuthTextField(controller: _usernameController, hint: 'Nhập tên đăng nhập'),

              _buildLabel('Họ'),
              AuthTextField(controller: _lastNameController, hint: 'Nhập họ'),

              _buildLabel('Tên'),
              AuthTextField(controller: _firstNameController, hint: 'Nhập tên'),

              _buildLabel('Ngày sinh'),
              AuthDatePicker(
                selectedDate: _selectedDate,
                onPick: (d) => setState(() => _selectedDate = d),
              ),

              _buildLabel('Giới tính'),
              AuthDropdown(
                value: _selectedGender,
                items: _genderOptions,
                hint: 'Chọn giới tính',
                onChanged: (v) => setState(() => _selectedGender = v),
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
              ),

              _buildLabel('Số điện thoại'),
              AuthTextField(controller: _phoneController, hint: 'Nhập số điện thoại'),

              _buildLabel('Email'),
              AuthTextField(controller: _emailController, hint: 'example@gmail.com'),

              _buildLabel('Địa chỉ'),
              AuthTextField(controller: _addressController, hint: 'Ví dụ: A-1205'),

              _buildLabel('Mật khẩu'),
              AuthPasswordField(controller: _passwordController),

              const SizedBox(height: 32),
              AuthPrimaryButton(
                text: 'Đăng ký',
                isLoading: _isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
    );
  }
}