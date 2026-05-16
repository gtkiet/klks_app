// lib/features/dich_vu/tien_ich/screens/dang_ky_filter_screen.dart

import 'package:flutter/material.dart';

import '../models/dich_vu_model.dart';
import '../services/dich_vu_service.dart';

import 'package:klks_app/design/design.dart';

class DangKyFilterScreen extends StatefulWidget {
  final DichVuDangKyRequest currentRequest;

  const DangKyFilterScreen({super.key, required this.currentRequest});

  @override
  State<DangKyFilterScreen> createState() => _DangKyFilterScreenState();
}

class _DangKyFilterScreenState extends State<DangKyFilterScreen> {
  // Filter state — khởi tạo từ request hiện tại
  int? _loaiDichVuId;
  int? _trangThaiDangKyId;
  DateTime? _tuNgay;
  DateTime? _denNgay;

  @override
  void initState() {
    super.initState();
    _loaiDichVuId = widget.currentRequest.loaiDichVuId;
    _trangThaiDangKyId = widget.currentRequest.trangThaiDangKyId;
    _tuNgay = widget.currentRequest.tuNgay;
    _denNgay = widget.currentRequest.denNgay;
  }

  Future<void> _pickDate({required bool isTuNgay}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isTuNgay ? _tuNgay : _denNgay) ?? DateTime.now(),
      firstDate: isTuNgay ? DateTime(2020) : (_tuNgay ?? DateTime(2020)),
      lastDate: isTuNgay ? (_denNgay ?? DateTime(2030)) : DateTime(2030),
    );
    if (picked != null) {
      setState(() => isTuNgay ? _tuNgay = picked : _denNgay = picked);
    }
  }

  void _apply() {
    if (_tuNgay != null && _denNgay != null && !_tuNgay!.isBefore(_denNgay!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Từ ngày phải nhỏ hơn Đến ngày')),
      );
      return;
    }

    Navigator.pop(
      context,
      widget.currentRequest.copyWith(
        loaiDichVuId: _loaiDichVuId,
        trangThaiDangKyId: _trangThaiDangKyId,
        tuNgay: _tuNgay,
        denNgay: _denNgay,
        pageNumber: 1,
      ),
    );
  }

  void _reset() => setState(() {
        _loaiDichVuId = null;
        _trangThaiDangKyId = null;
        _tuNgay = null;
        _denNgay = null;
      });

  String _fmtDate(DateTime? d) => d == null
      ? 'Chọn ngày'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppTopBar(
        title: 'Bộ lọc',
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(
              'Đặt lại',
              style: AppTypography.buttonLabel.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: AppSpacing.insetAll16,
              children: [
                // ── Loại dịch vụ ──────────────────────────────────────
                Text('Loại dịch vụ', style: AppTypography.subhead),
                const SizedBox(height: AppSpacing.sm),
                _buildDropdown<int?>(
                  value: _loaiDichVuId,
                  hint: 'Tất cả loại',
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả loại'),
                    ),
                    // Chỉ show loại có ý nghĩa với cư dân
                    ...DichVuCatalog.loaiDichVu.map(
                      (e) => DropdownMenuItem<int?>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _loaiDichVuId = v),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Trạng thái đăng ký ────────────────────────────────
                Text('Trạng thái đăng ký', style: AppTypography.subhead),
                const SizedBox(height: AppSpacing.sm),
                _buildDropdown<int?>(
                  value: _trangThaiDangKyId,
                  hint: 'Tất cả trạng thái',
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả trạng thái'),
                    ),
                    ...DichVuCatalog.trangThaiDangKy.map(
                      (e) => DropdownMenuItem<int?>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _trangThaiDangKyId = v),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Khoảng thời gian ──────────────────────────────────
                Text('Khoảng thời gian', style: AppTypography.subhead),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: 'Từ ngày',
                        value: _fmtDate(_tuNgay),
                        hasValue: _tuNgay != null,
                        onTap: () => _pickDate(isTuNgay: true),
                        onClear: _tuNgay != null
                            ? () => setState(() => _tuNgay = null)
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DateButton(
                        label: 'Đến ngày',
                        value: _fmtDate(_denNgay),
                        hasValue: _denNgay != null,
                        onTap: () => _pickDate(isTuNgay: false),
                        onClear: _denNgay != null
                            ? () => setState(() => _denNgay = null)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Apply ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.paddingOf(context).bottom,
            ),
            child: AppButton(label: 'Áp dụng', onPressed: _apply),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: AppRadius.inputField),
        contentPadding: AppSpacing.inputPadding,
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date button
// ─────────────────────────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateButton({
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.inputField,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: AppRadius.inputField),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_outlined, size: 16),
        ),
        child: Text(
          value,
          style: hasValue
              ? AppTypography.body
              : AppTypography.body.secondary,
        ),
      ),
    );
  }
}