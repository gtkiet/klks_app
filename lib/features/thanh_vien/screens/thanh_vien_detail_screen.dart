// lib/features/thanh_vien/screens/thanh_vien_detail_screen.dart

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';
import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thong_tin_cu_dan_model.dart';
import '../screens/sua_yeu_cau_thanh_vien_screen.dart';
import '../screens/xoa_yeu_cau_thanh_vien_screen.dart';
import '../services/thanh_vien_service.dart';

class ThanhVienDetailScreen extends StatefulWidget {
  final ThanhVienCuTruModel thanhVien;
  final QuanHeCuTruModel canHoInfo;

  const ThanhVienDetailScreen({
    super.key,
    required this.thanhVien,
    required this.canHoInfo,
  });

  @override
  State<ThanhVienDetailScreen> createState() => _ThanhVienDetailScreenState();
}

class _ThanhVienDetailScreenState extends State<ThanhVienDetailScreen> {
  final _service = ThanhVienService.instance;

  bool _isLoading = false;
  AppException? _error;
  ThongTinCuDanModel? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _service.getThongTinCuDan(
        widget.thanhVien.quanHeCuTruId,
      );
      setState(() => _data = result);
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToSua() async {
    if (_data == null) return;
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SuaYeuCauThanhVienScreen(
          thanhVien: widget.thanhVien,
          canHoInfo: widget.canHoInfo,
          // Truyền thongTinCuDan để pre-fill form
          thongTinCuDan: _data,
        ),
      ),
    );
    if (reload == true && mounted) _loadData();
  }

  void _goToXoa() async {
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => XoaYeuCauThanhVienScreen(
          thanhVien: widget.thanhVien,
          canHoInfo: widget.canHoInfo,
        ),
      ),
    );
    if (reload == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.thanhVien.fullName,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.canHoInfo.diaChiDayDu,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          // Nút Sửa
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Tạo yêu cầu sửa',
            onPressed: (_isLoading || _data == null) ? null : _goToSua,
          ),
          // Nút Xóa
          IconButton(
            icon: Icon(
              Icons.person_remove_outlined,
              color: Colors.red.shade400,
            ),
            tooltip: 'Tạo yêu cầu xóa',
            onPressed: _isLoading ? null : _goToXoa,
          ),
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
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

    if (_data == null) return const SizedBox.shrink();
    final d = _data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatarHeader(d),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Thông tin cá nhân',
            children: [
              _InfoRow(label: 'Họ tên', value: d.fullName),
              _InfoRow(label: 'Giới tính', value: d.gioiTinhName),
              if (d.dob != null)
                _InfoRow(label: 'Ngày sinh', value: _fmtDate(d.dob!)),
              if (d.idCard != null)
                _InfoRow(label: 'CMND/CCCD', value: d.idCard!),
              if (d.phoneNumber != null)
                _InfoRow(label: 'SĐT', value: d.phoneNumber!),
              if (d.diaChi != null)
                _InfoRow(label: 'Địa chỉ', value: d.diaChi!),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Thông tin cư trú',
            children: [
              _InfoRow(label: 'Quan hệ', value: d.loaiQuanHeTen),
              _InfoRow(label: 'Trạng thái', value: d.trangThaiCuTruTen),
              if (d.ngayBatDau != null)
                _InfoRow(label: 'Ngày bắt đầu', value: _fmtDate(d.ngayBatDau!)),
              if (d.ngayKetThuc != null)
                _InfoRow(
                  label: 'Ngày kết thúc',
                  value: _fmtDate(d.ngayKetThuc!),
                ),
            ],
          ),
          if (d.taiLieuCuTrus.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTaiLieuSection(d.taiLieuCuTrus),
          ],
          const SizedBox(height: 24),
          // ── Action buttons ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _goToSua,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Tạo yêu cầu sửa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _goToXoa,
                  icon: const Icon(Icons.person_remove_outlined),
                  label: const Text('Tạo yêu cầu xóa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAvatarHeader(ThongTinCuDanModel d) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage: d.anhDaiDienUrl != null
              ? NetworkImage(d.anhDaiDienUrl!)
              : null,
          child: d.anhDaiDienUrl == null
              ? Text(
                  d.fullName.isNotEmpty ? d.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 28),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.fullName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(d.trangThaiCuTruTen),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaiLieuSection(List<TaiLieuCuTruModel> taiLieus) {
    return _SectionCard(
      title: 'Tài liệu cư trú',
      children: taiLieus.map((tl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl.tenLoaiGiayTo,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (tl.soGiayTo.isNotEmpty)
              Text(
                'Số: ${tl.soGiayTo}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (tl.ngayPhatHanh != null)
              Text(
                'Ngày phát hành: ${_fmtDate(tl.ngayPhatHanh!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ...tl.files.map(
              (f) => Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Row(
                  children: [
                    Icon(
                      f.isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        f.fileName,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 16),
          ],
        );
      }).toList(),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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
            width: 120,
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
