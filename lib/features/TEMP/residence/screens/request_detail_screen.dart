// lib/features/residence/screens/request_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/residence_document.dart';
import '../models/residence_request.dart';
import '../services/residence_service.dart';
import '../../../../core/errors/app_exception.dart';

class RequestDetailScreen extends StatefulWidget {
  final int requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _service = ResidenceService.instance;

  bool _loading = true;
  String? _error;
  ResidenceRequestDetail? _detail;
  bool _actioning = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getRequestDetail(requestId: widget.requestId);
      setState(() => _detail = data);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final confirmed = await _showConfirm(
      title: 'Gửi yêu cầu',
      body:
          'Sau khi gửi, bạn sẽ không thể chỉnh sửa yêu cầu này nữa. Xác nhận?',
      confirmLabel: 'Gửi',
      confirmColor: Colors.blue,
    );
    if (!confirmed) return;

    setState(() => _actioning = true);
    try {
      final updated = await _service.updateRequest(
        id: widget.requestId,
        isSubmit: true,
        isWithdraw: false,
      );
      setState(() => _detail = updated);
      _showSnack('Đã gửi yêu cầu thành công!');
    } on AppException catch (e) {
      _showSnack(e.message);
    } finally {
      setState(() => _actioning = false);
    }
  }

  Future<void> _withdraw() async {
    final confirmed = await _showConfirm(
      title: 'Thu hồi yêu cầu',
      body: 'Yêu cầu sẽ bị thu hồi và không được xử lý nữa. Xác nhận?',
      confirmLabel: 'Thu hồi',
      confirmColor: Colors.red,
    );
    if (!confirmed) return;

    setState(() => _actioning = true);
    try {
      final updated = await _service.updateRequest(
        id: widget.requestId,
        isSubmit: false,
        isWithdraw: true,
      );
      setState(() => _detail = updated);
      _showSnack('Đã thu hồi yêu cầu');
    } on AppException catch (e) {
      _showSnack(e.message);
    } finally {
      setState(() => _actioning = false);
    }
  }

  Future<bool> _showConfirm({
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // trangThaiId: 1=Đang chờ duyệt, 2=Đã duyệt, 3=Từ chối, (draft=0 hay saved)
  bool get _canSubmit =>
      _detail != null &&
      (_detail!.trangThaiId == 0 || _detail!.trangThaiId == 4);
  bool get _canWithdraw =>
      _detail != null &&
      (_detail!.trangThaiId == 0 ||
          _detail!.trangThaiId == 1 ||
          _detail!.trangThaiId == 4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết yêu cầu #${widget.requestId}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _detail == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (_canWithdraw) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _actioning ? null : _withdraw,
                          icon: const Icon(Icons.undo, color: Colors.red),
                          label: const Text(
                            'Thu hồi',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (_canSubmit)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _actioning ? null : _submit,
                          icon: _actioning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: const Text('Gửi duyệt'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    final d = _detail!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status banner
        _StatusBanner(trangThaiId: d.trangThaiId, tenTrangThai: d.tenTrangThai),
        const SizedBox(height: 16),

        // Request info
        _InfoCard(
          title: 'Thông tin yêu cầu',
          rows: [
            ('Loại yêu cầu', d.tenLoaiYeuCau),
            ('Người gửi', d.tenNguoiGui),
            (
              'Ngày tạo',
              '${d.createdAt.day}/${d.createdAt.month}/${d.createdAt.year}',
            ),
            ('Căn hộ', d.tenCanHo),
            ('Tầng', d.tenTang),
            ('Tòa nhà', d.tenToaNha),
            if (d.tenNguoiXuLy != null) ('Người xử lý', d.tenNguoiXuLy!),
            if (d.lyDo != null && d.lyDo!.isNotEmpty) ('Lý do', d.lyDo!),
            if (d.noiDung != null && d.noiDung!.isNotEmpty)
              ('Nội dung', d.noiDung!),
          ],
        ),
        const SizedBox(height: 16),

        // Thông tin thay đổi
        if (d.yeuCauTen != null || d.yeuCauHo != null)
          _InfoCard(
            title: 'Thông tin cư dân trong yêu cầu',
            rows: [
              if (d.yeuCauHo != null || d.yeuCauTen != null)
                ('Họ tên', '${d.yeuCauHo ?? ''} ${d.yeuCauTen ?? ''}'.trim()),
              if (d.yeuCauNgaySinh != null)
                (
                  'Ngày sinh',
                  '${d.yeuCauNgaySinh!.day}/${d.yeuCauNgaySinh!.month}/${d.yeuCauNgaySinh!.year}',
                ),
              if (d.yeuCauGioiTinhTen != null)
                ('Giới tính', d.yeuCauGioiTinhTen!),
              if (d.yeuCauCCCD != null && d.yeuCauCCCD!.isNotEmpty)
                ('CCCD', d.yeuCauCCCD!),
              if (d.yeuCauSoDienThoai != null &&
                  d.yeuCauSoDienThoai!.isNotEmpty)
                ('Điện thoại', d.yeuCauSoDienThoai!),
              if (d.yeuCauDiaChi != null && d.yeuCauDiaChi!.isNotEmpty)
                ('Địa chỉ', d.yeuCauDiaChi!),
              if (d.yeuCauLoaiQuanHeTen != null)
                ('Quan hệ cư trú', d.yeuCauLoaiQuanHeTen!),
            ],
          ),
        if (d.yeuCauTen != null || d.yeuCauHo != null)
          const SizedBox(height: 16),

        // Documents
        if (d.documents.isNotEmpty) ...[
          Text(
            'Tài liệu đính kèm',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...d.documents.map((doc) => _DocumentCard(doc: doc)),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 60),
      ],
    );
  }
}

// ─── Sub widgets ──────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final int trangThaiId;
  final String tenTrangThai;

  const _StatusBanner({required this.trangThaiId, required this.tenTrangThai});

  Color get _color {
    switch (trangThaiId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData get _icon {
    switch (trangThaiId) {
      case 1:
        return Icons.hourglass_top;
      case 2:
        return Icons.check_circle;
      case 3:
        return Icons.cancel;
      default:
        return Icons.save;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 28),
          const SizedBox(width: 12),
          Text(
            tenTrangThai,
            style: TextStyle(
              color: _color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;

  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        row.$1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final ResidenceDocument doc;

  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_open, size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doc.tenLoaiGiayTo.isNotEmpty
                        ? doc.tenLoaiGiayTo
                        : 'Tài liệu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (doc.soGiayTo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Số: ${doc.soGiayTo}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (doc.files.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...doc.files.map(
                (f) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.insert_drive_file,
                    size: 20,
                    color: Colors.blue,
                  ),
                  title: Text(f.fileName, style: const TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {
                    // TODO: open URL in browser/viewer
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
