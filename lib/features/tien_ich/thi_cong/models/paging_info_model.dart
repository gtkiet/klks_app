// lib/features/tien_ich/thi_cong/models/paging_info_model.dart

class PagingInfoModel {
  final int pageSize;
  final int pageNumber;
  final int totalItems;

  const PagingInfoModel({
    required this.pageSize,
    required this.pageNumber,
    required this.totalItems,
  });

  factory PagingInfoModel.fromJson(Map<String, dynamic> json) =>
      PagingInfoModel(
        pageSize: json['pageSize'] as int? ?? 0,
        pageNumber: json['pageNumber'] as int? ?? 0,
        totalItems: json['totalItems'] as int? ?? 0,
      );

  bool get hasMore => pageNumber * pageSize < totalItems;
}
