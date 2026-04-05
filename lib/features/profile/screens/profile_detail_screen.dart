// lib/features/profile/screens/profile_detail_screen.dart

import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../model/user_profile.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final ProfileService _service = ProfileService();

  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final data = await _service.getProfile();

      setState(() => _profile = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết hồ sơ')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final p = _profile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hồ sơ'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: p.anhDaiDienUrl != null
                  ? NetworkImage(p.anhDaiDienUrl!)
                  : null,
              child: p.anhDaiDienUrl == null
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          _InfoTile(label: 'Họ', value: p.lastName),
          _InfoTile(label: 'Tên', value: p.firstName),
          _InfoTile(label: 'Tên đăng nhập', value: p.username),
          _InfoTile(label: 'Email', value: p.email),
          _InfoTile(label: 'Số điện thoại', value: p.phoneNumber ?? '—'),
          _InfoTile(label: 'Địa chỉ', value: p.diaChi ?? '—'),
          _InfoTile(label: 'Giới tính', value: p.gioiTinhName ?? '—'),
          _InfoTile(
            label: 'Ngày sinh',
            value: p.dob != null
                ? '${p.dob!.day}/${p.dob!.month}/${p.dob!.year}'
                : '—',
          ),
          _InfoTile(label: 'Vai trò', value: p.roles.join(', ')),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
