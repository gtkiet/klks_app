// // lib/features/residence/models/residence_models.dart

// // ─── Catalog / Selector ───────────────────────────────────────────────────────

// class SelectorItem {
//   final int id;
//   final String name;

//   const SelectorItem({required this.id, required this.name});

//   factory SelectorItem.fromJson(Map<String, dynamic> json) =>
//       SelectorItem(id: json['id'] as int, name: json['name'] as String);

//   Map<String, dynamic> toJson() => {'id': id, 'name': name};
// }

// // ─── Upload ───────────────────────────────────────────────────────────────────

// class UploadFileResponse {
//   final String fileId;
//   final String fileName;

//   const UploadFileResponse({required this.fileId, required this.fileName});

//   factory UploadFileResponse.fromJson(Map<String, dynamic> json) =>
//       UploadFileResponse(
//         fileId: json['fileId'] as String,
//         fileName: json['fileName'] as String,
//       );

//   Map<String, dynamic> toJson() => {'fileId': fileId, 'fileName': fileName};
// }

// // ─── Residence (căn hộ cư trú) ───────────────────────────────────────────────

// class ResidenceApartment {
//   final int quanHeCuTruId;
//   final int loaiQuanHeCuTruId;
//   final String loaiQuanHeTen;
//   final DateTime ngayBatDau;
//   final int toaNhaId;
//   final String maToaNha;
//   final String tenToaNha;
//   final int tangId;
//   final String maTang;
//   final String tenTang;
//   final int canHoId;
//   final String maCanHo;
//   final String tenCanHo;
//   final int tongCuDan;

//   const ResidenceApartment({
//     required this.quanHeCuTruId,
//     required this.loaiQuanHeCuTruId,
//     required this.loaiQuanHeTen,
//     required this.ngayBatDau,
//     required this.toaNhaId,
//     required this.maToaNha,
//     required this.tenToaNha,
//     required this.tangId,
//     required this.maTang,
//     required this.tenTang,
//     required this.canHoId,
//     required this.maCanHo,
//     required this.tenCanHo,
//     required this.tongCuDan,
//   });

//   factory ResidenceApartment.fromJson(Map<String, dynamic> json) =>
//       ResidenceApartment(
//         quanHeCuTruId: json['quanHeCuTruId'] as int,
//         loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int,
//         loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
//         ngayBatDau: DateTime.parse(json['ngayBatDau'] as String),
//         toaNhaId: json['toaNhaId'] as int,
//         maToaNha: json['maToaNha'] as String? ?? '',
//         tenToaNha: json['tenToaNha'] as String? ?? '',
//         tangId: json['tangId'] as int,
//         maTang: json['maTang'] as String? ?? '',
//         tenTang: json['tenTang'] as String? ?? '',
//         canHoId: json['canHoId'] as int,
//         maCanHo: json['maCanHo'] as String? ?? '',
//         tenCanHo: json['tenCanHo'] as String? ?? '',
//         tongCuDan: json['tongCuDan'] as int? ?? 0,
//       );

//   Map<String, dynamic> toJson() => {
//     'quanHeCuTruId': quanHeCuTruId,
//     'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
//     'loaiQuanHeTen': loaiQuanHeTen,
//     'ngayBatDau': ngayBatDau.toIso8601String(),
//     'toaNhaId': toaNhaId,
//     'maToaNha': maToaNha,
//     'tenToaNha': tenToaNha,
//     'tangId': tangId,
//     'maTang': maTang,
//     'tenTang': tenTang,
//     'canHoId': canHoId,
//     'maCanHo': maCanHo,
//     'tenCanHo': tenCanHo,
//     'tongCuDan': tongCuDan,
//   };
// }

// // ─── Member (thành viên rút gọn) ─────────────────────────────────────────────

// class Member {
//   final int quanHeCuTruId;
//   final int userId;
//   final int loaiQuanHeCuTruId;
//   final String loaiQuanHeTen;
//   final DateTime ngayBatDau;
//   final String fullName;
//   final String? anhDaiDienUrl;

