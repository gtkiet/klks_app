// lib/features/dich_vu/models/paging.dart

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
    pageSize: json['pageSize'] as int? ?? 10,
    pageNumber: json['pageNumber'] as int? ?? 1,
    totalItems: json['totalItems'] as int? ?? 0,
  );

  bool get hasNextPage => pageNumber * pageSize < totalItems;
}

class PagedResult<T> {
  final List<T> items;
  final PagingInfo pagingInfo;

  const PagedResult({required this.items, required this.pagingInfo});
}
