// lib/features/tien_ich/dich_vu/screens/dich_vu_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dich_vu_model.dart';

import '../services/dich_vu_service.dart';
import '../widgets/common_widgets.dart';
import 'dang_ky_dich_vu_screen.dart';

class DichVuDetailScreen extends StatefulWidget {
  final int dichVuId;

  const DichVuDetailScreen({super.key, required this.dichVuId});

  @override
  State<DichVuDetailScreen> createState() => _DichVuDetailScreenState();
}

class _DichVuDetailScreenState extends State<DichVuDetailScreen> {
  final _service = DichVuService.instance;
  DichVuDetail? _detail;
  bool _isLoading = true;
  String? _error;

  final _currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await _service.getDichVuById(widget.dichVuId);
      setState(() => _detail = detail);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_detail?.tenDichVu ?? 'Chi tiết Dịch Vụ'),
        actions: [
          if (_detail != null)
            IconButton(
              icon: const Icon(Icons.app_registration),
              tooltip: 'Đăng ký dịch vụ',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DangKyDichVuScreen(
                    dichVuId: _detail!.id,
                    tenDichVu: _detail!.tenDichVu,
                    khungGioList: _detail!.khungGioDichVu,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ErrorStateWidget(message: _error!, onRetry: _loadDetail);
    }

    final d = _detail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.tenDichVu,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      _StatusBadge(
                        isHoatDong: d.isHoatDong,
                        label: d.trangThaiDichVuTen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Mã dịch vụ', value: d.maDichVu),
                  _InfoRow(label: 'Loại', value: d.loaiDichVuTen),
                  _InfoRow(label: 'Đơn vị tính', value: d.donViTinh),
                  _InfoRow(
                    label: 'Bắt buộc',
                    value: d.isBatBuoc ? 'Có' : 'Không',
                  ),
                  if (d.soLuongToiDa != null)
                    _InfoRow(
                      label: 'Sức chứa tối đa',
                      value: '${d.soLuongToiDa}',
                    ),
                  if (d.moTa != null && d.moTa!.isNotEmpty)
                    _InfoRow(label: 'Mô tả', value: d.moTa!),
                ],
              ),
            ),
          ),

          // ── Bảng giá ────────────────────────────────────────────────────
          if (d.bangGia != null) ...[
            const SizedBox(height: 16),
            _SectionHeader(title: 'Bảng Giá: ${d.bangGia!.tenBangGia}'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'Loại định giá',
                      value: d.bangGia!.loaiDinhGiaTen,
                    ),
                    if (d.bangGia!.donGia > 0)
                      _InfoRow(
                        label: 'Đơn giá',
                        value: _currencyFmt.format(d.bangGia!.donGia),
                      ),
                    if (d.bangGia!.ngayApDung != null)
                      _InfoRow(
                        label: 'Ngày áp dụng',
                        value: DateFormat(
                          'dd/MM/yyyy',
                        ).format(d.bangGia!.ngayApDung!),
                      ),
                    if (d.bangGia!.ngayKetThuc != null)
                      _InfoRow(
                        label: 'Ngày kết thúc',
                        value: DateFormat(
                          'dd/MM/yyyy',
                        ).format(d.bangGia!.ngayKetThuc!),
                      ),
                    if (d.bangGia!.giaLuyTiens.isNotEmpty) ...[
                      const Divider(),
                      const Text(
                        'Giá lũy tiến:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...d.bangGia!.giaLuyTiens.map(
                        (g) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• Từ ${g.tuMuc} → ${g.denMuc ?? '∞'}: ${_currencyFmt.format(g.donGia)}',
                          ),
                        ),
                      ),
                    ],
                    if (d.bangGia!.giaKhungGios.isNotEmpty) ...[
                      const Divider(),
                      const Text(
                        'Giá theo khung giờ:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...d.bangGia!.giaKhungGios.map(
                        (g) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• ${g.tenKhungGio}: ${_currencyFmt.format(g.donGia)}',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // ── Khung giờ ───────────────────────────────────────────────────
          if (d.khungGioDichVu.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionHeader(title: 'Khung Giờ'),
            ...d.khungGioDichVu.map(
              (k) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color: k.isActive ? Colors.blue : Colors.grey,
                  ),
                  title: Text(k.tenKhungGio),
                  subtitle: Text(k.thoiGian),
                  trailing: k.isActive
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        )
                      : const Icon(Icons.cancel, color: Colors.grey, size: 20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isHoatDong;
  final String label;

  const _StatusBadge({required this.isHoatDong, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHoatDong ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isHoatDong ? Colors.green.shade700 : Colors.orange.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