//   const Member({
//     required this.quanHeCuTruId,
//     required this.userId,
//     required this.loaiQuanHeCuTruId,
//     required this.loaiQuanHeTen,
//     required this.ngayBatDau,
//     required this.fullName,
//     this.anhDaiDienUrl,
//   });

//   factory Member.fromJson(Map<String, dynamic> json) => Member(
//     quanHeCuTruId: json['quanHeCuTruId'] as int,
//     userId: json['userId'] as int,
//     loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int,
//     loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
//     ngayBatDau: DateTime.parse(json['ngayBatDau'] as String),
//     fullName: json['fullName'] as String? ?? '',
//     anhDaiDienUrl: json['anhDaiDienUrl'] as String?,
//   );

//   Map<String, dynamic> toJson() => {
//     'quanHeCuTruId': quanHeCuTruId,
//     'userId': userId,
//     'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
//     'loaiQuanHeTen': loaiQuanHeTen,
//     'ngayBatDau': ngayBatDau.toIso8601String(),
//     'fullName': fullName,
//     'anhDaiDienUrl': anhDaiDienUrl,
//   };
// }

// // ─── ResidenceDocument ────────────────────────────────────────────────────────

// class DocumentFile {
//   final int id;
//   final String fileUrl;
//   final String fileName;
//   final String contentType;

//   const DocumentFile({
//     required this.id,
//     required this.fileUrl,
//     required this.fileName,
//     required this.contentType,
//   });

//   factory DocumentFile.fromJson(Map<String, dynamic> json) => DocumentFile(
//     id: json['id'] as int,
//     fileUrl: json['fileUrl'] as String? ?? '',
//     fileName: json['fileName'] as String? ?? '',
//     contentType: json['contentType'] as String? ?? '',
//   );

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'fileUrl': fileUrl,
//     'fileName': fileName,
//     'contentType': contentType,
//   };
// }

// class ResidenceDocument {
//   final int id;
//   final int loaiGiayToId;
//   final String tenLoaiGiayTo;
//   final String soGiayTo;
//   final DateTime? ngayPhatHanh;
//   final int? targetTaiLieuCuTruId;
//   final List<DocumentFile> files;

//   const ResidenceDocument({
//     required this.id,
//     required this.loaiGiayToId,
//     required this.tenLoaiGiayTo,
//     required this.soGiayTo,
//     this.ngayPhatHanh,
//     this.targetTaiLieuCuTruId,
//     required this.files,
//   });

//   factory ResidenceDocument.fromJson(Map<String, dynamic> json) =>
//       ResidenceDocument(
//         id: json['id'] as int,
//         loaiGiayToId: json['loaiGiayToId'] as int? ?? 0,
//         tenLoaiGiayTo: json['tenLoaiGiayTo'] as String? ?? '',
//         soGiayTo: json['soGiayTo'] as String? ?? '',
//         ngayPhatHanh: json['ngayPhatHanh'] != null
//             ? DateTime.tryParse(json['ngayPhatHanh'] as String)
//             : null,
//         targetTaiLieuCuTruId: json['targetTaiLieuCuTruId'] as int?,
//         files:
//             (json['files'] as List<dynamic>?)
//                 ?.map((e) => DocumentFile.fromJson(e as Map<String, dynamic>))
//                 .toList() ??
//             [],
//       );

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'loaiGiayToId': loaiGiayToId,
//     'tenLoaiGiayTo': tenLoaiGiayTo,
//     'soGiayTo': soGiayTo,
//     'ngayPhatHanh': ngayPhatHanh?.toIso8601String(),
//     'targetTaiLieuCuTruId': targetTaiLieuCuTruId,
//     'files': files.map((e) => e.toJson()).toList(),
//   };
// }

// // ─── MemberDetail ─────────────────────────────────────────────────────────────

// class MemberDetail {
//   final int userId;
//   final String fullName;
//   final String firstName;
//   final String lastName;
//   final int gioiTinhId;
//   final String gioiTinhName;
//   final DateTime? dob;
//   final String? idCard;
//   final String? phoneNumber;
//   final String? diaChi;
//   final String? anhDaiDienUrl;
//   final int quanHeCuTruId;
//   final int loaiQuanHeCuTruId;
//   final String loaiQuanHeTen;
//   final DateTime ngayBatDau;
//   final DateTime? ngayKetThuc;
//   final int trangThaiCuTruId;
//   final String trangThaiCuTruTen;
//   final List<ResidenceDocument> taiLieuCuTrus;

