// lib/features/hoa_don/models/hoa_don_model.dart

// ─── PAGING ───────────────────────────────────────────────────────────────────

class PagingInfo {
  final int pageSize;
  final int pageNumber;
  final int totalItems;

  const PagingInfo({
    required this.pageSize,
    required this.pageNumber,
    required this.totalItems,
  });

  factory PagingInfo.fromJson(Map<String, dynamic> json) => PagingInfo(
    pageSize: json['pageSize'] ?? 0,
    pageNumber: json['pageNumber'] ?? 0,
    totalItems: json['totalItems'] ?? 0,
  );

  int get totalPages => pageSize == 0 ? 0 : (totalItems / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
}

// ─── HOA DON (LIST ITEM) ──────────────────────────────────────────────────────

class HoaDon {
  final int id;
  final int canHoId;
  final String maHoaDon;
  final int thang;
  final int nam;
  final DateTime ngayLap;
  final DateTime ngayHanThanhToan;
  final double tongTien;
  final int trangThaiHoaDonId;
  final String trangThaiHoaDonTen;

  const HoaDon({
    required this.id,
    required this.canHoId,
    required this.maHoaDon,
    required this.thang,
    required this.nam,
    required this.ngayLap,
    required this.ngayHanThanhToan,
    required this.tongTien,
    required this.trangThaiHoaDonId,
    required this.trangThaiHoaDonTen,
  });

  factory HoaDon.fromJson(Map<String, dynamic> json) => HoaDon(
    id: json['id'] ?? 0,
    canHoId: json['canHoId'] ?? 0,
    maHoaDon: json['maHoaDon'] ?? '',
    thang: json['thang'] ?? 0,
    nam: json['nam'] ?? 0,
    ngayLap: DateTime.tryParse(json['ngayLap'] ?? '') ?? DateTime.now(),
    ngayHanThanhToan:
        DateTime.tryParse(json['ngayHanThanhToan'] ?? '') ?? DateTime.now(),
    tongTien: (json['tongTien'] ?? 0).toDouble(),
    trangThaiHoaDonId: json['trangThaiHoaDonId'] ?? 0,
    trangThaiHoaDonTen: json['trangThaiHoaDonTen'] ?? '',
  );

  // Getters tiện ích
  bool get laDaThanhToan => trangThaiHoaDonId == 3;
  bool get laQuaHan => trangThaiHoaDonId == 4;
  bool get laChuaThanhToan => trangThaiHoaDonId == 2;
  bool get laCoTheThanhToan => trangThaiHoaDonId == 2 || trangThaiHoaDonId == 5;

  bool get sapHetHan {
    final soNgayConLai = ngayHanThanhToan.difference(DateTime.now()).inDays;
    return soNgayConLai >= 0 && soNgayConLai <= 3;
  }

  String get kyThanhToan => 'Tháng $thang/$nam';
}

class HoaDonListResult {
  final List<HoaDon> items;
  final PagingInfo pagingInfo;

  const HoaDonListResult({required this.items, required this.pagingInfo});

  factory HoaDonListResult.fromJson(Map<String, dynamic> json) =>
      HoaDonListResult(
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => HoaDon.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagingInfo: PagingInfo.fromJson(
          json['pagingInfo'] as Map<String, dynamic>? ?? {},
        ),
      );
}

// ─── CHI TIET HOA DON (LINE ITEM) ────────────────────────────────────────────

class ChiTietHoaDon {
  final int id;
  final int loaiChiTietHoaDonId;
  final String loaiChiTietHoaDonTen;
  final String tenMucPhi;
  final double soLuong;
  final double donGia;
  final double thanhTien;
  final int loaiDinhGiaId;
  final String loaiDinhGiaTen;
  final String ghiChu;

  const ChiTietHoaDon({
    required this.id,
    required this.loaiChiTietHoaDonId,
    required this.loaiChiTietHoaDonTen,
    required this.tenMucPhi,
    required this.soLuong,
    required this.donGia,
    required this.thanhTien,
    required this.loaiDinhGiaId,
    required this.loaiDinhGiaTen,
    required this.ghiChu,
  });

