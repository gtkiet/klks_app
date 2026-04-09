// lib/features/thanh_vien/screens/tabs/tv_lich_su_yeu_cau_tab.dart

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';
import '../services/tv_yeu_cau_service.dart';
import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_request.dart';
import '../models/yeu_cau_cu_tru_model.dart';
import '../screens/yeu_cau_detail_screen.dart';
import '../screens/yeu_cau_edit_screen.dart';

// ── Trạng thái constants ───────────────────────────────────────────────────
const int _kTrangThaiNhap = 4; // "Đã lưu" — chưa submit
const int _kTrangThaiChoDuyet = 1; // "Đang chờ duyệt"
const Set<int> _kCoTheRut = {_kTrangThaiNhap, _kTrangThaiChoDuyet};

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

  bool _isLoading = false;
  bool _isLoadingMore = false;
  AppException? _error;
  List<YeuCauCuTruModel> _list = [];
  int _pageNumber = 1;
  static const int _pageSize = 10;
  bool _hasMore = true;

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

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 100 &&
        _hasMore &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

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
          canHoId: widget.item.canHoId,
          sortCol: 'createdAt',
          isAsc: false,
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

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _pageNumber + 1;
      final result = await _service.getYeuCauList(
        GetListYeuCauCuTruRequest(
          pageNumber: nextPage,
          pageSize: _pageSize,
          canHoId: widget.item.canHoId,
          sortCol: 'createdAt',
          isAsc: false,
        ),
      );
      setState(() {
        _list.addAll(result.items);
        _pageNumber = nextPage;
        _hasMore = result.items.length >= _pageSize;
      });
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _withdraw(YeuCauCuTruModel yeuCau) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận thu hồi'),
        content: const Text('Bạn có chắc muốn thu hồi yêu cầu này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _service.updateYeuCau(
        CapNhatYeuCauCuTruRequest(id: yeuCau.id, isWithdraw: true),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã thu hồi yêu cầu')));
      }
      await _loadData();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _onTapCard(YeuCauCuTruModel yeuCau) {
    if (yeuCau.trangThaiId == _kTrangThaiNhap) {
      _openEdit(yeuCau);
    } else {
      _openDetail(yeuCau);
    }
  }

  void _openDetail(YeuCauCuTruModel yeuCau) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YeuCauDetailScreen(yeuCauId: yeuCau.id),
      ),
    );
  }

  void _openEdit(YeuCauCuTruModel yeuCau) async {
    final shouldReload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => YeuCauEditScreen(yeuCauId: yeuCau.id)),
    );
    if (shouldReload == true) _loadData();
  }

  // void _openDetail(YeuCauCuTruModel yeuCau) {
  //   // TODO: Navigator.push → YeuCauDetailScreen(id: yeuCau.id)
  //   // dùng getYeuCauById để load chi tiết
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text('Chi tiết yêu cầu #${yeuCau.id}')));
  // }

  // void _openEdit(YeuCauCuTruModel yeuCau) {
  //   // TODO: Navigator.push → YeuCauEditScreen(yeuCau: yeuCau)
  //   // dùng updateYeuCau để lưu / submit
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text('Chỉnh sửa nháp #${yeuCau.id}')));
  // }

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
          final yeuCau = _list[i];
          return _YeuCauCard(
            yeuCau: yeuCau,
            onTap: () => _onTapCard(yeuCau),
            onWithdraw: _kCoTheRut.contains(yeuCau.trangThaiId)
                ? () => _withdraw(yeuCau)
                : null,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _YeuCauCard extends StatelessWidget {
  final YeuCauCuTruModel yeuCau;
  final VoidCallback onTap;
  final VoidCallback? onWithdraw;

  const _YeuCauCard({
    required this.yeuCau,
    required this.onTap,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final isNhap = yeuCau.trangThaiId == _kTrangThaiNhap;
    final (bgColor, textColor) = _trangThaiColor(yeuCau.trangThaiId);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon loại yêu cầu ──
              CircleAvatar(
                radius: 20,
                child: Icon(_loaiIcon(yeuCau.loaiYeuCauId), size: 18),
              ),
              const SizedBox(width: 12),

              // ── Nội dung ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề + chip trạng thái
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            yeuCau.tenLoaiYeuCau,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            // Nháp: hiển thị "Đã lưu (nháp)" cho rõ
                            isNhap
                                ? '${yeuCau.tenTrangThai} (nháp)'
                                : yeuCau.tenTrangThai,
                            style: TextStyle(fontSize: 11, color: textColor),
                          ),
                          backgroundColor: bgColor,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    if (yeuCau.hoTenDayDu != null)
                      _InfoRow(
                        icon: Icons.person_outline,
                        text: 'Đối tượng: ${yeuCau.hoTenDayDu}',
                      ),

                    _InfoRow(
                      icon: Icons.send_outlined,
                      text: 'Người gửi: ${yeuCau.tenNguoiGui}',
                    ),

                    if (yeuCau.createdAt != null)
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: 'Ngày tạo: ${_fmtDate(yeuCau.createdAt!)}',
                        muted: true,
                      ),

                    // ── Nút thu hồi ──
                    if (onWithdraw != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: onWithdraw,
                          icon: const Icon(Icons.undo, size: 16),
                          label: const Text('Thu hồi'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color bg, Color text) _trangThaiColor(int id) => switch (id) {
    _kTrangThaiNhap => (
      Colors.grey.shade100,
      Colors.grey.shade600,
    ), // Đã lưu / nháp
    1 => (Colors.orange.shade50, Colors.orange.shade800), // Chờ duyệt
    2 => (Colors.green.shade50, Colors.green.shade800), // Đã duyệt
    3 => (Colors.red.shade50, Colors.red.shade800), // Từ chối
    _ => (Colors.blue.shade50, Colors.blue.shade800),
  };

  IconData _loaiIcon(int id) => switch (id) {
    1 => Icons.person_add_outlined, // Thêm
    2 => Icons.edit_outlined, // Sửa
    3 => Icons.person_remove_outlined, // Xóa
    _ => Icons.description_outlined,
  };

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widget
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool muted;

  const _InfoRow({required this.icon, required this.text, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? Theme.of(context).colorScheme.outline
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: muted
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