//   const MemberDetail({
//     required this.userId,
//     required this.fullName,
//     required this.firstName,
//     required this.lastName,
//     required this.gioiTinhId,
//     required this.gioiTinhName,
//     this.dob,
//     this.idCard,
//     this.phoneNumber,
//     this.diaChi,
//     this.anhDaiDienUrl,
//     required this.quanHeCuTruId,
//     required this.loaiQuanHeCuTruId,
//     required this.loaiQuanHeTen,
//     required this.ngayBatDau,
//     this.ngayKetThuc,
//     required this.trangThaiCuTruId,
//     required this.trangThaiCuTruTen,
//     required this.taiLieuCuTrus,
//   });

//   factory MemberDetail.fromJson(Map<String, dynamic> json) => MemberDetail(
//     userId: json['userId'] as int,
//     fullName: json['fullName'] as String? ?? '',
//     firstName: json['firstName'] as String? ?? '',
//     lastName: json['lastName'] as String? ?? '',
//     gioiTinhId: json['gioiTinhId'] as int? ?? 0,
//     gioiTinhName: json['gioiTinhName'] as String? ?? '',
//     dob: json['dob'] != null ? DateTime.tryParse(json['dob'] as String) : null,
//     idCard: json['idCard'] as String?,
//     phoneNumber: json['phoneNumber'] as String?,
//     diaChi: json['diaChi'] as String?,
//     anhDaiDienUrl: json['anhDaiDienUrl'] as String?,
//     quanHeCuTruId: json['quanHeCuTruId'] as int,
//     loaiQuanHeCuTruId: json['loaiQuanHeCuTruId'] as int? ?? 0,
//     loaiQuanHeTen: json['loaiQuanHeTen'] as String? ?? '',
//     ngayBatDau: DateTime.parse(json['ngayBatDau'] as String),
//     ngayKetThuc: json['ngayKetThuc'] != null
//         ? DateTime.tryParse(json['ngayKetThuc'] as String)
//         : null,
//     trangThaiCuTruId: json['trangThaiCuTruId'] as int? ?? 0,
//     trangThaiCuTruTen: json['trangThaiCuTruTen'] as String? ?? '',
//     taiLieuCuTrus:
//         (json['taiLieuCuTrus'] as List<dynamic>?)
//             ?.map((e) => ResidenceDocument.fromJson(e as Map<String, dynamic>))
//             .toList() ??
//         [],
//   );

//   MemberDetail copyWith({
//     String? firstName,
//     String? lastName,
//     int? gioiTinhId,
//     DateTime? dob,
//     String? idCard,
//     String? phoneNumber,
//     String? diaChi,
//     List<ResidenceDocument>? taiLieuCuTrus,
//   }) => MemberDetail(
//     userId: userId,
//     fullName: fullName,
//     firstName: firstName ?? this.firstName,
//     lastName: lastName ?? this.lastName,
//     gioiTinhId: gioiTinhId ?? this.gioiTinhId,
//     gioiTinhName: gioiTinhName,
//     dob: dob ?? this.dob,
//     idCard: idCard ?? this.idCard,
//     phoneNumber: phoneNumber ?? this.phoneNumber,
//     diaChi: diaChi ?? this.diaChi,
//     anhDaiDienUrl: anhDaiDienUrl,
//     quanHeCuTruId: quanHeCuTruId,
//     loaiQuanHeCuTruId: loaiQuanHeCuTruId,
//     loaiQuanHeTen: loaiQuanHeTen,
//     ngayBatDau: ngayBatDau,
//     ngayKetThuc: ngayKetThuc,
//     trangThaiCuTruId: trangThaiCuTruId,
//     trangThaiCuTruTen: trangThaiCuTruTen,
//     taiLieuCuTrus: taiLieuCuTrus ?? this.taiLieuCuTrus,
//   );

