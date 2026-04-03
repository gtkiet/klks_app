// lib/features/cu_tru/screens/chi_tiet_yeu_cau_screen.dart
//
// Screen 5: Chi tiết yêu cầu cư trú.
// Cho phép Submit hoặc Withdraw nếu yêu cầu đang ở trạng thái "Đã lưu".

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';

class ChiTietYeuCauScreen extends StatefulWidget {
  final int requestId;

  const ChiTietYeuCauScreen({super.key, required this.requestId});

  @override
  State<ChiTietYeuCauScreen> createState() => _ChiTietYeuCauScreenState();
}

class _ChiTietYeuCauScreenState extends State<ChiTietYeuCauScreen> {
  final _service = CuTruService();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _shortDateFormat = DateFormat('dd/MM/yyyy');

  YeuCauCuTruModel? _data;
  bool _isLoading = false;
  bool _isActioning = false;
  String? _errorMessage;

  // Trạng thái "Đã lưu" có thể submit/withdraw — giả sử id = 4
  static const int _trangThaiDaLuu = 4;

  bool get _canAction => _data?.trangThaiId == _trangThaiDaLuu;

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
      final result = await _service.getYeuCauById(widget.requestId);
      setState(() => _data = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _action({
    required bool isSubmit,
    required bool isWithdraw,
  }) async {
    setState(() => _isActioning = true);
    try {
      final updated = await _service.updateYeuCau(
        id: widget.requestId,
        isSubmit: isSubmit,
        isWithdraw: isWithdraw,
      );
      setState(() => _data = updated);
      _showSnack(
        isWithdraw ? '✅ Đã thu hồi yêu cầu.' : '✅ Đã gửi yêu cầu để duyệt.',
      );
    } catch (e) {
      _showSnack('❌ ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_data == null) return const SizedBox();

    final d = _data!;
    return AbsorbPointer(
      absorbing: _isActioning,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _StatusBadge(
              trangThaiId: d.trangThaiId,
              tenTrangThai: d.tenTrangThai,
            ),
            const SizedBox(height: 16),

            // ── Thông tin căn hộ ────────────────────────────────────────────
            _SectionCard(
              title: 'Căn hộ',
              children: [
                _InfoRow('Căn hộ', d.tenCanHo),
                _InfoRow('Tầng', d.tenTang),
                _InfoRow('Tòa nhà', d.tenToaNha),
                _InfoRow('Loại yêu cầu', d.tenLoaiYeuCau),
              ],
            ),

            // ── Thông tin người gửi ─────────────────────────────────────────
            _SectionCard(
              title: 'Người gửi',
              children: [
                _InfoRow('Họ tên', d.tenNguoiGui),
                _InfoRow(
                  'Ngày tạo',
                  d.createdAt != null
                      ? _dateFormat.format(d.createdAt!)
                      : '---',
                ),
              ],
            ),

            // ── Thông tin yêu cầu ───────────────────────────────────────────
            if (d.hoTenDayDu != null)
              _SectionCard(
                title: 'Thông tin đề nghị',
                children: [
                  if (d.hoTenDayDu != null) _InfoRow('Họ tên', d.hoTenDayDu!),
                  if (d.yeuCauNgaySinh != null)
                    _InfoRow(
                      'Ngày sinh',
                      _shortDateFormat.format(d.yeuCauNgaySinh!),
                    ),
                  if (d.yeuCauGioiTinhTen != null)
                    _InfoRow('Giới tính', d.yeuCauGioiTinhTen!),
                  if (d.yeuCauSoDienThoai != null)
                    _InfoRow('Điện thoại', d.yeuCauSoDienThoai!),
                  if (d.yeuCauCCCD != null) _InfoRow('CCCD', d.yeuCauCCCD!),
                  if (d.yeuCauDiaChi != null)
                    _InfoRow('Địa chỉ', d.yeuCauDiaChi!),
                  if (d.yeuCauLoaiQuanHeTen != null)
                    _InfoRow('Quan hệ', d.yeuCauLoaiQuanHeTen!),
                ],
              ),

            // ── Nội dung / Lý do ────────────────────────────────────────────
            if (d.noiDung != null && d.noiDung!.isNotEmpty)
              _SectionCard(
                title: 'Nội dung',
                children: [_InfoRow('', d.noiDung!)],
              ),

            if (d.lyDo != null && d.lyDo!.isNotEmpty)
              _SectionCard(
                title: 'Lý do xử lý',
                children: [_InfoRow('', d.lyDo!)],
              ),

            // ── Xử lý ───────────────────────────────────────────────────────
            if (d.tenNguoiXuLy != null)
              _SectionCard(
                title: 'Xử lý bởi',
                children: [
                  _InfoRow('Người xử lý', d.tenNguoiXuLy!),
                  if (d.ngayXuLy != null)
                    _InfoRow('Ngày xử lý', _dateFormat.format(d.ngayXuLy!)),
                ],
              ),

            // ── Tài liệu ────────────────────────────────────────────────────
            if (d.documents.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tài liệu đính kèm (${d.documents.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ...d.documents.map(
                (doc) => Card(
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
                        Text('Số: ${doc.soGiayTo}'),
                        Wrap(
                          spacing: 6,
                          children: doc.files
                              .map(
                                (f) => ActionChip(
                                  label: Text(
                                    f.fileName,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onPressed: () {
                                    /* TODO: mở file */
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // ── Actions ─────────────────────────────────────────────────────
            const SizedBox(height: 24),
            if (_canAction)
              _isActioning
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _action(isSubmit: false, isWithdraw: true),
                            icon: const Icon(Icons.undo),
                            label: const Text('Thu hồi'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: () =>
                                _action(isSubmit: true, isWithdraw: false),
                            icon: const Icon(Icons.send),
                            label: const Text('Gửi duyệt'),
                          ),
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _color),
      ),
      child: Text(
        'Trạng thái: $tenTrangThai',
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(value),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
