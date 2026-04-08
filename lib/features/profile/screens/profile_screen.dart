// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _service = ProfileService.instance;

  String? _fullName;
  String? _email;
  String? _role;
  String? _anhDaiDienUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromSession();
  }

  Future<void> _loadFromSession() async {
    final data = await _service.getSessionProfile();

    setState(() {
      _fullName = data['fullName'];
      _email = data['email'];
      _role = data['role'];
      _anhDaiDienUrl = data['anhDaiDienUrl'];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Xem chi tiết',
            onPressed: () => context.push('/profile/detail'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _anhDaiDienUrl != null
                  ? NetworkImage(_anhDaiDienUrl!)
                  : null,
              child: _anhDaiDienUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          Text('Họ tên: ${_fullName ?? ''}'),
          Text('Email: ${_email ?? ''}'),
          Text('Vai trò: ${_role ?? ''}'),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => context.push('/profile/detail'),
            child: const Text('Xem chi tiết hồ sơ'),
          ),

          ElevatedButton(
            onPressed: () => context.push('/profile/change-password'),
            child: const Text('Đổi mật khẩu'),
          ),

          ElevatedButton(
            onPressed: () => context.push('/profile/change-avatar'),
            child: const Text('Đổi ảnh đại diện'),
          ),
        ],
      ),
    );
  }
}
