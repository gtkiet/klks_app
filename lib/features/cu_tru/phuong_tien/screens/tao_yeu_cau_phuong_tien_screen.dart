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

import '../../../../core/errors/errors.dart';

import '../../models/quan_he_cu_tru_model.dart';
import '../../models/selector_item_model.dart';
import '../../models/uploaded_file_model.dart';

import '../../widgets/shared_widget.dart';
import '../../widgets/selector_field.dart';
import '../../widgets/file_upload_field.dart';

import '../models/phuong_tien_request_models.dart';

import '../services/pt_yeu_cau_service.dart';

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
  final _ptService = PTYeuCauService.instance;
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ───────────────────────────────────────────────────
  final _tenXeCtrl = TextEditingController();
  final _bienSoCtrl = TextEditingController();
  final _mauXeCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  // ── Selector state ─────────────────────────────────────────────────────
  SelectorItemModel? _loaiPhuongTien;

  // ── Upload state ───────────────────────────────────────────────────────
  // File upload lên server ngay → giữ fileId để đính vào request
  // Xóa khỏi list = xóa khỏi yêu cầu, không gọi API xóa server
  final List<UploadedFileModel> _uploadedFiles = [];

  // ── Submit state ───────────────────────────────────────────────────────
  bool _isSubmitting = false;
  AppException? _submitError;

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

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

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
          // fileIds từ các ảnh đã upload lên server
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
    } on AppException catch (e) {
      setState(() => _submitError = e);
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

                  // ── Lỗi submit ───────────────────────────────────────
                  if (_submitError != null) ...[
                    AppErrorWidget(error: _submitError!),
                    const SizedBox(height: 12),
                  ],

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
                    // Upload lên server ngay khi chọn → nhận fileId
                    uploadFn: _ptService.uploadMedia,
                    initialFiles: _uploadedFiles,
                    allowMultiple: true,
                    onChanged: (files) {
                      // Xóa file: chỉ xóa khỏi list,
                      // không gọi API xóa trên server
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
