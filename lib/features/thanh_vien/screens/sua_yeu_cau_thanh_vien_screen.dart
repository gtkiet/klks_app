// lib/features/thanh_vien/screens/sua_yeu_cau_thanh_vien_screen.dart
//
// Tạo yêu cầu LOẠI SỬA (loaiYeuCauId = 2).
// Pre-fill từ ThongTinCuDanModel nếu được truyền vào,
// nếu không sẽ tự gọi API lấy thông tin.

import 'package:flutter/material.dart';

import '../../../core/errors/errors.dart';
import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../../cu_tru/widgets/shared_widget.dart';
import '../../utils/models/selector_item_model.dart';
import '../../utils/services/utils_service.dart';
import '../../utils/widgets/app_selector_field.dart';
import '../models/tai_lieu_cu_tru_request.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';
import '../models/thong_tin_cu_dan_model.dart';
import '../services/thanh_vien_service.dart';
import '../services/tv_yeu_cau_service.dart';
import '../widgets/tai_lieu_cu_tru_editor.dart';

class SuaYeuCauThanhVienScreen extends StatefulWidget {
  final ThanhVienCuTruModel thanhVien;
  final QuanHeCuTruModel canHoInfo;

  /// Nếu đã có sẵn data từ màn hình chi tiết → truyền vào để tránh gọi lại API.
  final ThongTinCuDanModel? thongTinCuDan;

  const SuaYeuCauThanhVienScreen({
    super.key,
    required this.thanhVien,
    required this.canHoInfo,
    this.thongTinCuDan,
  });

  @override
  State<SuaYeuCauThanhVienScreen> createState() =>
      _SuaYeuCauThanhVienScreenState();
}

class _SuaYeuCauThanhVienScreenState extends State<SuaYeuCauThanhVienScreen> {
  final _yeuCauService = YeuCauCuTruService.instance;
  final _thanhVienService = ThanhVienService.instance;
  final _utilsService = UtilsService.instance;
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();

  // ── Load state (khi thongTinCuDan chưa có) ────────────────────────────
  bool _isLoadingData = false;
  AppException? _loadError;
  ThongTinCuDanModel? _cuDan;

  // ── Controllers ────────────────────────────────────────────────────────
  final _hoCtrl = TextEditingController();
  final _tenCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  DateTime? _dob;
  SelectorItemModel? _gioiTinh;
  SelectorItemModel? _loaiQuanHe;
  List<TaiLieuCuTruRequest> _taiLieuCuTrus = [];

  // ── Submit state ───────────────────────────────────────────────────────
  bool _isSubmitting = false;
  AppException? _submitError;

  // Catalog futures
  late final Future<List<SelectorItemModel>> _gioiTinhFuture =
      _utilsService.getGioiTinhSelector();
  late final Future<List<SelectorItemModel>> _loaiQuanHeFuture =
      _utilsService.getLoaiQuanHeCuTruSelector();

  @override
  void initState() {
    super.initState();
    if (widget.thongTinCuDan != null) {
      // Data đã có → pre-fill ngay
      _prefillFrom(widget.thongTinCuDan!);
    } else {
      // Chưa có → gọi API
      _loadCuDan();
    }
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
    super.dispose();
  }

  // ── Load thông tin cư dân nếu chưa có ────────────────────────────────

  Future<void> _loadCuDan() async {
    setState(() {
      _isLoadingData = true;
      _loadError = null;
    });
    try {
      // Gọi song song: thông tin cư dân + catalog để pre-select
      final results = await Future.wait([
        _thanhVienService
            .getThongTinCuDan(widget.thanhVien.quanHeCuTruId),
        _gioiTinhFuture,
        _loaiQuanHeFuture,
      ]);

      final cuDan = results[0] as ThongTinCuDanModel;
      final gioiTinh = results[1] as List<SelectorItemModel>;
      final loaiQuanHe = results[2] as List<SelectorItemModel>;

      _prefillFrom(cuDan);

      // Pre-select catalog từ ID
      setState(() {
        _gioiTinh =
            gioiTinh.where((e) => e.id == cuDan.gioiTinhId).firstOrNull;
        _loaiQuanHe = loaiQuanHe
            .where((e) => e.id == cuDan.loaiQuanHeCuTruId)
            .firstOrNull;
        _cuDan = cuDan;
        _isLoadingData = false;
      });
    } on AppException catch (e) {
      setState(() {
        _loadError = e;
        _isLoadingData = false;
      });
    }
  }