//   Map<String, dynamic> toJson() => {
//     'userId': userId,
//     'fullName': fullName,
//     'firstName': firstName,
//     'lastName': lastName,
//     'gioiTinhId': gioiTinhId,
//     'gioiTinhName': gioiTinhName,
//     'dob': dob?.toIso8601String(),
//     'idCard': idCard,
//     'phoneNumber': phoneNumber,
//     'diaChi': diaChi,
//     'anhDaiDienUrl': anhDaiDienUrl,
//     'quanHeCuTruId': quanHeCuTruId,
//     'loaiQuanHeCuTruId': loaiQuanHeCuTruId,
//     'loaiQuanHeTen': loaiQuanHeTen,
//     'ngayBatDau': ngayBatDau.toIso8601String(),
//     'ngayKetThuc': ngayKetThuc?.toIso8601String(),
//     'trangThaiCuTruId': trangThaiCuTruId,
//     'trangThaiCuTruTen': trangThaiCuTruTen,
//     'taiLieuCuTrus': taiLieuCuTrus.map((e) => e.toJson()).toList(),
//   };
// }

// // ─── ResidenceRequest ─────────────────────────────────────────────────────────

// class ResidenceRequestItem {
//   final int id;
//   final int createdBy;
//   final String tenNguoiGui;
//   final DateTime createdAt;
//   final int canHoId;
//   final String tenCanHo;
//   final String tenTang;
//   final String tenToaNha;
//   final int? nguoiXuLyId;
//   final String? tenNguoiXuLy;
//   final DateTime? ngayXuLy;
//   final int loaiYeuCauId;
//   final String tenLoaiYeuCau;
//   final int trangThaiId;
//   final String tenTrangThai;
//   final String? lyDo;
//   final String? noiDung;

//   const ResidenceRequestItem({
//     required this.id,
//     required this.createdBy,
//     required this.tenNguoiGui,
//     required this.createdAt,
//     required this.canHoId,
//     required this.tenCanHo,
//     required this.tenTang,
//     required this.tenToaNha,
//     this.nguoiXuLyId,
//     this.tenNguoiXuLy,
//     this.ngayXuLy,
//     required this.loaiYeuCauId,
//     required this.tenLoaiYeuCau,
//     required this.trangThaiId,
//     required this.tenTrangThai,
//     this.lyDo,
//     this.noiDung,
//   });

//   factory ResidenceRequestItem.fromJson(Map<String, dynamic> json) =>
//       ResidenceRequestItem(
//         id: json['id'] as int,
//         createdBy: json['createdBy'] as int? ?? 0,
//         tenNguoiGui: json['tenNguoiGui'] as String? ?? '',
//         createdAt: DateTime.parse(json['createdAt'] as String),
//         canHoId: json['canHoId'] as int,
//         tenCanHo: json['tenCanHo'] as String? ?? '',
//         tenTang: json['tenTang'] as String? ?? '',
//         tenToaNha: json['tenToaNha'] as String? ?? '',
//         nguoiXuLyId: json['nguoiXuLyId'] as int?,
//         tenNguoiXuLy: json['tenNguoiXuLy'] as String?,
//         ngayXuLy: json['ngayXuLy'] != null
//             ? DateTime.tryParse(json['ngayXuLy'] as String)
//             : null,
//         loaiYeuCauId: json['loaiYeuCauId'] as int,
//         tenLoaiYeuCau: json['tenLoaiYeuCau'] as String? ?? '',
//         trangThaiId: json['trangThaiId'] as int,
//         tenTrangThai: json['tenTrangThai'] as String? ?? '',
//         lyDo: json['lyDo'] as String?,
//         noiDung: json['noiDung'] as String?,
//       );

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'createdBy': createdBy,
//     'tenNguoiGui': tenNguoiGui,
//     'createdAt': createdAt.toIso8601String(),
//     'canHoId': canHoId,
//     'tenCanHo': tenCanHo,
//     'tenTang': tenTang,
//     'tenToaNha': tenToaNha,
//     'nguoiXuLyId': nguoiXuLyId,
//     'tenNguoiXuLy': tenNguoiXuLy,
//     'ngayXuLy': ngayXuLy?.toIso8601String(),
//     'loaiYeuCauId': loaiYeuCauId,
//     'tenLoaiYeuCau': tenLoaiYeuCau,
//     'trangThaiId': trangThaiId,
//     'tenTrangThai': tenTrangThai,
//     'lyDo': lyDo,
//     'noiDung': noiDung,
//   };
// }

