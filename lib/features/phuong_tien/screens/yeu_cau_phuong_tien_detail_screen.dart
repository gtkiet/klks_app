// lib/features/phuong_tien/screens/yeu_cau_phuong_tien_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/errors/errors.dart';
import '../services/pt_yeu_cau_service.dart';
import '../models/yeu_cau_phuong_tien_model.dart';

class YeuCauPhuongTienDetailScreen extends StatefulWidget {
  final int yeuCauId;

  /// Nếu đã có data sẵn (từ list), truyền vào để hiển thị ngay
  /// mà không cần gọi API lần đầu.
  final YeuCauPhuongTien? initialData;

  const YeuCauPhuongTienDetailScreen({
    super.key,
    required this.yeuCauId,
    this.initialData,
  });

  @override
  State<YeuCauPhuongTienDetailScreen> createState() =>
      _YeuCauPhuongTienDetailScreenState();
}

class _YeuCauPhuongTienDetailScreenState
    extends State<YeuCauPhuongTienDetailScreen> {
  final _service = PTYeuCauService.instance;

  bool _isLoading = false;
  AppException? _error;
  YeuCauPhuongTien? _data;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _service.getYeuCauById(widget.yeuCauId);
      setState(() => _data = result);
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết yêu cầu'),
        actions: [
          if (_data != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Làm mới',
              onPressed: _loadData,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppErrorWidget(error: _error!),
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

    if (_data == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBanner(data: _data!),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Thông tin yêu cầu',
              children: [
                _InfoRow(label: 'Mã yêu cầu', value: '#${_data!.id}'),
                _InfoRow(label: 'Loại yêu cầu', value: _data!.tenLoaiYeuCau),
                _InfoRow(label: 'Người gửi', value: _data!.tenNguoiGui),
                _InfoRow(label: 'Căn hộ', value: _data!.diaChiCanHo),
                if (_data!.createdAt != null)
                  _InfoRow(
                    label: 'Ngày tạo',
                    value: _fmtDateTime(_data!.createdAt!),
                  ),
                if (_data!.noiDung != null && _data!.noiDung!.isNotEmpty)
                  _InfoRow(
                    label: 'Nội dung',
                    value: _data!.noiDung!,
                    multiLine: true,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Thông tin phương tiện yêu cầu',
              children: [
                if (_data!.tenYeuCauLoaiPhuongTien != null)
                  _InfoRow(
                    label: 'Loại xe',
                    value: _data!.tenYeuCauLoaiPhuongTien!,
                  ),
                if (_data!.yeuCauTenPhuongTien != null)
                  _InfoRow(label: 'Tên xe', value: _data!.yeuCauTenPhuongTien!),
                if (_data!.yeuCauBienSo != null)
                  _InfoRow(label: 'Biển số', value: _data!.yeuCauBienSo!),
                if (_data!.yeuCauMauXe != null)
                  _InfoRow(label: 'Màu xe', value: _data!.yeuCauMauXe!),
                if (_data!.tenYeuCauLoaiPhuongTien == null &&
                    _data!.yeuCauTenPhuongTien == null &&
                    _data!.yeuCauBienSo == null &&
                    _data!.yeuCauMauXe == null)
                  const Text(
                    'Không có thông tin',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Xử lý',
              children: [
                _InfoRow(
                  label: 'Trạng thái',
                  value: _data!.tenTrangThai,
                  valueColor: _trangThaiColor(_data!.trangThaiId),
                ),
                if (_data!.tenNguoiXuLy != null)
                  _InfoRow(label: 'Người xử lý', value: _data!.tenNguoiXuLy!),
                if (_data!.ngayXuLy != null)
                  _InfoRow(
                    label: 'Ngày xử lý',
                    value: _fmtDateTime(_data!.ngayXuLy!),
                  ),
                if (_data!.lyDo != null && _data!.lyDo!.isNotEmpty)
                  _InfoRow(
                    label: 'Lý do',
                    value: _data!.lyDo!,
                    valueColor: Colors.red.shade700,
                    multiLine: true,
                  ),
              ],
            ),
            if (_data!.yeuCauHinhAnhPhuongTiens.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ImageSection(images: _data!.yeuCauHinhAnhPhuongTiens),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _trangThaiColor(int id) => switch (id) {
    2 => Colors.green.shade700,
    3 => Colors.red.shade700,
    4 => Colors.grey.shade600,
    _ => Colors.orange.shade700,
  };

  String _fmtDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'
      '  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ── Status Banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final YeuCauPhuongTien data;

  const _StatusBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _config(data.trangThaiId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.tenTrangThai,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  data.tenLoaiYeuCau,
                  style: TextStyle(color: fg.withValues(alpha: 0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color fg, IconData icon) _config(int id) => switch (id) {
    2 => (Colors.green.shade50, Colors.green.shade800, Icons.check_circle),
    3 => (Colors.red.shade50, Colors.red.shade800, Icons.cancel),
    4 => (Colors.grey.shade100, Colors.grey.shade700, Icons.undo),
    _ => (Colors.orange.shade50, Colors.orange.shade800, Icons.hourglass_top),
  };
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool multiLine;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: multiLine
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: valueColor)),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Image Section ─────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final List<HinhAnhYeuCau> images;

  const _ImageSection({required this.images});

  @override
  Widget build(BuildContext context) {
    final imageList = images.where((e) => e.isImage).toList();
    final fileList = images.where((e) => !e.isImage).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hình ảnh / Tài liệu đính kèm',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            if (imageList.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => _ImageThumb(image: imageList[i]),
                ),
              ),
            if (imageList.isNotEmpty && fileList.isNotEmpty)
              const SizedBox(height: 10),
            ...fileList.map((f) => _FileRow(file: f)),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final HinhAnhYeuCau image;

  const _ImageThumb({required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context, image.fileUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          image.fileUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: 100,
            height: 100,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 100,
              height: 100,
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final HinhAnhYeuCau file;

  const _FileRow({required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
