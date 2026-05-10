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

  // ================= NAVIGATION =================

  /// Push 1 screen vào stack của tab Profile (có nút back)
  void _pushInProfileTab(String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  // Đăng xuất (xóa session) và show snackbar
  Future<void> _logout() async {
    await _service.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.info_outline),
        //     tooltip: 'Xem chi tiết',
        //     onPressed: () => _pushInProfileTab('/profile/detail'),
        //   ),
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// AVATAR
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

          /// PUSH VÀO STACK CỦA TAB PROFILE (có nút back)
          _SectionTitle(text: 'Chức năng'),
          _NavButton(
            label: 'Xem chi tiết hồ sơ',
            onPressed: () => _pushInProfileTab('/profile/detail'),
          ),
          _NavButton(
            label: 'Đổi mật khẩu',
            onPressed: () => _pushInProfileTab('/profile/change-password'),
          ),
          _NavButton(
            label: 'Đổi ảnh đại diện',
            onPressed: () => _pushInProfileTab('/profile/change-avatar'),
          ),

          const SizedBox(height: 16),

          /// ── Đăng xuất ──
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const _NavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
