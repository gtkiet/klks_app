// lib/features/cu_tru/screens/chi_tiet_yeu_cau_screen.dart
//
// Chi tiết yêu cầu cư trú.
//
// Trạng thái "Đã lưu" (nháp):
//   - Nút "Sửa" → mở SuaYeuCauScreen (PUT /api/quan-he-cu-tru/yeu-cau)
//   - Nút "Gửi duyệt" → PUT isSubmit=true
//   - Nút "Thu hồi" → PUT isWithdraw=true
//
// Các trạng thái khác: chỉ đọc.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/quan_he_cu_tru_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import '../utils/file_opener.dart';
import '../widgets/file_list_tile.dart';
import 'sua_yeu_cau_screen.dart';

class ChiTietYeuCauScreen extends StatefulWidget {
  final int requestId;
  final QuanHeCuTruModel canHo;

  const ChiTietYeuCauScreen({
    super.key,
    required this.requestId,
    required this.canHo,
  });

  @override
  State<ChiTietYeuCauScreen> createState() => _ChiTietYeuCauScreenState();
}

class _ChiTietYeuCauScreenState extends State<ChiTietYeuCauScreen> {
  final _service = CuTruService();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _shortDate = DateFormat('dd/MM/yyyy');

  YeuCauCuTruModel? _data;
  bool _isLoading = false;
  bool _isActioning = false;
  String? _error;

