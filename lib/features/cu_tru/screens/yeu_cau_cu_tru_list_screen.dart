// lib/features/cu_tru/screens/yeu_cau_cu_tru_list_screen.dart
//
// Screen 3: Danh sách yêu cầu cư trú (có phân trang).
// Floating button để tạo yêu cầu mới → TaoYeuCauScreen.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import 'tao_yeu_cau_screen.dart';
import 'chi_tiet_yeu_cau_screen.dart';

class YeuCauCuTruListScreen extends StatefulWidget {
  const YeuCauCuTruListScreen({super.key});

  @override
  State<YeuCauCuTruListScreen> createState() => _YeuCauCuTruListScreenState();
}

class _YeuCauCuTruListScreenState extends State<YeuCauCuTruListScreen> {
  final _service = CuTruService();
  final _scrollController = ScrollController();

  List<YeuCauCuTruModel> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _pageNumber = 1;
  static const int _pageSize = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadData(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadData({bool reset = false}) async {
    if (reset) {
      setState(() {
        _pageNumber = 1;
        _hasMore = true;
        _errorMessage = null;
        _isLoading = true;
      });
    }

    try {
      final result = await _service.getYeuCauList(
        pageNumber: _pageNumber,
        pageSize: _pageSize,
      );

      setState(() {
        if (reset) {
          _items = result.items;
        } else {
          _items.addAll(result.items);
        }
        _hasMore = result.items.length >= _pageSize;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoadingMore = true;
      _pageNumber++;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu cư trú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () => _loadData(reset: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToTaoYeuCau,
        icon: const Icon(Icons.add),
        label: const Text('Tạo yêu cầu'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadData(reset: true),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có yêu cầu nào.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _YeuCauCard(
            item: _items[i],
            onTap: () => _navigateToChiTiet(_items[i].id),
          );
        },
      ),
    );
  }

  void _navigateToTaoYeuCau() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TaoYeuCauScreen()),
    );
    if (created == true) _loadData(reset: true);
  }

  void _navigateToChiTiet(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChiTietYeuCauScreen(requestId: id)),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _YeuCauCard extends StatelessWidget {
  final YeuCauCuTruModel item;
  final VoidCallback onTap;

  const _YeuCauCard({required this.item, required this.onTap});

  Color _statusColor(int trangThaiId) {
    switch (trangThaiId) {
      case 1:
        return Colors.orange; // Chờ duyệt
      case 2:
        return Colors.green; // Đã duyệt
      case 3:
        return Colors.red; // Từ chối
      default:
        return Colors.blue; // Đã lưu / khác
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngay = item.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt!)
        : '---';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text(
          '${item.tenLoaiYeuCau} - ${item.tenCanHo}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.tenToaNha} · ${item.tenTang}'),
            Text(
              'Người gửi: ${item.tenNguoiGui} · $ngay',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(item.trangThaiId).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor(item.trangThaiId)),
              ),
              child: Text(
                item.tenTrangThai,
                style: TextStyle(
                  fontSize: 11,
                  color: _statusColor(item.trangThaiId),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
