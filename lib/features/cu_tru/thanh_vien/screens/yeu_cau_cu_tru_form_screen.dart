// lib/features/cu_tru/thanh_vien/screens/yeu_cau_cu_tru_form_screen.dart
//
// Màn hình form dùng chung cho 3 luồng:
//   • create — Tạo yêu cầu THÊM thành viên mới (loaiYeuCauId = 1)
//   • edit   — Tạo yêu cầu SỬA thành viên (loaiYeuCauId = 2),
//              pre-fill từ ThongTinCuDanModel
//   • draft  — Chỉnh sửa yêu cầu NHÁP đã lưu (gọi updateYeuCau)
//
// Reload chain:
//   Screen này luôn pop(true) khi thành công → caller tự reload.

import 'package:flutter/material.dart';

import '../../quan_he/models/quan_he_cu_tru_model.dart';
import '../../quan_he/models/selector_item_model.dart';
import '../../quan_he/widgets/selector_field.dart';
import '../../quan_he/widgets/shared_widget.dart';

import '../models/tai_lieu_cu_tru_request.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';
import '../models/thong_tin_cu_dan_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';

import '../services/thanh_vien_service.dart';
import '../services/tv_yeu_cau_service.dart';

import '../widgets/tai_lieu_cu_tru_editor.dart';
import '../widgets/tv_shared_widgets.dart';

// =============================================================================
// MODE
// =============================================================================

sealed class YeuCauFormMode {
  const YeuCauFormMode();
}

/// Tạo yêu cầu THÊM thành viên (loaiYeuCauId = 1).
class YeuCauFormCreate extends YeuCauFormMode {
  final QuanHeCuTruModel canHoInfo;
  const YeuCauFormCreate({required this.canHoInfo});
}

/// Tạo yêu cầu SỬA thành viên (loaiYeuCauId = 2).
class YeuCauFormEdit extends YeuCauFormMode {
  final ThanhVienCuTruModel thanhVien;
  final QuanHeCuTruModel canHoInfo;
  final ThongTinCuDanModel? thongTinCuDan;

  const YeuCauFormEdit({
    required this.thanhVien,
    required this.canHoInfo,
    this.thongTinCuDan,
  });
}

/// Chỉnh sửa yêu cầu NHÁP (trangThaiId = 4) — gọi updateYeuCau.
class YeuCauFormDraft extends YeuCauFormMode {
  final int yeuCauId;
  const YeuCauFormDraft({required this.yeuCauId});
}

// =============================================================================
// SCREEN
// =============================================================================

class YeuCauCuTruFormScreen extends StatefulWidget {
  final YeuCauFormMode mode;

  const YeuCauCuTruFormScreen({super.key, required this.mode});

  @override
  State<YeuCauCuTruFormScreen> createState() => _YeuCauCuTruFormScreenState();
}

class _YeuCauCuTruFormScreenState extends State<YeuCauCuTruFormScreen> {
  final _yeuCauSvc = YeuCauCuTruService.instance;
  final _thanhVienSvc = ThanhVienService.instance;

  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  // ── Load state ─────────────────────────────────────────────────────────
  bool _isLoading = false;

  // ── Dữ liệu resolve khi load ────────────────────────────────────────────
  YeuCauCuTruModel? _draftYeuCau;
  ThongTinCuDanModel? _cuDan;

  // ── Form controllers ────────────────────────────────────────────────────
  final _hoCtrl = TextEditingController();
  final _tenCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  DateTime? _dob;
  SelectorItemModel? _gioiTinh;
  SelectorItemModel? _loaiQuanHe;

  // ── Tài liệu ────────────────────────────────────────────────────────────
  final _taiLieuNotifier = ValueNotifier<List<TaiLieuCuTruRequest>>([]);

  // ── Submit state ────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  // ── Catalog futures ─────────────────────────────────────────────────────
  late final Future<List<SelectorItemModel>> _gioiTinhFuture = _yeuCauSvc
      .getGioiTinhSelector();
  late final Future<List<SelectorItemModel>> _loaiQuanHeFuture = _yeuCauSvc
      .getLoaiQuanHeCuTruSelector();

  // ── Computed helpers ────────────────────────────────────────────────────

  bool get _isCreate => widget.mode is YeuCauFormCreate;
  bool get _isEdit => widget.mode is YeuCauFormEdit;
  bool get _isDraft => widget.mode is YeuCauFormDraft;

  QuanHeCuTruModel? get _canHoInfo => switch (widget.mode) {
    YeuCauFormCreate(canHoInfo: final c) => c,
    YeuCauFormEdit(canHoInfo: final c) => c,
    _ => null,
  };

  ThanhVienCuTruModel? get _thanhVien => switch (widget.mode) {
    YeuCauFormEdit(thanhVien: final m) => m,
    _ => null,
  };

