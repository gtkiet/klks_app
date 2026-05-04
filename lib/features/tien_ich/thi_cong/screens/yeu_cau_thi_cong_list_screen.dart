// lib/features/yeu_cau_thi_cong/screens/yeu_cau_thi_cong_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../cu_tru/quan_he/models/quan_he_cu_tru_model.dart';
import '../../../cu_tru/quan_he/services/cu_tru_service.dart';
import '../models/trang_thai_yeu_cau.dart';
import '../models/yeu_cau_thi_cong_list_item_model.dart';
import '../models/trang_thai_thi_cong_model.dart';
import '../services/yeu_cau_thi_cong_service.dart';
import 'yeu_cau_thi_cong_detail_screen.dart';
import 'yeu_cau_thi_cong_form_screen.dart';

class YeuCauThiCongListScreen extends StatefulWidget {
  const YeuCauThiCongListScreen({super.key});

  @override
  State<YeuCauThiCongListScreen> createState() =>
      _YeuCauThiCongListScreenState();
}

class _YeuCauThiCongListScreenState extends State<YeuCauThiCongListScreen> {
  final _service = YeuCauThiCongService.instance;
  final _cuTruService = CuTruService.instance;

  // Data
  List<YeuCauThiCongListItemModel> _items = [];
  List<TrangThaiThiCongModel> _dsTrangThai = [];
  List<QuanHeCuTruModel> _dsCanHo = [];

  // Selection state
  QuanHeCuTruModel? _selectedCanHo;
  int? _filterTrangThaiId;

  // Loading state
  bool _isInitLoading = true;
  bool _isListLoading = false;
  String? _initError;
  String? _listError;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // ── Load lần đầu: căn hộ + catalog ──────────────────────────────────────

  Future<void> _initData() async {
    setState(() {
      _isInitLoading = true;
      _initError = null;
    });

    try {
      final results = await Future.wait([
        _cuTruService.getQuanHeCuTruList(),
        _service.getTrangThaiThiCongList(),
      ]);

      final dsCanHo = results[0] as List<QuanHeCuTruModel>;
      final dsTrangThai = results[1] as List<TrangThaiThiCongModel>;

      setState(() {
        _dsCanHo = dsCanHo;
        _dsTrangThai = dsTrangThai;
        _selectedCanHo = dsCanHo.isNotEmpty ? dsCanHo.first : null;
        _isInitLoading = false;
      });

      if (_selectedCanHo != null) await _loadList();
    } on Exception catch (e) {
      setState(() {
        _initError = e.toString();
        _isInitLoading = false;
      });
    }
  }

  // ── Load / reload danh sách theo căn hộ đang chọn ───────────────────────

  Future<void> _loadList() async {
    if (_selectedCanHo == null) return;

    setState(() {
      _isListLoading = true;
      _listError = null;
    });

    try {
      final result = await _service.getList(
        canHoId: _selectedCanHo!.canHoId,
        trangThaiThiCongId: _filterTrangThaiId,
      );
      setState(() => _items = result.items);
    } on Exception catch (e) {
      setState(() => _listError = e.toString());
    } finally {
      setState(() => _isListLoading = false);
    }
  }

  // ── Đổi căn hộ ───────────────────────────────────────────────────────────

  void _onCanHoChanged(QuanHeCuTruModel canHo) {
    if (_selectedCanHo?.canHoId == canHo.canHoId) return;
    setState(() {
      _selectedCanHo = canHo;
      _filterTrangThaiId = null;
      _items = [];
    });
    _loadList();
  }

  // ── Navigate ──────────────────────────────────────────────────────────────

