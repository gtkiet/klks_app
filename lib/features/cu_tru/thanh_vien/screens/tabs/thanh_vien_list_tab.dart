// lib/features/cu_tru/thanh_vien/screens/tabs/thanh_vien_list_tab.dart
//
// Reload chain:
//   • ThanhVienDetailScreen pop(true) → _loadData()
//   • XoaYeuCauThanhVienScreen pop(true) (qua detail) → _loadData()
//   • YeuCauCuTruFormScreen (create) pop(true) → _loadData()

import 'package:flutter/material.dart';


import '../../models/thanh_vien_model.dart';
import '../../services/thanh_vien_service.dart';
import '../../widgets/tv_shared_widgets.dart';

import '../thanh_vien_detail_screen.dart';
import '../yeu_cau_cu_tru_form_screen.dart';
import '../xoa_yeu_cau_thanh_vien_screen.dart';

class ThanhVienListTab extends StatefulWidget {
  final QuanHeCuTruModel item;

  const ThanhVienListTab({super.key, required this.item});

  @override
  State<ThanhVienListTab> createState() => _ThanhVienListTabState();
}

class _ThanhVienListTabState extends State<ThanhVienListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _service = ThanhVienService.instance;

  bool _isLoading = false;
  List<ThanhVienCuTruModel> _list = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _service.getThanhVienCuTru(widget.item.canHoId);
      setState(() => _list = result);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  Future<void> _goToDetail(ThanhVienCuTruModel member) async {
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ThanhVienDetailScreen(thanhVien: member, canHoInfo: widget.item),
      ),
    );
    if (reload == true && mounted) _loadData();
  }

  Future<void> _goToSua(ThanhVienCuTruModel member) async {
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => YeuCauCuTruFormScreen(
          mode: YeuCauFormEdit(thanhVien: member, canHoInfo: widget.item),
        ),
      ),
    );
    if (reload == true && mounted) _loadData();
  }

  Future<void> _goToXoa(ThanhVienCuTruModel member) async {
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            XoaYeuCauThanhVienScreen(thanhVien: member, canHoInfo: widget.item),
      ),
    );
    if (reload == true && mounted) _loadData();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return TvAsyncLayout(
        isLoading: _isLoading,
        empty: const Center(child: Text('Chưa có thành viên nào')),
      );
    }

    if (_list.isEmpty) {
      return const Center(child: Text('Chưa có thành viên nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _list.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) => _ThanhVienTile(
          member: _list[i],
          onTap: () => _goToDetail(_list[i]),
          onSua: () => _goToSua(_list[i]),
          onXoa: () => _goToXoa(_list[i]),
        ),
      ),
    );
  }
}

// =============================================================================
// LIST TILE
// =============================================================================

class _ThanhVienTile extends StatelessWidget {
  final ThanhVienCuTruModel member;
  final VoidCallback onTap;
  final VoidCallback onSua;
  final VoidCallback onXoa;

  const _ThanhVienTile({
    required this.member,
    required this.onTap,
    required this.onSua,
    required this.onXoa,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: TvMemberAvatar(
        imageUrl: member.anhDaiDienUrl,
        name: member.fullName,
      ),
      title: Text(member.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(member.loaiQuanHeTen),
          if (member.ngayBatDau != null)
            Text(
              'Từ ngày: ${member.ngayBatDau!.tvFormatted}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
      ),
      isThreeLine: member.ngayBatDau != null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Tạo yêu cầu sửa',
            onPressed: onSua,
          ),
          IconButton(
            icon: Icon(
              Icons.person_remove_outlined,
              size: 20,
              color: Colors.red.shade400,
            ),
            tooltip: 'Tạo yêu cầu xóa',
            onPressed: onXoa,
          ),
        ],
      ),
    );
  }
}
