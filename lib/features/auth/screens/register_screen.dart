import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../widgets/form_field.dart';
import '../../../widgets/app_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  DateTime? _selectedDate;
  String? _selectedGender;
  final List<String> _genderOptions = ['Nam', 'Nữ'];

  int _getGenderId() {
    switch (_selectedGender) {
      case "Nam":
        return 1;
      case "Nữ":
        return 2;
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    // Validate
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
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
          const SnackBar(
            content: Text("Đăng ký thành công. Vui lòng đăng nhập."),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabelText(text: "Tên đăng nhập"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _usernameController,
                        hintText: "Nhập tên đăng nhập",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Họ"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _lastNameController,
                        hintText: "Nhập họ",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Tên"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _firstNameController,
                        hintText: "Nhập tên",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Ngày sinh"),
                      const SizedBox(height: 8),
                      DateField(
                        selectedDate: _selectedDate,
                        onTap: _pickDate,
                        placeholder: "Chọn ngày sinh",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Giới tính"),
                      const SizedBox(height: 8),
                      DropdownField<String>(
                        selectedValue: _selectedGender,
                        options: _genderOptions,
                        onChanged: (value) =>
                            setState(() => _selectedGender = value),
                        hint: 'Chọn giới tính',
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "CMND/CCCD"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _idController,
                        hintText: "Nhập số CMND/CCCD",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Số điện thoại"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: "Nhập số điện thoại",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Email"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Nhập email",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Địa chỉ"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _addressController,
                        hintText: "Nhập địa chỉ",
                      ),
                      const SizedBox(height: 12),

                      LabelText(text: "Mật khẩu"),
                      const SizedBox(height: 8),
                      PasswordField(
                        controller: _passwordController,
                        hintText: "Nhập mật khẩu",
                      ),
                      const SizedBox(height: 24),

                      SubmitButton(
                        onPressed: _register,
                        isLoading: _isLoading,
                        label: "Đăng ký",
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Đăng ký",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
