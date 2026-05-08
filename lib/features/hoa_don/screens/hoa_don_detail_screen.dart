// lib/features/hoa_don/screens/hoa_don_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/hoa_don_model.dart';
import '../services/hoa_don_service.dart';
import '../utils/hoa_don_utils.dart';
import 'chi_tiet_phi_screen.dart';
import 'thanh_toan_screen.dart';

/// Screen 2: Chi tiết hóa đơn.
///
/// Hiển thị header hóa đơn + danh sách từng khoản phí.
/// Mỗi khoản phí có thể bấm để xem breakdown chi tiết.
class HoaDonDetailScreen extends StatefulWidget {
  final int hoaDonId;
  final String maHoaDon;

  const HoaDonDetailScreen({
    super.key,
    required this.hoaDonId,
    required this.maHoaDon,
  });

  @override
  State<HoaDonDetailScreen> createState() => _HoaDonDetailScreenState();
}

class _HoaDonDetailScreenState extends State<HoaDonDetailScreen> {
  HoaDonDetail? _detail;
  bool _loading = true;
  String? _error;

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
      final detail = await HoaDonService.instance.getById(widget.hoaDonId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _goToThanhToan() {
    final detail = _detail;
    if (detail == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThanhToanScreen(
          hoaDonId: detail.id,
          maHoaDon: detail.maHoaDon,
          tongTien: detail.tongTien,
        ),
      ),
    ).then((_) => _load()); // Reload sau khi quay về
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết hóa đơn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              widget.maHoaDon,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6366F1)),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
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

    final detail = _detail!;
    final cfg = getTrangThaiConfig(detail.trangThaiHoaDonId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Thẻ tổng quan ──────────────────────────────────────────────────
        _buildSummaryCard(detail, cfg),
        const SizedBox(height: 16),

        // ── Danh sách chi tiết phí ─────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Chi tiết các khoản phí',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),

        ...detail.chiTietHoaDons.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChiTietCard(chiTiet: item),
          ),
        ),

        const SizedBox(height: 80), // Bottom bar safe area
      ],
    );
  }

  Widget _buildSummaryCard(HoaDonDetail detail, TrangThaiHoaDonConfig cfg) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: detail.laCoTheThanhToan
              ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
              : detail.laDaThanhToan
              ? [const Color(0xFF16A34A), const Color(0xFF059669)]
              : [const Color(0xFF475569), const Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                cfg.icon,
                color: Colors.white.withValues(alpha: 0.9),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                cfg.ten,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatTien(detail.tongTien),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.kyThanhToan,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.tag_rounded,
            label: 'Mã hóa đơn',
            value: detail.maHoaDon,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Ngày lập',
            value: formatNgay(detail.ngayLap),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.event_busy_rounded,
            label: 'Hạn thanh toán',
            value: formatNgay(detail.ngayHanThanhToan),
          ),
          if (detail.ghiChu.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'Ghi chú',
              value: detail.ghiChu,
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildBottomBar() {
    final detail = _detail;
    if (detail == null || !detail.laCoTheThanhToan) return null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _goToThanhToan,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: Text('Thanh toán ${formatTien(detail.tongTien)}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── INFO ROW (dùng trong gradient card) ─────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── CHI TIET CARD ────────────────────────────────────────────────────────────

class _ChiTietCard extends StatelessWidget {
  final ChiTietHoaDon chiTiet;

  const _ChiTietCard({required this.chiTiet});

  String get _loaiLabel {
    switch (chiTiet.loaiDinhGiaId) {
      case 1:
        return 'Cố định';
      case 2:
        return 'Lũy tiến';
      case 3:
        return 'Diện tích';
      case 4:
        return 'Khung giờ';
      default:
        return chiTiet.loaiDinhGiaTen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = getLoaiDinhGiaIcon(chiTiet.loaiDinhGiaId);
    final canDrillDown =
        chiTiet.laLuyTien ||
        chiTiet.laCoDinh ||
        chiTiet.laDienTich ||
        chiTiet.laKhungGio;

    return GestureDetector(
      onTap: canDrillDown
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChiTietPhiScreen(chiTiet: chiTiet),
              ),
            )
          : null,
      child: Container(
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chiTiet.tenMucPhi,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _loaiLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (chiTiet.ghiChu.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            chiTiet.ghiChu,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!chiTiet.laLuyTien) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${formatSoThap(chiTiet.soLuong)} × ${formatTien(chiTiet.donGia)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTien(chiTiet.thanhTien),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (canDrillDown) ...[
                  const SizedBox(height: 2),
                  const Row(
                    children: [
                      Text(
                        'Chi tiết',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
