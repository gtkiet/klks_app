// lib/features/phuong_tien/widgets/phuong_tien_list_tab.dart
//
// Tab 1 (mode Phương tiện):
//   - Tự động gọi PhuongTienService.getListPhuongTien(canHoId) khi mount
//   - Hỗ trợ load more (phân trang) + pull-to-refresh
//   - Tap vào item → mở PhuongTienDetailScreen (gọi getPhuongTienById)

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';

import '../services/phuong_tien_service.dart';

import '../../cu_tru/models/quan_he_cu_tru_model.dart';

import '../models/phuong_tien_model.dart';
import '../models/phuong_tien_request_models.dart';

import '../screens/phuong_tien_detail_screen.dart';

class PhuongTienListTab extends StatefulWidget {
  final QuanHeCuTruModel item;

  const PhuongTienListTab({super.key, required this.item});

  @override
  State<PhuongTienListTab> createState() => _PhuongTienListTabState();
}

class _PhuongTienListTabState extends State<PhuongTienListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _service = PhuongTienService.instance;
  final _scrollController = ScrollController();

  // ── State ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isLoadingMore = false;
  AppException? _error;
  List<PhuongTien> _list = [];
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
    if (atBottom && _hasMore && !_isLoadingMore) {
      _loadMore();
    }
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
      final result = await _service.getListPhuongTien(
        GetListPhuongTienRequest(
          pageNumber: 1,
          pageSize: _pageSize,
          canHoId: widget.item.canHoId, // lọc theo căn hộ
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
      final result = await _service.getListPhuongTien(
        GetListPhuongTienRequest(
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
      // Load more thất bại: snackbar, không xóa data cũ
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────
  void _goToDetail(PhuongTien pt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhuongTienDetailScreen(
          phuongTienId: pt.id,
          // Truyền snapshot để hiển thị ngay trong khi chờ API chi tiết
          snapshot: pt,
        ),
      ),
    );
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
      return const Center(child: Text('Chưa có phương tiện nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _list.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          // Load more indicator ở cuối
          if (i == _list.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _PhuongTienTile(
            pt: _list[i],
            onTap: () => _goToDetail(_list[i]),
          );
        },
      ),
    );
  }
}

// ── List tile ─────────────────────────────────────────────────────────────
class _PhuongTienTile extends StatelessWidget {
  final PhuongTien pt;
  final VoidCallback onTap;

  const _PhuongTienTile({required this.pt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAnh = pt.hinhAnhPhuongTiens.isNotEmpty;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: hasAnh
            ? NetworkImage(pt.hinhAnhPhuongTiens.first.fileUrl)
            : null,
        child: !hasAnh ? Icon(_loaiIcon(pt.loaiPhuongTienId), size: 20) : null,
      ),
      title: Text(
        pt.bienSo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${pt.tenLoaiPhuongTien} • ${pt.tenPhuongTien}'),
          Text(
            'Màu: ${pt.mauXe}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _TrangThaiChip(
            label: pt.tenTrangThaiPhuongTien,
            trangThaiId: pt.trangThaiPhuongTienId,
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }

  IconData _loaiIcon(int loaiId) => switch (loaiId) {
    1 => Icons.two_wheeler, // Xe máy
    2 => Icons.directions_car, // Ô tô
    3 => Icons.pedal_bike, // Xe đạp
    _ => Icons.commute,
  };
}

// ── Trạng thái chip nhỏ ───────────────────────────────────────────────────
class _TrangThaiChip extends StatelessWidget {
  final String label;
  final int trangThaiId;

  const _TrangThaiChip({required this.label, required this.trangThaiId});

  @override
  Widget build(BuildContext context) {
    final (bg, text) = switch (trangThaiId) {
      1 => (Colors.green.shade50, Colors.green.shade800), // Đang hoạt động
      2 => (Colors.grey.shade100, Colors.grey.shade700), // Ngừng hoạt động
      _ => (Colors.orange.shade50, Colors.orange.shade800), // Khác
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
