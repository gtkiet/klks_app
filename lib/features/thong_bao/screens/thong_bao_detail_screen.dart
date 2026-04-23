/*

// lib/features/thong_bao/screens/thong_bao_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/thong_bao_model.dart';
import '../services/thong_bao_service.dart';

class ThongBaoDetailScreen extends StatefulWidget {
  final ThongBaoItem item;

  const ThongBaoDetailScreen({super.key, required this.item});

  @override
  State<ThongBaoDetailScreen> createState() => _ThongBaoDetailScreenState();
}

class _ThongBaoDetailScreenState extends State<ThongBaoDetailScreen> {
  final _service = ThongBaoService.instance;
  late ThongBaoItem _item;
  bool _isMarkingRead = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    // Auto đánh dấu đã đọc nếu chưa đọc
    if (!_item.isRead) _markAsRead();
  }

  Future<void> _markAsRead() async {
    setState(() => _isMarkingRead = true);

    final result = await _service.daDDoc(phanBoThongBaoId: _item.id);

    if (!mounted) return;
    setState(() => _isMarkingRead = false);

    if (result.isOk) {
      setState(() {
        _item = _item.copyWith(isRead: true, readAt: DateTime.now());
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
        actions: [
          if (_isMarkingRead)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                _item.isRead ? Icons.done_all : Icons.circle_outlined,
                color: _item.isRead ? Colors.green : Colors.grey,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge loại thông báo
            if (_item.tenLoaiThongBao.isNotEmpty) ...[
              Chip(
                avatar: const Icon(Icons.label_outline, size: 16),
                label: Text(_item.tenLoaiThongBao),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(height: 12),
            ],

            // Tiêu đề
            Text(
              _item.tieuDe,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),

            // Thời gian tạo & đọc
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _item.thoiGianHienThi,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (_item.isRead) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.done_all, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text(
                    'Đã đọc',
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ],
            ),

            const Divider(height: 32),

            // Nội dung
            Text(
              _item.noiDung,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),

            // _TODO: parse metadata JSON để điều hướng đến màn hình liên quan
            // Ví dụ: nếu loaiThongBaoId == 1 → navigate đến màn hình hóa đơn
            // context.push('/hoa-don/${_item.referenceId}')
          ],
        ),
      ),
    );
  }
}

*/