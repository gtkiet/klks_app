// lib/features/thong_bao/screens/thong_bao_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/thong_bao_model.dart';
import '../services/thong_bao_service.dart';

import 'package:klks_app/core/navigation/app_navigation.dart';
import 'package:klks_app/design/design.dart';

class ThongBaoDetailArgs {
  final ThongBaoItem item;
  const ThongBaoDetailArgs({required this.item});
}

// ─────────────────────────────────────────────────────────────────────────────
// Loại thông báo
// ─────────────────────────────────────────────────────────────────────────────

enum _LoaiThongBao {
  cuTru(1, 'Yêu cầu cư trú'),
  phuongTien(2, 'Yêu cầu phương tiện'),
  thanhToan(3, 'Thanh toán'),
  thiCong(4, 'Yêu cầu thi công'),
  heTang(5, 'Hệ thống'),
  khac(6, 'Khác'),
  suaChua(7, 'Yêu cầu sửa chữa'),
  phanAnh(8, 'Yêu cầu phản ánh');

  const _LoaiThongBao(this.id, this.label);
  final int id;
  final String label;

  static _LoaiThongBao? fromId(int id) {
    for (final v in values) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// Có tab/route để navigate đến.
  bool get hasNavigation => switch (this) {
    cuTru || phuongTien || thanhToan || thiCong || suaChua || phanAnh => true,
    heTang || khac => false,
  };

  IconData get icon => switch (this) {
    cuTru      => Icons.apartment_outlined,
    phuongTien => Icons.two_wheeler_outlined,
    thanhToan  => Icons.receipt_long_outlined,
    thiCong    => Icons.construction_outlined,
    suaChua    => Icons.build_outlined,
    phanAnh    => Icons.campaign_outlined,
    heTang     => Icons.settings_outlined,
    khac       => Icons.notifications_outlined,
  };

  AppBadgeVariant get badgeVariant => switch (this) {
    thanhToan       => AppBadgeVariant.success,
    heTang || khac  => AppBadgeVariant.info,
    _               => AppBadgeVariant.warning,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ThongBaoDetailScreen extends StatefulWidget {
  final ThongBaoItem item;

  const ThongBaoDetailScreen({super.key, required this.item});

  @override
  State<ThongBaoDetailScreen> createState() => _ThongBaoDetailScreenState();
}

class _ThongBaoDetailScreenState extends State<ThongBaoDetailScreen> {
  final _service = ThongBaoService.instance;
  late ThongBaoItem _item;
  bool _isMarkingRead = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    if (!_item.isRead) _markAsRead();
  }

  Future<void> _markAsRead() async {
    setState(() => _isMarkingRead = true);

    final result = await _service.daDDoc(phanBoThongBaoId: _item.id);

    if (!mounted) return;
    setState(() => _isMarkingRead = false);

    if (result.isOk) {
      setState(() {
        _item = _item.copyWith(isRead: true, readAt: DateTime.now());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!)),
      );
    }
  }

  // ── Navigate theo loại thông báo ──────────────────────────────────────
  //
  // Hiện tại navigate đến tab tương ứng — khi server confirm referenceId
  // là yeuCauId thì có thể push thẳng đến detail screen.

  void _navigateToSource() {
    final loai = _LoaiThongBao.fromId(_item.loaiThongBaoId);
    if (loai == null || !loai.hasNavigation) return;

    switch (loai) {
      case _LoaiThongBao.cuTru:
      case _LoaiThongBao.phuongTien:
        // Phương tiện nằm trong tab Cư trú.
        AppNavigation.goResidence();

      case _LoaiThongBao.thanhToan:
        // Tab Tiện ích → Hóa đơn.
        AppNavigation.goTienIch();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) context.push('/dich-vu/hoa-don');
        });

      case _LoaiThongBao.thiCong:
        AppNavigation.goTienIchThiCong();

      case _LoaiThongBao.suaChua:
        AppNavigation.goTienIchSuaChua();

      case _LoaiThongBao.phanAnh:
        // Tab Tiện ích → Phản ánh.
        AppNavigation.goTienIch();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) context.push('/dich-vu/phan-anh');
        });

      case _LoaiThongBao.heTang:
      case _LoaiThongBao.khac:
        break;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loai = _LoaiThongBao.fromId(_item.loaiThongBaoId);

    return AppScaffold(
      appBar: AppTopBar(
        title: 'Chi tiết thông báo',
        actions: [
          if (_isMarkingRead)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: AppConstants.spinnerSize,
                height: AppConstants.spinnerSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppConstants.spinnerStrokeWidth,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                _item.isRead ? Icons.done_all : Icons.circle_outlined,
                color:
                    _item.isRead ? AppColors.success : AppColors.textDisabled,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Badge loại thông báo ────────────────────────────────
            if (loai != null)
              Row(
                children: [
                  Icon(loai.icon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  AppStatusBadge(
                    label: loai.label,
                    variant: loai.badgeVariant,
                  ),
                ],
              )
            else if (_item.tenLoaiThongBao.isNotEmpty)
              AppStatusBadge(
                label: _item.tenLoaiThongBao,
                variant: AppBadgeVariant.info,
              ),

            const SizedBox(height: AppSpacing.md),

            // ── Tiêu đề ────────────────────────────────────────────
            Text(_item.tieuDe, style: AppTypography.headline),
            const SizedBox(height: AppSpacing.sm),

            // ── Thời gian + trạng thái đọc ─────────────────────────
            Row(
              children: [
                const Icon(Icons.access_time_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _item.thoiGianHienThi,
                  style: AppTypography.captionSmall.secondary,
                ),
                if (_item.isRead) ...[
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.done_all,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'Đã đọc',
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),

            const Divider(height: 32),

            // ── Nội dung ───────────────────────────────────────────
            Text(
              _item.noiDung,
              style: AppTypography.body.copyWith(height: 1.7),
            ),

            // ── Nút navigate đến màn hình liên quan ────────────────
            if (loai != null && loai.hasNavigation) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Xem ${loai.label}',
                variant: AppButtonVariant.outline,
                leadingIcon: loai.icon,
                onPressed: _navigateToSource,
              ),
            ],

            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}