// lib/features/phuong_tien/screens/chi_tiet_phuong_tien_screen.dart

import 'package:flutter/material.dart';
import '../models/phuong_tien_models.dart';
import '../services/phuong_tien_service.dart';

class ChiTietPhuongTienScreen extends StatefulWidget {
  final int phuongTienId;

  const ChiTietPhuongTienScreen({super.key, required this.phuongTienId});

  @override
  State<ChiTietPhuongTienScreen> createState() =>
      _ChiTietPhuongTienScreenState();
}

class _ChiTietPhuongTienScreenState extends State<ChiTietPhuongTienScreen> {
  final _service = PhuongTienService();

  PhuongTien? _phuongTien;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBaoMatLoading = false;
  final Set<int> _selectedTheIds = {};

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
      final result = await _service.getPhuongTienById(widget.phuongTienId);
      if (mounted) {
        setState(() {
          _phuongTien = result;
          _isLoading = false;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _baoMatThe() async {
    if (_selectedTheIds.isEmpty) {
      _showSnackBar('Chọn ít nhất một thẻ để báo mất', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận báo mất thẻ'),
        content: Text(
          'Bạn có chắc muốn báo mất ${_selectedTheIds.length} thẻ?\n'
          'Hệ thống sẽ khóa ngay lập tức.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Báo mất'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBaoMatLoading = true);

    try {
      await _service.baoMatThe(_selectedTheIds.toList());
      if (mounted) {
        _showSnackBar(
          'Đã báo mất và khóa ${_selectedTheIds.length} thẻ thành công',
        );
        _selectedTheIds.clear();
        // Reload để lấy trạng thái mới
        _loadData();
      }
    } on AppException catch (e) {
      if (mounted) {
        _showSnackBar(e.message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isBaoMatLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_phuongTien?.tenPhuongTien ?? 'Chi tiết phương tiện'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final pt = _phuongTien!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Thông tin chính
        _SectionCard(
          title: 'Thông tin phương tiện',
          child: Column(
            children: [
              _InfoRow(label: 'Tên xe', value: pt.tenPhuongTien),
              _InfoRow(label: 'Loại xe', value: pt.tenLoaiPhuongTien),
              _InfoRow(label: 'Biển số', value: pt.bienSo),
              _InfoRow(label: 'Màu xe', value: pt.mauXe),
              _InfoRow(
                label: 'Trạng thái',
                value: pt.tenTrangThaiPhuongTien,
                valueColor: pt.trangThaiPhuongTienId == 1
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Vị trí
        _SectionCard(
          title: 'Vị trí',
          child: Column(
            children: [
              _InfoRow(label: 'Tòa nhà', value: pt.maToaNha),
              _InfoRow(label: 'Tầng', value: pt.maTang),
              _InfoRow(label: 'Căn hộ', value: pt.maCanHo),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Hình ảnh
        if (pt.hinhAnhPhuongTiens.isNotEmpty) ...[
          _SectionCard(
            title: 'Hình ảnh (${pt.hinhAnhPhuongTiens.length})',
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: pt.hinhAnhPhuongTiens.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final img = pt.hinhAnhPhuongTiens[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      img.fileUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Danh sách thẻ xe
        _SectionCard(
          title: 'Thẻ xe (${pt.thePhuongTiens.length})',
          trailing: _selectedTheIds.isNotEmpty
              ? _isBaoMatLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: _baoMatThe,
                        icon: const Icon(Icons.lock, size: 16),
                        label: Text('Báo mất (${_selectedTheIds.length})'),
                      )
              : null,
          child: pt.thePhuongTiens.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Chưa có thẻ xe nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: pt.thePhuongTiens
                      .map(
                        (the) => _TheXeRow(
                          the: the,
                          isSelected: _selectedTheIds.contains(the.id),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedTheIds.add(the.id);
                              } else {
                                _selectedTheIds.remove(the.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                ?trailing,
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

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
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TheXeRow extends StatelessWidget {
  final ThePhuongTien the;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _TheXeRow({
    required this.the,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: isSelected,
      onChanged: onChanged,
      title: Text(
        the.maThe,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        the.tenTrangThaiThePhuongTien,
        style: TextStyle(
          fontSize: 12,
          color: the.trangThaiThePhuongTienId == 1 ? Colors.green : Colors.red,
        ),
      ),
      secondary: Text(
        the.ngayBatDau != null
            ? '${the.ngayBatDau!.day}/${the.ngayBatDau!.month}/${the.ngayBatDau!.year}'
            : '-',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
