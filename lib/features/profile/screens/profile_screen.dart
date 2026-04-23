// // lib/features/profile/screens/profile_screen.dart

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../services/profile_service.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final ProfileService _service = ProfileService.instance;

//   String? _fullName;
//   String? _email;
//   String? _role;
//   String? _anhDaiDienUrl;
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadFromSession();
//   }

//   Future<void> _loadFromSession() async {
//     final data = await _service.getSessionProfile();

//     setState(() {
//       _fullName = data['fullName'];
//       _email = data['email'];
//       _role = data['role'];
//       _anhDaiDienUrl = data['anhDaiDienUrl'];
//       _loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trang cá nhân'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             tooltip: 'Xem chi tiết',
//             onPressed: () => context.push('/profile/detail'),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Center(
//             child: CircleAvatar(
//               radius: 40,
//               backgroundImage: _anhDaiDienUrl != null
//                   ? NetworkImage(_anhDaiDienUrl!)
//                   : null,
//               child: _anhDaiDienUrl == null
//                   ? const Icon(Icons.person, size: 40)
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 16),

//           Text('Họ tên: ${_fullName ?? ''}'),
//           Text('Email: ${_email ?? ''}'),
//           Text('Vai trò: ${_role ?? ''}'),

//           const SizedBox(height: 24),

//           ElevatedButton(
//             onPressed: () => context.push('/profile/detail'),
//             child: const Text('Xem chi tiết hồ sơ'),
//           ),

//           ElevatedButton(
//             onPressed: () => context.push('/profile/change-password'),
//             child: const Text('Đổi mật khẩu'),
//           ),

//           ElevatedButton(
//             onPressed: () => context.push('/profile/change-avatar'),
//             child: const Text('Đổi ảnh đại diện'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_navigation.dart';
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

  /// Switch sang tab khác (không push, không có nút back)
  void _switchTab(int tabIndex) {
    AppNavigation.goTab(tabIndex);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Xem chi tiết',
            onPressed: () => _pushInProfileTab('/profile/detail'),
          ),
        ],
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
          _SectionTitle(text: 'Màn hình trong tab Profile (có nút back)'),
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

          /// SWITCH SANG TAB KHÁC (không có nút back)
          _SectionTitle(text: 'Chuyển sang tab khác (không có nút back)'),
          _NavButton(
            label: 'Về trang chủ → Tab Home',
            onPressed: () => _switchTab(0),
          ),
          _NavButton(
            label: 'Căn hộ của tôi → Tab Cư trú',
            onPressed: () => _switchTab(1),
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
  // final Color? color;

  // const _NavButton({required this.label, required this.onPressed, this.color});
  const _NavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onPressed,
        // style: color != null
        //     ? ElevatedButton.styleFrom(backgroundColor: color)
        //     : null,
        child: Text(label),
      ),
    );
  }
}
