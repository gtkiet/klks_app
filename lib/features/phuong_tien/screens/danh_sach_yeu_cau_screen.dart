// lib/features/phuong_tien/screens/danh_sach_yeu_cau_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/phuong_tien_models.dart';
import '../services/phuong_tien_service.dart';

class DanhSachYeuCauScreen extends StatefulWidget {
  const DanhSachYeuCauScreen({super.key});

  @override
  State<DanhSachYeuCauScreen> createState() => _DanhSachYeuCauScreenState();
}

class _DanhSachYeuCauScreenState extends State<DanhSachYeuCauScreen> {
  final _service = PhuongTienService();

  List<YeuCauPhuongTien> _items = [];
  PagingInfo? _pagingInfo;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getListYeuCau(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử yêu cầu xe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(resetPage: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (_pagingInfo != null) _buildPagination(),
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
                onPressed: _loadData,
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
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Chưa có yêu cầu nào', style: TextStyle(color: Colors.grey)),
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
        itemBuilder: (_, index) => _YeuCauCard(
          item: _items[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChiTietYeuCauScreen(yeuCauId: _items[index].id),
            ),
          ).then((_) => _loadData()),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final info = _pagingInfo!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng: ${info.totalItems} yêu cầu | Trang $_currentPage/${info.totalPages}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadData();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                iconSize: 20,
              ),
              IconButton(
                onPressed: info.hasNextPage
                    ? () {
                        setState(() => _currentPage++);
                        _loadData();
                      }
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

class _YeuCauCard extends StatelessWidget {
  final YeuCauPhuongTien item;
  final VoidCallback onTap;

  const _YeuCauCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = item.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt!)
        : '-';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: _LoaiYeuCauIcon(loaiYeuCauId: item.loaiYeuCauId),
        title: Text(
          item.yeuCauTenPhuongTien ?? item.tenLoaiYeuCau,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.yeuCauBienSo != null)
              Text('Biển số: ${item.yeuCauBienSo}'),
            Text(
              '${item.diaChiCanHo} • $dateStr',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: _TrangThaiYeuCauChip(
          trangThaiId: item.trangThaiId,
          ten: item.tenTrangThai,
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _LoaiYeuCauIcon extends StatelessWidget {
  final int loaiYeuCauId;
  const _LoaiYeuCauIcon({required this.loaiYeuCauId});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (loaiYeuCauId) {
      case 1:
        icon = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case 2:
        icon = Icons.edit_outlined;
        color = Colors.blue;
        break;
      case 3:
        icon = Icons.remove_circle_outline;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }
}

class _TrangThaiYeuCauChip extends StatelessWidget {
  final int trangThaiId;
  final String ten;

  const _TrangThaiYeuCauChip({required this.trangThaiId, required this.ten});

  @override
  Widget build(BuildContext context) {
    // Mapping trangThaiId → color (điều chỉnh theo thực tế)
    Color color;
    switch (trangThaiId) {
      case 1: // Đã lưu / nháp
        color = Colors.grey;
        break;
      case 2: // Chờ duyệt
        color = Colors.orange;
        break;
      case 3: // Đã duyệt
        color = Colors.green;
        break;
      case 4: // Từ chối
        color = Colors.red;
        break;
      case 5: // Đã rút
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        ten,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// =============================================================================
// Chi tiết yêu cầu + actions (submit / withdraw)
// =============================================================================

class ChiTietYeuCauScreen extends StatefulWidget {
  final int yeuCauId;

  const ChiTietYeuCauScreen({super.key, required this.yeuCauId});

  @override
  State<ChiTietYeuCauScreen> createState() => _ChiTietYeuCauScreenState();
}

class _ChiTietYeuCauScreenState extends State<ChiTietYeuCauScreen> {
  final _service = PhuongTienService();

  YeuCauPhuongTien? _yeuCau;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isActioning = false;

  // Trạng thái "Đã lưu" → có thể submit / withdraw
  static const int _trangThaiDaLuu = 1;
  static const int _trangThaiChoDuyet = 2;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getYeuCauById(widget.yeuCauId);
      if (mounted) {
        setState(() {
          _yeuCau = result;
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

  Future<void> _doAction({
    required bool isSubmit,
    required bool isWithdraw,
    required String confirmMessage,
    required String successMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isActioning = true);

    try {
      final updated = await _service.capNhatYeuCau(
        CapNhatYeuCauRequest(
          id: widget.yeuCauId,
          isSubmit: isSubmit,
          isWithdraw: isWithdraw,
        ),
      );

      if (mounted) {
        setState(() {
          _yeuCau = updated;
          _isActioning = false;
        });
        _showSnackBar(successMessage);
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isActioning = false);
        _showSnackBar(e.message, isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết yêu cầu'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
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
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final yc = _yeuCau!;

    String dateStr(DateTime? dt) =>
        dt != null ? DateFormat('dd/MM/yyyy HH:mm').format(dt) : '-';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header: loại yêu cầu + trạng thái
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _LoaiYeuCauIcon(loaiYeuCauId: yc.loaiYeuCauId),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yc.tenLoaiYeuCau,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Yêu cầu #${yc.id}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _TrangThaiYeuCauChip(
                  trangThaiId: yc.trangThaiId,
                  ten: yc.tenTrangThai,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Thông tin người gửi
        _buildInfoCard('Thông tin gửi', [
          _InfoItem('Người gửi', yc.tenNguoiGui),
          _InfoItem('Ngày gửi', dateStr(yc.createdAt)),
          _InfoItem('Căn hộ', yc.diaChiCanHo),
        ]),
        const SizedBox(height: 12),

        // Thông tin phương tiện yêu cầu
        _buildInfoCard('Thông tin xe yêu cầu', [
          if (yc.yeuCauTenPhuongTien != null)
            _InfoItem('Tên xe', yc.yeuCauTenPhuongTien!),
          if (yc.tenYeuCauLoaiPhuongTien != null)
            _InfoItem('Loại xe', yc.tenYeuCauLoaiPhuongTien!),
          if (yc.yeuCauBienSo != null) _InfoItem('Biển số', yc.yeuCauBienSo!),
          if (yc.yeuCauMauXe != null) _InfoItem('Màu xe', yc.yeuCauMauXe!),
        ]),
        const SizedBox(height: 12),

        // Người xử lý
        if (yc.tenNguoiXuLy != null)
          _buildInfoCard('Thông tin xử lý', [
            _InfoItem('Người xử lý', yc.tenNguoiXuLy!),
            _InfoItem('Ngày xử lý', dateStr(yc.ngayXuLy)),
            if (yc.lyDo != null) _InfoItem('Lý do', yc.lyDo!),
          ]),
        if (yc.tenNguoiXuLy != null) const SizedBox(height: 12),

        // Nội dung
        if (yc.noiDung != null && yc.noiDung!.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ghi chú',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  Text(yc.noiDung!),
                ],
              ),
            ),
          ),
        if (yc.noiDung != null && yc.noiDung!.isNotEmpty)
          const SizedBox(height: 12),

        // Hình ảnh
        if (yc.yeuCauHinhAnhPhuongTiens.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hình ảnh (${yc.yeuCauHinhAnhPhuongTiens.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: yc.yeuCauHinhAnhPhuongTiens.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final img = yc.yeuCauHinhAnhPhuongTiens[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            img.fileUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_yeuCau == null) return const SizedBox.shrink();
    final yc = _yeuCau!;

    // Chỉ hiển thị action khi "Đã lưu"
    if (yc.trangThaiId != _trangThaiDaLuu) {
      // Nếu "Chờ duyệt" → chỉ cho rút
      if (yc.trangThaiId == _trangThaiChoDuyet) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _isActioning
                  ? null
                  : () => _doAction(
                      isSubmit: false,
                      isWithdraw: true,
                      confirmMessage: 'Rút lại yêu cầu này?',
                      successMessage: 'Đã rút yêu cầu thành công',
                    ),
              icon: _isActioning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.undo),
              label: const Text('Rút yêu cầu'),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isActioning
                    ? null
                    : () => _doAction(
                        isSubmit: false,
                        isWithdraw: true,
                        confirmMessage: 'Rút lại và hủy yêu cầu này?',
                        successMessage: 'Đã rút yêu cầu',
                      ),
                icon: const Icon(Icons.close),
                label: const Text('Rút'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isActioning
                    ? null
                    : () => _doAction(
                        isSubmit: true,
                        isWithdraw: false,
                        confirmMessage: 'Gửi yêu cầu để BQL phê duyệt?',
                        successMessage: 'Đã gửi yêu cầu. Chờ BQL phê duyệt!',
                      ),
                icon: _isActioning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: const Text('Gửi duyệt'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<_InfoItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}