  String get _appBarTitle => switch (widget.mode) {
    YeuCauFormCreate() => 'Thêm thành viên',
    YeuCauFormEdit() => 'Yêu cầu sửa thành viên',
    YeuCauFormDraft(yeuCauId: final id) => 'Chỉnh sửa yêu cầu #$id',
  };

  String get _sectionLabel => switch (widget.mode) {
    YeuCauFormCreate() => 'Thông tin người thêm *',
    YeuCauFormEdit() => 'Thông tin cần sửa *',
    YeuCauFormDraft() => 'Thông tin người được yêu cầu *',
  };

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  void dispose() {
    _hoCtrl.dispose();
    _tenCtrl.dispose();
    _cccdCtrl.dispose();
    _phoneCtrl.dispose();
    _diaChiCtrl.dispose();
    _noiDungCtrl.dispose();
    _scrollCtrl.dispose();
    _taiLieuNotifier.dispose();
    super.dispose();
  }

  // ==========================================================================
  // LOAD
  // ==========================================================================

  Future<void> _initLoad() async {
    switch (widget.mode) {
      case YeuCauFormCreate():
        break;
      case YeuCauFormEdit(thongTinCuDan: final data, thanhVien: final tv):
        if (data != null) {
          _prefillFromCuDan(data);
          await _loadCatalogAndPreselect(data);
        } else {
          await _loadCuDanAndCatalog(tv.quanHeCuTruId);
        }
      case YeuCauFormDraft(yeuCauId: final id):
        await _loadDraftAndCatalog(id);
    }
  }

