// lib/features/cu_tru/phuong_tien/screens/tao_yeu_cau_phuong_tien_screen.dart
//
// Screen tạo yêu cầu đăng ký phương tiện mới.
//   - Thông tin căn hộ: readonly
//   - Loại phương tiện: AppSelectorField.future → UtilsService.getLoaiPhuongTienSelector
//   - Upload: AppFileUploadField → upload lên server ngay (trả fileId)
//     File chỉ xóa khỏi danh sách yêu cầu, không xóa trên server
//   - 2 nút: Lưu nháp (isSubmit: false) | Nộp yêu cầu (isSubmit: true)
//   - Thành công: pop + SnackBar

import 'package:flutter/material.dart';

import '../../quan_he/models/quan_he_cu_tru_model.dart';

import '../../quan_he/widgets/shared_widget.dart';
import '../../quan_he/widgets/selector_field.dart';
import '../../quan_he/widgets/file_upload_field.dart';

import '../models/phuong_tien_model.dart';
import '../services/phuong_tien_service.dart';


class TaoYeuCauPhuongTienScreen extends StatefulWidget {
  final QuanHeCuTruModel canHoInfo;
  final int loaiYeuCauId; // 1 = Đăng ký xe mới

  const TaoYeuCauPhuongTienScreen({
    super.key,
    required this.canHoInfo,
    this.loaiYeuCauId = 1,
  });

  @override
  State<TaoYeuCauPhuongTienScreen> createState() =>
      _TaoYeuCauPhuongTienScreenState();
}

class _TaoYeuCauPhuongTienScreenState extends State<TaoYeuCauPhuongTienScreen> {
  final _ptService = PhuongTienService.instance;
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ───────────────────────────────────────────────────
  final _tenXeCtrl = TextEditingController();
  final _bienSoCtrl = TextEditingController();
  final _mauXeCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  // ── Selector state ─────────────────────────────────────────────────────
  SelectorItemModel? _loaiPhuongTien;

  // ── Upload state ───────────────────────────────────────────────────────
  final List<UploadedFileModel> _uploadedFiles = [];

  // ── Submit state ───────────────────────────────────────────────────────
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tenXeCtrl.dispose();
    _bienSoCtrl.dispose();
    _mauXeCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  // ── Validate + submit ──────────────────────────────────────────────────
  Future<void> _submit(bool isSubmit) async {
    if (!_formKey.currentState!.validate()) return;
    if (_loaiPhuongTien == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại phương tiện')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _ptService.taoYeuCau(
        TaoYeuCauPhuongTienRequest(
          canHoId: widget.canHoInfo.canHoId,
          loaiYeuCauId: widget.loaiYeuCauId,
          isSubmit: isSubmit,
          yeuCauLoaiPhuongTienId: _loaiPhuongTien?.id,
          yeuCauTenPhuongTien: _tenXeCtrl.text.trim(),
          yeuCauBienSo: _bienSoCtrl.text.trim(),
          yeuCauMauXe: _mauXeCtrl.text.trim(),
          noiDung: _noiDungCtrl.text.trim(),
          fileIds: _uploadedFiles.isNotEmpty
              ? _uploadedFiles.map((f) => f.fileId).toList()
              : null,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSubmit ? 'Đã nộp yêu cầu thành công' : 'Đã lưu nháp',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký phương tiện')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Căn hộ (readonly) ────────────────────────────────
                  ReadonlyCanHoCard(canHoInfo: widget.canHoInfo),
                  const SizedBox(height: 20),

                  // ── Thông tin phương tiện ────────────────────────────
                  SectionLabel('Thông tin phương tiện'),

                  // Loại phương tiện — load từ API catalog
                  AppSelectorField.future(
                    label: 'Loại phương tiện *',
                    future: _ptService.getLoaiPhuongTienSelector(),
                    selectedItems: _loaiPhuongTien != null
                        ? [_loaiPhuongTien!]
                        : [],
                    isRequired: true,
                    onChangedSingle: (v) => setState(() => _loaiPhuongTien = v),
                  ),
                  const SizedBox(height: 12),

                  // Tên xe
                  Field(
                    controller: _tenXeCtrl,
                    label: 'Tên xe *',
                    hint: 'VD: Honda Wave Alpha, Toyota Vios...',
                    validator: _required,
                  ),
                  const SizedBox(height: 12),

                  // Biển số
                  Field(
                    controller: _bienSoCtrl,
                    label: 'Biển số *',
                    hint: 'VD: 51A-123.45',
                    textCapitalization: TextCapitalization.characters,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),

                  // Màu xe
                  Field(
                    controller: _mauXeCtrl,
                    label: 'Màu xe',
                    hint: 'VD: Đỏ, Trắng, Đen...',
                  ),
                  const SizedBox(height: 12),

                  // Ghi chú
                  Field(
                    controller: _noiDungCtrl,
                    label: 'Ghi chú',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // ── Hình ảnh phương tiện ─────────────────────────────
                  SectionLabel('Hình ảnh phương tiện'),

                  AppFileUploadField(
                    label: 'Ảnh xe (tùy chọn)',
                    targetContainer: 'tai-lieu-phuong-tien',
                    uploadFn: _ptService.uploadMedia,
                    initialFiles: _uploadedFiles,
                    allowMultiple: true,
                    onChanged: (files) {
                      setState(() {
                        _uploadedFiles
                          ..clear()
                          ..addAll(files);
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── 2 nút submit ─────────────────────────────────────
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
                          child: const Text('Nộp yêu cầu'),
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Trường này là bắt buộc' : null;
}