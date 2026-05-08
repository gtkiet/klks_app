// lib/features/hoa_don/utils/hoa_don_utils.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── FORMATTER ────────────────────────────────────────────────────────────────

final _currencyFmt = NumberFormat('#,###', 'vi_VN');
final _dateFmt = DateFormat('dd/MM/yyyy');

String formatTien(double amount) => '${_currencyFmt.format(amount)} đ';
String formatNgay(DateTime dt) => _dateFmt.format(dt);
String formatSoThap(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

// ─── TRANG THAI HOA DON ───────────────────────────────────────────────────────

class TrangThaiHoaDonConfig {
  final String ten;
  final Color mau;
  final Color mauNen;
  final IconData icon;

  const TrangThaiHoaDonConfig({
    required this.ten,
    required this.mau,
    required this.mauNen,
    required this.icon,
  });
}

TrangThaiHoaDonConfig getTrangThaiConfig(int id) {
  switch (id) {
    case 1:
      return TrangThaiHoaDonConfig(
        ten: 'Chờ duyệt',
        mau: const Color(0xFFF59E0B),
        mauNen: const Color(0xFFFEF3C7),
        icon: Icons.hourglass_empty_rounded,
      );
    case 2:
      return TrangThaiHoaDonConfig(
        ten: 'Chưa thanh toán',
        mau: const Color(0xFFF97316),
        mauNen: const Color(0xFFFFF7ED),
        icon: Icons.payment_rounded,
      );
    case 3:
      return TrangThaiHoaDonConfig(
        ten: 'Đã thanh toán',
        mau: const Color(0xFF16A34A),
        mauNen: const Color(0xFFF0FDF4),
        icon: Icons.check_circle_rounded,
      );
    case 4:
      return TrangThaiHoaDonConfig(
        ten: 'Quá hạn',
        mau: const Color(0xFFDC2626),
        mauNen: const Color(0xFFFEF2F2),
        icon: Icons.warning_rounded,
      );
    case 5:
      return TrangThaiHoaDonConfig(
        ten: 'Thanh toán một phần',
        mau: const Color(0xFF0891B2),
        mauNen: const Color(0xFFECFEFF),
        icon: Icons.incomplete_circle_rounded,
      );
    case 6:
      return TrangThaiHoaDonConfig(
        ten: 'Đã hủy',
        mau: const Color(0xFF6B7280),
        mauNen: const Color(0xFFF9FAFB),
        icon: Icons.cancel_rounded,
      );
    default:
      return TrangThaiHoaDonConfig(
        ten: 'Không xác định',
        mau: const Color(0xFF6B7280),
        mauNen: const Color(0xFFF9FAFB),
        icon: Icons.help_outline_rounded,
      );
  }
}

// ─── LOAI DINH GIA ICON ───────────────────────────────────────────────────────

IconData getLoaiDinhGiaIcon(int loaiDinhGiaId) {
  switch (loaiDinhGiaId) {
    case 1:
      return Icons.receipt_long_rounded; // Cố định
    case 2:
      return Icons.show_chart_rounded; // Lũy tiến
    case 3:
      return Icons.square_foot_rounded; // Diện tích
    case 4:
      return Icons.access_time_rounded; // Khung giờ
    default:
      return Icons.attach_money_rounded;
  }
}