  factory ChiTietHoaDon.fromJson(Map<String, dynamic> json) => ChiTietHoaDon(
    id: json['id'] ?? 0,
    loaiChiTietHoaDonId: json['loaiChiTietHoaDonId'] ?? 0,
    loaiChiTietHoaDonTen: json['loaiChiTietHoaDonTen'] ?? '',
    tenMucPhi: json['tenMucPhi'] ?? '',
    soLuong: (json['soLuong'] ?? 0).toDouble(),
    donGia: (json['donGia'] ?? 0).toDouble(),
    thanhTien: (json['thanhTien'] ?? 0).toDouble(),
    loaiDinhGiaId: json['loaiDinhGiaId'] ?? 0,
    loaiDinhGiaTen: json['loaiDinhGiaTen'] ?? '',
    ghiChu: json['ghiChu'] ?? '',
  );

  // loaiDinhGiaId: 1=Cố định, 2=Lũy tiến, 3=Diện tích, 4=Khung giờ
  bool get laLuyTien => loaiDinhGiaId == 2;
  bool get laCoDinh => loaiDinhGiaId == 1;
  bool get laDienTich => loaiDinhGiaId == 3;
  bool get laKhungGio => loaiDinhGiaId == 4;
}

// ─── HOA DON DETAIL ───────────────────────────────────────────────────────────

class HoaDonDetail {
  final int id;
  final int canHoId;
  final String maHoaDon;
  final int thang;
  final int nam;
  final DateTime ngayLap;
  final DateTime ngayHanThanhToan;
  final double tongTien;
  final int trangThaiHoaDonId;
  final String trangThaiHoaDonTen;
  final String ghiChu;
  final List<ChiTietHoaDon> chiTietHoaDons;

  const HoaDonDetail({
    required this.id,
    required this.canHoId,
    required this.maHoaDon,
    required this.thang,
    required this.nam,
    required this.ngayLap,
    required this.ngayHanThanhToan,
    required this.tongTien,
    required this.trangThaiHoaDonId,
    required this.trangThaiHoaDonTen,
    required this.ghiChu,
    required this.chiTietHoaDons,
  });

