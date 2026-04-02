// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_navigation.dart';

import '../services/home_service.dart';
import '../models/home_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = HomeService();

  bool _isLoading = true;
  String? _error;
  HomeData? _data;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  // ================= DATA =================

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _data = await _service.getHomeData();
    } catch (e) {
      _error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _service.logout();
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out')));

    /// global route OK
    context.go('/login');
  }

  // ================= NAVIGATION =================

  /// Push trong cùng tab
  void _push(String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  /// Switch tab
  void _goTab(int index) {
    AppNavigation.goTab(index);
  }

  // /// 🔥 Cross-tab navigation chuẩn (KHÔNG BUG)
  // void _goToProfileSubRoute(String subRoute) {
  //   AppNavigation.goTab(2);

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!mounted) return;
  //     context.push('/profile/$subRoute');
  //   });
  // }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _button({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onPressed,
        style: color != null
            ? ElevatedButton.styleFrom(backgroundColor: color)
            : null,
        child: Text(label),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: _data?.avatarUrl != null
                ? NetworkImage(_data!.avatarUrl!)
                : null,
            child: _data?.avatarUrl == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            _data?.fullName ?? 'No name',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// USER
          _buildUserInfo(),

          const SizedBox(height: 24),

          /// FEATURES
          _sectionTitle('Features (Push in stack)'),
          _button(
            label: 'Căn hộ của tôi',
            onPressed: () => _push('/residence'),
          ),
          _button(label: 'Hóa đơn', onPressed: () => _push('/bills')),
          _button(label: 'Dịch vụ', onPressed: () => _push('/services')),
          _button(
            label: 'Thông báo (push)',
            onPressed: () => _push('/notification'),
          ),
          _button(label: 'Phương tiện', onPressed: () => _push('/phuong-tien')),

          const SizedBox(height: 16),

          /// TAB NAVIGATION
          _sectionTitle('Tab Navigation'),
          _button(label: 'Go to Profile Tab', onPressed: () => _goTab(2)),
          _button(label: 'Go to Notification Tab', onPressed: () => _goTab(1)),

          const SizedBox(height: 24),

          /// DEBUG
          _sectionTitle('Raw Data'),
          Text(_data.toString()),

          const SizedBox(height: 24),

          /// ACTIONS
          _button(label: 'Reload API', onPressed: _fetch),
          _button(label: 'Logout', onPressed: _logout, color: Colors.red),
        ],
      ),
    );
  }
}
