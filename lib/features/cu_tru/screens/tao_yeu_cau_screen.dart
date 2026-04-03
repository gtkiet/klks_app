// lib/features/cu_tru/screens/tao_yeu_cau_screen.dart
//
// Screen tạo yêu cầu cư trú — tích hợp FileUploadWidget & UploadMediaScreen.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import '../screens/upload_media_screen.dart';
import '../widgets/file_upload_widget.dart';

class TaoYeuCauScreen extends StatefulWidget {
  const TaoYeuCauScreen({super.key});

  @override
  State<TaoYeuCauScreen> createState() => _TaoYeuCauScreenState();
}

class _TaoYeuCauScreenState extends State<TaoYeuCauScreen> {
  final _service = CuTruService();
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  final _canHoIdCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  final _targetQuanHeCtrl = TextEditingController();
  final _noiDungCtrl = TextEditingController();

  List<SelectorItemModel> _loaiYeuCauList = [];
  List<SelectorItemModel> _gioiTinhList = [];
  List<SelectorItemModel> _loaiQuanHeList = [];

  SelectorItemModel? _selectedLoaiYeuCau;
  SelectorItemModel? _selectedGioiTinh;
  SelectorItemModel? _selectedLoaiQuanHe;
  DateTime? _selectedDob;

  // Lưu fileIds từ FileUploadWidget để submit
  List<UploadedFileModel> _uploadedFiles = [];

  bool _isLoadingCatalogs = true;
  bool _isSubmitting = false;
  String? _catalogError;

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  @override
  void dispose() {
    _canHoIdCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cccdCtrl.dispose();
    _diaChiCtrl.dispose();
    _targetQuanHeCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    setState(() {
      _isLoadingCatalogs = true;
      _catalogError = null;
    });
    try {
      final results = await Future.wait([
        _service.getLoaiYeuCauSelector(),
        _service.getGioiTinhSelector(),
        _service.getLoaiQuanHeCuTruSelector(),
      ]);
      setState(() {
        _loaiYeuCauList = results[0];
        _gioiTinhList = results[1];
        _loaiQuanHeList = results[2];
        if (_loaiYeuCauList.isNotEmpty) {
          _selectedLoaiYeuCau = _loaiYeuCauList.first;
        }
      });
    } catch (e) {
      setState(() => _catalogError = e.toString());
    } finally {
      setState(() => _isLoadingCatalogs = false);
    }
  }

