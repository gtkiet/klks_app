// lib/features/cu_tru/screens/tabs/lich_su_yeu_cau_thanh_vien_tab.dart
//
// Tab 2 (mode Thành viên): lịch sử yêu cầu cư trú liên quan THÀNH VIÊN.
//   - Gọi YeuCauCuTruService.getYeuCauList với canHoId
//   - Hỗ trợ load more (phân trang) + pull-to-refresh
//   - Chi tiết yêu cầu: tạm thời bỏ qua (TODO)

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';

import '../services/tv_yeu_cau_service.dart';

import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';
import '../models/yeu_cau_cu_tru_model.dart';

class LichSuYeuCauThanhVienTab extends StatefulWidget {
  final QuanHeCuTruModel item;

  const LichSuYeuCauThanhVienTab({super.key, required this.item});

  @override
  State<LichSuYeuCauThanhVienTab> createState() =>
      _LichSuYeuCauThanhVienTabState();
}

class _LichSuYeuCauThanhVienTabState extends State<LichSuYeuCauThanhVienTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _service = YeuCauCuTruService.instance;
  final _scrollController = ScrollController();

  // ── State ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isLoadingMore = false;
  AppException? _error;
  List<YeuCauCuTruModel> _list = [];
  int _pageNumber = 1;
  static const int _pageSize = 10;
  bool _hasMore = true;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadData();
    // Lắng nghe scroll để load more khi gần cuối
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
    if (atBottom && _hasMore && !_isLoadingMore) {
      _loadMore();
    }
  }

  // ── Service call: tải trang đầu ────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pageNumber = 1;
      _hasMore = true;
    });

    try {
      final result = await _service.getYeuCauList(
        GetListYeuCauCuTruRequest(
          pageNumber: 1,
          pageSize: _pageSize,
          canHoId: widget.item.canHoId, // lọc theo căn hộ
        ),
      );
      setState(() {
        _list = result.items;
        _hasMore = result.items.length >= _pageSize;
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
      final result = await _service.getYeuCauList(
        GetListYeuCauCuTruRequest(
          pageNumber: nextPage,
          pageSize: _pageSize,
          canHoId: widget.item.canHoId,
        ),
      );
      setState(() {
        _list.addAll(result.items);
        _pageNumber = nextPage;
        _hasMore = result.items.length >= _pageSize;
      });
    } on AppException catch (e) {
      // Load more thất bại: hiển thị snackbar, không xóa data cũ
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
      return const Center(child: Text('Chưa có lịch sử yêu cầu thành viên'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        // +1 item nếu đang load more (indicator ở cuối)
        itemCount: _list.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          // Load more indicator
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

// ── Card yêu cầu ──────────────────────────────────────────────────────────
class _YeuCauCard extends StatelessWidget {
  final YeuCauCuTruModel yeuCau;

  const _YeuCauCard({required this.yeuCau});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _trangThaiColor(yeuCau.trangThaiId);

    return Card(
      child: ListTile(
        // TODO: onTap → navigate to YeuCauDetailScreen(yeuCau.id)
        leading: CircleAvatar(
          radius: 20,
          child: Icon(_loaiIcon(yeuCau.loaiYeuCauId), size: 18),
        ),
        title: Text(yeuCau.tenLoaiYeuCau),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên người được yêu cầu (nếu là thêm/xóa thành viên)
            if (yeuCau.hoTenDayDu != null)
              Text('Đối tượng: ${yeuCau.hoTenDayDu}'),
            Text('Người gửi: ${yeuCau.tenNguoiGui}'),
            if (yeuCau.createdAt != null)
              Text(
                'Ngày tạo: ${_fmtDate(yeuCau.createdAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Chip(
          label: Text(
            yeuCau.tenTrangThai,
            style: TextStyle(fontSize: 11, color: textColor),
          ),
          backgroundColor: bgColor,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  // Màu chip theo trangThaiId — điều chỉnh theo enum thực tế của dự án
  (Color bg, Color text) _trangThaiColor(int id) => switch (id) {
    2 => (Colors.green.shade50, Colors.green.shade800), // Đã duyệt
    3 => (Colors.red.shade50, Colors.red.shade800), // Từ chối
    4 => (Colors.grey.shade100, Colors.grey.shade700), // Đã rút
    _ => (Colors.orange.shade50, Colors.orange.shade800), // Chờ duyệt
  };

  // Icon theo loại yêu cầu — điều chỉnh theo loaiYeuCauId thực tế
  IconData _loaiIcon(int id) => switch (id) {
    1 => Icons.person_add_outlined, // Thêm thành viên
    2 => Icons.person_remove_outlined, // Xóa thành viên
    3 => Icons.edit_outlined, // Cập nhật
    _ => Icons.description_outlined,
  };

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
