// lib/features/thanh_vien/screens/tao_yeu_cau_thanh_vien_screen.dart
//
// Screen tạo yêu cầu thêm thành viên cư trú.
//   - Thông tin căn hộ: readonly
//   - Selector: dùng AppSelectorField.future → load từ UtilsService
//   - Upload: dùng AppFileUploadField → upload lên server ngay (trả fileId)
//     File chỉ xóa khỏi danh sách yêu cầu, không xóa trên server
//   - 2 nút: Lưu nháp (isSubmit: false) | Nộp yêu cầu (isSubmit: true)
//   - Thành công: pop + SnackBar

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';
import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../../thanh_vien/models/thanh_vien_request.dart';
import '../../thanh_vien/services/tv_yeu_cau_service.dart';
import '../../utils/models/selector_item_model.dart';
import '../../utils/models/uploaded_file_model.dart';
import '../../utils/services/utils_service.dart';
import '../../utils/widgets/app_selector_field.dart';
import '../../utils/widgets/app_file_upload_field.dart';
import '../models/tai_lieu_cu_tru_request.dart';
import '../../cu_tru/widgets/shared_widget.dart';

class TaoYeuCauThanhVienScreen extends StatefulWidget {
  final QuanHeCuTruModel canHoInfo;
  final int loaiYeuCauId; // 1 = Thêm thành viên

  const TaoYeuCauThanhVienScreen({
    super.key,
    required this.canHoInfo,
    this.loaiYeuCauId = 1,
  });

  @override
  State<TaoYeuCauThanhVienScreen> createState() =>
      _TaoYeuCauThanhVienScreenState();
}

class _TaoYeuCauThanhVienScreenState extends State<TaoYeuCauThanhVienScreen> {
  final _yeuCauService = YeuCauCuTruService.instance;
  final _utilsService = UtilsService();
  final _formKey = GlobalKey<FormState>();

  // ── Text controllers ───────────────────────────────────────────────────
  final _hoCtrl = TextEditingController();
  final _tenCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  // ── Selector state ─────────────────────────────────────────────────────
  SelectorItemModel? _gioiTinh;
  SelectorItemModel? _loaiQuanHe;
  DateTime? _dob;

  // ── Upload state ───────────────────────────────────────────────────────
  // Giữ danh sách file đã upload thành công (có fileId từ server)
  final List<UploadedFileModel> _uploadedFiles = [];

  // ── Submit state ───────────────────────────────────────────────────────
  bool _isSubmitting = false;
  AppException? _submitError;

  @override
  void dispose() {
    _hoCtrl.dispose();
    _tenCtrl.dispose();
    _cccdCtrl.dispose();
    _phoneCtrl.dispose();
    _diaChiCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ────────────────────────────────────────────────────────
  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── Validate + submit ──────────────────────────────────────────────────
  Future<void> _submit(bool isSubmit) async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;
    if (_loaiQuanHe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại quan hệ')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await _yeuCauService.createYeuCau(
        TaoYeuCauCuTruRequest(
          canHoId: widget.canHoInfo.canHoId,
          loaiYeuCauId: widget.loaiYeuCauId,
          isSubmit: isSubmit,
          firstName: _tenCtrl.text.trim(),
          lastName: _hoCtrl.text.trim(),
          gioiTinhId: _gioiTinh?.id,
          dob: _dob,
          cccd: _cccdCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          diaChi: _diaChiCtrl.text.trim(),
          loaiQuanHeId: _loaiQuanHe?.id,
          noiDung: _noiDungCtrl.text.trim(),
          // Đính kèm fileId từ các file đã upload lên server
          taiLieuCuTrus: _uploadedFiles.isNotEmpty
              ? [
                  TaiLieuCuTruRequest(
                    fileIds: _uploadedFiles.map((f) => f.fileId).toList(),
                  ),
                ]
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
      appBar: AppBar(title: const Text('Thêm thành viên')),
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

                  // ── Thông tin cá nhân ────────────────────────────────
                  SectionLabel('Thông tin người thêm'),

                  // Họ + Tên
                  Row(
                    children: [
                      Expanded(
                        child: Field(
                          controller: _hoCtrl,
                          label: 'Họ *',
                          validator: _required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Field(
                          controller: _tenCtrl,
                          label: 'Tên *',
                          validator: _required,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Giới tính — load từ API
                  AppSelectorField.future(
                    label: 'Giới tính',
                    future: _utilsService.getGioiTinhSelector(),
                    selectedItems: _gioiTinh != null ? [_gioiTinh!] : [],
                    onChangedSingle: (v) => setState(() => _gioiTinh = v),
                  ),
                  const SizedBox(height: 12),

                  // Ngày sinh
                  DatePickerField(
                    label: 'Ngày sinh',
                    value: _dob,
                    onTap: _pickDob,
                  ),
                  const SizedBox(height: 12),

                  // CCCD
                  Field(
                    controller: _cccdCtrl,
                    label: 'CMND/CCCD',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // SĐT
                  Field(
                    controller: _phoneCtrl,
                    label: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  // Địa chỉ
                  Field(controller: _diaChiCtrl, label: 'Địa chỉ thường trú'),
                  const SizedBox(height: 12),

                  // Loại quan hệ — load từ API
                  AppSelectorField.future(
                    label: 'Loại quan hệ *',
                    future: _utilsService.getLoaiQuanHeCuTruSelector(),
                    selectedItems: _loaiQuanHe != null ? [_loaiQuanHe!] : [],
                    isRequired: true,
                    onChangedSingle: (v) => setState(() => _loaiQuanHe = v),
                  ),
                  const SizedBox(height: 12),

                  // Ghi chú
                  Field(
                    controller: _noiDungCtrl,
                    label: 'Ghi chú',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // ── Tài liệu đính kèm ────────────────────────────────
                  SectionLabel('Tài liệu đính kèm'),

                  AppFileUploadField(
                    label: 'Hình ảnh / Tài liệu',
                    targetContainer: 'tai-lieu-cu-tru',
                    // Upload lên server ngay khi chọn file → nhận fileId
                    uploadFn: _utilsService.uploadMedia,
                    initialFiles: _uploadedFiles,
                    allowMultiple: true,
                    onChanged: (files) {
                      // Xóa file chỉ xóa khỏi danh sách này,
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