  void _navigateToCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            YeuCauThiCongFormScreen(dsCanHo: _dsCanHo),
      ),
    );
    if (created == true) _loadList();
  }

  void _navigateToDetail(YeuCauThiCongListItemModel item) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => YeuCauThiCongDetailScreen(id: item.id),
      ),
    );
    if (changed == true) _loadList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu thi công'),
        actions: [
          // Filter trạng thái
          PopupMenuButton<int?>(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_filterTrangThaiId != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Lọc trạng thái',
            enabled: !_isInitLoading && _initError == null,
            onSelected: (val) {
              setState(() => _filterTrangThaiId = val);
              _loadList();
            },
            itemBuilder: (_) => [
              const PopupMenuItem<int?>(
                value: null,
                child: Text('Tất cả trạng thái'),
              ),
              ..._dsTrangThai.map(
                (t) => PopupMenuItem<int?>(
                  value: t.id,
                  child: Row(
                    children: [
                      Text(t.name),
                      if (_filterTrangThaiId == t.id) ...[
                        const Spacer(),
                        const Icon(Icons.check, size: 16, color: Colors.blue),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isInitLoading ? null : _loadList,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isInitLoading || _initError != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _dsCanHo.isEmpty ? null : _navigateToCreate,
              icon: const Icon(Icons.add),
              label: const Text('Tạo yêu cầu'),
            ),
    );
  }

  Widget _buildBody() {
    if (_initError != null) {
      return _ErrorRetry(message: _initError!, onRetry: _initData);
    }

    if (_isInitLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dsCanHo.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Bạn chưa được liên kết với căn hộ nào.\nVui lòng liên hệ Ban quản lý.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── Selector căn hộ ───────────────────────────────────────────────
        _CanHoSelector(
          dsCanHo: _dsCanHo,
          selected: _selectedCanHo,
          onChanged: _onCanHoChanged,
        ),

        // ── Filter chip active ────────────────────────────────────────────
        if (_filterTrangThaiId != null) _buildActiveFilterBar(),

        // ── Danh sách ─────────────────────────────────────────────────────
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildActiveFilterBar() {
    final tenTrangThai = _dsTrangThai
        .where((t) => t.id == _filterTrangThaiId)
        .map((t) => t.name)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 14, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            'Đang lọc: ${tenTrangThai ?? ''}',
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() => _filterTrangThaiId = null);
              _loadList();
            },
            child: const Icon(Icons.close, size: 16, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listError != null) {
      return _ErrorRetry(message: _listError!, onRetry: _loadList);
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              _filterTrangThaiId != null
                  ? 'Không có yêu cầu nào với bộ lọc này.'
                  : 'Căn hộ này chưa có yêu cầu thi công nào.',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadList,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _YeuCauCard(
          item: _items[i],
          onTap: () => _navigateToDetail(_items[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selector căn hộ
// ─────────────────────────────────────────────────────────────────────────────

class _CanHoSelector extends StatelessWidget {
  final List<QuanHeCuTruModel> dsCanHo;
  final QuanHeCuTruModel? selected;
  final ValueChanged<QuanHeCuTruModel> onChanged;

  const _CanHoSelector({
    required this.dsCanHo,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (dsCanHo.length == 1) {
      return _SingleCanHoBanner(canHo: dsCanHo.first);
    }
    return _CanHoDropdown(
      dsCanHo: dsCanHo,
      selected: selected,
      onChanged: onChanged,
    );
  }
}

class _SingleCanHoBanner extends StatelessWidget {
  final QuanHeCuTruModel canHo;
  const _SingleCanHoBanner({required this.canHo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.apartment, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canHo.tenCanHo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${canHo.tenToaNha} · ${canHo.tenTang}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CanHoDropdown extends StatelessWidget {
  final List<QuanHeCuTruModel> dsCanHo;
  final QuanHeCuTruModel? selected;
  final ValueChanged<QuanHeCuTruModel> onChanged;

  const _CanHoDropdown({
    required this.dsCanHo,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Căn hộ',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<QuanHeCuTruModel>(
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.apartment, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.blue.shade600, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: dsCanHo.map((canHo) {
              return DropdownMenuItem<QuanHeCuTruModel>(
                value: canHo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      canHo.tenCanHo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${canHo.tenToaNha} · ${canHo.tenTang}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            selectedItemBuilder: (context) => dsCanHo.map((canHo) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${canHo.tenCanHo}  ·  ${canHo.tenToaNha}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (canHo) {
              if (canHo != null) onChanged(canHo);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card yêu cầu
// ─────────────────────────────────────────────────────────────────────────────

class _YeuCauCard extends StatelessWidget {
  final YeuCauThiCongListItemModel item;
  final VoidCallback onTap;

  const _YeuCauCard({required this.item, required this.onTap});

  Color get _statusColor {
    switch (item.trangThaiYeuCauId) {
      case TrangThaiYeuCauConst.daLuu:
        return Colors.grey;
      case TrangThaiYeuCauConst.dangChoDuyet:
        return Colors.orange;
      case TrangThaiYeuCauConst.daDuyet:
        return Colors.blue;
      case TrangThaiYeuCauConst.yeuCauBoSung:
        return Colors.amber.shade700;
      case TrangThaiYeuCauConst.hoanTat:
        return Colors.green;
      case TrangThaiYeuCauConst.tuChoi:
      case TrangThaiYeuCauConst.daHuy:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.hangMucThiCong,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(label: item.trangThaiYeuCauTen, color: _statusColor),
                ],
              ),
              const SizedBox(height: 6),
              _IconText(Icons.apartment, 'Căn hộ: ${item.tenCanHo}'),
              if (item.tenDonViThiCong.isNotEmpty) ...[
                const SizedBox(height: 4),
                _IconText(Icons.business, 'Đơn vị: ${item.tenDonViThiCong}'),
              ],
              if (item.trangThaiThiCongTen.isNotEmpty) ...[
                const SizedBox(height: 4),
                _IconText(
                  Icons.engineering,
                  item.trangThaiThiCongTen,
                  color: Colors.teal,
                ),
              ],
              if (item.duKienBatDau != null) ...[
                const SizedBox(height: 4),
                _IconText(
                  Icons.calendar_today,
                  'Dự kiến: ${df.format(item.duKienBatDau!)}'
                  '${item.duKienKetThuc != null ? ' → ${df.format(item.duKienKetThuc!)}' : ''}',
                  color: Colors.teal,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _IconText(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade600;
    return Row(
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: c)),
        ),
      ],
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