  // TODO: Kiểm tra lại id từ API loai-yeu-cau-for-selector
  bool get _isThemMoi => _selectedLoaiYeuCau?.id == 1;
  bool get _isSuaHoacXoa => !_isThemMoi;

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  Future<void> _submit({required bool isSubmit}) async {
    if (!_formKey.currentState!.validate()) return;

    final canHoId = int.tryParse(_canHoIdCtrl.text.trim());
    if (canHoId == null) {
      _showSnack('Mã căn hộ không hợp lệ');
      return;
    }
    if (_selectedLoaiYeuCau == null) {
      _showSnack('Vui lòng chọn loại yêu cầu');
      return;
    }
    if (_isThemMoi) {
      if (_firstNameCtrl.text.trim().isEmpty ||
          _lastNameCtrl.text.trim().isEmpty) {
        _showSnack('Vui lòng nhập họ và tên');
        return;
      }
      if (_selectedDob == null) {
        _showSnack('Vui lòng chọn ngày sinh');
        return;
      }
      if (_selectedGioiTinh == null) {
        _showSnack('Vui lòng chọn giới tính');
        return;
      }
      if (_selectedLoaiQuanHe == null) {
        _showSnack('Vui lòng chọn loại quan hệ cư trú');
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final targetId = int.tryParse(_targetQuanHeCtrl.text.trim());

      // Build taiLieuCuTrus từ uploaded files
      // TODO: Nếu cần phân loại (loaiGiayToId, soGiayTo) thêm UI riêng.
      List<Map<String, dynamic>>? taiLieuCuTrus;
      if (_uploadedFiles.isNotEmpty) {
        taiLieuCuTrus = [
          {
            'taiLieuCuTruId': 0,
            'loaiGiayToId': 0,
            'soGiayTo': '',
            'ngayPhatHanh': null,
            'fileIds': _uploadedFiles.map((f) => f.fileId).toList(),
          },
        ];
      }

      await _service.createYeuCau(
        canHoId: canHoId,
        loaiYeuCauId: _selectedLoaiYeuCau!.id,
        targetQuanHeCuTruId: _isSuaHoacXoa ? targetId : null,
        firstName: _isThemMoi ? _firstNameCtrl.text.trim() : null,
        lastName: _isThemMoi ? _lastNameCtrl.text.trim() : null,
        gioiTinhId: _selectedGioiTinh?.id,
        dob: _selectedDob,
        cccd: _cccdCtrl.text.trim().isEmpty ? null : _cccdCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
        diaChi: _diaChiCtrl.text.trim().isEmpty
            ? null
            : _diaChiCtrl.text.trim(),
        loaiQuanHeId: _selectedLoaiQuanHe?.id,
        noiDung: _noiDungCtrl.text.trim().isEmpty
            ? null
            : _noiDungCtrl.text.trim(),
        taiLieuCuTrus: taiLieuCuTrus,
        isSubmit: isSubmit,
      );

      if (mounted) {
        _showSnack(
          isSubmit ? '✅ Đã gửi yêu cầu thành công!' : '💾 Đã lưu nháp!',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('❌ ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCatalogs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_catalogError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tạo yêu cầu cư trú')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _catalogError!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCatalogs,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo yêu cầu cư trú')),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Loại yêu cầu ────────────────────────────────────────────
              _Label('Loại yêu cầu *'),
              DropdownButtonFormField<SelectorItemModel>(
                initialValue: _selectedLoaiYeuCau,
                items: _loaiYeuCauList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLoaiYeuCau = v),
                decoration: _deco('Chọn loại yêu cầu'),
              ),
              const SizedBox(height: 16),

              // ── CanHoId ──────────────────────────────────────────────────
              _Label('Mã căn hộ (CanHoId) *'),
              TextFormField(
                controller: _canHoIdCtrl,
                decoration: _deco('Nhập ID căn hộ'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),

              // ── Target (Sửa/Xóa) ────────────────────────────────────────
              if (_isSuaHoacXoa) ...[
                _Label('ID quan hệ cư trú cần sửa/xóa *'),
                TextFormField(
                  controller: _targetQuanHeCtrl,
                  decoration: _deco('Nhập QuanHeCuTruId mục tiêu'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      _isSuaHoacXoa && (v == null || v.trim().isEmpty)
                      ? 'Bắt buộc khi Sửa/Xóa'
                      : null,
                ),
                const SizedBox(height: 16),
              ],

              // ── Cá nhân (Thêm mới) ───────────────────────────────────────
              if (_isThemMoi) ...[
                _Label('Họ *'),
                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: _deco('Nhập họ'),
                  validator: (v) =>
                      _isThemMoi && (v == null || v.trim().isEmpty)
                      ? 'Bắt buộc'
                      : null,
                ),
                const SizedBox(height: 12),
                _Label('Tên *'),
                TextFormField(
                  controller: _firstNameCtrl,
                  decoration: _deco('Nhập tên'),
                  validator: (v) =>
                      _isThemMoi && (v == null || v.trim().isEmpty)
                      ? 'Bắt buộc'
                      : null,
                ),
                const SizedBox(height: 12),
                _Label('Ngày sinh *'),
                InkWell(
                  onTap: _pickDob,
                  child: InputDecorator(
                    decoration: _deco('Chọn ngày sinh'),
                    child: Text(
                      _selectedDob != null
                          ? _dateFormat.format(_selectedDob!)
                          : 'Chọn ngày',
                      style: TextStyle(
                        color: _selectedDob != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _Label('Giới tính *'),
                DropdownButtonFormField<SelectorItemModel>(
                  initialValue: _selectedGioiTinh,
                  items: _gioiTinhList
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGioiTinh = v),
                  decoration: _deco('Chọn giới tính'),
                ),
                const SizedBox(height: 12),
                _Label('Loại quan hệ cư trú *'),
                DropdownButtonFormField<SelectorItemModel>(
                  initialValue: _selectedLoaiQuanHe,
                  items: _loaiQuanHeList
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLoaiQuanHe = v),
                  decoration: _deco('Chủ hộ, Thành viên...'),
                ),
                const SizedBox(height: 12),
              ],

              // ── Tuỳ chọn ────────────────────────────────────────────────
              _Label('Số điện thoại'),
              TextFormField(
                controller: _phoneCtrl,
                decoration: _deco('Nhập số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _Label('CCCD / CMND'),
              TextFormField(
                controller: _cccdCtrl,
                decoration: _deco('Nhập số CCCD'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _Label('Địa chỉ'),
              TextFormField(
                controller: _diaChiCtrl,
                decoration: _deco('Nhập địa chỉ thường trú'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _Label('Nội dung / Ghi chú'),
              TextFormField(
                controller: _noiDungCtrl,
                decoration: _deco('Ghi chú thêm...'),
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // ── UPLOAD FILE (inline widget) ──────────────────────────────
              FileUploadWidget(
                label: 'Tài liệu đính kèm',
                targetContainer: 'tai-lieu-cu-tru',
                // Chỉnh allowedTypes tuỳ theo màn hình:
                allowedTypes: FileTypePreset.imageAndDocument,
                maxFiles: 5,
                maxFileSizeMb: 20,
                onFilesChanged: (files) {
                  setState(() => _uploadedFiles = files);
                },
              ),

              const SizedBox(height: 8),

              // Nút mở màn hình upload riêng nếu cần (cho nhiều file hơn)
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<List<UploadedFileModel>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadMediaScreen(
                        targetContainer: 'tai-lieu-cu-tru',
                        // Cho phép tất cả loại file:
                        allowedTypes: FileTypePreset.all,
                        maxFiles: 20,
                        maxFileSizeMb: 50,
                      ),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    setState(() {
                      final existingIds = _uploadedFiles
                          .map((f) => f.fileId)
                          .toSet();
                      for (final f in result) {
                        if (!existingIds.contains(f.fileId)) {
                          _uploadedFiles.add(f);
                        }
                      }
                    });
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Mở màn hình upload đầy đủ'),
              ),

              if (_uploadedFiles.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${_uploadedFiles.length} file đã sẵn sàng gửi.',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],

              const SizedBox(height: 24),

              // ── Buttons ──────────────────────────────────────────────────
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _submit(isSubmit: false),
                        child: const Text('Lưu nháp'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () => _submit(isSubmit: true),
                        child: const Text('Gửi duyệt'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );
}
