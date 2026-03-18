import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
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

  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  int _getGenderId() {
    switch (_selectedGender) {
      case "Nam":
        return 1;
      case "Nữ":
        return 2;
      case "Khác":
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
          const SnackBar(content: Text("Đăng ký thành công. Vui lòng đăng nhập.")),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        Navigator.pop(context);
      } else {
        _showError(_extractError(response));
      }
    } catch (e) {
      _showError("Lỗi kết nối, vui lòng thử lại");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _extractError(dynamic response) {
    try {
      if (response["errors"] != null &&
          response["errors"] is List &&
          response["errors"].isNotEmpty) {
        return response["errors"][0]["description"] ??
            "Đăng ký thất bại";
      }
    } catch (_) {}

    return "Đăng ký thất bại";
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
                    children: [
                      _buildTextField(_usernameController, "Tên đăng nhập"),
                      _buildTextField(_lastNameController, "Họ"),
                      _buildTextField(_firstNameController, "Tên"),
                      _buildDateField(),
                      _buildGenderDropdown(),
                      _buildTextField(_idController, "CMND/CCCD"),
                      _buildTextField(_phoneController, "SĐT"),
                      _buildTextField(_emailController, "Email"),
                      _buildTextField(_addressController, "Địa chỉ"),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      _buildRegisterButton(),
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
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Text("Đăng ký"),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          _selectedDate != null
              ? _formatDate(_selectedDate!)
              : "Chọn ngày sinh",
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButton<String>(
      value: _selectedGender,
      hint: const Text("Chọn giới tính"),
      isExpanded: true,
      items: _genderOptions
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Mật khẩu",
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword
              ? Icons.visibility_off
              : Icons.visibility),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Đăng ký"),
    );
  }
}