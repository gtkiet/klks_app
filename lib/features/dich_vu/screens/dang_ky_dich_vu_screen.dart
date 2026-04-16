// lib/features/dich_vu/screens/dang_ky_dich_vu_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/khung_gio_model.dart';
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
  final _service = DichVuService();
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _canHoIdCtrl = TextEditingController();
  final _soLuongCtrl = TextEditingController(text: '1');
  DateTime _ngaySuDung = DateTime.now();
  KhungGioItem? _selectedKhungGio;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _canHoIdCtrl.dispose();
    _soLuongCtrl.dispose();
    super.dispose();
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

    final canHoId = int.tryParse(_canHoIdCtrl.text.trim());
    if (canHoId == null) {
      _showSnackbar('Mã căn hộ không hợp lệ', isError: true);
      return;
    }

    final soLuong = int.tryParse(_soLuongCtrl.text.trim()) ?? 1;

    setState(() => _isSubmitting = true);

    try {
      final resultId = await _service.dangKyDichVu(
        canHoId: canHoId,
        dichVuId: widget.dichVuId,
        ngaySuDung: _ngaySuDung,
        soLuong: soLuong,
        khungGioId: _selectedKhungGio?.id,
      );

      if (!mounted) return;
      _showSnackbar('Đăng ký thành công! ID: $resultId');

      // Quay lại sau khi đăng ký thành công
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
      appBar: AppBar(
        title: const Text('Đăng Ký Dịch Vụ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.miscellaneous_services,
                        color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.tenDichVu,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Căn hộ ID
              TextFormField(
                controller: _canHoIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã căn hộ (ID) *',
                  hintText: 'Nhập ID căn hộ',
                  prefixIcon: Icon(Icons.apartment),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mã căn hộ';
                  if (int.tryParse(v) == null) return 'Phải là số nguyên';
                  // TODO: validate canHoId tồn tại qua API nếu cần
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Ngày sử dụng
              InkWell(
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
              ),

              const SizedBox(height: 16),

              // Số lượng
              TextFormField(
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
              ),

              // Khung giờ (chỉ hiện nếu có)
              if (widget.khungGioList.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<KhungGioItem>(
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
                  onChanged: (val) =>
                      setState(() => _selectedKhungGio = val),
                ),
              ],

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    _isSubmitting ? 'Đang đăng ký...' : 'Xác nhận đăng ký',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}