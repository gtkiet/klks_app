// ─────────────────────────────────────────────────────────────────────────────
// lib/features/thanh_vien/screens/yeu_cau_detail_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/errors.dart';

import '../services/tv_yeu_cau_service.dart';
import '../models/yeu_cau_cu_tru_model.dart';

class YeuCauDetailScreen extends StatefulWidget {
  final int yeuCauId;

  const YeuCauDetailScreen({super.key, required this.yeuCauId});

  @override
  State<YeuCauDetailScreen> createState() => _YeuCauDetailScreenState();
}

class _YeuCauDetailScreenState extends State<YeuCauDetailScreen> {
  final _service = YeuCauCuTruService.instance;

  bool _isLoading = true;
  AppException? _error;
  YeuCauCuTruModel? _data;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
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
      appBar: AppBar(title: const Text('Chi tiết yêu cầu')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(error: _error!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final d = _data!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Trạng thái + loại ─────────────────────────────────────────
          _StatusBanner(
            trangThaiId: d.trangThaiId,
            tenTrangThai: d.tenTrangThai,
          ),
          const SizedBox(height: 16),

          // ── Thông tin yêu cầu ─────────────────────────────────────────
          _SectionCard(
            title: 'Thông tin yêu cầu',
            children: [
              _InfoTile(label: 'Loại yêu cầu', value: d.tenLoaiYeuCau),
              _InfoTile(label: 'Căn hộ', value: d.diaChiCanHo),
              _InfoTile(label: 'Người gửi', value: d.tenNguoiGui),
              if (d.createdAt != null)
                _InfoTile(label: 'Ngày tạo', value: _fmtDate(d.createdAt!)),
              if (d.tenNguoiXuLy != null)
                _InfoTile(label: 'Người xử lý', value: d.tenNguoiXuLy!),
              if (d.ngayXuLy != null)
                _InfoTile(label: 'Ngày xử lý', value: _fmtDate(d.ngayXuLy!)),
              if (d.lyDo != null && d.lyDo!.isNotEmpty)
                _InfoTile(label: 'Lý do', value: d.lyDo!, highlight: true),
            ],
          ),
          const SizedBox(height: 12),

          // ── Thông tin người được yêu cầu ──────────────────────────────
          if (_hasPersonInfo(d)) ...[
            _SectionCard(
              title: 'Thông tin người được yêu cầu',
              children: [
                if (d.hoTenDayDu != null)
                  _InfoTile(label: 'Họ tên', value: d.hoTenDayDu!),
                if (d.yeuCauNgaySinh != null)
                  _InfoTile(
                    label: 'Ngày sinh',
                    value: _fmtDate(d.yeuCauNgaySinh!),
                  ),
                if (d.yeuCauGioiTinhTen != null)
                  _InfoTile(label: 'Giới tính', value: d.yeuCauGioiTinhTen!),
                if (d.yeuCauCCCD != null && d.yeuCauCCCD!.isNotEmpty)
                  _InfoTile(label: 'CCCD', value: d.yeuCauCCCD!),
                if (d.yeuCauSoDienThoai != null &&
                    d.yeuCauSoDienThoai!.isNotEmpty)
                  _InfoTile(label: 'SĐT', value: d.yeuCauSoDienThoai!),
                if (d.yeuCauDiaChi != null && d.yeuCauDiaChi!.isNotEmpty)
                  _InfoTile(label: 'Địa chỉ', value: d.yeuCauDiaChi!),
                if (d.yeuCauLoaiQuanHeTen != null)
                  _InfoTile(
                    label: 'Quan hệ cư trú',
                    value: d.yeuCauLoaiQuanHeTen!,
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Nội dung ──────────────────────────────────────────────────
          if (d.noiDung != null && d.noiDung!.isNotEmpty) ...[
            _SectionCard(
              title: 'Nội dung',
              children: [
                Text(d.noiDung!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Tài liệu đính kèm ─────────────────────────────────────────
          if (d.documents.isNotEmpty) ...[
            _SectionCard(
              title: 'Tài liệu đính kèm (${d.documents.length})',
              children: d.documents
                  .map((doc) => _DocumentItem(doc: doc))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  bool _hasPersonInfo(YeuCauCuTruModel d) =>
      d.hoTenDayDu != null ||
      d.yeuCauNgaySinh != null ||
      d.yeuCauGioiTinhTen != null ||
      (d.yeuCauCCCD != null && d.yeuCauCCCD!.isNotEmpty) ||
      (d.yeuCauSoDienThoai != null && d.yeuCauSoDienThoai!.isNotEmpty) ||
      (d.yeuCauDiaChi != null && d.yeuCauDiaChi!.isNotEmpty) ||
      d.yeuCauLoaiQuanHeTen != null;

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

// ── Banner trạng thái ─────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final int trangThaiId;
  final String tenTrangThai;

  const _StatusBanner({required this.trangThaiId, required this.tenTrangThai});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _resolve(trangThaiId);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Text(
            tenTrangThai,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color fg, IconData icon) _resolve(int id) => switch (id) {
    4 => (
      Colors.grey.shade100,
      Colors.grey.shade700,
      Icons.save_outlined,
    ), // Đã lưu / nháp
    1 => (
      Colors.orange.shade50,
      Colors.orange.shade800,
      Icons.hourglass_top,
    ), // Chờ duyệt
    2 => (
      Colors.green.shade50,
      Colors.green.shade800,
      Icons.check_circle_outline,
    ), // Đã duyệt
    3 => (
      Colors.red.shade50,
      Colors.red.shade800,
      Icons.cancel_outlined,
    ), // Từ chối
    _ => (Colors.blue.shade50, Colors.blue.shade800, Icons.info_outline),
  };
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Info tile (label + value) ─────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: highlight ? Colors.red.shade700 : null,
                fontWeight: highlight ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final dynamic doc; // TaiLieuCuTruModel

  const _DocumentItem({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên loại giấy tờ + số
        Row(
          children: [
            const Icon(Icons.article_outlined, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                doc.tenLoaiGiayTo.isNotEmpty ? doc.tenLoaiGiayTo : 'Tài liệu',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (doc.soGiayTo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text(
              'Số: ${doc.soGiayTo}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (doc.ngayPhatHanh != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text(
              'Ngày phát hành: ${_fmtDate(doc.ngayPhatHanh!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        // Files
        if (doc.files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (doc.files as List)
                  .map<Widget>((f) => _FileChip(file: f))
                  .toList(),
            ),
          ),
        const Divider(height: 20),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _FileChip extends StatelessWidget {
  final dynamic file; // TaiLieuFileModel

  const _FileChip({required this.file});

  Future<void> _openFile(BuildContext context) async {
    final rawUrl = file.fileUrl as String;
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không có đường dẫn tệp')));
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đường dẫn không hợp lệ')));
      return;
    }

    // Ưu tiên mở trong browser ngoài (externalApplication)
    // → phù hợp với link website hiển thị file từ server
    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở tệp trên thiết bị này')),
        );
      }
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isImage = (file.contentType as String).startsWith('image/');
    return ActionChip(
      avatar: Icon(
        isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
        size: 16,
      ),
      label: Text(
        file.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () => _openFile(context),
    );
  }
}
