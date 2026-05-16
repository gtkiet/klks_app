// lib/features/cu_tru/phuong_tien/screens/phuong_tien_detail_screen.dart
//
// Màn hình chi tiết một phương tiện.
//   - Nhận [phuongTienId] + optional [snapshot] để hiển thị ngay khi chờ API
//   - Actions: Sửa / Xoá / Báo mất thẻ → TaoYeuCauPhuongTienScreen

import 'package:flutter/material.dart';

import '../models/phuong_tien_model.dart';
import '../services/phuong_tien_service.dart';
import 'tao_yeu_cau_phuong_tien_screen.dart';

import 'package:klks_app/design/design.dart';

class PhuongTienDetailArgs {
  final int phuongTienId;
  final PhuongTien? snapshot;
  final QuanHeCuTruModel canHoInfo;

  const PhuongTienDetailArgs({
    required this.phuongTienId,
    required this.canHoInfo,
    this.snapshot,
  });
}

class PhuongTienDetailScreen extends StatefulWidget {
  final int phuongTienId;
  final PhuongTien? snapshot;

  /// Cần để tạo yêu cầu Sửa/Xóa — truyền từ màn hình trước.
  final QuanHeCuTruModel canHoInfo;

  const PhuongTienDetailScreen({
    super.key,
    required this.phuongTienId,
    required this.canHoInfo,
    this.snapshot,
  });

  @override
  State<PhuongTienDetailScreen> createState() => _PhuongTienDetailScreenState();
}

class _PhuongTienDetailScreenState extends State<PhuongTienDetailScreen> {
  final _service = PhuongTienService.instance;

  bool _isLoading = false;
  String? _error;
  PhuongTien? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.snapshot;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getPhuongTienById(widget.phuongTienId);
      if (!mounted) return;
      setState(() => _data = result);
    } on Exception catch (e) {
      if (!mounted) return;
      // Nếu đã có snapshot thì chỉ show lỗi nhỏ, không block UI.
      if (_data == null) {
        setState(() => _error = e.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể làm mới: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Navigate tạo yêu cầu ───────────────────────────────────────────────

  Future<void> _goTaoYeuCau(int loaiYeuCauId) async {
    if (_data == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaoYeuCauPhuongTienScreen(
          canHoInfo: widget.canHoInfo,
          loaiYeuCauId: loaiYeuCauId,
          phuongTien: _data,
        ),
      ),
    );
    // Reload nếu yêu cầu được tạo thành công.
    if (result == true && mounted) _loadData();
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title = _data?.bienSo ?? 'Chi tiết phương tiện';

    return AppScaffold(
      appBar: AppTopBar(
        title: title,
        actions: [
          if (_data != null) ...[
            // Menu yêu cầu
            PopupMenuButton<int>(
              tooltip: 'Tạo yêu cầu',
              icon: const Icon(Icons.more_vert),
              onSelected: _goTaoYeuCau,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Yêu cầu sửa thông tin'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Yêu cầu huỷ đăng ký',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Không có data và đang lỗi.
    if (_data == null && _error != null) {
      return ErrorDisplay(error: _error, onRetry: _loadData);
    }

    // Không có data và đang load.
    if (_data == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final d = _data!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh phương tiện
          if (d.hinhAnhPhuongTiens.isNotEmpty)
            _ImageGallery(images: d.hinhAnhPhuongTiens),

          // Loading bar khi refresh (có snapshot rồi)
          if (_isLoading) const LinearProgressIndicator(color: AppColors.primary),

          Padding(
            padding: AppSpacing.insetAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon + biển số + trạng thái
                _VehicleHeader(d: d),
                const SizedBox(height: AppSpacing.md),

                // Thông tin chính
                _SectionCard(
                  title: 'Thông tin phương tiện',
                  children: [
                    _InfoRow('Biển số', d.bienSo),
                    _InfoRow('Tên xe', d.tenPhuongTien),
                    _InfoRow('Loại', d.tenLoaiPhuongTien),
                    _InfoRow('Màu xe', d.mauXe),
                    _InfoRow('Vị trí', d.viTriNgan),
                    _InfoRow('Trạng thái', d.tenTrangThaiPhuongTien),
                  ],
                ),

                // Danh sách thẻ
                if (d.thePhuongTiens.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _TheSection(theList: d.thePhuongTiens),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Quick action: báo mất thẻ (nếu có thẻ active)
                if (d.thePhuongTiens.any((t) => t.trangThaiThePhuongTienId == 1))
                  AppButton(
                    label: 'Báo mất thẻ',
                    variant: AppButtonVariant.outline,
                    leadingIcon: Icons.credit_card_off_outlined,
                    onPressed: () => _goTaoYeuCau(2),
                    // Dùng loai=2 (Sửa) làm entry point để mở sheet báo mất thẻ
                    // thực ra screen sẽ detect và show bottom sheet riêng.
                    // Nếu muốn trực tiếp: truyền showBaoMatThe flag.
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
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ImageGallery extends StatelessWidget {
  final List<FileAttachment> images;
  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, i) => Image.network(
          images[i].fileUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.broken_image_outlined,
                size: 48, color: AppColors.textDisabled),
          ),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
    );
  }
}

class _VehicleHeader extends StatelessWidget {
  final PhuongTien d;
  const _VehicleHeader({required this.d});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.card,
          ),
          child: Icon(_loaiIcon(d.loaiPhuongTienId),
              size: 28, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.bienSo, style: AppTypography.headline),
              Text(
                '${d.tenLoaiPhuongTien} • ${d.mauXe}',
                style: AppTypography.body.secondary,
              ),
            ],
          ),
        ),
        AppStatusBadge(
          label: d.tenTrangThaiPhuongTien,
          variant: _trangThaiVariant(d.trangThaiPhuongTienId),
        ),
      ],
    );
  }

  AppBadgeVariant _trangThaiVariant(int id) => switch (id) {
    1 => AppBadgeVariant.success,
    2 => AppBadgeVariant.info,
    _ => AppBadgeVariant.warning,
  };

  IconData _loaiIcon(int id) => switch (id) {
    1 => Icons.two_wheeler,
    2 => Icons.directions_car,
    3 => Icons.pedal_bike,
    _ => Icons.commute,
  };
}

class _TheSection extends StatelessWidget {
  final List<ThePhuongTien> theList;
  const _TheSection({required this.theList});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Thẻ phương tiện (${theList.length})',
      children: theList.map((the) => _TheTile(the: the)).toList(),
    );
  }
}

class _TheTile extends StatelessWidget {
  final ThePhuongTien the;
  const _TheTile({required this.the});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.credit_card_outlined,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(the.maThe, style: AppTypography.subhead),
                if (the.ngayBatDau != null || the.ngayKetThuc != null)
                  Text(
                    [
                      if (the.ngayBatDau != null)
                        'Từ: ${_fmtDate(the.ngayBatDau!)}',
                      if (the.ngayKetThuc != null)
                        'Đến: ${_fmtDate(the.ngayKetThuc!)}',
                    ].join('  •  '),
                    style: AppTypography.captionSmall.secondary,
                  ),
              ],
            ),
          ),
          AppStatusBadge(
            label: the.tenTrangThaiThePhuongTien,
            variant: the.trangThaiThePhuongTienId == 1
                ? AppBadgeVariant.success
                : AppBadgeVariant.info,
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.subhead),
          const Divider(height: AppSpacing.lg),
          ...children,
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTypography.caption.secondary),
          ),
          Expanded(
            child: Text(value, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}