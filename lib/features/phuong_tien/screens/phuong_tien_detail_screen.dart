// lib/features/phuong_tien/screens/phuong_tien_detail_screen.dart
//
// Màn hình chi tiết một phương tiện.
//   - Nhận [phuongTienId] để gọi PhuongTienService.getPhuongTienById
//   - Nhận [snapshot] (PhuongTien từ list) để hiển thị ngay trong khi chờ API
//   - Hiển thị: hình ảnh, thông tin phương tiện, danh sách thẻ

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';
import '../models/phuong_tien_model.dart';
import '../services/phuong_tien_service.dart';

class PhuongTienDetailScreen extends StatefulWidget {
  final int phuongTienId;

  /// Snapshot từ list — dùng làm title/header ngay khi chưa có data đầy đủ
  final PhuongTien? snapshot;

  const PhuongTienDetailScreen({
    super.key,
    required this.phuongTienId,
    this.snapshot,
  });

  @override
  State<PhuongTienDetailScreen> createState() => _PhuongTienDetailScreenState();
}

class _PhuongTienDetailScreenState extends State<PhuongTienDetailScreen> {
  final _service = PhuongTienService.instance;

  // ── State ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  AppException? _error;
  PhuongTien? _data;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Hiển thị snapshot ngay, sau đó load chi tiết đầy đủ
    _data = widget.snapshot;
    _loadData();
  }

  // ── Service call ───────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getPhuongTienById(widget.phuongTienId);
      setState(() => _data = result);
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final title = _data?.bienSo ?? 'Chi tiết phương tiện';
    final subtitle = _data != null
        ? '${_data!.tenLoaiPhuongTien} • ${_data!.tenPhuongTien}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: const TextStyle(fontSize: 11)),
          ],
        ),
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
    // Lỗi khi không có snapshot (không có gì để hiển thị)
    if (_error != null && _data == null) {
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

    // Không có gì cả
    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final d = _data!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hình ảnh phương tiện ───────────────────────────────────
          if (d.hinhAnhPhuongTiens.isNotEmpty)
            _buildImageSection(d.hinhAnhPhuongTiens),

          // Loading overlay khi đang refresh (có snapshot rồi)
          if (_isLoading) const LinearProgressIndicator(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: biển số + trạng thái ──────────────────
                _buildHeader(d),

                const SizedBox(height: 16),

                // ── Thông tin phương tiện ──────────────────────────
                _SectionCard(
                  title: 'Thông tin phương tiện',
                  children: [
                    _InfoRow(label: 'Biển số', value: d.bienSo),
                    _InfoRow(label: 'Tên', value: d.tenPhuongTien),
                    _InfoRow(label: 'Loại', value: d.tenLoaiPhuongTien),
                    _InfoRow(label: 'Màu xe', value: d.mauXe),
                    _InfoRow(label: 'Vị trí', value: d.viTriNgan),
                    _InfoRow(
                      label: 'Trạng thái',
                      value: d.tenTrangThaiPhuongTien,
                    ),
                  ],
                ),

                // ── Danh sách thẻ ─────────────────────────────────
                if (d.thePhuongTiens.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildTheSection(d.thePhuongTiens),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Image gallery ──────────────────────────────────────────────────────
  Widget _buildImageSection(List<HinhAnhPhuongTien> images) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, i) => Image.network(
          images[i].fileUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  // ── Header: biển số lớn + trạng thái ──────────────────────────────────
  Widget _buildHeader(PhuongTien d) {
    final (bg, text) = switch (d.trangThaiPhuongTienId) {
      1 => (Colors.green.shade50, Colors.green.shade800),
      2 => (Colors.grey.shade100, Colors.grey.shade700),
      _ => (Colors.orange.shade50, Colors.orange.shade800),
    };

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          child: Icon(_loaiIcon(d.loaiPhuongTienId), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.bienSo,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${d.tenLoaiPhuongTien} • ${d.mauXe}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            d.tenTrangThaiPhuongTien,
            style: TextStyle(
              fontSize: 12,
              color: text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Danh sách thẻ phương tiện ─────────────────────────────────────────
  Widget _buildTheSection(List<ThePhuongTien> theList) {
    return _SectionCard(
      title: 'Thẻ phương tiện (${theList.length})',
      children: theList.map((the) {
        final (bg, text) = switch (the.trangThaiThePhuongTienId) {
          1 => (Colors.green.shade50, Colors.green.shade800), // Đang dùng
          2 => (Colors.grey.shade100, Colors.grey.shade600), // Hết hạn
          _ => (Colors.orange.shade50, Colors.orange.shade800),
        };

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.credit_card_outlined, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      the.maThe,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (the.ngayBatDau != null || the.ngayKetThuc != null)
                      Text(
                        [
                          if (the.ngayBatDau != null)
                            'Từ: ${_fmtDate(the.ngayBatDau!)}',
                          if (the.ngayKetThuc != null)
                            'Đến: ${_fmtDate(the.ngayKetThuc!)}',
                        ].join('  '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  the.tenTrangThaiThePhuongTien,
                  style: TextStyle(
                    fontSize: 10,
                    color: text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _loaiIcon(int loaiId) => switch (loaiId) {
    1 => Icons.two_wheeler,
    2 => Icons.directions_car,
    3 => Icons.pedal_bike,
    _ => Icons.commute,
  };

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Reusable widgets ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
