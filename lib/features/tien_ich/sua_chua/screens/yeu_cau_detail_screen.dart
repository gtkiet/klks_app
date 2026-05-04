// lib/features/yeu_cau_sua_chua/screens/yeu_cau_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../cu_tru/quan_he/services/cu_tru_service.dart';
import '../models/yeu_cau_sua_chua_model.dart';
import '../services/yeu_cau_sua_chua_service.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'yeu_cau_create_screen.dart';

class YeuCauDetailScreen extends StatefulWidget {
  final int yeuCauId;
  const YeuCauDetailScreen({super.key, required this.yeuCauId});

  @override
  State<YeuCauDetailScreen> createState() => _YeuCauDetailScreenState();
}

class _YeuCauDetailScreenState extends State<YeuCauDetailScreen> {
  final _service = YeuCauSuaChuaService.instance;
  final _cuTruService = CuTruService.instance;

  YeuCauSuaChua? _data;
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
      final data = await _service.getById(widget.yeuCauId);
      setState(() => _data = data);
    } on Exception catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _thuHoi() async {
    final d = _data!;
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
      await _service.thuHoiYeuCau(
        id: d.id,
        phamViId: d.phamViId ?? 1,
        loaiSuCoId: d.loaiSuCoId ?? 1,
        noiDung: d.noiDung,
      );
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

  Future<void> _navigateToEdit() async {
    final d = _data!;
    final dsCanHo = await _cuTruService.getQuanHeCuTruList();
    if (!mounted) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => YeuCauCreateScreen(dsCanHo: dsCanHo, editData: d),
      ),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết #${widget.yeuCauId}'),
        actions: [
          if (_data?.coTheChinhSua == true)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
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
    if (_data == null) return const SizedBox.shrink();

    final d = _data!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusBanner(yeuCau: d),
        const SizedBox(height: 14),

        // Phản hồi BQL (lyDo khi Returned / Rejected)
        if (d.lyDo != null && d.lyDo!.isNotEmpty) ...[
          _SectionCard(
            title: 'Phản hồi từ BQL',
            titleColor: Colors.orange,
            children: [_InfoRow('Lý do', d.lyDo!)],
          ),
          const SizedBox(height: 12),
        ],

        _SectionCard(
          title: 'Thông tin yêu cầu',
          children: [
            _InfoRow('Căn hộ', d.diaChiDayDu),
            if (d.phamViTen != null) _InfoRow('Phạm vi', d.phamViTen!),
            if (d.loaiSuCoTen != null) _InfoRow('Loại sự cố', d.loaiSuCoTen!),
            _InfoRow('Nội dung', d.noiDung),
            if (d.moTaViTri != null && d.moTaViTri!.isNotEmpty)
              _InfoRow('Vị trí', d.moTaViTri!),
            if (d.tenNguoiGui != null) _InfoRow('Người gửi', d.tenNguoiGui!),
            if (d.createdAt != null)
              _InfoRow('Ngày tạo', _fmtDate(d.createdAt!)),
          ],
        ),
        const SizedBox(height: 12),

        // Nhân sự
        if (d.coNhanSu) ...[
          _SectionCard(
            title: 'Nhân sự tác nghiệp',
            children: d.nhanSuSuaChuas.map(_buildNhanSuRow).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Người xử lý (BQL)
        if (d.tenNguoiXuLy != null) ...[
          _SectionCard(
            title: 'Người xử lý',
            children: [
              _InfoRow('Nhân viên', d.tenNguoiXuLy!),
              if (d.ngayXuLy != null)
                _InfoRow('Ngày xử lý', _fmtDate(d.ngayXuLy!)),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Hẹn lịch
        if (d.henTu != null) ...[
          _SectionCard(
            title: 'Lịch hẹn kỹ thuật viên',
            children: [
              _InfoRow('Từ', _fmtDate(d.henTu!)),
              if (d.henDen != null) _InfoRow('Đến', _fmtDate(d.henDen!)),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Chi phí
        if (d.chiPhiDuKien != null || d.chiPhiThucTe != null) ...[
          _SectionCard(
            title: 'Chi phí',
            children: [
              if (d.isMienPhi == true)
                const _InfoRow('Loại', 'Miễn phí (bảo trì / bảo hành)'),
              if (d.chiPhiDuKien != null)
                _InfoRow('Dự kiến', _fmtCurrency(d.chiPhiDuKien!)),
              if (d.chiPhiThucTe != null)
                _InfoRow('Thực tế', _fmtCurrency(d.chiPhiThucTe!)),
              if (d.ghiChuBaoGia != null && d.ghiChuBaoGia!.isNotEmpty)
                _InfoRow('Ghi chú', d.ghiChuBaoGia!),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Đối tác
        if (d.tenDoiTac != null) ...[
          _SectionCard(
            title: 'Đối tác thực hiện',
            children: [_InfoRow('Đối tác', d.tenDoiTac!)],
          ),
          const SizedBox(height: 12),
        ],

        // Kết quả
        if (d.ketQuaXuLy != null && d.ketQuaXuLy!.isNotEmpty) ...[
          _SectionCard(
            title: 'Kết quả xử lý',
            titleColor: Colors.green,
            children: [_InfoRow('Kết quả', d.ketQuaXuLy!)],
          ),
          const SizedBox(height: 12),
        ],

        // Lý do hủy
        if (d.lyDoHuy != null && d.lyDoHuy!.isNotEmpty) ...[
          _SectionCard(
            title: 'Lý do hủy',
            titleColor: Colors.red,
            children: [_InfoRow('Lý do', d.lyDoHuy!)],
          ),
          const SizedBox(height: 12),
        ],

        // Ảnh đính kèm
        if (d.danhSachTep.isNotEmpty) ...[
          _SectionCard(
            title: 'Ảnh hiện trạng (${d.danhSachTep.length})',
            children: [
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: d.danhSachTep.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final tep = d.danhSachTep[i];
                    return GestureDetector(
                      onTap: () => FullScreenImageViewer.show(
                        context,
                        files: d.danhSachTep,
                        initialIndex: i,
                      ),
                      child: Hero(
                        tag: 'img_${tep.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tep.fileUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  Widget? _buildBottom() {
    final d = _data;
    if (d == null || !d.coTheChinhSua || _isLoading) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isActioning ? null : _thuHoi,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size.fromHeight(48),
          ),
          icon: _isActioning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.undo),
          label: Text(_isActioning ? 'Đang thu hồi...' : 'Thu hồi yêu cầu'),
        ),
      ),
    );
  }

  Widget _buildNhanSuRow(NhanSuSuaChua ns) {
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
                  ns.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  ns.vaiTro,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (ns.soDienThoai != null)
                  Text(
                    ns.soDienThoai!,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day}/${l.month}/${l.year} '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _fmtCurrency(double v) {
    final format = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return format.format(v);
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final YeuCauSuaChua yeuCau;
  const _StatusBanner({required this.yeuCau});

  Color get _color {
    switch (yeuCau.trangThaiYeuCauId) {
      case TrangThaiYeuCau.pending:
        return Colors.orange;
      case TrangThaiYeuCau.approved:
        return Colors.blue;
      case TrangThaiYeuCau.returned:
        return Colors.amber.shade700;
      case TrangThaiYeuCau.completed:
        return Colors.green;
      case TrangThaiYeuCau.saved:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  IconData get _icon {
    switch (yeuCau.trangThaiYeuCauId) {
      case TrangThaiYeuCau.pending:
        return Icons.hourglass_top;
      case TrangThaiYeuCau.approved:
        return Icons.check_circle_outline;
      case TrangThaiYeuCau.returned:
        return Icons.assignment_return_outlined;
      case TrangThaiYeuCau.completed:
        return Icons.task_alt;
      case TrangThaiYeuCau.saved:
        return Icons.drafts_outlined;
      default:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: c, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yeuCau.trangThaiLabel,
                  style: TextStyle(
                    color: c,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (yeuCau.trangThaiYeuCauId == TrangThaiYeuCau.returned)
                  const Text(
                    'Vui lòng bổ sung thông tin và gửi lại',
                    style: TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
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
