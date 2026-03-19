import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/user_profile.dart';
import '../services/profile_service.dart';
import '../../../widgets/form_field.dart';
import '../../../widgets/app_button.dart';

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
    _selectedGender = widget.profile.gioiTinhName;
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
      final updated = await ProfileService.updateProfile(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        idCard: idCardCtrl.text.trim(),
        dob: dob!,
        gioiTinhId: _getGenderId(),
        diaChi: addressCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));

      Navigator.pop(context, updated);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
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
                  const LabelText(text: "Họ"),
                  CustomTextField(
                    controller: lastNameCtrl,
                    hintText: "Họ",
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  const LabelText(text: "Tên"),
                  CustomTextField(
                    controller: firstNameCtrl,
                    hintText: "Tên",
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  const LabelText(text: "Số điện thoại"),
                  CustomTextField(
                    controller: phoneCtrl,
                    hintText: "Số điện thoại",
                    keyboardType: TextInputType.phone,
                    validator: _phoneValidator,
                  ),
                  const SizedBox(height: 16),
                  const LabelText(text: "CCCD"),
                  CustomTextField(
                    controller: idCardCtrl,
                    hintText: "CCCD",
                    keyboardType: TextInputType.number,
                    validator: _idValidator,
                  ),
                  const SizedBox(height: 16),
                  const LabelText(text: "Địa chỉ"),
                  CustomTextField(
                    controller: addressCtrl,
                    hintText: "Địa chỉ",
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  const LabelText(text: "Ngày sinh"),
                  DateField(
                    selectedDate: dob,
                    onTap: _pickDate,
                    placeholder: "Chọn ngày sinh",
                  ),
                  const SizedBox(height: 16),
                  const LabelText(text: "Giới tính"),
                  DropdownField<String>(
                    selectedValue: _selectedGender,
                    options: _genderOptions,
                    onChanged: (value) =>
                        setState(() => _selectedGender = value),
                    hint: 'Chọn giới tính',
                  ),
                  const SizedBox(height: 30),

                  /// ===== ACTION BUTTONS =====
                  EditButton(onPressed: _submit, isLoading: isLoading),
                  const SizedBox(height: 16),
                  CancelButton(onPressed: () => Navigator.pop(context)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          /// LOADING OVERLAY
          if (isLoading) Container(color: Colors.black.withOpacity(0.1)),
        ],
      ),
    );
  }
}