  // Trạng thái "Đã lưu" (nháp) — confirm với server thực tế
  // Thường là trangThaiId = 4, tên chứa "lưu" hoặc "nháp"
  bool get _isDraft {
    if (_data == null) return false;
    final ten = _data!.tenTrangThai.toLowerCase();
    return ten.contains('lưu') || ten.contains('nháp') || ten.contains('nhap');
  }

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
      final result = await _service.getYeuCauById(widget.requestId);
      setState(() => _data = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitDraft() async {
    final confirm = await _showConfirmDialog(
      title: 'Gửi yêu cầu để duyệt?',
      content:
          'Sau khi gửi, bạn sẽ không thể tự chỉnh sửa yêu cầu này nữa.\n'
          'BQL sẽ xem xét và phê duyệt.',
      confirmLabel: 'Gửi duyệt',
      confirmColor: Colors.blue,
    );
    if (!confirm) return;

    setState(() => _isActioning = true);
    try {
      final updated = await _service.updateYeuCau(
        id: widget.requestId,
        isSubmit: true,
        isWithdraw: false,
      );
      setState(() => _data = updated);
      _showSnack('✅ Đã gửi yêu cầu để BQL duyệt!');
    } catch (e) {
      _showSnack('❌ $e');
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
  }

  Future<void> _withdrawDraft() async {
    final confirm = await _showConfirmDialog(
      title: 'Thu hồi yêu cầu?',
      content: 'Yêu cầu sẽ bị thu hồi và không được gửi đi nữa.',
      confirmLabel: 'Thu hồi',
      confirmColor: Colors.red,
    );
    if (!confirm) return;

    setState(() => _isActioning = true);
    try {
      final updated = await _service.updateYeuCau(
        id: widget.requestId,
        isSubmit: false,
        isWithdraw: true,
      );
      setState(() => _data = updated);
      _showSnack('✅ Đã thu hồi yêu cầu.');
    } catch (e) {
      _showSnack('❌ $e');
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openEdit() async {
    if (_data == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SuaYeuCauScreen(yeuCau: _data!, canHo: widget.canHo),
      ),
    );
    if (updated == true) _load(); // Reload sau khi sửa
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yêu cầu #${widget.requestId}'),
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_data == null) return const SizedBox();

    final d = _data!;

    return AbsorbPointer(
      absorbing: _isActioning,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Trạng thái + loại yêu cầu ───────────────────────────────────
            Row(
              children: [
                _StatusBadge(
                  trangThaiId: d.trangThaiId,
                  tenTrangThai: d.tenTrangThai,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    d.tenLoaiYeuCau,
                    style: const TextStyle(fontSize: 12),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Căn hộ ──────────────────────────────────────────────────────
            _SectionCard(
              title: 'Căn hộ',
              children: [
                _Row('Căn hộ', d.tenCanHo),
                _Row('Tầng', d.tenTang),
                _Row('Tòa nhà', d.tenToaNha),
              ],
            ),

            // ── Người gửi ────────────────────────────────────────────────────
            _SectionCard(
              title: 'Người gửi',
              children: [
                _Row('Họ tên', d.tenNguoiGui),
                _Row(
                  'Ngày tạo',
                  d.createdAt != null
                      ? _dateFormat.format(d.createdAt!)
                      : '---',
                ),
              ],
            ),

            // ── Thông tin đề nghị ────────────────────────────────────────────
            if (d.hoTenDayDu != null || d.yeuCauGioiTinhTen != null)
              _SectionCard(
                title: 'Thông tin đề nghị',
                children: [
                  if (d.hoTenDayDu != null) _Row('Họ tên', d.hoTenDayDu!),
                  if (d.yeuCauNgaySinh != null)
                    _Row('Ngày sinh', _shortDate.format(d.yeuCauNgaySinh!)),
                  if (d.yeuCauGioiTinhTen != null)
                    _Row('Giới tính', d.yeuCauGioiTinhTen!),
                  if (d.yeuCauLoaiQuanHeTen != null)
                    _Row('Quan hệ', d.yeuCauLoaiQuanHeTen!),
                  if (d.yeuCauSoDienThoai != null)
                    _Row('Điện thoại', d.yeuCauSoDienThoai!),
                  if (d.yeuCauCCCD != null) _Row('CCCD', d.yeuCauCCCD!),
                  if (d.yeuCauDiaChi != null) _Row('Địa chỉ', d.yeuCauDiaChi!),
                ],
              ),

            // ── Nội dung / Lý do ─────────────────────────────────────────────
            if (d.noiDung != null && d.noiDung!.isNotEmpty)
              _SectionCard(
                title: 'Nội dung',
                children: [
                  Text(d.noiDung!, style: const TextStyle(fontSize: 13)),
                ],
              ),

            if (d.lyDo != null && d.lyDo!.isNotEmpty)
              _SectionCard(
                title: 'Lý do xử lý',
                titleColor: Colors.orange,
                children: [Text(d.lyDo!, style: const TextStyle(fontSize: 13))],
              ),

            // ── Người xử lý ──────────────────────────────────────────────────
            if (d.tenNguoiXuLy != null)
              _SectionCard(
                title: 'Xử lý bởi',
                children: [
                  _Row('Người xử lý', d.tenNguoiXuLy!),
                  if (d.ngayXuLy != null)
                    _Row('Ngày xử lý', _dateFormat.format(d.ngayXuLy!)),
                ],
              ),

            // ── Tài liệu ────────────────────────────────────────────────────
            if (d.documents.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tài liệu đính kèm (${d.documents.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...d.documents.map((doc) {
                final allFiles = doc.files
                    .map((f) => OpenableFile.fromTaiLieu(f))
                    .toList();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.tenLoaiGiayTo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (doc.soGiayTo.isNotEmpty)
                          Text(
                            'Số: ${doc.soGiayTo}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (doc.files.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          if (allFiles.any((f) => f.isImage))
                            FileGrid(
                              files: allFiles.where((f) => f.isImage).toList(),
                            ),
                          ...allFiles
                              .where((f) => !f.isImage)
                              .map(
                                (f) =>
                                    FileListTile(file: f, siblings: allFiles),
                              ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 8),

            // ── Action buttons (chỉ khi nháp) ─────────────────────────────
            if (_isDraft) ...[
              const Divider(),
              const SizedBox(height: 8),
              if (_isActioning)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    // Sửa nháp
                    OutlinedButton.icon(
                      onPressed: _openEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Chỉnh sửa nháp'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Gửi duyệt
                    FilledButton.icon(
                      onPressed: _submitDraft,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Gửi duyệt'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Thu hồi
                    OutlinedButton.icon(
                      onPressed: _withdrawDraft,
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Thu hồi yêu cầu'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final int trangThaiId;
  final String tenTrangThai;
  const _StatusBadge({required this.trangThaiId, required this.tenTrangThai});

  Color get _color {
    switch (trangThaiId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Text(
        tenTrangThai,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? titleColor;

  const _SectionCard({
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: titleColor ?? Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                ),
              ),
              const Divider(height: 14),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
