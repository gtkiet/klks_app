// lib/features/thanh_vien/screens/tao_yeu_cau_thanh_vien_screen.dart

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';
import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../../cu_tru/widgets/shared_widget.dart';
import '../widgets/tai_lieu_cu_tru_editor.dart';
import '../models/tai_lieu_cu_tru_request.dart';
import '../models/thanh_vien_request.dart';
import '../services/tv_yeu_cau_service.dart';
import '../../utils/models/selector_item_model.dart';
import '../../utils/services/utils_service.dart';
import '../../utils/widgets/app_selector_field.dart';

class TaoYeuCauThanhVienScreen extends StatefulWidget {
  final QuanHeCuTruModel canHoInfo;
  final int loaiYeuCauId;

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
  final _scrollCtrl = ScrollController();

  // ── Controllers ────────────────────────────────────────────────────────
  final _hoCtrl = TextEditingController();
  final _tenCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  // ── Selector state (bắt buộc) ──────────────────────────────────────────
  SelectorItemModel? _gioiTinh;
  SelectorItemModel? _loaiQuanHe;
  DateTime? _dob;

  // ── Tài liệu — quản lý bởi TaiLieuCuTruEditor ─────────────────────────
  List<TaiLieuCuTruRequest> _taiLieuCuTrus = [];

  // ── Submit state ───────────────────────────────────────────────────────
  bool _isSubmitting = false;
  AppException? _submitError;

  // Cache future
  late final Future<List<SelectorItemModel>> _gioiTinhFuture = _utilsService
      .getGioiTinhSelector();
  late final Future<List<SelectorItemModel>> _loaiQuanHeFuture = _utilsService
      .getLoaiQuanHeCuTruSelector();

  @override
  void dispose() {
    _hoCtrl.dispose();
    _tenCtrl.dispose();
    _cccdCtrl.dispose();
    _phoneCtrl.dispose();
    _diaChiCtrl.dispose();
    _noiDungCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Validate selector/datepicker bắt buộc ─────────────────────────────
  bool _validateRequiredFields() {
    final missing = <String>[
      if (_dob == null) 'Ngày sinh',
      if (_gioiTinh == null) 'Giới tính',
      if (_loaiQuanHe == null) 'Loại quan hệ',
    ];
    if (missing.isNotEmpty) {
      _showSnack('Vui lòng điền: ${missing.join(', ')}');
      return false;
    }
    return true;
  }

  // ── Submit ─────────────────────────────────────────────────────────────
  Future<void> _submit(bool isSubmit) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateRequiredFields()) return;

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
          // Bắt buộc khi Thêm mới
          firstName: _tenCtrl.text.trim(),
          lastName: _hoCtrl.text.trim(),
          dob: _dob,
          gioiTinhId: _gioiTinh!.id,
          loaiQuanHeId: _loaiQuanHe!.id,
          // Tùy chọn
          cccd: _cccdCtrl.text.trim().isEmpty ? null : _cccdCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
          diaChi: _diaChiCtrl.text.trim().isEmpty
              ? null
              : _diaChiCtrl.text.trim(),
          noiDung: _noiDungCtrl.text.trim().isEmpty
              ? null
              : _noiDungCtrl.text.trim(),
          // Tài liệu từ editor — chỉ include entry có file
          taiLieuCuTrus: _taiLieuCuTrus.isEmpty ? null : _taiLieuCuTrus,
        ),
      );

      if (mounted) {
        _showSnack(isSubmit ? 'Đã nộp yêu cầu thành công' : 'Đã lưu nháp');
        Navigator.pop(context, true);
      }
    } on AppException catch (e) {
      setState(() => _submitError = e);
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
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
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                children: [
                  // Căn hộ readonly
                  ReadonlyCanHoCard(canHoInfo: widget.canHoInfo),
                  const SizedBox(height: 20),

                  // Lỗi submit
                  if (_submitError != null) ...[
                    AppErrorWidget(error: _submitError!),
                    const SizedBox(height: 12),
                  ],

                  // ── Thông tin bắt buộc ───────────────────────────────
                  const SectionLabel('Thông tin người thêm *'),

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

                  DatePickerField(
                    label: 'Ngày sinh *',
                    value: _dob,
                    onTap: _pickDob,
                  ),
                  const SizedBox(height: 12),

                  AppSelectorField.future(
                    label: 'Giới tính *',
                    future: _gioiTinhFuture,
                    selectedItems: _gioiTinh != null ? [_gioiTinh!] : [],
                    isRequired: true,
                    onChangedSingle: (v) => setState(() => _gioiTinh = v),
                  ),
                  const SizedBox(height: 12),

                  AppSelectorField.future(
                    label: 'Loại quan hệ *',
                    future: _loaiQuanHeFuture,
                    selectedItems: _loaiQuanHe != null ? [_loaiQuanHe!] : [],
                    isRequired: true,
                    onChangedSingle: (v) => setState(() => _loaiQuanHe = v),
                  ),
                  const SizedBox(height: 20),

                  // ── Thông tin tùy chọn ───────────────────────────────
                  const SectionLabel('Thông tin bổ sung'),

                  Field(
                    controller: _cccdCtrl,
                    label: 'CMND/CCCD',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  Field(
                    controller: _phoneCtrl,
                    label: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  Field(controller: _diaChiCtrl, label: 'Địa chỉ thường trú'),
                  const SizedBox(height: 12),

                  Field(
                    controller: _noiDungCtrl,
                    label: 'Ghi chú',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // ── Tài liệu đính kèm ────────────────────────────────
                  const SectionLabel('Tài liệu đính kèm'),

                  // Editor quản lý nhiều tài liệu, mỗi tài liệu nhiều file
                  TaiLieuCuTruEditor(
                    onChanged: (list) => setState(() => _taiLieuCuTrus = list),
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
