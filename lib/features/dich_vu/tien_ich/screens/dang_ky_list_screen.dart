// lib/features/dich_vu/tien_ich/screens/dang_ky_list_screen.dart

import 'package:flutter/material.dart';

import '../models/dich_vu_model.dart';
import '../services/dich_vu_service.dart';
import 'dang_ky_filter_screen.dart';

import 'package:klks_app/design/design.dart';

class DangKyListScreen extends StatefulWidget {
  const DangKyListScreen({super.key});

  @override
  State<DangKyListScreen> createState() => _DangKyListScreenState();
}

class _DangKyListScreenState extends State<DangKyListScreen> {
  final _service = DichVuService.instance;

  List<DichVuDangKyItem> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  bool _hasMore = true;

  DichVuDangKyRequest _request = DichVuDangKyRequest.tienIch();

  @override
  void initState() {
    super.initState();
    _loadData(reset: true);
  }

  Future<void> _loadData({bool reset = false}) async {
    if (reset) {
      _request = _request.copyWith(pageNumber: 1);
      _hasMore = true;
    }

    setState(() {
      if (reset) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final result = await _service.getDanhSachDangKy(_request);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items = result.items;
        } else {
          _items.addAll(result.items);
        }
        _hasMore = result.pagingInfo.hasNextPage;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      }
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoading && !_isLoadingMore) {
      _request = _request.copyWith(pageNumber: _request.pageNumber + 1);
      _loadData();
    }
  }

  Future<void> _openFilter() async {
    final newRequest = await Navigator.push<DichVuDangKyRequest>(
      context,
      MaterialPageRoute(
        builder: (_) => DangKyFilterScreen(currentRequest: _request),
      ),
    );
    if (newRequest != null && mounted) {
      setState(() => _request = newRequest);
      _loadData(reset: true);
    }
  }

  bool get _hasActiveFilter =>
      _request.loaiDichVuId != null ||
      _request.trangThaiDangKyId != null ||
      _request.tuNgay != null ||
      _request.denNgay != null;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppTopBar(
        title: 'Dịch vụ đã đăng ký',
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Bộ lọc',
                onPressed: _openFilter,
              ),
              if (_hasActiveFilter)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () => _loadData(reset: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null && _items.isEmpty) {
      return ErrorDisplay(
        error: _error,
        onRetry: () => _loadData(reset: true),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 56, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.sm),
            Text('Chưa có dịch vụ đăng ký nào',
                style: AppTypography.body.secondary),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => _loadData(reset: true),
        color: AppColors.primary,
        child: ListView.separated(
          padding: AppSpacing.insetAll16,
          itemCount: _items.length + (_isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            if (i == _items.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            return _DangKyCard(item: _items[i]);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _DangKyCard extends StatelessWidget {
  final DichVuDangKyItem item;
  const _DangKyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(item.tenDichVu, style: AppTypography.subhead),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppStatusBadge(
                label: item.trangThaiDangKyTen.isNotEmpty
                    ? item.trangThaiDangKyTen
                    : 'N/A',
                variant: _trangThaiVariant(item.trangThaiDangKyId),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.maDichVu}  •  ${item.loaiDichVuTen}',
            style: AppTypography.captionSmall.secondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Số lượng: ${item.soLuong}', style: AppTypography.caption),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.date_range_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.thoiGianHienThi,
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBadgeVariant _trangThaiVariant(int id) => switch (id) {
    2 => AppBadgeVariant.success,  // Đang sử dụng
    4 => AppBadgeVariant.error,    // Đã hủy
    3 => AppBadgeVariant.info,     // Tạm ngưng
    _ => AppBadgeVariant.warning,  // Chờ duyệt
  };
}