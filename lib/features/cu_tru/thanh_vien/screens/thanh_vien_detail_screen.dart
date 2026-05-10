// lib/features/cu_tru/thanh_vien/screens/thanh_vien_detail_screen.dart
//
// Reload chain:
//   • _goToSua: pop(true) từ form → _loadData() → giữ nguyên screen này
//   • _goToXoa: pop(true) từ xoa → Navigator.pop(context, true) →
//     ThanhVienListTab reload

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../quan_he/models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_model.dart';
import 'xoa_yeu_cau_thanh_vien_screen.dart';
import 'yeu_cau_cu_tru_form_screen.dart';
import '../services/thanh_vien_service.dart';
import '../widgets/tv_shared_widgets.dart';

class ThanhVienDetailArgs {
  final ThanhVienCuTruModel thanhVien;
  final QuanHeCuTruModel canHoInfo;

  ThanhVienDetailArgs({
    required this.thanhVien,
    required this.canHoInfo,
  });
}

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
  ThongTinCuDanModel? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _service.getThongTinCuDan(
        widget.thanhVien.quanHeCuTruId,
      );
      setState(() => _data = result);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _goToSua() async {
    if (_data == null) return;
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => YeuCauCuTruFormScreen(
          mode: YeuCauFormEdit(
            thanhVien: widget.thanhVien,
            canHoInfo: widget.canHoInfo,
            thongTinCuDan: _data, // pass data → tránh gọi lại API
          ),
        ),
      ),
    );
    if (reload == true && mounted) _loadData();
  }

  Future<void> _goToXoa() async {
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => XoaYeuCauThanhVienScreen(
          thanhVien: widget.thanhVien,
          canHoInfo: widget.canHoInfo,
        ),
      ),
    );
    // Xóa thành công → pop về list và báo reload.
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
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Tạo yêu cầu sửa',
            onPressed: (_isLoading || _data == null) ? null : _goToSua,
          ),
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
            tooltip: 'Tải lại',
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return TvAsyncLayout(
        isLoading: _isLoading,
      );
    }

    if (_data == null) return const SizedBox.shrink();
    final d = _data!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarHeader(d),
            const SizedBox(height: 20),

            TvSectionCard(
              title: 'Thông tin cá nhân',
              children: [
                TvInfoRow(label: 'Họ tên', value: d.fullName),
                TvInfoRow(label: 'Giới tính', value: d.gioiTinhName),
                if (d.dob != null)
                  TvInfoRow(label: 'Ngày sinh', value: d.dob!.tvFormatted),
                if (d.idCard != null)
                  TvInfoRow(label: 'CMND/CCCD', value: d.idCard!),
                if (d.phoneNumber != null)
                  TvInfoRow(label: 'SĐT', value: d.phoneNumber!),
                if (d.diaChi != null)
                  TvInfoRow(label: 'Địa chỉ', value: d.diaChi!),
              ],
            ),
            const SizedBox(height: 12),

            TvSectionCard(
              title: 'Thông tin cư trú',
              children: [
                TvInfoRow(label: 'Quan hệ', value: d.loaiQuanHeTen),
                TvInfoRow(label: 'Trạng thái', value: d.trangThaiCuTruTen),
                if (d.ngayBatDau != null)
                  TvInfoRow(
                    label: 'Ngày bắt đầu',
                    value: d.ngayBatDau!.tvFormatted,
                  ),
                if (d.ngayKetThuc != null)
                  TvInfoRow(
                    label: 'Ngày kết thúc',
                    value: d.ngayKetThuc!.tvFormatted,
                  ),
              ],
            ),

            if (d.taiLieuCuTrus.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildTaiLieuSection(d.taiLieuCuTrus),
            ],

            const SizedBox(height: 24),

            // ── Action buttons ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _data != null ? _goToSua : null,
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
      ),
    );
  }

  Widget _buildAvatarHeader(ThongTinCuDanModel d) {
    return Row(
      children: [
        TvMemberAvatar(
          imageUrl: d.anhDaiDienUrl,
          name: d.fullName,
          radius: 36,
          fontSize: 28,
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
    return TvSectionCard(
      title: 'Tài liệu cư trú',
      children: taiLieus.map((tl) => _TaiLieuItem(tl: tl)).toList(),
    );
  }
}

// =============================================================================
// TÀI LIỆU ITEM
// =============================================================================

class _TaiLieuItem extends StatelessWidget {
  final TaiLieuCuTruModel tl;
  const _TaiLieuItem({required this.tl});

  @override
  Widget build(BuildContext context) {
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
            'Ngày phát hành: ${tl.ngayPhatHanh!.tvFormatted}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (tl.files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tl.files.map((f) => _FileChip(file: f)).toList(),
            ),
          ),
        const Divider(height: 16),
      ],
    );
  }
}

class _FileChip extends StatelessWidget {
  final TaiLieuFileModel file;
  const _FileChip({required this.file});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(file.fileUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        file.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
        size: 16,
      ),
      label: Text(
        file.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () => _open(context),
    );
  }
}
