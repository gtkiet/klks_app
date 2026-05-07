// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đăng xuất')),
    );
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
            const SizedBox(height: 32),

            /// ── Tiện ích ──
            _sectionTitle('Tiện ích'),
            const SizedBox(height: 8),
            _buildTienIchGrid(),
            const SizedBox(height: 32),

            /// ── Chuyển tab nhanh ──
            _sectionTitle('Truy cập nhanh'),
            const SizedBox(height: 8),
            _quickTabRow(),
            const SizedBox(height: 32),

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
      ),
    );
  }

  // ── User info ──────────────────────────────────────────────

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: _data?.anhDaiDienUrl != null
              ? NetworkImage(_data!.anhDaiDienUrl!)
              : null,
          child: _data?.anhDaiDienUrl == null
              ? const Icon(Icons.person, size: 32)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _data?.fullName ?? 'Chưa có tên',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Thêm subtitle nếu HomeData có (email, căn hộ, v.v.)
              // Text(_data?.canHo ?? '', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tiện ích grid ──────────────────────────────────────────

  Widget _buildTienIchGrid() {
    final items = [
      _TienIchItem(
        icon: Icons.miscellaneous_services_outlined,
        label: 'Dịch vụ',
        onTap: AppNavigation.goTienIchDichVu,
      ),
      _TienIchItem(
        icon: Icons.build_outlined,
        label: 'Sửa chữa',
        onTap: AppNavigation.goTienIchSuaChua,
      ),
      _TienIchItem(
        icon: Icons.construction_outlined,
        label: 'Thi công',
        onTap: AppNavigation.goTienIchThiCong,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: items.map(_buildGridItem).toList(),
    );
  }

  Widget _buildGridItem(_TienIchItem item) {
    final color = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).colorScheme.primaryContainer;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick tab row ──────────────────────────────────────────

  Widget _quickTabRow() {
    return Row(
      children: [
        _quickTabChip(
          icon: Icons.apartment_outlined,
          label: 'Cư trú',
          onTap: AppNavigation.goResidence,
        ),
        const SizedBox(width: 8),
        _quickTabChip(
          icon: Icons.notifications_outlined,
          label: 'Thông báo',
          onTap: AppNavigation.goNotification,
        ),
        const SizedBox(width: 8),
        _quickTabChip(
          icon: Icons.person_outline,
          label: 'Cá nhân',
          onTap: AppNavigation.goProfile,
        ),
      ],
    );
  }

  Widget _quickTabChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );
}

class _TienIchItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TienIchItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}