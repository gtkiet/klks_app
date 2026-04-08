// lib/features/cu_tru/screens/tabs/lich_su_yeu_cau_phuong_tien_tab.dart
//
// Tab 2 (mode Phương tiện): lịch sử yêu cầu liên quan PHƯƠNG TIỆN.
//   - Tự động gọi PTYeuCauService.getListYeuCau(canHoId) khi mount
//   - Hỗ trợ load more (phân trang) + pull-to-refresh
//   - Chi tiết yêu cầu: TODO

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';

import '../services/pt_yeu_cau_service.dart';

import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../models/yeu_cau_phuong_tien_model.dart';
import '../models/phuong_tien_request_models.dart';

class LichSuYeuCauPhuongTienTab extends StatefulWidget {
  final QuanHeCuTruModel item;

  const LichSuYeuCauPhuongTienTab({super.key, required this.item});

  @override
  State<LichSuYeuCauPhuongTienTab> createState() =>
      _LichSuYeuCauPhuongTienTabState();
}

class _LichSuYeuCauPhuongTienTabState extends State<LichSuYeuCauPhuongTienTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _service = PTYeuCauService.instance;
  final _scrollController = ScrollController();

  // ── State ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isLoadingMore = false;
  AppException? _error;
  List<YeuCauPhuongTien> _list = [];
  int _pageNumber = 1;
  static const int _pageSize = 10;
  bool _hasMore = true;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll listener ────────────────────────────────────────────────────
  void _onScroll() {
    final atBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;
    if (atBottom && _hasMore && !_isLoadingMore) _loadMore();
  }

  // ── Service call: trang đầu ────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pageNumber = 1;
      _hasMore = true;
    });

    try {
      final result = await _service.getListYeuCau(
        GetListYeuCauPhuongTienRequest(
          pageNumber: 1,
          pageSize: _pageSize,
          canHoId: widget.item.canHoId,
        ),
      );
      setState(() {
        _list = result.items;
        _hasMore = !result.pagingInfo.isLastPage;
      });
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Service call: load thêm trang ──────────────────────────────────────
  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _pageNumber + 1;
      final result = await _service.getListYeuCau(
        GetListYeuCauPhuongTienRequest(
          pageNumber: nextPage,
          pageSize: _pageSize,
          canHoId: widget.item.canHoId,
        ),
      );
      setState(() {
        _list.addAll(result.items);
        _pageNumber = nextPage;
        _hasMore = !result.pagingInfo.isLastPage;
      });
    } on AppException catch (e) {
      // Load more thất bại: snackbar, giữ nguyên data cũ
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(error: _error!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_list.isEmpty) {
      return const Center(child: Text('Chưa có lịch sử yêu cầu phương tiện'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _list.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == _list.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _YeuCauCard(yeuCau: _list[i]);
        },
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────
class _YeuCauCard extends StatelessWidget {
  final YeuCauPhuongTien yeuCau;

  const _YeuCauCard({required this.yeuCau});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, textColor) = _trangThaiColor(yeuCau.trangThaiId);

    // Dòng tóm tắt xe: loại + biển số + màu
    final xeInfo = [
      if (yeuCau.tenYeuCauLoaiPhuongTien != null)
        yeuCau.tenYeuCauLoaiPhuongTien!,
      if (yeuCau.yeuCauBienSo != null) yeuCau.yeuCauBienSo!,
      if (yeuCau.yeuCauMauXe != null) yeuCau.yeuCauMauXe!,
    ].join(' • ');

    return Card(
      child: ListTile(
        // TODO: onTap → navigate to YeuCauPhuongTienDetailScreen(yeuCau.id)
        leading: CircleAvatar(
          radius: 20,
          // Dùng ảnh đầu tiên nếu có, fallback icon loại yêu cầu
          backgroundImage: yeuCau.yeuCauHinhAnhPhuongTiens.isNotEmpty
              ? NetworkImage(yeuCau.yeuCauHinhAnhPhuongTiens.first.fileUrl)
              : null,
          child: yeuCau.yeuCauHinhAnhPhuongTiens.isEmpty
              ? Icon(_loaiIcon(yeuCau.loaiYeuCauId), size: 18)
              : null,
        ),
        title: Text(yeuCau.tenLoaiYeuCau),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin xe yêu cầu
            if (xeInfo.isNotEmpty)
              Text(xeInfo, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('Người gửi: ${yeuCau.tenNguoiGui}'),
            if (yeuCau.createdAt != null)
              Text(
                'Ngày tạo: ${_fmtDate(yeuCau.createdAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            // Lý do từ chối
            if (yeuCau.lyDo != null && yeuCau.lyDo!.isNotEmpty)
              Text(
                'Lý do: ${yeuCau.lyDo}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Chip(
          label: Text(
            yeuCau.tenTrangThai,
            style: TextStyle(fontSize: 11, color: textColor),
          ),
          backgroundColor: bg,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  // Điều chỉnh trangThaiId theo enum backend
  (Color bg, Color text) _trangThaiColor(int id) => switch (id) {
    2 => (Colors.green.shade50, Colors.green.shade800), // Đã duyệt
    3 => (Colors.red.shade50, Colors.red.shade800), // Từ chối
    4 => (Colors.grey.shade100, Colors.grey.shade700), // Đã rút
    _ => (Colors.orange.shade50, Colors.orange.shade800), // Chờ duyệt
  };

  // Điều chỉnh loaiYeuCauId theo enum backend
  IconData _loaiIcon(int id) => switch (id) {
    1 => Icons.add_road, // Đăng ký xe mới
    2 => Icons.no_crash, // Hủy đăng ký
    3 => Icons.edit_road, // Cập nhật thông tin
    _ => Icons.description_outlined,
  };

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