// class ResidenceRequestDetail {
//   final int id;
//   final int createdBy;
//   final String tenNguoiGui;
//   final DateTime createdAt;
//   final int canHoId;
//   final String tenCanHo;
//   final String tenTang;
//   final String tenToaNha;
//   final int? nguoiXuLyId;
//   final String? tenNguoiXuLy;
//   final DateTime? ngayXuLy;
//   final int loaiYeuCauId;
//   final String tenLoaiYeuCau;
//   final int? targetQuanHeCuTruId;
//   final String? yeuCauTen;
//   final String? yeuCauHo;
//   final DateTime? yeuCauNgaySinh;
//   final int? yeuCauGioiTinhId;
//   final String? yeuCauGioiTinhTen;
//   final String? yeuCauSoDienThoai;
//   final String? yeuCauCCCD;
//   final String? yeuCauDiaChi;
//   final int? yeuCauLoaiQuanHeId;
//   final String? yeuCauLoaiQuanHeTen;
//   final String? noiDung;
//   final String? lyDo;
//   final int trangThaiId;
//   final String tenTrangThai;
//   final List<ResidenceDocument> documents;

//   const ResidenceRequestDetail({
//     required this.id,
//     required this.createdBy,
//     required this.tenNguoiGui,
//     required this.createdAt,
//     required this.canHoId,
//     required this.tenCanHo,
//     required this.tenTang,
//     required this.tenToaNha,
//     this.nguoiXuLyId,
//     this.tenNguoiXuLy,
//     this.ngayXuLy,
//     required this.loaiYeuCauId,
//     required this.tenLoaiYeuCau,
//     this.targetQuanHeCuTruId,
//     this.yeuCauTen,
//     this.yeuCauHo,
//     this.yeuCauNgaySinh,
//     this.yeuCauGioiTinhId,
//     this.yeuCauGioiTinhTen,
//     this.yeuCauSoDienThoai,
//     this.yeuCauCCCD,
//     this.yeuCauDiaChi,
//     this.yeuCauLoaiQuanHeId,
//     this.yeuCauLoaiQuanHeTen,
//     this.noiDung,
//     this.lyDo,
//     required this.trangThaiId,
//     required this.tenTrangThai,
//     required this.documents,
//   });

//   factory ResidenceRequestDetail.fromJson(Map<String, dynamic> json) =>
//       ResidenceRequestDetail(
//         id: json['id'] as int,
//         createdBy: json['createdBy'] as int? ?? 0,
//         tenNguoiGui: json['tenNguoiGui'] as String? ?? '',
//         createdAt: DateTime.parse(json['createdAt'] as String),
//         canHoId: json['canHoId'] as int,
//         tenCanHo: json['tenCanHo'] as String? ?? '',
//         tenTang: json['tenTang'] as String? ?? '',
//         tenToaNha: json['tenToaNha'] as String? ?? '',
//         nguoiXuLyId: json['nguoiXuLyId'] as int?,
//         tenNguoiXuLy: json['tenNguoiXuLy'] as String?,
//         ngayXuLy: json['ngayXuLy'] != null
//             ? DateTime.tryParse(json['ngayXuLy'] as String)
//             : null,
//         loaiYeuCauId: json['loaiYeuCauId'] as int,
//         tenLoaiYeuCau: json['tenLoaiYeuCau'] as String? ?? '',
//         targetQuanHeCuTruId: json['targetQuanHeCuTruId'] as int?,
//         yeuCauTen: json['yeuCauTen'] as String?,
//         yeuCauHo: json['yeuCauHo'] as String?,
//         yeuCauNgaySinh: json['yeuCauNgaySinh'] != null
//             ? DateTime.tryParse(json['yeuCauNgaySinh'] as String)
//             : null,
//         yeuCauGioiTinhId: json['yeuCauGioiTinhId'] as int?,
//         yeuCauGioiTinhTen: json['yeuCauGioiTinhTen'] as String?,
//         yeuCauSoDienThoai: json['yeuCauSoDienThoai'] as String?,
//         yeuCauCCCD: json['yeuCauCCCD'] as String?,
//         yeuCauDiaChi: json['yeuCauDiaChi'] as String?,
//         yeuCauLoaiQuanHeId: json['yeuCauLoaiQuanHeId'] as int?,
//         yeuCauLoaiQuanHeTen: json['yeuCauLoaiQuanHeTen'] as String?,
//         noiDung: json['noiDung'] as String?,
//         lyDo: json['lyDo'] as String?,
//         trangThaiId: json['trangThaiId'] as int,
//         tenTrangThai: json['tenTrangThai'] as String? ?? '',
//         documents:
//             (json['documents'] as List<dynamic>?)
//                 ?.map(
//                   (e) => ResidenceDocument.fromJson(e as Map<String, dynamic>),
//                 )
//                 .toList() ??
//             [],
//       );

