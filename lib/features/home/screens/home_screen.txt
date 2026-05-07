// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/home_data.dart';

import '../services/home_service.dart';

import '../../../core/navigation/app_navigation.dart';

import '../../../features/thong_bao/widgets/thong_bao_bell_icon.dart';

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
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await _service.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã đăng xuất')));
    context.go('/login');
  }

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
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetch,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_data?.fullName ?? 'Trang chủ'),
        actions: [
          // Caller truyền navigate — widget không tự hard-code route
          // ThongBaoBellIcon(onPressed: AppNavigation.goNotification),
          ThongBaoBellIcon(),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildUserInfo(),
            const SizedBox(height: 24),

            _sectionTitle('Dịch vụ & yêu cầu'),
            _navButton(label: 'Dịch vụ', route: '/dich-vu'),
            _navButton(label: 'Yêu cầu sửa chữa', route: '/sua-chua'),
            _navButton(label: 'Yêu cầu thi công', route: '/thi-cong'),

            const SizedBox(height: 16),

            _sectionTitle('Chuyển tab'),
            _tabButton(
              label: 'Căn hộ của tôi',
              onPressed: AppNavigation.goResidence,
            ),
            _tabButton(
              label: 'Thông báo',
              onPressed: AppNavigation.goNotification,
            ),
            _tabButton(
              label: 'Trang cá nhân',
              onPressed: AppNavigation.goProfile,
            ),

            const SizedBox(height: 24),

            _sectionTitle('Debug'),
            Text(_data.toString()),

            const SizedBox(height: 24),

            _tabButton(label: 'Reload', onPressed: _fetch),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
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
            _data?.fullName ?? 'Chưa có tên',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  Widget _navButton({required String label, required String route}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: ElevatedButton(
      onPressed: () => context.push(route),
      child: Text(label),
    ),
  );

  Widget _tabButton({required String label, required VoidCallback onPressed}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ElevatedButton(onPressed: onPressed, child: Text(label)),
      );
}
