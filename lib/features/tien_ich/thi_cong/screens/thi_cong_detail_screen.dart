// lib/features/yeu_cau_thi_cong/screens/yeu_cau_thi_cong_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../cu_tru/quan_he/services/cu_tru_service.dart';

import '../models/trang_thai_yeu_cau.dart';
import '../models/yeu_cau_thi_cong_detail_model.dart';
import '../models/nhan_su_thi_cong_model.dart';
import '../models/tep_dinh_kem_model.dart';

import '../services/thi_cong_service.dart';

import 'thi_cong_form_screen.dart';

class YeuCauThiCongDetailScreen extends StatefulWidget {
  final int id;
  const YeuCauThiCongDetailScreen({super.key, required this.id});

  @override
  State<YeuCauThiCongDetailScreen> createState() =>
      _YeuCauThiCongDetailScreenState();
}

class _YeuCauThiCongDetailScreenState extends State<YeuCauThiCongDetailScreen> {
  final _service = YeuCauThiCongService.instance;
  final _cuTruService = CuTruService.instance;

  YeuCauThiCongDetailModel? _detail;
  bool _isLoading = false;
  bool _isActioning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final detail = await _service.getById(widget.id);
      setState(() => _detail = detail);
    } on Exception catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Navigate to edit ──────────────────────────────────────────────────────

  Future<void> _navigateToEdit() async {
    if (_detail == null) return;
    final dsCanHo = await _cuTruService.getQuanHeCuTruList();
    if (!mounted) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            YeuCauThiCongFormScreen(dsCanHo: dsCanHo, existingDetail: _detail),
      ),
    );
    if (changed == true) _load();
  }

  // ── Thu hồi ───────────────────────────────────────────────────────────────

  Future<void> _thuHoi() async {
    final d = _detail!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thu hồi yêu cầu'),
        content: const Text(
          'Bạn chắc chắn muốn thu hồi?\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isActioning = true);
    try {
      await _service.withdraw(d);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thu hồi thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết #${widget.id}'),
        actions: [
          if (_detail?.coTheChinhSua == true)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: _navigateToEdit,
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottom(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null) {
      return _ErrorRetry(message: _errorMessage!, onRetry: _load);
    }

    if (_detail == null) return const SizedBox.shrink();

    final d = _detail!;
    final df = DateFormat('dd/MM/yyyy');
    final dtf = DateFormat('dd/MM/yyyy HH:mm');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Status banner ────────────────────────────────────────────────
          _StatusBanner(detail: d),
          const SizedBox(height: 14),

          // ── Phản hồi BQL (Returned) ──────────────────────────────────────
          if (d.isReturned && d.lyDo.isNotEmpty) ...[
            _SectionCard(
              title: 'Phản hồi từ BQL',
              titleColor: Colors.orange,
              children: [_InfoRow('Lý do', d.lyDo)],
            ),
            const SizedBox(height: 12),
          ],

          // ── Thông tin yêu cầu ────────────────────────────────────────────
          _SectionCard(
            title: 'Thông tin yêu cầu',
            children: [
              _InfoRow('Căn hộ', d.tenCanHo),
              _InfoRow('Hạng mục', d.hangMucThiCong),
              _InfoRow(
                'Dự kiến bắt đầu',
                d.duKienBatDau != null ? df.format(d.duKienBatDau!) : '-',
              ),
              _InfoRow(
                'Dự kiến kết thúc',
                d.duKienKetThuc != null ? df.format(d.duKienKetThuc!) : '-',
              ),
              _InfoRow('Đơn vị thi công', d.tenDonViThiCong),
              _InfoRow('Người đại diện', d.nguoiDaiDien),
              _InfoRow('Điện thoại ĐD', d.soDienThoaiDaiDien),
              if (d.noiDung.isNotEmpty) _InfoRow('Nội dung', d.noiDung),
            ],
          ),
          const SizedBox(height: 12),

          // ── Trạng thái ───────────────────────────────────────────────────
          _SectionCard(
            title: 'Trạng thái',
            children: [
              _InfoRow('Hành chính', d.trangThaiYeuCauTen),
              _InfoRow('Thi công', d.trangThaiThiCongTen),
              _InfoRow(
                'Ngày tạo',
                d.createdAt != null ? dtf.format(d.createdAt!) : '-',
              ),
              _InfoRow('Người gửi', d.tenNguoiGui),
            ],
          ),
          const SizedBox(height: 12),

          // ── Tiền cọc ─────────────────────────────────────────────────────
          if (d.tienDatCoc > 0) ...[
            _SectionCard(
              title: 'Thông tin tiền cọc',
              children: [
                _InfoRow('Tiền đặt cọc', d.tienDatCocFormatted),
                _InfoRow('Đã thu cọc', d.isDaThuCoc ? 'Đã thu' : 'Chưa thu'),
                if (d.ghiChuThuCoc.isNotEmpty)
                  _InfoRow('Ghi chú', d.ghiChuThuCoc),
                if (d.tienKhauTru > 0) ...[
                  _InfoRow(
                    'Tiền khấu trừ',
                    '${d.tienKhauTru.toStringAsFixed(0)} đ',
                  ),
                  if (d.lyDoKhauTru.isNotEmpty)
                    _InfoRow('Lý do khấu trừ', d.lyDoKhauTru),
                ],
                _InfoRow(
                  'Đã hoàn cọc',
                  d.isDaHoanCoc ? 'Đã hoàn' : 'Chưa hoàn',
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Nhân sự ──────────────────────────────────────────────────────
          _SectionCard(
            title: 'Danh sách nhân sự (${d.nhanSuThiCongs.length})',
            children: d.nhanSuThiCongs.isEmpty
                ? [
                    const Text(
                      'Chưa có nhân sự',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ]
                : d.nhanSuThiCongs.map((ns) => _buildNhanSuRow(ns)).toList(),
          ),
          const SizedBox(height: 12),

          // ── Tệp đính kèm ─────────────────────────────────────────────────
          _SectionCard(
            title: 'Hồ sơ đính kèm (${d.danhSachTep.length})',
            children: d.danhSachTep.isEmpty
                ? [
                    const Text(
                      'Chưa có tệp',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ]
                : d.danhSachTep.map((tep) => _TepTile(tep: tep)).toList(),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget? _buildBottom() {
    final d = _detail;
    if (d == null || _isLoading) return null;
    if (!d.coTheChinhSua && !d.coTheThuHoi) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (d.coTheChinhSua)
              ElevatedButton.icon(
                onPressed: _isActioning ? null : _navigateToEdit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Chỉnh sửa & Gửi lại'),
              ),
            if (d.coTheChinhSua && d.coTheThuHoi) const SizedBox(height: 8),
            if (d.coTheThuHoi)
              OutlinedButton.icon(
                onPressed: _isActioning ? null : _thuHoi,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: _isActioning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : const Icon(Icons.undo),
                label: Text(
                  _isActioning ? 'Đang thu hồi...' : 'Thu hồi yêu cầu',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNhanSuRow(NhanSuThiCongModel ns) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ns.hoTen,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (ns.vaiTro.isNotEmpty)
                  Text(
                    ns.vaiTro,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (ns.soCCCD.isNotEmpty)
                  Text(
                    'CCCD: ${ns.soCCCD}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (ns.soDienThoai.isNotEmpty)
                  Text(
                    ns.soDienThoai,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                if (ns.ghiChu.isNotEmpty)
                  Text(
                    'Ghi chú: ${ns.ghiChu}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status banner — tổng quát cho mọi trạng thái yêu cầu
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final YeuCauThiCongDetailModel detail;
  const _StatusBanner({required this.detail});

  _StatusStyle get _style {
    switch (detail.trangThaiYeuCauId) {
      case TrangThaiYeuCauConst.daLuu:
        return _StatusStyle(color: Colors.grey, icon: Icons.drafts_outlined);
      case TrangThaiYeuCauConst.dangChoDuyet:
        return _StatusStyle(color: Colors.orange, icon: Icons.hourglass_top);
      case TrangThaiYeuCauConst.daDuyet:
        return _StatusStyle(
          color: Colors.blue,
          icon: Icons.check_circle_outline,
        );
      case TrangThaiYeuCauConst.yeuCauBoSung:
        return _StatusStyle(
          color: Colors.amber.shade700,
          icon: Icons.assignment_return_outlined,
          hint: 'Vui lòng bổ sung thông tin và gửi lại',
        );
      case TrangThaiYeuCauConst.hoanTat:
        return _StatusStyle(color: Colors.green, icon: Icons.task_alt);
      case TrangThaiYeuCauConst.daThuHoi:
      case TrangThaiYeuCauConst.hetHieuLuc:
        return _StatusStyle(color: Colors.grey, icon: Icons.undo);
      case TrangThaiYeuCauConst.tuChoi:
      case TrangThaiYeuCauConst.daHuy:
        return _StatusStyle(color: Colors.red, icon: Icons.cancel_outlined);
      default:
        return _StatusStyle(color: Colors.grey, icon: Icons.help_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: s.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(s.icon, color: s.color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.trangThaiYeuCauTen,
                  style: TextStyle(
                    color: s.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (s.hint != null)
                  Text(s.hint!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  final String? hint;
  const _StatusStyle({required this.color, required this.icon, this.hint});
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: titleColor ?? Colors.grey.shade600,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _TepTile extends StatelessWidget {
  final TepDinhKemModel tep;
  const _TepTile({required this.tep});

  @override
  Widget build(BuildContext context) {
    final isImage = tep.contentType.startsWith('image/');
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isImage ? Icons.image : Icons.insert_drive_file,
        color: Colors.blue,
      ),
      title: Text(
        tep.fileName.isNotEmpty ? tep.fileName : 'Tệp #${tep.id}',
        style: const TextStyle(fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: tep.contentType.isNotEmpty
          ? Text(tep.contentType, style: const TextStyle(fontSize: 11))
          : null,
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
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
