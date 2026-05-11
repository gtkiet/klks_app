// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/storage/user_session.dart';
import '../../../features/thong_bao/widgets/thong_bao_bell_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fullName = UserSession.instance.fullName ?? 'Người dùng';

    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
        actions: [const ThongBaoBellIcon(), const SizedBox(width: 4)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UserInfo(fullName: fullName),
          const SizedBox(height: 32),

          const _SectionTitle('Tiện ích'),
          const SizedBox(height: 8),
          const _TienIchGrid(),
          const SizedBox(height: 32),

          const _SectionTitle('Truy cập nhanh'),
          const SizedBox(height: 8),
          const _QuickTabRow(),
          const SizedBox(height: 32),

          const _SectionTitle('Test chức năng'),
          const SizedBox(height: 8),
          _NavButton(
            label: 'Phản ánh',
            onPressed: () => context.push('/home/phan-anh'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── User info ─────────────────────────────────────────────────────────────────
//
// fullName: đọc sync từ session, không cần lắng nghe (chưa có chức năng đổi tên)
// avatar:   dùng ValueListenableBuilder vì có chức năng đổi ảnh từ ProfileScreen

class _UserInfo extends StatelessWidget {
  final String fullName;
  const _UserInfo({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: UserSession.instance.anhDaiDienUrlNotifier,
          builder: (context, url, _) => CircleAvatar(
            radius: 32,
            backgroundImage: url != null ? NetworkImage(url) : null,
            child: url == null ? const Icon(Icons.person, size: 32) : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tiện ích grid ─────────────────────────────────────────────────────────────

class _TienIchGrid extends StatelessWidget {
  const _TienIchGrid();

  static const _items = [
    (
      icon: Icons.miscellaneous_services_outlined,
      label: 'Dịch vụ',
      go: AppNavigation.goTienIchDichVu,
    ),
    (
      icon: Icons.build_outlined,
      label: 'Sửa chữa',
      go: AppNavigation.goTienIchSuaChua,
    ),
    (
      icon: Icons.construction_outlined,
      label: 'Thi công',
      go: AppNavigation.goTienIchThiCong,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final color   = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).colorScheme.primaryContainer;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: _items
          .map(
            (e) => InkWell(
              onTap: e.go,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(e.icon, size: 32, color: color),
                    const SizedBox(height: 8),
                    Text(
                      e.label,
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
            ),
          )
          .toList(),
    );
  }
}

// ── Quick tab row ─────────────────────────────────────────────────────────────

class _QuickTabRow extends StatelessWidget {
  const _QuickTabRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickChip(
          icon: Icons.apartment_outlined,
          label: 'Cư trú',
          onTap: AppNavigation.goResidence,
        ),
        const SizedBox(width: 8),
        _QuickChip(
          icon: Icons.notifications_outlined,
          label: 'Thông báo',
          onTap: AppNavigation.goNotification,
        ),
        const SizedBox(width: 8),
        _QuickChip(
          icon: Icons.person_outline,
          label: 'Cá nhân',
          onTap: AppNavigation.goProfile,
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}