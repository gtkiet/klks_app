// lib/features/utils/models/paged_result.dart

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
    pageSize: json['pageSize'] as int? ?? 0,
    pageNumber: json['pageNumber'] as int? ?? 0,
    totalItems: json['totalItems'] as int? ?? 0,
  );

  int get totalPages => pageSize > 0 ? (totalItems / pageSize).ceil() : 0;
  bool get hasNextPage => pageNumber < totalPages;
  bool get isLastPage => !hasNextPage;
}

// PagedResult giữ cùng file với PagingInfo —
// hai class này không có ý nghĩa khi tách riêng.
class PagedResult<T> {
  final List<T> items;
  final PagingInfo pagingInfo;

  const PagedResult({required this.items, required this.pagingInfo});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) => PagedResult(
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList(),
    pagingInfo: PagingInfo.fromJson(
      json['pagingInfo'] as Map<String, dynamic>? ?? {},
    ),
  );
}
