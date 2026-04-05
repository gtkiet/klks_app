// lib/features/cu_tru/screens/can_ho_detail_screen.dart
//
// Screen trung tâm sau khi chọn căn hộ.
// Tab 1: Danh sách thành viên đang cư trú (POST /api/cu-dan/thanh-vien-cu-tru)
// Tab 2: Danh sách yêu cầu cư trú       (POST /api/quan-he-cu-tru/yeu-cau/get-list)
//
// FAB "Tạo yêu cầu" → BottomSheet chọn loại → routing vào form phù hợp.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../models/yeu_cau_cu_tru_model.dart';
import '../services/cu_tru_service.dart';
import 'chon_thanh_vien_screen.dart';
import 'tao_yeu_cau_screen.dart';
import 'chi_tiet_yeu_cau_screen.dart';

class CanHoDetailScreen extends StatefulWidget {
  final QuanHeCuTruModel canHo;

  const CanHoDetailScreen({super.key, required this.canHo});

  @override
  State<CanHoDetailScreen> createState() => _CanHoDetailScreenState();
}

class _CanHoDetailScreenState extends State<CanHoDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = CuTruService();

  // ── Tab 1: Thành viên ────────────────────────────────────────────────────────
  List<ThanhVienCuTruModel> _thanhVienList = [];
  bool _thanhVienLoading = false;
  String? _thanhVienError;

  // ── Tab 2: Yêu cầu ──────────────────────────────────────────────────────────
  List<YeuCauCuTruModel> _yeuCauList = [];
  bool _yeuCauLoading = false;
  bool _yeuCauLoadingMore = false;
  String? _yeuCauError;
  int _yeuCauPage = 1;
  bool _yeuCauHasMore = true;
  static const int _pageSize = 20;
  final _yeuCauScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadThanhVien();
    _loadYeuCau(reset: true);
    _yeuCauScrollCtrl.addListener(_onYeuCauScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _yeuCauScrollCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Không làm gì thêm, data đã load ở initState
  }

  void _onYeuCauScroll() {
    if (_yeuCauScrollCtrl.position.pixels >=
            _yeuCauScrollCtrl.position.maxScrollExtent - 200 &&
        !_yeuCauLoadingMore &&
        _yeuCauHasMore) {
      _loadMoreYeuCau();
    }
  }

  // ── Load thành viên ───────────────────────────────────────────────────────────

  Future<void> _loadThanhVien() async {
    setState(() {
      _thanhVienLoading = true;
      _thanhVienError = null;
    });
    try {
      final list = await _service.getThanhVienCuTru(widget.canHo.canHoId);
      setState(() => _thanhVienList = list);
    } catch (e) {
      setState(() => _thanhVienError = e.toString());
    } finally {
      setState(() => _thanhVienLoading = false);
    }
  }

  // ── Load yêu cầu ─────────────────────────────────────────────────────────────

  Future<void> _loadYeuCau({bool reset = false}) async {
    if (reset) {
      setState(() {
        _yeuCauPage = 1;
        _yeuCauHasMore = true;
        _yeuCauError = null;
        _yeuCauLoading = true;
      });
    }
    try {
      final result = await _service.getYeuCauList(
        pageNumber: _yeuCauPage,
        pageSize: _pageSize,
        canHoId: widget.canHo.canHoId,
      );
      setState(() {
        if (reset) {
          _yeuCauList = result.items;
        } else {
          _yeuCauList.addAll(result.items);
        }
        _yeuCauHasMore = result.items.length >= _pageSize;
      });
    } catch (e) {
      setState(() => _yeuCauError = e.toString());
    } finally {
      setState(() {
        _yeuCauLoading = false;
        _yeuCauLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreYeuCau() async {
    setState(() {
      _yeuCauLoadingMore = true;
      _yeuCauPage++;
    });
    await _loadYeuCau();
  }

  // ── FAB: chọn loại yêu cầu ───────────────────────────────────────────────────

  Future<void> _onFabTapped() async {
    // 1. Lấy danh sách loại yêu cầu từ catalog
    List<SelectorItemModel> loaiYeuCauList = [];
    try {
      loaiYeuCauList = await _service.getLoaiYeuCauSelector();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tải được loại yêu cầu: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    // 2. Hiển thị bottom sheet chọn loại
    final chosen = await showModalBottomSheet<SelectorItemModel>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LoaiYeuCauBottomSheet(items: loaiYeuCauList),
    );

    if (chosen == null || !mounted) return;

    // 3. Routing theo loại yêu cầu
    // Giả sử: id=1 Thêm, id=2 Sửa, id=3 Xóa
    // → Dùng tên để detect vì id có thể khác nhau theo server
    final tenLower = chosen.name.toLowerCase();
    final isDelete = tenLower.contains('xóa') || tenLower.contains('xoa');
    final isUpdate = tenLower.contains('sửa') || tenLower.contains('sua');
    final isCreate = !isDelete && !isUpdate;

    bool? created;

    if (isCreate) {
      // Thêm mới: vào form trực tiếp
      created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TaoYeuCauScreen(canHo: widget.canHo, loaiYeuCau: chosen),
        ),
      );
    } else {
      // Sửa / Xóa: cần chọn thành viên trước
      final selected = await Navigator.push<ThanhVienCuTruModel>(
        context,
        MaterialPageRoute(
          builder: (_) => ChonThanhVienScreen(
            canHoId: widget.canHo.canHoId,
            tenCanHo: widget.canHo.tenCanHo,
            title: isUpdate
                ? 'Chọn thành viên cần sửa'
                : 'Chọn thành viên cần xóa',
          ),
        ),
      );

      if (selected == null || !mounted) return;

      created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => TaoYeuCauScreen(
            canHo: widget.canHo,
            loaiYeuCau: chosen,
            targetThanhVien: selected,
            // Chỉ prefill form khi sửa, xóa chỉ cần nội dung
            prefillForm: isUpdate,
          ),
        ),
      );
    }

    if (created == true && mounted) {
      _loadYeuCau(reset: true);
      // Chuyển sang tab yêu cầu
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.canHo.tenCanHo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.canHo.diaChiDayDu,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text:
                  'Thành viên'
                  '${_thanhVienList.isNotEmpty ? ' (${_thanhVienList.length})' : ''}',
            ),
            Tab(
              text:
                  'Yêu cầu'
                  '${_yeuCauList.isNotEmpty ? ' (${_yeuCauList.length})' : ''}',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabTapped,
        icon: const Icon(Icons.add),
        label: const Text('Tạo yêu cầu'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ThanhVienTab(
            list: _thanhVienList,
            isLoading: _thanhVienLoading,
            error: _thanhVienError,
            onRetry: _loadThanhVien,
          ),
          _YeuCauTab(
            list: _yeuCauList,
            isLoading: _yeuCauLoading,
            isLoadingMore: _yeuCauLoadingMore,
            error: _yeuCauError,
            scrollController: _yeuCauScrollCtrl,
            onRetry: () => _loadYeuCau(reset: true),
            onTapItem: (item) async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChiTietYeuCauScreen(
                    requestId: item.id,
                    canHo: widget.canHo,
                  ),
                ),
              );
              // Refresh sau khi quay lại (có thể user đã submit/withdraw)
              _loadYeuCau(reset: true);
            },
          ),
        ],
      ),
    );
  }
}

