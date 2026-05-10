// lib/features/phan_anh/screens/phan_anh_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/phan_anh_model.dart';
import '../services/phan_anh_service.dart';

import 'phan_anh_detail_screen.dart';
import 'phan_anh_create_screen.dart';

/// Màu badge theo mã trạng thái (tham chiếu bảng Status Catalog)
Color _statusColor(int id) {
  switch (id) {
    case 1:
      return const Color(0xFFE2E8F0);
    case 2:
      return const Color(0xFF3182CE);
    case 3:
      return const Color(0xFFED8936);
    case 4:
      return const Color(0xFFECC94B);
    case 5:
      return const Color(0xFF805AD5);
    case 6:
      return const Color(0xFF38A169);
    case 7:
      return const Color(0xFFE53E3E);
    case 8:
      return const Color(0xFFCBD5E0);
    case 9:
      return const Color(0xFFA0AEC0);
    default:
      return Colors.grey;
  }
}

Color _statusTextColor(int id) =>
    (id == 1 || id == 8 || id == 9) ? Colors.black87 : Colors.white;

// ─── Status filter data ──────────────────────────────────────────────────────

const _kStatuses = <(int?, String)>[
  (null, 'Tất cả'),
  (1, 'Chờ tiếp nhận'),
  (2, 'Đang xử lý'),
  (3, 'BQL đã phản hồi'),
  (4, 'Cư dân đã phản hồi'),
  (5, 'Chờ đánh giá'),
  (6, 'Đã hoàn thành'),
  (7, 'Đã hủy'),
  (8, 'Nháp'),
  (9, 'Đã thu hồi'),
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class PhanAnhListScreen extends StatefulWidget {
  const PhanAnhListScreen({super.key});

  @override
  State<PhanAnhListScreen> createState() => _PhanAnhListScreenState();
}

class _PhanAnhListScreenState extends State<PhanAnhListScreen> {
  final _service = PhanAnhService.instance;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<PhanAnhResponse> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMsg;
  int _page = 1;
  bool _hasMore = true;
  int? _filterStatus;
  bool _hasSearchText = false;

  static const _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _scrollCtrl.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final has = _searchCtrl.text.isNotEmpty;
    if (has != _hasSearchText) setState(() => _hasSearchText = has);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _items = [];
        _isLoading = true;
        _errorMsg = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final keyword = _searchCtrl.text.trim();
      final result = await _service.getList(
        keyword: keyword.isEmpty ? null : keyword,
        trangThaiPhanAnhId: _filterStatus,
        pageNumber: _page,
        pageSize: _pageSize,
      );

      setState(() {
        _items.addAll(result.items);
        _hasMore = _items.length < result.pagingInfo.totalItems;
        _page++;
      });
    } catch (e) {
      setState(() => _errorMsg = 'Đã xảy ra lỗi khi tải danh sách phản ánh.');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  // ── Filter bottom sheet ──────────────────────────────────────────────────

  void _showFilterSheet() {
    int? localSelected = _filterStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void apply(int? value) {
              setSheetState(() {
                localSelected = value;
              });

              setState(() {
                _filterStatus = value;
              });

              Navigator.pop(sheetCtx);

              _load(reset: true);
            }

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Lọc theo trạng thái',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    RadioGroup<int?>(
                      groupValue: localSelected,
                      onChanged: apply,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _kStatuses.length,
                        itemBuilder: (_, i) {
                          final (value, label) = _kStatuses[i];

                          return InkWell(
                            onTap: () => apply(value),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Radio<int?>(value: value),

                                  const SizedBox(width: 4),

                                  Expanded(child: Text(label)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  String? get _activeStatusLabel => _filterStatus != null
      ? _kStatuses
            .firstWhere(
              (s) => s.$1 == _filterStatus,
              orElse: () => (_filterStatus, 'ID $_filterStatus'),
            )
            .$2
      : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phản ánh khiếu nại'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _filterStatus != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Lọc trạng thái',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PhanAnhCreateScreen()),
          );
          if (created == true && mounted) _load(reset: true);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo mới'),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tiêu đề...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _hasSearchText
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load(reset: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _load(reset: true),
            ),
          ),

          // ── Active filter chip ──────────────────────────────────────
          if (_activeStatusLabel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Chip(
                  avatar: const Icon(Icons.filter_alt, size: 16),
                  label: Text(
                    _activeStatusLabel!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onDeleted: () {
                    setState(() => _filterStatus = null);
                    _load(reset: true);
                  },
                ),
              ),
            ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_errorMsg!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _load(reset: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Không có phản ánh nào.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
        // FIX: đặt tên tham số rõ ràng, không dùng wildcard _ bị lỗi trùng
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          if (i == _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final item = _items[i];
          return _PhanAnhCard(
            item: item,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhanAnhDetailScreen(phanAnhId: item.id),
                ),
              );
              if (mounted) _load(reset: true);
            },
          );
        },
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _PhanAnhCard extends StatelessWidget {
  final PhanAnhResponse item;
  final VoidCallback onTap;

  const _PhanAnhCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.tieuDe,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    id: item.trangThaiPhanAnhId,
                    label: item.trangThaiPhanAnhTen,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _MetaRow(icon: Icons.home_outlined, text: item.tenCanHo),
              _MetaRow(
                icon: Icons.category_outlined,
                text: item.loaiPhanAnhTen,
              ),
              _MetaRow(icon: Icons.person_outline, text: item.tenNguoiGui),
              if (item.tenNguoiXuLy != null)
                _MetaRow(
                  icon: Icons.engineering_outlined,
                  text: item.tenNguoiXuLy!,
                ),
              _MetaRow(
                icon: Icons.access_time,
                text: fmt.format(item.createdAt.toLocal()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int id;
  final String label;

  const _StatusBadge({required this.id, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor(id),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _statusTextColor(id),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
