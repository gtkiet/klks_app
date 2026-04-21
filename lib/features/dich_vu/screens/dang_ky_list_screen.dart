// lib/features/dich_vu/screens/dang_ky_list_screen.dart

import 'package:flutter/material.dart';

import '../models/paging.dart';
import '../models/selector_item.dart';
import '../models/dang_ky_model.dart';

import '../services/dich_vu_service.dart';
import '../widgets/common_widgets.dart';
import 'dang_ky_filter_screen.dart';

class DangKyListScreen extends StatefulWidget {
  const DangKyListScreen({super.key});

  @override
  State<DangKyListScreen> createState() => _DangKyListScreenState();
}

class _DangKyListScreenState extends State<DangKyListScreen> {
  final _service = DichVuService.instance;

  List<DichVuDangKyItem> _items = [];
  PagingInfo? _paging;
  bool _isLoading = false;
  String? _error;

  List<SelectorItem> _loaiDichVuList = [];

  DichVuDangKyRequest _request = DichVuDangKyRequest.tienIch();

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
    _loadData();
  }

  Future<void> _loadCatalogs() async {
    try {
      final list = await _service.getLoaiDichVu();
      if (!mounted) return;
      setState(() => _loaiDichVuList = list);
    } catch (_) {
      // Catalog lỗi không block UI chính
    }
  }

  Future<void> _loadData({bool reset = false}) async {
    if (reset) {
      _request = _request.copyWith(pageNumber: 1);
      _items = [];
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getDanhSachDangKy(_request);
      setState(() {
        _items = reset ? result.items : [..._items, ...result.items];
        _paging = result.pagingInfo;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onLoadMore() {
    if (_paging != null && _paging!.hasNextPage && !_isLoading) {
      _request = _request.copyWith(pageNumber: _request.pageNumber + 1);
      _loadData();
    }
  }

  void _openFilter() async {
    final newRequest = await Navigator.push<DichVuDangKyRequest>(
      context,
      MaterialPageRoute(
        builder: (_) => DangKyFilterScreen(
          currentRequest: _request,
          loaiDichVuList: _loaiDichVuList,
        ),
      ),
    );
    if (newRequest != null) {
      _request = newRequest;
      _loadData(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch Vụ Đã Đăng Ký'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Bộ lọc',
            onPressed: _openFilter,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_paging != null)
            PagingBanner(
              totalItems: _paging!.totalItems,
              pageNumber: _paging!.pageNumber,
              itemLabel: 'dịch vụ',
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return ErrorStateWidget(
        message: _error!,
        onRetry: () => _loadData(reset: true),
      );
    }
    if (_items.isEmpty) {
      return const EmptyStateWidget(message: 'Không có dịch vụ nào.');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          _onLoadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => _loadData(reset: true),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _items.length + (_paging?.hasNextPage == true ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            if (index == _items.length) return const LoadMoreIndicator();
            return _DangKyCard(item: _items[index]);
          },
        ),
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _DangKyCard extends StatelessWidget {
  final DichVuDangKyItem item;

  const _DangKyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.tenDichVu,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _TrangThaiChip(
                  label: item.trangThaiDangKyTen,
                  isActive: item.isActive,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.maDichVu}  •  ${item.loaiDichVuTen}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 15,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Số lượng: ${item.soLuong}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.date_range_outlined,
                  size: 15,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.thoiGianHienThi,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrangThaiChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _TrangThaiChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.isNotEmpty ? label : 'N/A',
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green.shade800 : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
