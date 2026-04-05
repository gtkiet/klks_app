// lib/features/cu_tru/screens/quan_he_cu_tru_list_screen.dart

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';
import '../models/quan_he_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import 'cu_tru_detail_screen.dart';

class QuanHeCuTruListScreen extends StatefulWidget {
  const QuanHeCuTruListScreen({super.key});

  @override
  State<QuanHeCuTruListScreen> createState() => _QuanHeCuTruListScreenState();
}

class _QuanHeCuTruListScreenState extends State<QuanHeCuTruListScreen> {
  final _service = CuTruService.instance;

  // ── State ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  AppException? _error;
  List<QuanHeCuTruModel> _list = [];

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData(); // tự động tải khi mở màn hình
  }

  // ── Service call ───────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getQuanHeCuTruList();
      setState(() => _list = result);
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────
  void _goToDetail(QuanHeCuTruModel item, CuTruDetailMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CuTruDetailScreen(item: item, initialMode: mode),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách cư trú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(error: _error!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_list.isEmpty) {
      return const Center(child: Text('Không có dữ liệu cư trú'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) => _CuTruCard(
          item: _list[index],
          onThanhVien: () =>
              _goToDetail(_list[index], CuTruDetailMode.thanhVien),
          onPhuongTien: () =>
              _goToDetail(_list[index], CuTruDetailMode.phuongTien),
        ),
      ),
    );
  }
}

// ── Card item ─────────────────────────────────────────────────────────────
class _CuTruCard extends StatelessWidget {
  final QuanHeCuTruModel item;
  final VoidCallback onThanhVien;
  final VoidCallback onPhuongTien;

  const _CuTruCard({
    required this.item,
    required this.onThanhVien,
    required this.onPhuongTien,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Địa chỉ đầy đủ
            Text(
              item.diaChiDayDu,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // Loại quan hệ + mã căn hộ + tổng cư dân
            Row(
              children: [
                Chip(
                  label: Text(item.loaiQuanHeTen),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text('Mã: ${item.maCanHo}', style: theme.textTheme.bodySmall),
                const Spacer(),
                Icon(Icons.people, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 2),
                Text(
                  '${item.tongCuDan}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            // Ngày bắt đầu
            if (item.ngayBatDau != null) ...[
              const SizedBox(height: 2),
              Text(
                'Từ ngày: ${_fmtDate(item.ngayBatDau!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],

            const Divider(height: 16),

            // 2 nút điều hướng
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onThanhVien,
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('Thành viên'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPhuongTien,
                    icon: const Icon(Icons.directions_car_outlined, size: 18),
                    label: const Text('Phương tiện'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
