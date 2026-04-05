// lib/features/phuong_tien/screens/danh_sach_phuong_tien_screen.dart

import 'package:flutter/material.dart';
import '../models/phuong_tien_models.dart';
import '../services/phuong_tien_service.dart';
import 'chi_tiet_phuong_tien_screen.dart';
import 'tao_yeu_cau_screen.dart';

class DanhSachPhuongTienScreen extends StatefulWidget {
  const DanhSachPhuongTienScreen({super.key});

  @override
  State<DanhSachPhuongTienScreen> createState() =>
      _DanhSachPhuongTienScreenState();
}

class _DanhSachPhuongTienScreenState extends State<DanhSachPhuongTienScreen> {
  final _service = PhuongTienService();

  List<PhuongTien> _items = [];
  List<SelectorItem> _loaiPhuongTiens = [];
  List<SelectorItem> _trangThais = [];
  PagingInfo? _pagingInfo;

  bool _isLoading = false;
  String? _errorMessage;

  // Filter state
  final _keywordCtrl = TextEditingController();
  int? _selectedLoaiId;
  int? _selectedTrangThaiId;
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
    _loadData();
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogs() async {
    try {
      final results = await Future.wait([
        _service.getLoaiPhuongTien(),
        _service.getTrangThaiPhuongTien(),
      ]);
      if (mounted) {
        setState(() {
          // _loaiPhuongTiens = results[0] as List<SelectorItem>;
          _loaiPhuongTiens = results[0];
          // _trangThais = results[1] as List<SelectorItem>;
          _trangThais = results[1];
        });
      }
    } on AppException catch (e) {
      // Catalog lỗi không chặn main flow
      debugPrint('Catalog error: $e');
    }
  }

  Future<void> _loadData({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = GetListPhuongTienRequest(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        keyword: _keywordCtrl.text.trim().isEmpty
            ? null
            : _keywordCtrl.text.trim(),
        loaiPhuongTienId: _selectedLoaiId,
        trangThaiPhuongTienId: _selectedTrangThaiId,
      );

      final result = await _service.getListPhuongTien(request);

      if (mounted) {
        setState(() {
          _items = result.items;
          _pagingInfo = result.pagingInfo;
          _isLoading = false;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  // void _showSnackBar(String message, {bool isError = false}) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: isError ? Colors.red : Colors.green,
  //     ),
  //   );
  // }

  void _onSearch() => _loadData(resetPage: true);

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách phương tiện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(resetPage: true),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const TaoYeuCauScreen()),
          );
          if (created == true) {
            _loadData(resetPage: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo yêu cầu'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
          if (_pagingInfo != null) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Keyword search
          TextField(
            controller: _keywordCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm theo tên xe, biển số, màu xe...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _keywordCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _keywordCtrl.clear();
                        _onSearch();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) => _onSearch(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Loại phương tiện
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Loại xe',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  initialValue: _selectedLoaiId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả')),
                    ..._loaiPhuongTiens.map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedLoaiId = val);
                    _onSearch();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Trạng thái
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  initialValue: _selectedTrangThaiId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả')),
                    ..._trangThais.map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedTrangThaiId = val);
                    _onSearch();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Không có phương tiện nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(resetPage: true),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) => _PhuongTienCard(
          item: _items[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChiTietPhuongTienScreen(phuongTienId: _items[index].id),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (_pagingInfo == null) return const SizedBox.shrink();
    final info = _pagingInfo!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: const Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng: ${info.totalItems} xe | Trang $_currentPage/${info.totalPages}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () => _onPageChanged(_currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
                iconSize: 20,
              ),
              IconButton(
                onPressed: info.hasNextPage
                    ? () => _onPageChanged(_currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card widget cho từng phương tiện
// ---------------------------------------------------------------------------

class _PhuongTienCard extends StatelessWidget {
  final PhuongTien item;
  final VoidCallback onTap;

  const _PhuongTienCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(
            item.loaiPhuongTienId == 1
                ? Icons.motorcycle
                : item.loaiPhuongTienId == 2
                ? Icons.directions_car
                : Icons.pedal_bike,
            color: Colors.blue,
          ),
        ),
        title: Text(
          item.tenPhuongTien,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Biển số: ${item.bienSo}  |  Màu: ${item.mauXe}'),
            Text(
              'Vị trí: ${item.viTriNgan}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _TrangThaiChip(ten: item.tenTrangThaiPhuongTien),
            const SizedBox(height: 4),
            Text(
              '${item.thePhuongTiens.length} thẻ',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _TrangThaiChip extends StatelessWidget {
  final String ten;
  const _TrangThaiChip({required this.ten});

  @override
  Widget build(BuildContext context) {
    final lowerTen = ten.toLowerCase();
    Color color;
    if (lowerTen.contains('hoạt động')) {
      color = Colors.green;
    } else if (lowerTen.contains('khóa') || lowerTen.contains('hủy')) {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(ten, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
