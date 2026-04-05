// lib/features/cu_tru/screens/chon_thanh_vien_screen.dart
//
// Màn hình chọn thành viên — dùng cho flow Sửa và Xóa.
// Gọi POST /api/cu-dan/thanh-vien-cu-tru, hiển thị danh sách,
// trả về ThanhVienCuTruModel khi user chọn.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/thanh_vien_cu_tru_model.dart';
import '../services/cu_tru_service.dart';

class ChonThanhVienScreen extends StatefulWidget {
  final int canHoId;
  final String tenCanHo;
  final String title;

  const ChonThanhVienScreen({
    super.key,
    required this.canHoId,
    required this.tenCanHo,
    this.title = 'Chọn thành viên',
  });

  @override
  State<ChonThanhVienScreen> createState() => _ChonThanhVienScreenState();
}

class _ChonThanhVienScreenState extends State<ChonThanhVienScreen> {
  final _service = CuTruService();

  List<ThanhVienCuTruModel> _list = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _service.getThanhVienCuTru(widget.canHoId);
      setState(() => _list = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.tenCanHo,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    if (_list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Không có thành viên nào đang cư trú.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Hint bar
        Container(
          width: double.infinity,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(
            children: [
              Icon(Icons.touch_app_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Nhấn vào thành viên để chọn',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _list.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) => _MemberSelectTile(
              item: _list[i],
              onSelect: () => Navigator.pop(context, _list[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberSelectTile extends StatelessWidget {
  final ThanhVienCuTruModel item;
  final VoidCallback onSelect;

  const _MemberSelectTile({required this.item, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final ngay = item.ngayBatDau != null
        ? DateFormat('dd/MM/yyyy').format(item.ngayBatDau!)
        : '---';

    return ListTile(
      onTap: onSelect,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: item.anhDaiDienUrl != null
            ? NetworkImage(item.anhDaiDienUrl!)
            : null,
        child: item.anhDaiDienUrl == null
            ? Text(
                item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            : null,
      ),
      title: Text(
        item.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${item.loaiQuanHeTen} · Từ $ngay',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Chọn',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
