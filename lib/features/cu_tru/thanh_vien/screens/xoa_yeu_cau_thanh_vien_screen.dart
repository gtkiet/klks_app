// lib/features/cu_tru/thanh_vien/screens/xoa_yeu_cau_thanh_vien_screen.dart
//
// Tạo yêu cầu LOẠI XÓA (loaiYeuCauId = 3).
// pop(true) khi thành công → caller reload.

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';
import '../../models/quan_he_cu_tru_model.dart';
import '../../widgets/shared_widget.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';
import '../services/tv_yeu_cau_service.dart';
import '../widgets/tv_shared_widgets.dart';

class XoaYeuCauThanhVienScreen extends StatefulWidget {
  final ThanhVienCuTruModel thanhVien;
  final QuanHeCuTruModel canHoInfo;

  const XoaYeuCauThanhVienScreen({
    super.key,
    required this.thanhVien,
    required this.canHoInfo,
  });

  @override
  State<XoaYeuCauThanhVienScreen> createState() =>
      _XoaYeuCauThanhVienScreenState();
}

class _XoaYeuCauThanhVienScreenState extends State<XoaYeuCauThanhVienScreen> {
  final _service = YeuCauCuTruService.instance;
  final _noiDungCtrl = TextEditingController();

  bool _isSubmitting = false;
  AppException? _submitError;

  @override
  void dispose() {
    _noiDungCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isSubmit) async {
    if (_isSubmitting) return;

    if (isSubmit) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận yêu cầu xóa thành viên'),
          content: Text(
            'Bạn đang tạo yêu cầu XÓA thành viên '
            '"${widget.thanhVien.fullName}" khỏi căn hộ. '
            'Sau khi nộp, yêu cầu sẽ chờ BQL phê duyệt. Tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xác nhận xóa'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await _service.createYeuCau(
        TaoYeuCauCuTruRequest(
          canHoId: widget.canHoInfo.canHoId,
          loaiYeuCauId: 3,
          isSubmit: isSubmit,
          targetQuanHeCuTruId: widget.thanhVien.quanHeCuTruId,
          noiDung: _noiDungCtrl.text.trim().isEmpty
              ? null
              : _noiDungCtrl.text.trim(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSubmit
                  ? 'Đã nộp yêu cầu xóa thành viên'
                  : 'Đã lưu nháp yêu cầu xóa',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } on AppException catch (e) {
      setState(() => _submitError = e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu xóa thành viên')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cảnh báo ────────────────────────────────────────────
                  _WarningBanner(thanhVien: widget.thanhVien),
                  const SizedBox(height: 20),

                  // ── Thông tin thành viên (dùng shared card) ────────────
                  TvMemberReadonlyCard(
                    thanhVien: widget.thanhVien,
                    diaChiCanHo: widget.canHoInfo.diaChiDayDu,
                    badgeLabel: 'Xóa',
                    badgeColor: Colors.red,
                  ),
                  const SizedBox(height: 20),

                  if (_submitError != null) ...[
                    AppErrorWidget(error: _submitError!),
                    const SizedBox(height: 12),
                  ],

                  // ── Lý do ────────────────────────────────────────────────
                  const SectionLabel('Lý do yêu cầu xóa (tùy chọn)'),
                  Field(
                    controller: _noiDungCtrl,
                    label: 'Ghi chú / lý do',
                    maxLines: 4,
                    hint: 'Ví dụ: Thành viên đã chuyển đi nơi khác...',
                  ),
                  const SizedBox(height: 32),

                  // ── Buttons ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _submit(false),
                          child: const Text('Lưu nháp'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _submit(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Nộp yêu cầu xóa'),
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
}

// =============================================================================
// WARNING BANNER
// =============================================================================

class _WarningBanner extends StatelessWidget {
  final ThanhVienCuTruModel thanhVien;
  const _WarningBanner({required this.thanhVien});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yêu cầu xóa thành viên',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thao tác này sẽ tạo yêu cầu xóa '
                  '"${thanhVien.fullName}" khỏi danh sách cư trú. '
                  'Yêu cầu cần được BQL phê duyệt trước khi có hiệu lực.',
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
