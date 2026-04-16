// lib/features/dich_vu/models/khung_gio_model.dart

class KhungGioItem {
  final int id;
  final int dichVuId;
  final String gioBatDau;
  final String gioKetThuc;
  final String tenKhungGio;
  final int ngayTrongTuan;
  final bool isActive;

  const KhungGioItem({
    required this.id,
    required this.dichVuId,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.tenKhungGio,
    required this.ngayTrongTuan,
    required this.isActive,
  });

  // Getter: hiển thị giờ đẹp hơn
  String get thoiGian => '$gioBatDau - $gioKetThuc';

  factory KhungGioItem.fromJson(Map<String, dynamic> json) => KhungGioItem(
        id: json['id'] as int,
        dichVuId: json['dichVuId'] as int,
        gioBatDau: json['gioBatDau'] as String? ?? '',
        gioKetThuc: json['gioKetThuc'] as String? ?? '',
        tenKhungGio: json['tenKhungGio'] as String? ?? '',
        ngayTrongTuan: json['ngayTrongTuan'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'dichVuId': dichVuId,
        'gioBatDau': gioBatDau,
        'gioKetThuc': gioKetThuc,
        'tenKhungGio': tenKhungGio,
        'ngayTrongTuan': ngayTrongTuan,
        'isActive': isActive,
      };

  KhungGioItem copyWith({
    int? id,
    int? dichVuId,
    String? gioBatDau,
    String? gioKetThuc,
    String? tenKhungGio,
    int? ngayTrongTuan,
    bool? isActive,
  }) {
    return KhungGioItem(
      id: id ?? this.id,
      dichVuId: dichVuId ?? this.dichVuId,
      gioBatDau: gioBatDau ?? this.gioBatDau,
      gioKetThuc: gioKetThuc ?? this.gioKetThuc,
      tenKhungGio: tenKhungGio ?? this.tenKhungGio,
      ngayTrongTuan: ngayTrongTuan ?? this.ngayTrongTuan,
      isActive: isActive ?? this.isActive,
    );
  }
}