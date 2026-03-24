import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/loading/app_loading.dart';
import '../services/profile_service.dart';
import '../model/user_profile.dart';
import '../../../core/errors/app_exception.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final ProfileService _service = ProfileService();

  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _dob;
  int _gioiTinhId = 1; // 1=Nam,2=Nữ

  // Avatar & Save loading
  final ValueNotifier<bool> _avatarLoading = ValueNotifier(false);
  final ValueNotifier<bool> _saving = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    _avatarLoading.dispose();
    _saving.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadProfile() async {
    try {
      setState(() => _loading = true);
      final profile = await _service.getProfile();
      if (!mounted) return;

      _profile = profile;
      _firstNameController.text = profile?.firstName ?? '';
      _lastNameController.text = profile?.lastName ?? '';
      _emailController.text = profile?.email ?? '';
      _phoneController.text = profile?.phoneNumber ?? '';
      _idCardController.text = profile?.idCard ?? '';
      _addressController.text = profile?.diaChi ?? '';
      _dob = profile?.dob;
      _gioiTinhId = profile?.gioiTinhId ?? 1;
    } catch (e) {
      _error = e is AppException ? e.message : 'Đã xảy ra lỗi';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      if (result != null && _profile != null) {
        _avatarLoading.value = true;
        final newUrl = await _service.changeAvatar(File(result.path));
        if (newUrl != null) {
          _profile = _profile!.copyWith(anhDaiDienUrl: newUrl);
        }
        _avatarLoading.value = false;
        setState(() {}); // rebuild avatar
      }
    } catch (e) {
      _avatarLoading.value = false;
      _showError(e);
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;
    _saving.value = true;
    try {
      final updated = await _service.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        idCard: _idCardController.text,
        diaChi: _addressController.text,
        dob: _dob ?? DateTime(2000, 1, 1),
        gioiTinhId: _gioiTinhId,
      );
      _profile = updated;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );
      setState(() {});
    } catch (e) {
      _showError(e);
    } finally {
      _saving.value = false;
    }
  }

  void _showError(Object e) {
    final msg = e is AppException ? e.message : 'Đã xảy ra lỗi';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) return const Scaffold(body: AppLoading());

    if (_error != null) {
      return _ErrorView(
        message: _error!,
        onRetry: () {
          setState(() {
            _error = null;
            _loading = true;
          });
          _loadProfile();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _saving,
            builder: (context, saving, _) {
              return IconButton(
                icon: saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                onPressed: saving ? null : _saveProfile,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: _avatarLoading,
              builder: (context, loading, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profile?.anhDaiDienUrl != null
                            ? NetworkImage(_profile!.anhDaiDienUrl!)
                            : null,
                        child: _profile?.anhDaiDienUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                    ),
                    if (loading)
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black38,
                        child: AppLoading(size: 30),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${_firstNameController.text} ${_lastNameController.text}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField('Họ', _firstNameController),
          _buildTextField('Tên', _lastNameController),
          _buildTextField(
            'Email',
            _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            'Số điện thoại',
            _phoneController,
            keyboardType: TextInputType.phone,
          ),
          _buildTextField('CMND/CCCD', _idCardController),
          _buildTextField('Địa chỉ', _addressController),
          const SizedBox(height: 16),

          // Gender
          Row(
            children: [
              const Text('Giới tính:'),
              Radio<int>(
                value: 1,
                groupValue: _gioiTinhId,
                onChanged: (v) => setState(() => _gioiTinhId = v ?? 1),
              ),
              const Text('Nam'),
              Radio<int>(
                value: 2,
                groupValue: _gioiTinhId,
                onChanged: (v) => setState(() => _gioiTinhId = v ?? 2),
              ),
              const Text('Nữ'),
            ],
          ),
          const SizedBox(height: 16),

          // DOB
          Row(
            children: [
              const Text('Ngày sinh:'),
              const SizedBox(width: 16),
              Text(_dob != null
                  ? '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}'
                  : ''),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _dob ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (selected != null) setState(() => _dob = selected);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration:
            InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}

/// Error View
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      ),
    );
  }
}