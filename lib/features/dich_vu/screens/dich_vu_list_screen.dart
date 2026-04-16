// lib/features/dich_vu/screens/dich_vu_list_screen.dart

import 'package:flutter/material.dart';
import '../models/dich_vu_model.dart';
import '../models/selector_item.dart';
import '../services/dich_vu_service.dart';
import 'dich_vu_detail_screen.dart';
import 'dang_ky_dich_vu_screen.dart';

class DichVuListScreen extends StatefulWidget {
  const DichVuListScreen({super.key});

  @override
  State<DichVuListScreen> createState() => _DichVuListScreenState();
}

class _DichVuListScreenState extends State<DichVuListScreen> {
  final _service = DichVuService();
  final _searchCtrl = TextEditingController();

  List<DichVuItem> _items = [];
  List<SelectorItem> _loaiDichVuList = [];
  List<SelectorItem> _trangThaiList = [];

  PagingInfo? _paging;
  bool _isLoading = false;
  String? _error;

  // Filter state
  int? _selectedLoaiDichVuId;
  int? _selectedTrangThaiId;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Load catalog cho dropdown ─────────────────────────────────────────────

  Future<void> _loadCatalogs() async {
    try {
      final results = await Future.wait([
        _service.getLoaiDichVu(),
        _service.getTrangThaiDichVu(),
      ]);
      if (!mounted) return;
      setState(() {
        _loaiDichVuList = results[0];
        _trangThaiList = results[1];
      });
    } catch (_) {
      // Catalog load lỗi thì bỏ qua, không block UI chính
    }
  }

  // ── Load danh sách dịch vụ ────────────────────────────────────────────────

  Future<void> _loadData({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _items = [];
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getDichVuList(
        loaiDichVuId: _selectedLoaiDichVuId,
        trangThaiDichVuId: _selectedTrangThaiId,
        keyword: _searchCtrl.text.trim(),
        pageNumber: _page,
      );

      setState(() {
        if (reset) {
          _items = result.items;
        } else {
          _items = [..._items, ...result.items];
        }
        _paging = result.pagingInfo;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() => _loadData(reset: true);

  void _onLoadMore() {
    if (_paging != null && _paging!.hasNextPage && !_isLoading) {
      _page++;
      _loadData();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Dịch Vụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Tìm theo mã hoặc tên dịch vụ...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => _onSearch(),
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 8),
          // Dropdowns
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  hint: 'Loại dịch vụ',
                  value: _selectedLoaiDichVuId,
                  items: _loaiDichVuList,
                  onChanged: (val) {
                    setState(() => _selectedLoaiDichVuId = val);
                    _loadData(reset: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  hint: 'Trạng thái',
                  value: _selectedTrangThaiId,
                  items: _trangThaiList,
                  onChanged: (val) {
                    setState(() => _selectedTrangThaiId = val);
                    _loadData(reset: true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required int? value,
    required List<SelectorItem> items,
    required void Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: Text(hint, style: const TextStyle(fontSize: 13)),
      items: [
        DropdownMenuItem<int>(
          value: null,
          child: Text('Tất cả - $hint', style: const TextStyle(fontSize: 13)),
        ),
        ...items.map(
          (e) => DropdownMenuItem<int>(
            value: e.id,
            child: Text(e.name, style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadData(reset: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(child: Text('Không có dịch vụ nào.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          _onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length + (_paging?.hasNextPage == true ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildDichVuCard(_items[index]);
        },
      ),
    );
  }

  Widget _buildDichVuCard(DichVuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: item.isHoatDong
              ? Colors.green.shade100
              : Colors.orange.shade100,
          child: Icon(
            Icons.miscellaneous_services,
            color: item.isHoatDong ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          item.tenDichVu,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã: ${item.maDichVu} • ${item.loaiDichVuTen}'),
            Row(
              children: [
                Chip(
                  label: Text(
                    item.trangThaiDichVuTen,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: item.isHoatDong
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                if (item.isBatBuoc) ...[
                  const SizedBox(width: 6),
                  const Chip(
                    label: Text('Bắt buộc', style: TextStyle(fontSize: 11)),
                    backgroundColor: Color(0xFFE3F2FD),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Chi tiết',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DichVuDetailScreen(dichVuId: item.id),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.app_registration),
              tooltip: 'Đăng ký',
              color: Colors.blue,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DangKyDichVuScreen(
                    dichVuId: item.id,
                    tenDichVu: item.tenDichVu,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
