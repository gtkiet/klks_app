// lib/features/hoa_don/screens/thanh_toan_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/hoa_don_model.dart';
import '../services/hoa_don_service.dart';

/// Screen 4: Thanh toán hóa đơn qua VietQR.
///
/// Flow:
///   1. Gọi API tạo phiên → nhận vietQrUrl + maThanhToan.
///   2. Hiển thị QR image.
///   3. Polling get-by-id mỗi 3 giây → khi trangThai == 3 (Đã TT) → thông báo thành công.
class ThanhToanScreen extends StatefulWidget {
  final int hoaDonId;
  final String maHoaDon;
  final double tongTien;
  final List<int> chiTietHoaDonIds;

  const ThanhToanScreen({
    super.key,
    required this.hoaDonId,
    required this.maHoaDon,
    required this.tongTien,
    required this.chiTietHoaDonIds,
  });

  @override
  State<ThanhToanScreen> createState() => _ThanhToanScreenState();
}

class _ThanhToanScreenState extends State<ThanhToanScreen> {
  // Bước tạo phiên
  bool _creatingSession = true;
  String? _sessionError;
  PhienThanhToan? _phien;

  // Polling
  Timer? _pollingTimer;
  bool _donePolling = false;
  int _pollCount = 0;
  static const _maxPollCount = 100; // 5 phút tối đa

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // ── Bước 1: Tạo phiên thanh toán ─────────────────────────────────────────
  Future<void> _createSession() async {
    setState(() {
      _creatingSession = true;
      _sessionError = null;
    });
    try {
      final phien = await HoaDonService.instance.taoPhienThanhToan(
        hoaDonId: widget.hoaDonId,
        chiTietHoaDonIds: widget.chiTietHoaDonIds,
      );
      if (!mounted) return;
      setState(() {
        _phien = phien;
        _creatingSession = false;
      });
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sessionError = e.toString();
        _creatingSession = false;
      });
    }
  }

  // ── Bước 2: Polling kiểm tra trạng thái hóa đơn ─────────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_donePolling) return;
    _pollCount++;
    if (_pollCount >= _maxPollCount) {
      _pollingTimer?.cancel();
      return;
    }
    try {
      final detail = await HoaDonService.instance.getById(widget.hoaDonId);
      if (!mounted) return;
      if (detail.laDaThanhToan) {
        _pollingTimer?.cancel();
        setState(() => _donePolling = true);
        _showSuccess();
      }
    } catch (_) {
      // Nuốt lỗi polling — không làm phiền UX
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        tongTien: widget.tongTien,
        onClose: () {
          Navigator.of(context).pop(); // Đóng dialog
          Navigator.of(context).pop(); // Quay về detail screen
        },
      ),
    );
  }

  void _copyMa() {
    final ma = _phien?.maThanhToan;
    if (ma == null) return;
    Clipboard.setData(ClipboardData(text: ma));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép mã thanh toán'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_creatingSession) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang tạo mã thanh toán...',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (_sessionError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFFCA5A5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tạo phiên thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _sessionError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createSession,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final phien = _phien!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Tiêu đề số tiền ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text(
                  'Số tiền cần thanh toán',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  formatTien(phien.soTien),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.maHoaDon,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── QR Code ───────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // QR image từ VietQR URL
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    phien.vietQrUrl,
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, _, _) => Container(
                      width: 240,
                      height: 240,
                      color: const Color(0xFFF1F5FF),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_rounded,
                            size: 64,
                            color: Color(0xFFCBD5E1),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Không tải được QR',
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
                const SizedBox(height: 14),
                const Text(
                  'Quét mã QR bằng ứng dụng ngân hàng',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Mã thanh toán ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nội dung chuyển khoản',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        phien.maThanhToan,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _copyMa,
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                      tooltip: 'Sao chép',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '⚠️ Nhập đúng nội dung để hệ thống tự xác nhận',
                  style: TextStyle(fontSize: 11, color: Color(0xFFF97316)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Trạng thái đợi ────────────────────────────────────────────────
          if (!_donePolling)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF16A34A)),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Đang chờ xác nhận thanh toán...',
                    style: TextStyle(color: Color(0xFF15803D), fontSize: 13),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // ── Hướng dẫn ─────────────────────────────────────────────────────
          const _HuongDanWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── HƯỚNG DẪN ───────────────────────────────────────────────────────────────

class _HuongDanWidget extends StatelessWidget {
  const _HuongDanWidget();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        icon: Icons.phone_android_rounded,
        text: 'Mở ứng dụng ngân hàng trên điện thoại',
      ),
      (
        icon: Icons.qr_code_scanner_rounded,
        text: 'Chọn chức năng quét mã QR / chuyển tiền',
      ),
      (
        icon: Icons.edit_note_rounded,
        text: 'Kiểm tra nội dung chuyển khoản khớp với mã trên',
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        text: 'Xác nhận & hệ thống tự động ghi nhận',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hướng dẫn thanh toán',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.value.text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SUCCESS DIALOG ───────────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  final double tongTien;
  final VoidCallback onClose;

  const _SuccessDialog({required this.tongTien, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 56,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thanh toán thành công!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatTien(tongTien),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hóa đơn đã được ghi nhận.\nCảm ơn bạn đã thanh toán!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hoàn tất',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
