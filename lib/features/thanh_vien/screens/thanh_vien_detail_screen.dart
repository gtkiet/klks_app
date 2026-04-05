// lib/features/cu_tru/screens/thanh_vien_detail_screen.dart
//
// Màn hình chi tiết một thành viên cư trú.
//   - Nhận [thanhVien] (ThanhVienCuTruModel) từ màn hình danh sách
//   - Tự động gọi ThanhVienService.getThongTinCuDan(quanHeCuTruId)
//   - Hiển thị: avatar, thông tin cá nhân, tài liệu cư trú

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';

import '../../cu_tru/models/quan_he_cu_tru_model.dart';

import '../../thanh_vien/models/thanh_vien_cu_tru_model.dart';
import '../../thanh_vien/models/thong_tin_cu_dan_model.dart';
import '../../thanh_vien/services/thanh_vien_service.dart';

class ThanhVienDetailScreen extends StatefulWidget {
  /// Dữ liệu tóm tắt từ list — dùng để hiển thị ngay trong khi chờ API
  final ThanhVienCuTruModel thanhVien;

  /// Thông tin căn hộ — hiển thị ở AppBar
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

  // ── State ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  AppException? _error;
  ThongTinCuDanModel? _data;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData(); // tự động tải khi mở màn hình
  }

  // ── Service call ───────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Dùng quanHeCuTruId từ thanhVien để lấy chi tiết
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

  // ── Build ──────────────────────────────────────────────────────────────
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
          // ── Avatar + tên + trạng thái ──────────────────────────────
          _buildAvatarHeader(d),

          const SizedBox(height: 20),

          // ── Thông tin cá nhân ──────────────────────────────────────
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

          // ── Thông tin cư trú ───────────────────────────────────────
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

          // ── Tài liệu cư trú ───────────────────────────────────────
          if (d.taiLieuCuTrus.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTaiLieuSection(d.taiLieuCuTrus),
          ],
        ],
      ),
    );
  }

  // ── Avatar header ──────────────────────────────────────────────────────
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

  // ── Danh sách tài liệu ────────────────────────────────────────────────
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
            // Danh sách file đính kèm
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
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Section card ──────────────────────────────────────────────────────────
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

// ── Info row ──────────────────────────────────────────────────────────────
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
