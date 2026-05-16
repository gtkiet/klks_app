// lib/features/dich_vu/tien_ich/screens/dang_ky_dich_vu_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dich_vu_model.dart';
import '../services/dich_vu_service.dart';

import 'package:klks_app/features/cu_tru/quan_he/widgets/can_ho_selector.dart';
import 'package:klks_app/design/design.dart';

class DangKyDichVuScreen extends StatefulWidget {
  final int dichVuId;
  final String tenDichVu;
  final List<KhungGioItem> khungGioList;

  const DangKyDichVuScreen({
    super.key,
    required this.dichVuId,
    required this.tenDichVu,
    this.khungGioList = const [],
  });

  @override
  State<DangKyDichVuScreen> createState() => _DangKyDichVuScreenState();
}

class _DangKyDichVuScreenState extends State<DangKyDichVuScreen> {
  final _service = DichVuService.instance;
  final _formKey = GlobalKey<FormState>();

  // ── Căn hộ ─────────────────────────────────────────────────────────────
  List<QuanHeCuTruModel> _canHoList = [];
  bool _isLoadingCanHo = true;
  String? _loadCanHoError;
  QuanHeCuTruModel? _selectedCanHo;

  // ── Form ───────────────────────────────────────────────────────────────
  final _soLuongCtrl = TextEditingController(text: '1');
  DateTime _ngaySuDung = DateTime.now();
  KhungGioItem? _selectedKhungGio;

  // ── Submit ─────────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCanHoList();
  }

  @override
  void dispose() {
    _soLuongCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCanHoList() async {
    setState(() {
      _isLoadingCanHo = true;
      _loadCanHoError = null;
    });
    try {
      final list = await _service.getCanHoList();
      if (!mounted) return;
      setState(() {
        _canHoList = list;
        if (list.length == 1) _selectedCanHo = list.first;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _loadCanHoError = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingCanHo = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ngaySuDung,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _ngaySuDung = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCanHo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn căn hộ')),
      );
      return;
    }

    final soLuong = int.tryParse(_soLuongCtrl.text.trim()) ?? 1;

    setState(() => _isSubmitting = true);
    try {
      final resultId = await _service.dangKyDichVu(
        canHoId: _selectedCanHo!.canHoId,
        dichVuId: widget.dichVuId,
        ngaySuDung: _ngaySuDung,
        soLuong: soLuong,
        khungGioId: _selectedKhungGio?.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thành công! Mã: $resultId')),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Đăng ký dịch vụ',
      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: AppSpacing.insetAll16,
                children: [
                  // ── Banner tên dịch vụ ──────────────────────────────
                  AppCard(
                    color: AppColors.primaryLight,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.miscellaneous_services_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            widget.tenDichVu,
                            style: AppTypography.subhead.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Chọn căn hộ ─────────────────────────────────────
                  Text('Căn hộ', style: AppTypography.subhead),
                  const SizedBox(height: AppSpacing.sm),
                  _buildCanHoSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Ngày sử dụng ─────────────────────────────────────
                  Text('Thông tin đăng ký', style: AppTypography.subhead),
                  const SizedBox(height: AppSpacing.sm),

                  InkWell(
                    onTap: _pickDate,
                    borderRadius: AppRadius.inputField,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày sử dụng *',
                        prefixIcon: const Icon(Icons.calendar_today_outlined,
                            size: 20),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.inputField,
                        ),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_ngaySuDung),
                        style: AppTypography.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm2),

                  // ── Số lượng ─────────────────────────────────────────
                  AppTextField(
                    label: 'Số lượng',
                    hint: 'Mặc định: 1',
                    controller: _soLuongCtrl,
                    keyboardType: TextInputType.number,
                  ),

                  // ── Khung giờ ────────────────────────────────────────
                  if (widget.khungGioList.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm2),
                    _KhungGioDropdown(
                      khungGioList: widget.khungGioList,
                      selected: _selectedKhungGio,
                      onChanged: (v) => setState(() => _selectedKhungGio = v),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // ── Submit ───────────────────────────────────────────
                  AppButton(
                    label: 'Xác nhận đăng ký',
                    leadingIcon: Icons.check_circle_outline,
                    onPressed: (_isLoadingCanHo || _canHoList.isEmpty)
                        ? null
                        : _submit,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
    );
  }

  Widget _buildCanHoSection() {
    if (_isLoadingCanHo) {
      return const AppLoadingIndicator(isLoading: true, child: SizedBox(height: 56));
    }

    if (_loadCanHoError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Không tải được danh sách căn hộ',
              style: AppTypography.caption.error,
            ),
          ),
          TextButton.icon(
            onPressed: _loadCanHoList,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Thử lại'),
          ),
        ],
      );
    }

    if (_canHoList.isEmpty) {
      return Text(
        'Bạn chưa có căn hộ nào',
        style: AppTypography.body.secondary,
      );
    }

    return CanHoSelector(
      dsCanHo: _canHoList,
      selected: _selectedCanHo,
      onChanged: (v) => setState(() => _selectedCanHo = v),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Khung giờ dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _KhungGioDropdown extends StatelessWidget {
  final List<KhungGioItem> khungGioList;
  final KhungGioItem? selected;
  final ValueChanged<KhungGioItem?> onChanged;

  const _KhungGioDropdown({
    required this.khungGioList,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<KhungGioItem?>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Khung giờ (tùy chọn)',
        prefixIcon: const Icon(Icons.access_time_outlined, size: 20),
        border: OutlineInputBorder(borderRadius: AppRadius.inputField),
      ),
      items: [
        const DropdownMenuItem<KhungGioItem?>(
          value: null,
          child: Text('Không chọn khung giờ'),
        ),
        ...khungGioList.where((k) => k.isActive).map(
          (k) => DropdownMenuItem<KhungGioItem?>(
            value: k,
            child: Text('${k.tenKhungGio} (${k.thoiGian})'),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}