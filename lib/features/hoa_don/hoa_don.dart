// lib/features/hoa_don/hoa_don.dart
// Barrel export – import duy nhất file này là đủ.

export 'models/hoa_don_model.dart';
export 'services/hoa_don_service.dart';
export 'utils/hoa_don_utils.dart';
export 'screens/hoa_don_list_screen.dart';
export 'screens/hoa_don_detail_screen.dart';
export 'screens/chi_tiet_phi_screen.dart';
export 'screens/thanh_toan_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USAGE GUIDE
// ─────────────────────────────────────────────────────────────────────────────
//
// Sau khi lấy canHoId từ API /api/cu-dan/quan-he-cu-tru, push màn hình:
//
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => HoaDonListScreen(
//         canHoId: 15,            // canHoId từ quan hệ cư trú
//         tenCanHo: 'Phòng 302',  // hiển thị trên AppBar
//       ),
//     ),
//   );
//
// ─── NAVIGATION FLOW ──────────────────────────────────────────────────────────
//
//   HoaDonListScreen (4 tab: Tất cả / Chưa TT / Đã TT / Quá hạn)
//       │
//       ▼  onTap card
//   HoaDonDetailScreen (summary card + list chi tiết phí)
//       │                       │
//       ▼  tap khoản phí        ▼  bấm nút "Thanh toán"
//   ChiTietPhiScreen        ThanhToanScreen
//   (auto-route dựa vào     (tạo phiên → QR → polling
//    loaiDinhGiaId:          → success dialog)
//    1=CoDinh, 2=LuyTien,
//    3=DienTich, 4=KhungGio)
//
// ─── DEPENDENCY ───────────────────────────────────────────────────────────────
//
//  pubspec.yaml cần thêm:
//    intl: ^0.19.0
//
// ─── TODO ─────────────────────────────────────────────────────────────────────
//
//  [ ] Validation: kiểm tra canHoId > 0 trước khi vào list screen
//  [ ] Deep-link từ push notification thẳng vào HoaDonDetailScreen
//  [ ] Thêm filter tháng/năm trên list screen
//  [ ] Download PDF hóa đơn (nếu backend hỗ trợ)