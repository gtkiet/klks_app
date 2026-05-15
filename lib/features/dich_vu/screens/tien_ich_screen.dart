// lib/features/tien_ich/screens/tien_ich_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TienIchScreen extends StatelessWidget {
  const TienIchScreen({super.key});

  static const _items = [
    _TienIchMeta(
      icon: Icons.miscellaneous_services_outlined,
      label: 'Dịch vụ',
      description: 'Đăng ký và quản lý dịch vụ',
      route: '/tien-ich/dich-vu',
    ),
    _TienIchMeta(
      icon: Icons.build_outlined,
      label: 'Sửa chữa',
      description: 'Yêu cầu sửa chữa thiết bị, hạ tầng',
      route: '/tien-ich/sua-chua',
    ),
    _TienIchMeta(
      icon: Icons.construction_outlined,
      label: 'Thi công',
      description: 'Yêu cầu thi công, cải tạo',
      route: '/tien-ich/thi-cong',
    ),
    _TienIchMeta(
      icon: Icons.receipt_outlined,
      label: 'Hóa đơn',
      description: 'Hóa đơn thanh toán',
      route: '/tien-ich/hoa-don',
    ),
    _TienIchMeta(
      icon: Icons.feedback_outlined,
      label: 'Phản ánh',
      description: 'Phản ánh',
      route: '/tien-ich/phan-anh',
    ),
    _TienIchMeta(
      icon: Icons.poll_outlined,
      label: 'Khảo sát',
      description: 'Khảo sát',
      route: '/tien-ich/khao-sat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiện ích')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _TienIchCard(meta: _items[i]),
      ),
    );
  }
}

// ── Card ────────────────────────────────────────────────────

class _TienIchCard extends StatelessWidget {
  final _TienIchMeta meta;
  const _TienIchCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).colorScheme.primaryContainer;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(meta.icon, color: color),
        ),
        title: Text(
          meta.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(meta.description),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(meta.route),
      ),
    );
  }
}

// ── Data class ──────────────────────────────────────────────

class _TienIchMeta {
  final IconData icon;
  final String label;
  final String description;
  final String route;

  const _TienIchMeta({
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
  });
}