//   ResidenceRequestDetail copyWith({int? trangThaiId, String? tenTrangThai}) =>
//       ResidenceRequestDetail(
//         id: id,
//         createdBy: createdBy,
//         tenNguoiGui: tenNguoiGui,
//         createdAt: createdAt,
//         canHoId: canHoId,
//         tenCanHo: tenCanHo,
//         tenTang: tenTang,
//         tenToaNha: tenToaNha,
//         nguoiXuLyId: nguoiXuLyId,
//         tenNguoiXuLy: tenNguoiXuLy,
//         ngayXuLy: ngayXuLy,
//         loaiYeuCauId: loaiYeuCauId,
//         tenLoaiYeuCau: tenLoaiYeuCau,
//         targetQuanHeCuTruId: targetQuanHeCuTruId,
//         yeuCauTen: yeuCauTen,
//         yeuCauHo: yeuCauHo,
//         yeuCauNgaySinh: yeuCauNgaySinh,
//         yeuCauGioiTinhId: yeuCauGioiTinhId,
//         yeuCauGioiTinhTen: yeuCauGioiTinhTen,
//         yeuCauSoDienThoai: yeuCauSoDienThoai,
//         yeuCauCCCD: yeuCauCCCD,
//         yeuCauDiaChi: yeuCauDiaChi,
//         yeuCauLoaiQuanHeId: yeuCauLoaiQuanHeId,
//         yeuCauLoaiQuanHeTen: yeuCauLoaiQuanHeTen,
//         noiDung: noiDung,
//         lyDo: lyDo,
//         trangThaiId: trangThaiId ?? this.trangThaiId,
//         tenTrangThai: tenTrangThai ?? this.tenTrangThai,
//         documents: documents,
//       );

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'trangThaiId': trangThaiId,
//     'tenTrangThai': tenTrangThai,
//   };
// }

// class PagingInfo {
//   final int pageSize;
//   final int pageNumber;
//   final int totalItems;

//   const PagingInfo({
//     required this.pageSize,
//     required this.pageNumber,
//     required this.totalItems,
//   });

//   factory PagingInfo.fromJson(Map<String, dynamic> json) => PagingInfo(
//     pageSize: json['pageSize'] as int,
//     pageNumber: json['pageNumber'] as int,
//     totalItems: json['totalItems'] as int,
//   );
// }

// class ResidenceRequestListResult {
//   final List<ResidenceRequestItem> items;
//   final PagingInfo pagingInfo;

//   const ResidenceRequestListResult({
//     required this.items,
//     required this.pagingInfo,
//   });

//   factory ResidenceRequestListResult.fromJson(
//     Map<String, dynamic> json,
//   ) => ResidenceRequestListResult(
//     items: (json['items'] as List<dynamic>)
//         .map((e) => ResidenceRequestItem.fromJson(e as Map<String, dynamic>))
//         .toList(),
//     pagingInfo: PagingInfo.fromJson(json['pagingInfo'] as Map<String, dynamic>),
//   );
// }