  // ── Pre-fill controllers từ ThongTinCuDanModel ────────────────────────

  void _prefillFrom(ThongTinCuDanModel d) {
    _cuDan = d;
    _hoCtrl.text = d.lastName;
    _tenCtrl.text = d.firstName;
    _cccdCtrl.text = d.idCard ?? '';
    _phoneCtrl.text = d.phoneNumber ?? '';
    _diaChiCtrl.text = d.diaChi ?? '';
    _dob = d.dob;

    // Nếu catalog đã load (khi thongTinCuDan được truyền từ ngoài),
    // việc pre-select sẽ xảy ra sau khi Future resolve trong AppSelectorField.
    // Với trường hợp tự load → _loadCuDan() xử lý.
  }

  // ── Validate ──────────────────────────────────────────────────────────

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

  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _submit(bool isSubmit) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateRequiredFields()) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await _yeuCauService.createYeuCau(
        TaoYeuCauCuTruRequest(
          canHoId: widget.canHoInfo.canHoId,
          // loaiYeuCauId = 2 = Sửa
          loaiYeuCauId: 2,
          isSubmit: isSubmit,
          // targetQuanHeCuTruId bắt buộc khi Sửa/Xóa
          targetQuanHeCuTruId: widget.thanhVien.quanHeCuTruId,
          firstName: _tenCtrl.text.trim(),
          lastName: _hoCtrl.text.trim(),
          dob: _dob,
          gioiTinhId: _gioiTinh!.id,
          loaiQuanHeId: _loaiQuanHe!.id,
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
          taiLieuCuTrus: _taiLieuCuTrus.isEmpty ? null : _taiLieuCuTrus,
        ),
      );

      if (mounted) {
        _showSnack(isSubmit ? 'Đã nộp yêu cầu sửa' : 'Đã lưu nháp');
        Navigator.pop(context, true);
      }
    } on AppException catch (e) {
      setState(() => _submitError = e);
      _scrollCtrl.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yêu cầu sửa thành viên', style: TextStyle(fontSize: 16)),
            Text(widget.thanhVien.fullName,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Đang tải thông tin cư dân
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    // Lỗi tải
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(error: _loadError!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadCuDan,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Đang submit
    if (_isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          // ── Thông tin căn hộ + thành viên (readonly) ─────────────────
          _MemberReadonlyCard(
            thanhVien: widget.thanhVien,
            canHoInfo: widget.canHoInfo,
          ),
          const SizedBox(height: 20),

          // ── Lỗi submit ────────────────────────────────────────────────
          if (_submitError != null) ...[
            AppErrorWidget(error: _submitError!),
            const SizedBox(height: 12),
          ],

          // ── Thông tin cần sửa ─────────────────────────────────────────
          const SectionLabel('Thông tin cần sửa *'),

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

          // ── Thông tin bổ sung ─────────────────────────────────────────
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
            label: 'Lý do / ghi chú',
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // ── Tài liệu đính kèm ─────────────────────────────────────────
          const SectionLabel('Tài liệu đính kèm'),

          TaiLieuCuTruEditor(
            // Pre-fill tài liệu hiện tại của cư dân (nếu có)
            initialDocuments: _cuDan?.taiLieuCuTrus,
            onChanged: (list) => setState(() => _taiLieuCuTrus = list),
          ),
          const SizedBox(height: 24),

          // ── Buttons ───────────────────────────────────────────────────
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Trường này là bắt buộc' : null;
}

// ── Card thành viên readonly ──────────────────────────────────────────────────

class _MemberReadonlyCard extends StatelessWidget {
  final ThanhVienCuTruModel thanhVien;
  final QuanHeCuTruModel canHoInfo;

  const _MemberReadonlyCard({
    required this.thanhVien,
    required this.canHoInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: thanhVien.anhDaiDienUrl != null
                  ? NetworkImage(thanhVien.anhDaiDienUrl!)
                  : null,
              child: thanhVien.anhDaiDienUrl == null
                  ? Text(thanhVien.fullName.isNotEmpty
                      ? thanhVien.fullName[0].toUpperCase()
                      : '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(thanhVien.fullName,
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    '${thanhVien.loaiQuanHeTen} · ${canHoInfo.diaChiDayDu}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            // Badge loại yêu cầu
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Sửa',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}