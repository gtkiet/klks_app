import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;

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
    final response = await _authService.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneController.text,
      idCard: _idController.text,
      dob: _selectedDate!.toIso8601String(),
      gioiTinhId: _getGenderId(),
      address: _addressController.text,
    );

    if (response["isOk"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công. Vui lòng đăng nhập.")));

      // Delay 1 chút để user thấy thông báo
      await Future.delayed(const Duration(seconds: 1));

      // Quay về Login
      Navigator.pop(context);

    } else {
      String errorMessage = "Đăng ký thất bại";

      if (response["errors"] != null && response["errors"].length > 0) {
        errorMessage = response["errors"][0]["description"];
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$m/$d/$y';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroImage(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
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
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _usernameController,
                            hintText: 'Nhập tên đăng nhập',
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Họ'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _lastNameController,
                            hintText: 'Nhập họ',
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Tên'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _firstNameController,
                            hintText: 'Nhập tên',
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Ngày sinh'),
                          const SizedBox(height: 8),
                          _buildDateField(),
                          const SizedBox(height: 16),

                          _buildLabel('Giới tính'),
                          const SizedBox(height: 8),
                          _buildGenderDropdown(),
                          const SizedBox(height: 16),

                          _buildLabel('Số CMND/CCCD'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _idController,
                            hintText: 'Nhập số CMND/CCCD',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Số điện thoại'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: 'Nhập số điện thoại',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Email'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'example@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Địa chỉ'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _addressController,
                            hintText: 'Ví dụ: A-1205',
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('Mật khẩu'),
                          const SizedBox(height: 8),
                          _buildPasswordField(),
                          const SizedBox(height: 32),

                          _buildRegisterButton(),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Đã có tài khoản? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).maybePop(),
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF111827),
              size: 24,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Text(
            'Đăng ký tài khoản',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0D0D0D),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF1C1408),
                    Color(0xFF2A1E06),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      const Color(0xFFD97706).withOpacity(0.5),
                      const Color(0xFFB45309).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 2,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.9),
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                      const Color(0xFFFBBF24).withOpacity(0.6),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.1, 0.4, 0.7, 0.88, 1.0],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 40,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFFFDE68A).withOpacity(0.08),
                      const Color(0xFFFDE68A).withOpacity(0.18),
                      const Color(0xFFFBBF24).withOpacity(0.25),
                      const Color(0xFFD97706).withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.15, 0.4, 0.65, 0.85, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedDate != null
                    ? _formatDate(_selectedDate!)
                    : 'mm/dd/yyyy',
                style: TextStyle(
                  fontSize: 15,
                  color: _selectedDate != null
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          hint: const Text(
            'Chọn giới tính',
            style: TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
          ),
          isExpanded: true,
          style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
          items: _genderOptions
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGender = v),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: 'Nhập mật khẩu',
          hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Đăng ký',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
