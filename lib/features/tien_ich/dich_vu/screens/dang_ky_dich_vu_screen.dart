// lib/features/tien_ich/dich_vu/screens/dang_ky_dich_vu_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dich_vu_model.dart';
import '../services/dich_vu_service.dart';

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

  List<QuanHeCuTruModel> _canHoList = [];
  bool _isLoadingCanHo = true;
  String? _loadCanHoError;

  QuanHeCuTruModel? _selectedCanHo;
  final _soLuongCtrl = TextEditingController(text: '1');
  DateTime _ngaySuDung = DateTime.now();
  KhungGioItem? _selectedKhungGio;
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
    } catch (e) {
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
      _showSnackbar('Vui lòng chọn căn hộ', isError: true);
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
      _showSnackbar('Đăng ký thành công! ID: $resultId');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackbar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Ký Dịch Vụ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildServiceBanner(),
              const SizedBox(height: 24),
              _buildCanHoSelector(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildSoLuongField(),
              if (widget.khungGioList.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildKhungGioSelector(),
              ],
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.miscellaneous_services, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.tenDichVu,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanHoSelector() {
    if (_isLoadingCanHo) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Căn hộ *',
          prefixIcon: Icon(Icons.apartment),
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 20,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Đang tải danh sách căn hộ...'),
            ],
          ),
        ),
      );
    }

    if (_loadCanHoError != null) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Căn hộ *',
          prefixIcon: const Icon(Icons.apartment),
          border: const OutlineInputBorder(),
          errorText: 'Không tải được danh sách',
          suffixIcon: IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Thử lại',
            onPressed: _loadCanHoList,
          ),
        ),
        child: const SizedBox.shrink(),
      );
    }

    if (_canHoList.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Căn hộ *',
          prefixIcon: Icon(Icons.apartment),
          border: OutlineInputBorder(),
          errorText: 'Bạn chưa có căn hộ nào',
        ),
        child: SizedBox.shrink(),
      );
    }

    return DropdownButtonFormField<QuanHeCuTruModel>(
      isExpanded: true,
      initialValue: _selectedCanHo,
      decoration: const InputDecoration(
        labelText: 'Căn hộ *',
        prefixIcon: Icon(Icons.apartment),
        border: OutlineInputBorder(),
      ),
      items: _canHoList
          .map(
            (canHo) => DropdownMenuItem<QuanHeCuTruModel>(
              value: canHo,
              child: Text(
                canHo.diaChiDayDu,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _selectedCanHo = val),
      validator: (_) => _selectedCanHo == null ? 'Vui lòng chọn căn hộ' : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ngày sử dụng *',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(_ngaySuDung)),
      ),
    );
  }

  Widget _buildSoLuongField() {
    return TextFormField(
      controller: _soLuongCtrl,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Số lượng',
        hintText: 'Mặc định: 1',
        prefixIcon: Icon(Icons.format_list_numbered),
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final n = int.tryParse(v);
        if (n == null || n < 1) return 'Số lượng phải ≥ 1';
        return null;
      },
    );
  }

  Widget _buildKhungGioSelector() {
    return DropdownButtonFormField<KhungGioItem>(
      initialValue: _selectedKhungGio,
      decoration: const InputDecoration(
        labelText: 'Khung giờ (tùy chọn)',
        prefixIcon: Icon(Icons.access_time),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<KhungGioItem>(
          value: null,
          child: Text('Không chọn khung giờ'),
        ),
        ...widget.khungGioList
            .where((k) => k.isActive)
            .map(
              (k) => DropdownMenuItem<KhungGioItem>(
                value: k,
                child: Text('${k.tenKhungGio} (${k.thoiGian})'),
              ),
            ),
      ],
      onChanged: (val) => setState(() => _selectedKhungGio = val),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: (_isSubmitting || _isLoadingCanHo || _canHoList.isEmpty)
            ? null
            : _submit,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle),
        label: Text(_isSubmitting ? 'Đang đăng ký...' : 'Xác nhận đăng ký'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
