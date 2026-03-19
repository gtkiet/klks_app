import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/user_profile.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController idCardCtrl;
  late TextEditingController addressCtrl;

  DateTime? dob;
  int gioiTinhId = 1;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    firstNameCtrl = TextEditingController(text: widget.profile.firstName);
    lastNameCtrl = TextEditingController(text: widget.profile.lastName);
    phoneCtrl = TextEditingController(text: widget.profile.phoneNumber);
    idCardCtrl = TextEditingController(text: widget.profile.idCard);
    addressCtrl = TextEditingController(text: widget.profile.diaChi);

    dob = widget.profile.dob;
    gioiTinhId = widget.profile.gioiTinhId ?? 1;
  }

  /// =========================
  /// PICK DATE
  /// =========================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => dob = picked);
    }
  }

  /// =========================
  /// SUBMIT
  /// =========================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || dob == null) {
      if (dob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn ngày sinh")),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      final provider = context.read<ProfileProvider>();
      final success = await provider.updateProfile(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        idCard: idCardCtrl.text.trim(),
        dob: dob!,
        gioiTinhId: gioiTinhId,
        diaChi: addressCtrl.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công')),
        );
        Navigator.pop(context, provider.profile);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? "Cập nhật thất bại")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// =========================
  /// VALIDATORS
  /// =========================
  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? "Không được bỏ trống" : null;

  String? _phoneValidator(String? v) {
    if (v == null || v.isEmpty) return "Không được bỏ trống";
    if (!RegExp(r'^[0-9]{9,11}$').hasMatch(v)) {
      return "SĐT không hợp lệ";
    }
    return null;
  }

  String? _idValidator(String? v) {
    if (v == null || v.isEmpty) return "Không được bỏ trống";
    if (!RegExp(r'^[0-9]{9,12}$').hasMatch(v)) {
      return "CCCD không hợp lệ";
    }
    return null;
  }

  /// =========================
  /// UI HELPERS
  /// =========================
  Widget _input({
    required String label,
    required TextEditingController ctrl,
    String? Function(String?)? validator,
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        validator: validator ?? _required,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật hồ sơ')),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _section("Thông tin cá nhân"),
                  _input(label: "Họ", ctrl: firstNameCtrl),
                  _input(label: "Tên", ctrl: lastNameCtrl),
                  _section("Liên hệ"),
                  _input(
                    label: "Số điện thoại",
                    ctrl: phoneCtrl,
                    validator: _phoneValidator,
                    type: TextInputType.phone,
                  ),
                  _input(
                    label: "CCCD",
                    ctrl: idCardCtrl,
                    validator: _idValidator,
                    type: TextInputType.number,
                  ),
                  _input(label: "Địa chỉ", ctrl: addressCtrl),
                  _section("Khác"),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    title: Text(
                      dob == null ? "Chọn ngày sinh" : dateFormat.format(dob!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: gioiTinhId,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Nam')),
                      DropdownMenuItem(value: 2, child: Text('Nữ')),
                      DropdownMenuItem(value: 3, child: Text('Khác')),
                    ],
                    onChanged: (v) => setState(() => gioiTinhId = v ?? 1),
                    decoration: InputDecoration(
                      labelText: "Giới tính",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Cập nhật",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) Container(color: Colors.black.withOpacity(0.1)),
        ],
      ),
    );
  }
}