// ─── BottomSheet chọn loại yêu cầu ───────────────────────────────────────────

class _LoaiYeuCauBottomSheet extends StatelessWidget {
  final List<SelectorItemModel> items;
  const _LoaiYeuCauBottomSheet({required this.items});

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('thêm') || n.contains('them')) {
      return Icons.person_add_outlined;
    }
    if (n.contains('sửa') || n.contains('sua')) return Icons.edit_outlined;
    if (n.contains('xóa') || n.contains('xoa')) {
      return Icons.person_remove_outlined;
    }
    return Icons.assignment_outlined;
  }

  Color _colorFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('thêm') || n.contains('them')) return Colors.green;
    if (n.contains('sửa') || n.contains('sua')) return Colors.orange;
    if (n.contains('xóa') || n.contains('xoa')) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn loại yêu cầu',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bạn muốn thay đổi nhân sự trong căn hộ như thế nào?',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              final color = _colorFor(item.name);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () => Navigator.pop(context, item),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                  ),
                  tileColor: color.withValues(alpha: 0.05),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(_iconFor(item.name), color: color, size: 22),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(Icons.chevron_right, color: color),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Thành viên ────────────────────────────────────────────────────────

class _ThanhVienTab extends StatelessWidget {
  final List<ThanhVienCuTruModel> list;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _ThanhVienTab({
    required this.list,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (error != null) {
      return _ErrorRetry(message: error!, onRetry: onRetry);
    }

    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Chưa có thành viên nào đang cư trú.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: list.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
      itemBuilder: (_, i) => _ThanhVienTile(item: list[i]),
    );
  }
}

class _ThanhVienTile extends StatelessWidget {
  final ThanhVienCuTruModel item;
  const _ThanhVienTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final ngay = item.ngayBatDau != null
        ? DateFormat('dd/MM/yyyy').format(item.ngayBatDau!)
        : '---';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundImage: item.anhDaiDienUrl != null
            ? NetworkImage(item.anhDaiDienUrl!)
            : null,
        child: item.anhDaiDienUrl == null
            ? Text(
                item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        item.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${item.loaiQuanHeTen} · Từ $ngay',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

// ─── Tab 2: Yêu cầu ──────────────────────────────────────────────────────────

class _YeuCauTab extends StatelessWidget {
  final List<YeuCauCuTruModel> list;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final ValueChanged<YeuCauCuTruModel> onTapItem;

  const _YeuCauTab({
    required this.list,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.scrollController,
    required this.onRetry,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (error != null) {
      return _ErrorRetry(message: error!, onRetry: onRetry);
    }

    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Chưa có yêu cầu nào.', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            Text(
              'Nhấn "Tạo yêu cầu" để bắt đầu.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: list.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == list.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _YeuCauCard(item: list[i], onTap: () => onTapItem(list[i]));
        },
      ),
    );
  }
}

class _YeuCauCard extends StatelessWidget {
  final YeuCauCuTruModel item;
  final VoidCallback onTap;
  const _YeuCauCard({required this.item, required this.onTap});

  Color _statusColor(int id) {
    switch (id) {
      case 1:
        return Colors.orange; // Chờ duyệt
      case 2:
        return Colors.green; // Đã duyệt
      case 3:
        return Colors.red; // Từ chối
      default:
        return Colors.blue; // Đã lưu / nháp
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngay = item.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt!)
        : '---';
    final color = _statusColor(item.trangThaiId);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tenLoaiYeuCau,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (item.hoTenDayDu != null)
                      Text(
                        item.hoTenDayDu!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.tenNguoiGui} · $ngay',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  item.tenTrangThai,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared error widget ──────────────────────────────────────────────────────

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
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