  Future<void> _loadCatalogAndPreselect(ThongTinCuDanModel d) async {
    _setLoading(true);
    try {
      final results = await Future.wait([_gioiTinhFuture, _loaiQuanHeFuture]);
      if (!mounted) return;
      setState(() {
        _gioiTinh = results[0].where((e) => e.id == d.gioiTinhId).firstOrNull;
        _loaiQuanHe = results[1]
            .where((e) => e.id == d.loaiQuanHeCuTruId)
            .firstOrNull;
      });
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadCuDanAndCatalog(int quanHeCuTruId) async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _thanhVienSvc.getThongTinCuDan(quanHeCuTruId),
        _gioiTinhFuture,
        _loaiQuanHeFuture,
      ]);
      if (!mounted) return;
      final cuDan = results[0] as ThongTinCuDanModel;
      _prefillFromCuDan(cuDan);
      setState(() {
        _cuDan = cuDan;
        _gioiTinh = (results[1] as List<SelectorItemModel>)
            .where((e) => e.id == cuDan.gioiTinhId)
            .firstOrNull;
        _loaiQuanHe = (results[2] as List<SelectorItemModel>)
            .where((e) => e.id == cuDan.loaiQuanHeCuTruId)
            .firstOrNull;
      });
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadDraftAndCatalog(int yeuCauId) async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _yeuCauSvc.getYeuCauById(yeuCauId),
        _gioiTinhFuture,
        _loaiQuanHeFuture,
      ]);
      if (!mounted) return;
      final d = results[0] as YeuCauCuTruModel;
      _prefillFromDraft(d);
      setState(() {
        _draftYeuCau = d;
        _gioiTinh = (results[1] as List<SelectorItemModel>)
            .where((e) => e.id == d.yeuCauGioiTinhId)
            .firstOrNull;
        _loaiQuanHe = (results[2] as List<SelectorItemModel>)
            .where((e) => e.id == d.yeuCauLoaiQuanHeId)
            .firstOrNull;
      });
    } finally {
      _setLoading(false);
    }
  }

  void _prefillFromCuDan(ThongTinCuDanModel d) {
    _cuDan = d;
    _hoCtrl.text = d.lastName;
    _tenCtrl.text = d.firstName;
    _cccdCtrl.text = d.idCard ?? '';
    _phoneCtrl.text = d.phoneNumber ?? '';
    _diaChiCtrl.text = d.diaChi ?? '';
    _dob = d.dob;
  }

  void _prefillFromDraft(YeuCauCuTruModel d) {
    _hoCtrl.text = d.yeuCauHo ?? '';
    _tenCtrl.text = d.yeuCauTen ?? '';
    _cccdCtrl.text = d.yeuCauCCCD ?? '';
    _phoneCtrl.text = d.yeuCauSoDienThoai ?? '';
    _diaChiCtrl.text = d.yeuCauDiaChi ?? '';
    _noiDungCtrl.text = d.noiDung ?? '';
    _dob = d.yeuCauNgaySinh;
  }

  void _setLoading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  // ==========================================================================
  // VALIDATE + SUBMIT
  // ==========================================================================

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

  Future<void> _submit(bool isSubmit) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateRequiredFields()) return;
    if (_isSubmitting) return;

    if (_isDraft && isSubmit) {
      final ok = await _showConfirmDialog(
        title: 'Xác nhận gửi yêu cầu',
        content:
            'Sau khi gửi, yêu cầu sẽ chuyển sang trạng thái chờ duyệt '
            'và không thể chỉnh sửa. Tiếp tục?',
        confirmLabel: 'Gửi',
      );
      if (!ok || !mounted) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final taiLieus = _taiLieuNotifier.value;

      if (_isDraft) {
        final mode = widget.mode as YeuCauFormDraft;
        await _yeuCauSvc.updateYeuCau(
          CapNhatYeuCauCuTruRequest(
            id: mode.yeuCauId,
            isSubmit: isSubmit,
            lastName: _trim(_hoCtrl),
            firstName: _trim(_tenCtrl),
            dob: _dob,
            gioiTinhId: _gioiTinh?.id,
            loaiQuanHeId: _loaiQuanHe?.id,
            cccd: _trimOrNull(_cccdCtrl),
            phoneNumber: _trimOrNull(_phoneCtrl),
            diaChi: _trimOrNull(_diaChiCtrl),
            noiDung: _trimOrNull(_noiDungCtrl),
            taiLieuCuTrus: taiLieus.isEmpty ? null : taiLieus,
          ),
        );
      } else {
        final canHoId = _canHoInfo!.canHoId;
        final loaiYeuCauId = _isCreate ? 1 : 2;
        final targetId = _isEdit ? (_thanhVien!.quanHeCuTruId) : null;

        await _yeuCauSvc.createYeuCau(
          TaoYeuCauCuTruRequest(
            canHoId: canHoId,
            loaiYeuCauId: loaiYeuCauId,
            isSubmit: isSubmit,
            targetQuanHeCuTruId: targetId,
            firstName: _trim(_tenCtrl),
            lastName: _trim(_hoCtrl),
            dob: _dob,
            gioiTinhId: _gioiTinh!.id,
            loaiQuanHeId: _loaiQuanHe!.id,
            cccd: _trimOrNull(_cccdCtrl),
            phoneNumber: _trimOrNull(_phoneCtrl),
            diaChi: _trimOrNull(_diaChiCtrl),
            noiDung: _trimOrNull(_noiDungCtrl),
            taiLieuCuTrus: taiLieus.isEmpty ? null : taiLieus,
          ),
        );
      }

      if (mounted) {
        _showSnack(isSubmit ? 'Đã nộp yêu cầu thành công' : 'Đã lưu nháp');
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _dob = picked);
  }

  String _trim(TextEditingController c) => c.text.trim();
  String? _trimOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Trường này là bắt buộc' : null;

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isEdit && _thanhVien != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_appBarTitle, style: const TextStyle(fontSize: 16)),
                  Text(
                    _thanhVien!.fullName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
            : Text(_appBarTitle),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_isSubmitting) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _formKey,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          // ── Readonly card ──────────────────────────────────────────────
          _buildReadonlyCard(),
          const SizedBox(height: 20),

          // ── Thông tin chính ────────────────────────────────────────────
          SectionLabel(_sectionLabel),

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

          DatePickerField(label: 'Ngày sinh *', value: _dob, onTap: _pickDob),
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

          // ── Thông tin bổ sung ──────────────────────────────────────────
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
            label: _isDraft ? 'Ghi chú' : 'Nội dung',
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // ── Tài liệu đính kèm ─────────────────────────────────────────
          const SectionLabel('Tài liệu đính kèm'),

          TaiLieuCuTruEditor(
            key: const ValueKey('tai_lieu_editor'),
            initialDocuments: _isDraft
                ? _draftYeuCau?.documents
                : _cuDan?.taiLieuCuTrus,
            onChanged: (list) => _taiLieuNotifier.value = list,
          ),
          const SizedBox(height: 24),

          // ── Buttons ────────────────────────────────────────────────────
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
    );
  }

  Widget _buildReadonlyCard() {
    return switch (widget.mode) {
      YeuCauFormCreate(canHoInfo: final c) => ReadonlyCanHoCard(canHoInfo: c),
      YeuCauFormEdit(thanhVien: final tv, canHoInfo: final c) =>
        TvMemberReadonlyCard(
          thanhVien: tv,
          diaChiCanHo: c.diaChiDayDu,
          badgeLabel: 'Sửa',
          badgeColor: Colors.orange,
        ),
      YeuCauFormDraft() =>
        _draftYeuCau != null
            ? _DraftReadonlyCard(yeuCau: _draftYeuCau!)
            : const SizedBox.shrink(),
    };
  }
}

// =============================================================================
// DRAFT READONLY CARD
// =============================================================================

class _DraftReadonlyCard extends StatelessWidget {
  final YeuCauCuTruModel yeuCau;
  const _DraftReadonlyCard({required this.yeuCau});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.apartment_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yeuCau.diaChiCanHo,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Loại yêu cầu: ${yeuCau.tenLoaiYeuCau}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}