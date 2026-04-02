// lib/features/residence/models/member.dart

import 'residence_document.dart';

class Member {
  final int quanHeCuTruId;
  final int userId;
  final int loaiQuanHeCuTruId;
  final String loaiQuanHeTen;
  final DateTime ngayBatDau;
  final String fullName;
  final String? anhDaiDienUrl;

  const Member({
    required this.quanHeCuTruId,
    required this.userId,
    required this.loaiQuanHeCuTruId,
    required this.loaiQuanHeTen,
    required this.ngayBatDau,
    required this.fullName,
    this.anhDaiDienUrl,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        quanHeCuTruId: json['quanHeCuTruId'] as int,
        userId: json['userId'] as int,
        loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int,
        loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
        ngayBatDau: DateTime.parse(json['ngayBatDau'] as String),
        fullName: json['fullName'] as String? ?? '',
        anhDaiDienUrl: json['anhDaiDienUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'quanHeCuTruId': quanHeCuTruId,
        'userId': userId,
        'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
        'loaiQuanHeTen': loaiQuanHeTen,
        'ngayBatDau': ngayBatDau.toIso8601String(),
        'fullName': fullName,
        'anhDaiDienUrl': anhDaiDienUrl,
      };
}

class MemberDetail {
  final int userId;
  final String fullName;
  final String firstName;
  final String lastName;
  final int gioiTinhId;
  final String gioiTinhName;
  final DateTime? dob;
  final String? idCard;
  final String? phoneNumber;
  final String? diaChi;
  final String? anhDaiDienUrl;
  final int quanHeCuTruId;
  final int loaiQuanHeCuTruId;
  final String loaiQuanHeTen;
  final DateTime ngayBatDau;
  final DateTime? ngayKetThuc;
  final int trangThaiCuTruId;
  final String trangThaiCuTruTen;
  final List<ResidenceDocument> taiLieuCuTrus;

  const MemberDetail({
    required this.userId,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.gioiTinhId,
    required this.gioiTinhName,
    this.dob,
    this.idCard,
    this.phoneNumber,
    this.diaChi,
    this.anhDaiDienUrl,
    required this.quanHeCuTruId,
    required this.loaiQuanHeCuTruId,
    required this.loaiQuanHeTen,
    required this.ngayBatDau,
    this.ngayKetThuc,
    required this.trangThaiCuTruId,
    required this.trangThaiCuTruTen,
    required this.taiLieuCuTrus,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) => MemberDetail(
        userId: json['userId'] as int,
        fullName: json['fullName'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        gioiTinhId: json['gioiTinhId'] as int? ?? 0,
        gioiTinhName: json['gioiTinhName'] as String? ?? '',
        dob: json['dob'] != null ? DateTime.tryParse(json['dob'] as String) : null,
        idCard: json['idCard'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        diaChi: json['diaChi'] as String?,
        anhDaiDienUrl: json['anhDaiDienUrl'] as String?,
        quanHeCuTruId: json['quanHeCuTruId'] as int,
        loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int? ?? 0,
        loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
        ngayBatDau: DateTime.parse(json['ngayBatDau'] as String),
        ngayKetThuc: json['ngayKetThuc'] != null
            ? DateTime.tryParse(json['ngayKetThuc'] as String)
            : null,
        trangThaiCuTruId: json['trangThaiCuTruId'] as int? ?? 0,
        trangThaiCuTruTen: json['trangThaiCuTruTen'] as String? ?? '',
        taiLieuCuTrus:
            (json['taiLieuCuTrus'] as List<dynamic>?)
                    ?.map((e) => ResidenceDocument.fromJson(e))
                    .toList() ??
                [],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'fullName': fullName,
        'firstName': firstName,
        'lastName': lastName,
        'gioiTinhId': gioiTinhId,
        'gioiTinhName': gioiTinhName,
        'dob': dob?.toIso8601String(),
        'idCard': idCard,
        'phoneNumber': phoneNumber,
        'diaChi': diaChi,
        'anhDaiDienUrl': anhDaiDienUrl,
        'quanHeCuTruId': quanHeCuTruId,
        'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
        'loaiQuanHeTen': loaiQuanHeTen,
        'ngayBatDau': ngayBatDau.toIso8601String(),
        'ngayKetThuc': ngayKetThuc?.toIso8601String(),
        'trangThaiCuTruId': trangThaiCuTruId,
        'trangThaiCuTruTen': trangThaiCuTruTen,
        'taiLieuCuTrus': taiLieuCuTrus.map((e) => e.toJson()).toList(),
      };
}