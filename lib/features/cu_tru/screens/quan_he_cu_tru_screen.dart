// lib/features/cu_tru/screens/quan_he_cu_tru_screen.dart
//
// Screen 1: Danh sách căn hộ cư trú của user hiện tại.
// Nhấn vào một căn hộ để xem danh sách thành viên đang ở.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/quan_he_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import 'thanh_vien_cu_tru_screen.dart';
import 'yeu_cau_cu_tru_list_screen.dart';

class QuanHeCuTruScreen extends StatefulWidget {
  const QuanHeCuTruScreen({super.key});

  @override
  State<QuanHeCuTruScreen> createState() => _QuanHeCuTruScreenState();
}

class _QuanHeCuTruScreenState extends State<QuanHeCuTruScreen> {
  final _service = CuTruService();

  List<QuanHeCuTruModel> _list = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getQuanHeCuTruList();
      setState(() => _list = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Căn hộ cư trú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Yêu cầu cư trú',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const YeuCauCuTruListScreen()),
            ),
          ),
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

    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _loadData);
    }

    if (_list.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu cư trú.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) => _CanHoCard(
          item: _list[index],
          onTap: () => _navigateToThanhVien(_list[index]),
        ),
      ),
    );
  }

  void _navigateToThanhVien(QuanHeCuTruModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThanhVienCuTruScreen(
          canHoId: item.canHoId,
          tenCanHo: item.tenCanHo,
        ),
      ),
    );
  }
}

// ─── Card widget ─────────────────────────────────────────────────────────────

class _CanHoCard extends StatelessWidget {
  final QuanHeCuTruModel item;
  final VoidCallback onTap;

  const _CanHoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ngay = item.ngayBatDau != null
        ? DateFormat('dd/MM/yyyy').format(item.ngayBatDau!)
        : '---';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            item.maCanHo.isNotEmpty ? item.maCanHo[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.tenCanHo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.diaChiDayDu),
            const SizedBox(height: 2),
            Text(
              'Quan hệ: ${item.loaiQuanHeTen} · Bắt đầu: $ngay',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                '${item.tongCuDan} người',
                style: const TextStyle(fontSize: 11),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
