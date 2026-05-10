// lib/features/cu_tru/screens/quan_he_cu_tru_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  List<QuanHeCuTruModel> _list = [];

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Service call ───────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final result = await _service.getQuanHeCuTruList();
      setState(() => _list = result);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────
  void _goToDetail(QuanHeCuTruModel item, CuTruDetailMode mode) {
    context.push(
      '/cu-tru/detail',
      extra: CuTruDetailArgs(item: item, initialMode: mode),
    );
  }

  void _goToHoaDon(QuanHeCuTruModel item) {
    context.push(
      '/cu-tru/hoa-don',
      extra: {
        'canHoId': item.canHoId,
        'tenCanHo': item.tenCanHo,
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
          onHoaDon: () => _goToHoaDon(_list[index]),
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
  final VoidCallback onHoaDon;

  const _CuTruCard({
    required this.item,
    required this.onThanhVien,
    required this.onPhuongTien,
    required this.onHoaDon,
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
            Text(
              item.diaChiDayDu,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

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
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onHoaDon,
                    icon: const Icon(Icons.receipt, size: 18),
                    label: const Text('Hóa đơn'),
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