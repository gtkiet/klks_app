// lib/features/thong_bao/screens/thong_bao_detail_screen.dart

import 'package:flutter/material.dart';

import '../models/thong_bao_model.dart';
import '../services/thong_bao_service.dart';

import 'package:klks_app/design/design.dart';

class ThongBaoDetailArgs {
  final ThongBaoItem item;
  const ThongBaoDetailArgs({required this.item});
}

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

  @override
  Widget build(BuildContext context) {
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
                color: _item.isRead ? AppColors.success : AppColors.textDisabled,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge loại thông báo
            if (_item.tenLoaiThongBao.isNotEmpty) ...[
              AppStatusBadge(
                label: _item.tenLoaiThongBao,
                variant: AppBadgeVariant.info,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Tiêu đề
            Text(
              _item.tieuDe,
              style: AppTypography.headline,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Thời gian tạo & trạng thái đọc
            Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _item.thoiGianHienThi,
                  style: AppTypography.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_item.isRead) ...[
                  const SizedBox(width: AppSpacing.md),
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: AppColors.success,
                  ),
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

            // Nội dung
            Text(
              _item.noiDung,
              style: AppTypography.body.copyWith(height: 1.7),
            ),

            // TODO: parse metadata JSON để điều hướng đến màn hình liên quan.
            // Ví dụ: nếu loaiThongBaoId == 1 → navigate đến màn hình hóa đơn:
            // context.push('/hoa-don/${_item.referenceId}')
          ],
        ),
      ),
    );
  }
}