  factory HoaDonDetail.fromJson(Map<String, dynamic> json) => HoaDonDetail(
    id: json['id'] ?? 0,
    canHoId: json['canHoId'] ?? 0,
    maHoaDon: json['maHoaDon'] ?? '',
    thang: json['thang'] ?? 0,
    nam: json['nam'] ?? 0,
    ngayLap: DateTime.tryParse(json['ngayLap'] ?? '') ?? DateTime.now(),
    ngayHanThanhToan:
        DateTime.tryParse(json['ngayHanThanhToan'] ?? '') ?? DateTime.now(),
    tongTien: (json['tongTien'] ?? 0).toDouble(),
    trangThaiHoaDonId: json['trangThaiHoaDonId'] ?? 0,
    trangThaiHoaDonTen: json['trangThaiHoaDonTen'] ?? '',
    ghiChu: json['ghiChu'] ?? '',
    chiTietHoaDons: (json['chiTietHoaDons'] as List<dynamic>? ?? [])
        .map((e) => ChiTietHoaDon.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  bool get laCoTheThanhToan => trangThaiHoaDonId == 2 || trangThaiHoaDonId == 5;
  bool get laDaThanhToan => trangThaiHoaDonId == 3;
  String get kyThanhToan => 'Tháng $thang/$nam';
}

// ─── CHI TIET CO DINH ─────────────────────────────────────────────────────────

class ChiTietCoDinh {
  final int id;
  final String tenMucPhi;
  final double soLuong;
  final double donGia;
  final double thanhTien;
  final String ghiChu;

  const ChiTietCoDinh({
    required this.id,
    required this.tenMucPhi,
    required this.soLuong,
    required this.donGia,
    required this.thanhTien,
    required this.ghiChu,
  });

  factory ChiTietCoDinh.fromJson(Map<String, dynamic> json) => ChiTietCoDinh(
    id: json['id'] ?? 0,
    tenMucPhi: json['tenMucPhi'] ?? '',
    soLuong: (json['soLuong'] ?? 0).toDouble(),
    donGia: (json['donGia'] ?? 0).toDouble(),
    thanhTien: (json['thanhTien'] ?? 0).toDouble(),
    ghiChu: json['ghiChu'] ?? '',
  );
}

// ─── CHI TIET LUY TIEN ────────────────────────────────────────────────────────

class BacThang {
  final String tenBac;
  final double tuSo;
  final double denSo;
  final double soLuong;
  final double donGia;
  final double thanhTien;

  const BacThang({
    required this.tenBac,
    required this.tuSo,
    required this.denSo,
    required this.soLuong,
    required this.donGia,
    required this.thanhTien,
  });

  factory BacThang.fromJson(Map<String, dynamic> json) => BacThang(
    tenBac: json['tenBac'] ?? '',
    tuSo: (json['tuSo'] ?? 0).toDouble(),
    denSo: (json['denSo'] ?? 0).toDouble(),
    soLuong: (json['soLuong'] ?? 0).toDouble(),
    donGia: (json['donGia'] ?? 0).toDouble(),
    thanhTien: (json['thanhTien'] ?? 0).toDouble(),
  );
}

class ChiTietLuyTien {
  final int id;
  final String tenMucPhi;
  final double chiSoCu;
  final double chiSoMoi;
  final double soLuongTieuThu;
  final double thanhTien;
  final String anhDongHoUrl;
  final List<BacThang> bacThang;

  const ChiTietLuyTien({
    required this.id,
    required this.tenMucPhi,
    required this.chiSoCu,
    required this.chiSoMoi,
    required this.soLuongTieuThu,
    required this.thanhTien,
    required this.anhDongHoUrl,
    required this.bacThang,
  });

  factory ChiTietLuyTien.fromJson(Map<String, dynamic> json) => ChiTietLuyTien(
    id: json['id'] ?? 0,
    tenMucPhi: json['tenMucPhi'] ?? '',
    chiSoCu: (json['chiSoCu'] ?? 0).toDouble(),
    chiSoMoi: (json['chiSoMoi'] ?? 0).toDouble(),
    soLuongTieuThu: (json['soLuongTieuThu'] ?? 0).toDouble(),
    thanhTien: (json['thanhTien'] ?? 0).toDouble(),
    anhDongHoUrl: json['anhDongHoUrl'] ?? '',
    bacThang: (json['bacThang'] as List<dynamic>? ?? [])
        .map((e) => BacThang.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

// ─── CHI TIET DIEN TICH ───────────────────────────────────────────────────────

class ChiTietDienTich {
  final int id;
  final String tenMucPhi;
  final String tenLoaiCanHo;
  final double dienTich;
  final double donGia;
  final double thanhTien;

  const ChiTietDienTich({
    required this.id,
    required this.tenMucPhi,
    required this.tenLoaiCanHo,
    required this.dienTich,
    required this.donGia,
    required this.thanhTien,
  });

  factory ChiTietDienTich.fromJson(Map<String, dynamic> json) =>
      ChiTietDienTich(
        id: json['id'] ?? 0,
        tenMucPhi: json['tenMucPhi'] ?? '',
        tenLoaiCanHo: json['tenLoaiCanHo'] ?? '',
        dienTich: (json['dienTich'] ?? 0).toDouble(),
        donGia: (json['donGia'] ?? 0).toDouble(),
        thanhTien: (json['thanhTien'] ?? 0).toDouble(),
      );
}

// ─── CHI TIET KHUNG GIO ───────────────────────────────────────────────────────

class KhungGio {
  final String tenKhungGio;
  final String gioBatDau;
  final String gioKetThuc;
  final double donGia;

  const KhungGio({
    required this.tenKhungGio,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.donGia,
  });

  factory KhungGio.fromJson(Map<String, dynamic> json) => KhungGio(
    tenKhungGio: json['tenKhungGio'] ?? '',
    gioBatDau: json['gioBatDau'] ?? '',
    gioKetThuc: json['gioKetThuc'] ?? '',
    donGia: (json['donGia'] ?? 0).toDouble(),
  );
}

class ChiTietKhungGio {
  final int id;
  final String tenMucPhi;
  final double thanhTien;
  final List<KhungGio> khungGios;

  const ChiTietKhungGio({
    required this.id,
    required this.tenMucPhi,
    required this.thanhTien,
    required this.khungGios,
  });

  factory ChiTietKhungGio.fromJson(Map<String, dynamic> json) =>
      ChiTietKhungGio(
        id: json['id'] ?? 0,
        tenMucPhi: json['tenMucPhi'] ?? '',
        thanhTien: (json['thanhTien'] ?? 0).toDouble(),
        khungGios: (json['khungGios'] as List<dynamic>? ?? [])
            .map((e) => KhungGio.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ─── THANH TOAN ───────────────────────────────────────────────────────────────

class PhienThanhToan {
  final String maThanhToan;
  final double soTien;
  final String vietQrUrl;

  const PhienThanhToan({
    required this.maThanhToan,
    required this.soTien,
    required this.vietQrUrl,
  });

  factory PhienThanhToan.fromJson(Map<String, dynamic> json) => PhienThanhToan(
    maThanhToan: json['maThanhToan'] ?? '',
    soTien: (json['soTien'] ?? 0).toDouble(),
    vietQrUrl: json['vietQrUrl'] ?? '',
  );
}
