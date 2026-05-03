// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../features/thong_bao/services/thong_bao_hub_service.dart';
import '../services/home_service.dart';
import '../models/home_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = HomeService.instance;

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
    context.go('/login');
  }

  // ================= NAVIGATION =================

  void _pushInHomeTab(String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

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
            backgroundImage: _data?.anhDaiDienUrl != null
                ? NetworkImage(_data!.anhDaiDienUrl!)
                : null,
            child: _data?.anhDaiDienUrl == null
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

  Widget _buildNotificationButton() {
    return StreamBuilder<int>(
      stream: ThongBaoHubService.instance.onUnreadCountChanged,
      initialData: 0,
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return IconButton(
          tooltip: 'Thông báo',
          onPressed: () => AppNavigation.goNotification(),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(
              unread > 99 ? '99+' : '$unread',
              style: const TextStyle(fontSize: 10),
            ),
            child: const Icon(Icons.notifications_outlined),
          ),
        );
      },
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_data?.fullName ?? 'Trang chủ'),
        actions: [_buildNotificationButton()],
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// USER INFO
            _buildUserInfo(),

            const SizedBox(height: 24),

            /// PUSH VÀO STACK CỦA TAB HOME (có nút back)
            _sectionTitle('Màn hình trong tab Home (có nút back)'),
            _button(
              label: 'Dịch vụ',
              onPressed: () => _pushInHomeTab('/dich-vu'),
            ),
            _button(
              label: 'Yêu cầu sửa chữa',
              onPressed: () => _pushInHomeTab('/sua-chua'),
            ),
            _button(
              label: 'Yêu cầu thi công',
              onPressed: () => _pushInHomeTab('/thi-cong'),
            ),

            const SizedBox(height: 16),

            /// SWITCH SANG TAB KHÁC (không có nút back)
            _sectionTitle('Chuyển sang tab khác (không có nút back)'),
            _button(
              label: 'Căn hộ của tôi → Tab Cư trú',
              onPressed: () => AppNavigation.goResidence(),
            ),
            _button(
              label: 'Thông báo → Tab Thông báo',
              onPressed: () => AppNavigation.goNotification(),
            ),
            _button(
              label: 'Trang cá nhân → Tab Profile',
              onPressed: () => AppNavigation.goProfile(),
            ),

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
      ),
    );
  }
}
