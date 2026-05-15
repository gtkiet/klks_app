// lib/features/tien_ich/dich_vu/screens/dang_ky_filter_screen.dart

import 'package:flutter/material.dart';

import '../models/dich_vu_model.dart';

import '../services/dich_vu_service.dart';

class DangKyFilterScreen extends StatefulWidget {
  const DangKyFilterScreen({
    super.key,
    required this.currentRequest,
    required this.loaiDichVuList, // truyền từ DangKyListScreen, đã load sẵn
  });

  final DichVuDangKyRequest currentRequest;
  final List<SelectorItem> loaiDichVuList;

  @override
  State<DangKyFilterScreen> createState() => _DangKyFilterScreenState();
}

class _DangKyFilterScreenState extends State<DangKyFilterScreen> {
  final _service = DichVuService.instance;
  final _keywordCtrl = TextEditingController();

  // Catalog
  List<SelectorItem> _trangThaiList = [];
  bool _isLoadingTrangThai = true;

  // Filter state
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
    _keywordCtrl.text = widget.currentRequest.keyword ?? '';
    _loadTrangThai();
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTrangThai() async {
    try {
      final list = await _service.getTrangThaiDangKy();
      if (!mounted) return;
      setState(() => _trangThaiList = list);
    } catch (_) {
      // Catalog lỗi không block UI filter
    } finally {
      if (mounted) setState(() => _isLoadingTrangThai = false);
    }
  }

  Future<void> _pickDate({required bool isTuNgay}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isTuNgay ? _tuNgay : _denNgay) ?? DateTime.now(),
      // Constrain picker: tuNgay không vượt denNgay và ngược lại
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
        const SnackBar(
          content: Text('Từ ngày phải nhỏ hơn Đến ngày'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final newRequest = widget.currentRequest.copyWith(
      loaiDichVuId: _loaiDichVuId,
      trangThaiDangKyId: _trangThaiDangKyId,
      tuNgay: _tuNgay,
      denNgay: _denNgay,
      keyword: _keywordCtrl.text.trim().isEmpty
          ? null
          : _keywordCtrl.text.trim(),
      pageNumber: 1,
    );
    Navigator.pop(context, newRequest);
  }

  void _reset() => setState(() {
    _loaiDichVuId = null;
    _trangThaiDangKyId = null;
    _tuNgay = null;
    _denNgay = null;
    _keywordCtrl.clear();
  });

  String _fmtDate(DateTime? d) => d == null
      ? 'Chọn ngày'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ Lọc Dịch Vụ'),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text('Đặt lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Keyword ─────────────────────────────────────────────────────
          const Text('Từ khóa', style: _label),
          const SizedBox(height: 6),
          TextField(
            controller: _keywordCtrl,
            decoration: const InputDecoration(
              hintText: 'Tìm theo tên dịch vụ...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Loại dịch vụ ────────────────────────────────────────────────
          const Text('Loại dịch vụ', style: _label),
          const SizedBox(height: 6),
          DropdownButtonFormField<int?>(
            initialValue: _loaiDichVuId,
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả loại'),
              ),
              ...widget.loaiDichVuList.map(
                (e) => DropdownMenuItem<int?>(value: e.id, child: Text(e.name)),
              ),
            ],
            onChanged: (val) => setState(() => _loaiDichVuId = val),
          ),
          const SizedBox(height: 20),

          // ── Trạng thái đăng ký ──────────────────────────────────────────
          const Text('Trạng thái đăng ký', style: _label),
          const SizedBox(height: 6),
          _isLoadingTrangThai
              ? const LinearProgressIndicator()
              : DropdownButtonFormField<int?>(
                  initialValue: _trangThaiDangKyId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả trạng thái'),
                    ),
                    ..._trangThaiList.map(
                      (e) => DropdownMenuItem<int?>(
                        value: e.id,
                        child: Text(e.name),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _trangThaiDangKyId = val),
                ),
          const SizedBox(height: 20),

          // ── Khoảng thời gian ────────────────────────────────────────────
          const Text('Khoảng thời gian', style: _label),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Từ ngày',
                  value: _fmtDate(_tuNgay),
                  onTap: () => _pickDate(isTuNgay: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: 'Đến ngày',
                  value: _fmtDate(_denNgay),
                  onTap: () => _pickDate(isTuNgay: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Apply ────────────────────────────────────────────────────────
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _apply,
            child: const Text('Áp dụng', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  static const _label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
