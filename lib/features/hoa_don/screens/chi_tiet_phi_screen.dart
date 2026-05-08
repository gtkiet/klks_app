// lib/features/hoa_don/screens/chi_tiet_phi_screen.dart

import 'package:flutter/material.dart';
import '../models/hoa_don_model.dart';
import '../services/hoa_don_service.dart';
import '../utils/hoa_don_utils.dart';

/// Screen 3: Breakdown chi tiết 1 khoản phí.
///
/// Tự routing sang đúng API dựa vào [ChiTietHoaDon.loaiDinhGiaId].
class ChiTietPhiScreen extends StatefulWidget {
  final ChiTietHoaDon chiTiet;

  const ChiTietPhiScreen({super.key, required this.chiTiet});

  @override
  State<ChiTietPhiScreen> createState() => _ChiTietPhiScreenState();
}

class _ChiTietPhiScreenState extends State<ChiTietPhiScreen> {
  bool _loading = true;
  String? _error;

  // Chỉ một trong bốn sẽ có giá trị
  ChiTietLuyTien? _luyTien;
  ChiTietCoDinh? _coDinh;
  ChiTietDienTich? _dienTich;
  ChiTietKhungGio? _khungGio;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = widget.chiTiet.id;
      if (widget.chiTiet.laLuyTien) {
        _luyTien = await HoaDonService.instance.getChiTietLuyTien(id);
      } else if (widget.chiTiet.laCoDinh) {
        _coDinh = await HoaDonService.instance.getChiTietCoDinh(id);
      } else if (widget.chiTiet.laDienTich) {
        _dienTich = await HoaDonService.instance.getChiTietDienTich(id);
      } else if (widget.chiTiet.laKhungGio) {
        _khungGio = await HoaDonService.instance.getChiTietKhungGio(id);
      }
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.chiTiet.tenMucPhi,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_luyTien != null) return _LuyTienView(data: _luyTien!);
    if (_coDinh != null) return _CoDinhView(data: _coDinh!);
    if (_dienTich != null) return _DienTichView(data: _dienTich!);
    if (_khungGio != null) return _KhungGioView(data: _khungGio!);

    return const Center(child: Text('Không có dữ liệu'));
  }
}

// ─── SECTION WIDGET ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5FF)),
          ...children,
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DataRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LŨY TIẾN VIEW ────────────────────────────────────────────────────────────

class _LuyTienView extends StatelessWidget {
  final ChiTietLuyTien data;

  const _LuyTienView({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        // Ảnh đồng hồ
        if (data.anhDongHoUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data.anhDongHoUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_rounded,
                        color: Color(0xFFCBD5E1),
                        size: 32,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Không tải được ảnh đồng hồ',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Chỉ số tiêu thụ
        _SectionCard(
          title: 'Thông tin chỉ số',
          children: [
            _DataRow(label: 'Chỉ số cũ', value: formatSoThap(data.chiSoCu)),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            _DataRow(label: 'Chỉ số mới', value: formatSoThap(data.chiSoMoi)),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            _DataRow(
              label: 'Tiêu thụ',
              value: '${formatSoThap(data.soLuongTieuThu)} đơn vị',
              isBold: true,
            ),
          ],
        ),

        // Bậc thang
        if (data.bacThang.isNotEmpty)
          _SectionCard(
            title: 'Phân bổ theo bậc thang',
            children: [
              ...data.bacThang.asMap().entries.map((entry) {
                final i = entry.key;
                final bac = entry.value;
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(height: 1, color: Color(0xFFF8FAFC)),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6366F1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bac.tenBac,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 14),
                              Expanded(
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 4,
                                  children: [
                                    _MiniInfo(
                                      label: 'Số lượng',
                                      value: formatSoThap(bac.soLuong),
                                    ),
                                    _MiniInfo(
                                      label: 'Đơn giá',
                                      value: formatTien(bac.donGia),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatTien(bac.thanhTien),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              const Divider(height: 1, color: Color(0xFFF1F5FF)),
              _DataRow(
                label: 'Tổng cộng',
                value: formatTien(data.thanhTien),
                isBold: true,
                valueColor: const Color(0xFF6366F1),
              ),
            ],
          ),
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

// ─── CỐ ĐỊNH VIEW ────────────────────────────────────────────────────────────

class _CoDinhView extends StatelessWidget {
  final ChiTietCoDinh data;

  const _CoDinhView({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        _SectionCard(
          title: 'Thông tin phí cố định',
          children: [
            _DataRow(label: 'Tên mục phí', value: data.tenMucPhi),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            _DataRow(label: 'Số lượng', value: formatSoThap(data.soLuong)),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            _DataRow(label: 'Đơn giá', value: formatTien(data.donGia)),
            const Divider(height: 1, color: Color(0xFFF1F5FF)),
            _DataRow(
              label: 'Thành tiền',
              value: formatTien(data.thanhTien),
              isBold: true,
              valueColor: const Color(0xFF6366F1),
            ),
          ],
        ),
        if (data.ghiChu.isNotEmpty)
          _SectionCard(
            title: 'Ghi chú',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  data.ghiChu,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ─── DIỆN TÍCH VIEW ───────────────────────────────────────────────────────────

class _DienTichView extends StatelessWidget {
  final ChiTietDienTich data;

  const _DienTichView({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        _SectionCard(
          title: 'Phí theo diện tích',
          children: [
            _DataRow(label: 'Loại căn hộ', value: data.tenLoaiCanHo),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            _DataRow(
              label: 'Diện tích',
              value: '${formatSoThap(data.dienTich)} m²',
            ),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            _DataRow(label: 'Đơn giá/m²', value: formatTien(data.donGia)),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${formatSoThap(data.dienTich)} m² × ${formatTien(data.donGia)}/m²',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5FF)),
            _DataRow(
              label: 'Thành tiền',
              value: formatTien(data.thanhTien),
              isBold: true,
              valueColor: const Color(0xFF6366F1),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── KHUNG GIỜ VIEW ───────────────────────────────────────────────────────────

class _KhungGioView extends StatelessWidget {
  final ChiTietKhungGio data;

  const _KhungGioView({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        _SectionCard(
          title: 'Phân bổ theo khung giờ',
          children: [
            ...data.khungGios.asMap().entries.map((entry) {
              final i = entry.key;
              final kg = entry.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, color: Color(0xFFF8FAFC)),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF6366F1),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kg.tenKhungGio,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${kg.gioBatDau} – ${kg.gioKetThuc}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatTien(kg.donGia),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const Divider(height: 1, color: Color(0xFFF1F5FF)),
            _DataRow(
              label: 'Tổng cộng',
              value: formatTien(data.thanhTien),
              isBold: true,
              valueColor: const Color(0xFF6366F1),
            ),
          ],
        ),
      ],
    );
  }
}
