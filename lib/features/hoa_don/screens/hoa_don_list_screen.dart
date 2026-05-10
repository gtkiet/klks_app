// lib/features/hoa_don/screens/hoa_don_list_screen.dart

import 'package:flutter/material.dart';
import '../models/hoa_don_model.dart';
import '../services/hoa_don_service.dart';
import '../utils/hoa_don_utils.dart';
import 'hoa_don_detail_screen.dart';

class HoaDonListArgs {
  final int canHoId;
  final String tenCanHo;

  HoaDonListArgs({required this.canHoId, this.tenCanHo = 'Căn hộ của tôi'});
}

class HoaDonListScreen extends StatefulWidget {
  final int canHoId;
  final String tenCanHo;

  const HoaDonListScreen({
    super.key,
    required this.canHoId,
    required this.tenCanHo,
  });

  @override
  State<HoaDonListScreen> createState() => _HoaDonListScreenState();
}

class _HoaDonListScreenState extends State<HoaDonListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get _isValidCanHoId => widget.canHoId > 0;

  int? _filterThang;
  int? _filterNam;

  bool get _hasFilter => _filterThang != null || _filterNam != null;

  String get _filterLabel {
    if (_filterThang != null && _filterNam != null) {
      return 'T$_filterThang/$_filterNam';
    }
    if (_filterThang != null) return 'Tháng $_filterThang';
    if (_filterNam != null) return 'Năm $_filterNam';
    return 'Lọc';
  }

  static const _tabs = [
    (label: 'Tất cả', trangThaiId: null as int?),
    (label: 'Chờ duyệt', trangThaiId: 1),
    (label: 'Chưa thanh toán', trangThaiId: 2),
    (label: 'Đã thanh toán', trangThaiId: 3),
    (label: 'Quá hạn', trangThaiId: 4),
    (label: 'Một phần', trangThaiId: 5),
    (label: 'Đã hủy', trangThaiId: 6),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    // Lưu giá trị tạm — user Cancel thì không mất filter cũ
    int? tempThang = _filterThang;
    int? tempNam = _filterNam;

    final now = DateTime.now();
    final years = List.generate(now.year - 2019, (i) => now.year - i);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title + nút xoá filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lọc theo tháng/năm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (tempThang != null || tempNam != null)
                    TextButton(
                      onPressed: () => setSheetState(() {
                        tempThang = null;
                        tempNam = null;
                      }),
                      child: const Text(
                        'Xoá lọc',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Chọn năm
              const Text(
                'Năm',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: years.map((y) {
                  final selected = tempNam == y;
                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => tempNam = selected ? null : y),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$y',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ── Chọn tháng
              const Text(
                'Tháng',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(12, (i) => i + 1).map((m) {
                  final selected = tempThang == m;
                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => tempThang = selected ? null : m),
                    child: Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'T$m',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Nút Áp dụng
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Commit filter ra ngoài — sẽ trigger rebuild TabBarView
                    setState(() {
                      _filterThang = tempThang;
                      _filterNam = tempNam;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidCanHoId) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Hóa đơn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 56,
                  color: Color(0xFFCBD5E1),
                ),
                SizedBox(height: 12),
                Text(
                  'Không tìm thấy thông tin căn hộ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Vui lòng liên hệ Ban Quản Lý\nđể được hỗ trợ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hóa đơn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              widget.tenCanHo,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _openFilterSheet,
              icon: Icon(
                _hasFilter
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_outlined,
                size: 18,
                color: _hasFilter
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
              ),
              label: Text(
                _filterLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hasFilter
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF94A3B8),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF6366F1),
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // ValueKey theo filter → force rebuild toàn bộ tabs khi filter thay đổi
        key: ValueKey('$_filterThang-$_filterNam'),
        children: _tabs
            .map(
              (t) => _HoaDonTabContent(
                canHoId: widget.canHoId,
                trangThaiId: t.trangThaiId,
                filterThang: _filterThang,
                filterNam: _filterNam,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── TAB CONTENT ─────────────────────────────────────────────────────────────

class _HoaDonTabContent extends StatefulWidget {
  final int canHoId;
  final int? trangThaiId;
  final int? filterThang;
  final int? filterNam;

  const _HoaDonTabContent({
    required this.canHoId,
    this.trangThaiId,
    this.filterThang,
    this.filterNam,
  });

  @override
  State<_HoaDonTabContent> createState() => _HoaDonTabContentState();
}

class _HoaDonTabContentState extends State<_HoaDonTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  // false vì filter thay đổi thì TabBarView rebuild hoàn toàn qua ValueKey
  bool get wantKeepAlive => false;

  List<HoaDon> _items = [];
  PagingInfo? _paging;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _currentPage = 1;
        _items = [];
      });
    }

    try {
      final result = await HoaDonService.instance.getList(
        canHoId: widget.canHoId,
        trangThaiHoaDonId: widget.trangThaiId,
        thang: widget.filterThang,
        nam: widget.filterNam,
        pageNumber: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _items = reset ? result.items : [..._items, ...result.items];
        _paging = result.pagingInfo;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final paging = _paging;
    if (paging == null || !paging.hasNextPage || _loadingMore || _loading) {
      return;
    }
    setState(() {
      _loadingMore = true;
      _currentPage++;
    });
    try {
      final result = await HoaDonService.instance.getList(
        canHoId: widget.canHoId,
        trangThaiHoaDonId: widget.trangThaiId,
        thang: widget.filterThang,
        nam: widget.filterNam,
        pageNumber: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...result.items];
        _paging = result.pagingInfo;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _currentPage--;
      });
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorRetry(message: _error!, onRetry: () => _load(reset: true));
    }

    if (_items.isEmpty) {
      return _EmptyState(
        hasFilter: widget.filterThang != null || widget.filterNam != null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _HoaDonCard(
            hoaDon: _items[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HoaDonDetailScreen(
                    hoaDonId: _items[index].id,
                    maHoaDon: _items[index].maHoaDon,
                  ),
                ),
              ).then((_) => _load(reset: true));
            },
          );
        },
      ),
    );
  }
}

// ─── HOA DON CARD ─────────────────────────────────────────────────────────────

class _HoaDonCard extends StatelessWidget {
  final HoaDon hoaDon;
  final VoidCallback onTap;

  const _HoaDonCard({required this.hoaDon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cfg = getTrangThaiConfig(hoaDon.trangThaiHoaDonId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: hoaDon.laQuaHan
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF8FAFF),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cfg.mauNen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cfg.icon, color: cfg.mau, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hoaDon.maHoaDon,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          hoaDon.kyThanhToan,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cfg.mauNen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cfg.ten,
                      style: TextStyle(
                        fontSize: 11,
                        color: cfg.mau,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hạn thanh toán',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (hoaDon.sapHetHan && !hoaDon.laDaThanhToan)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFF97316),
                                size: 14,
                              ),
                            ),
                          Text(
                            formatNgay(hoaDon.ngayHanThanhToan),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: hoaDon.laQuaHan
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatTien(hoaDon.tongTien),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CTA nếu chưa thanh toán
            if (hoaDon.laCoTheThanhToan)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Xem & Thanh toán',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── EMPTY / ERROR ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilter;

  const _EmptyState({this.hasFilter = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter ? Icons.search_off_rounded : Icons.receipt_long_outlined,
            size: 56,
            color: const Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 12),
          Text(
            hasFilter
                ? 'Không có hóa đơn nào\ntrong khoảng thời gian này'
                : 'Không có hóa đơn nào',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
