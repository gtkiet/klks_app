// // lib/features/thanh_vien/screens/tabs/thanh_vien_list_tab.dart
// //
// // Tab 1 (mode Thành viên):
// //   - Tự động gọi ThanhVienService.getThanhVienCuTru(canHoId) khi mount
// //   - Tap vào item → mở ThanhVienDetailScreen (gọi getThongTinCuDan)

// import 'package:flutter/material.dart';

// import '../../../../core/errors/errors.dart';

// import '../services/thanh_vien_service.dart';

// import '../../cu_tru/models/quan_he_cu_tru_model.dart';
// import '../models/thanh_vien_cu_tru_model.dart';

// import '../screens/thanh_vien_detail_screen.dart';

// class ThanhVienListTab extends StatefulWidget {
//   final QuanHeCuTruModel item;

//   const ThanhVienListTab({super.key, required this.item});

//   @override
//   State<ThanhVienListTab> createState() => _ThanhVienListTabState();
// }

// class _ThanhVienListTabState extends State<ThanhVienListTab>
//     with AutomaticKeepAliveClientMixin {
//   // Giữ state khi swipe qua lại giữa các tab
//   @override
//   bool get wantKeepAlive => true;

//   final _service = ThanhVienService.instance;

//   // ── State ──────────────────────────────────────────────────────────────
//   bool _isLoading = false;
//   AppException? _error;
//   List<ThanhVienCuTruModel> _list = [];

//   // ── Lifecycle ──────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _loadData(); // tự động tải khi tab được tạo
//   }

//   // ── Service call ───────────────────────────────────────────────────────
//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final result =
//           await _service.getThanhVienCuTru(widget.item.canHoId);
//       setState(() => _list = result);
//     } on AppException catch (e) {
//       setState(() => _error = e);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ── Navigation ─────────────────────────────────────────────────────────
//   void _goToDetail(ThanhVienCuTruModel member) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ThanhVienDetailScreen(
//           thanhVien: member,
//           canHoInfo: widget.item,
//         ),
//       ),
//     );
//   }

//   // ── Build ──────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // bắt buộc với AutomaticKeepAliveClientMixin

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AppErrorWidget(error: _error!),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               onPressed: _loadData,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Thử lại'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_list.isEmpty) {
//       return const Center(child: Text('Chưa có thành viên nào'));
//     }

//     return RefreshIndicator(
//       onRefresh: _loadData,
//       child: ListView.separated(
//         padding: const EdgeInsets.all(12),
//         itemCount: _list.length,
//         separatorBuilder: (_, _) => const Divider(height: 1),
//         itemBuilder: (_, i) => _ThanhVienTile(
//           member: _list[i],
//           onTap: () => _goToDetail(_list[i]),
//         ),
//       ),
//     );
//   }
// }

// // ── List tile ─────────────────────────────────────────────────────────────
// class _ThanhVienTile extends StatelessWidget {
//   final ThanhVienCuTruModel member;
//   final VoidCallback onTap;

//   const _ThanhVienTile({required this.member, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: onTap,
//       leading: CircleAvatar(
//         backgroundImage: member.anhDaiDienUrl != null
//             ? NetworkImage(member.anhDaiDienUrl!)
//             : null,
//         child: member.anhDaiDienUrl == null
//             ? Text(
//                 member.fullName.isNotEmpty
//                     ? member.fullName[0].toUpperCase()
//                     : '?',
//               )
//             : null,
//       ),
//       title: Text(member.fullName),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(member.loaiQuanHeTen),
//           if (member.ngayBatDau != null)
//             Text(
//               'Từ ngày: ${_fmtDate(member.ngayBatDau!)}',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Theme.of(context).colorScheme.outline,
//                   ),
//             ),
//         ],
//       ),
//       isThreeLine: member.ngayBatDau != null,
//       trailing: const Icon(Icons.chevron_right),
//     );
//   }

//   String _fmtDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
// }

// lib/features/thanh_vien/screens/tabs/thanh_vien_list_tab.dart

import 'package:flutter/material.dart';

import '../../../../core/errors/errors.dart';
import '../../cu_tru/models/quan_he_cu_tru_model.dart';
import '../models/thanh_vien_cu_tru_model.dart';
import '../screens/thanh_vien_detail_screen.dart';
import '../screens/sua_yeu_cau_thanh_vien_screen.dart';
import '../screens/xoa_yeu_cau_thanh_vien_screen.dart';
import '../services/thanh_vien_service.dart';

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
  AppException? _error;
  List<ThanhVienCuTruModel> _list = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _service.getThanhVienCuTru(widget.item.canHoId);
      setState(() => _list = result);
    } on AppException catch (e) {
      setState(() => _error = e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToDetail(ThanhVienCuTruModel member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThanhVienDetailScreen(
          thanhVien: member,
          canHoInfo: widget.item,
        ),
      ),
    ).then((_) => _loadData()); // reload sau khi quay lại
  }

  void _goToSua(ThanhVienCuTruModel member) async {
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SuaYeuCauThanhVienScreen(
          thanhVien: member,
          canHoInfo: widget.item,
        ),
      ),
    );
    if (reload == true) _loadData();
  }

  void _goToXoa(ThanhVienCuTruModel member) async {
    final reload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => XoaYeuCauThanhVienScreen(
          thanhVien: member,
          canHoInfo: widget.item,
        ),
      ),
    );
    if (reload == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(error: _error!),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
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

// ── List tile ─────────────────────────────────────────────────────────────

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
      leading: CircleAvatar(
        backgroundImage: member.anhDaiDienUrl != null
            ? NetworkImage(member.anhDaiDienUrl!)
            : null,
        child: member.anhDaiDienUrl == null
            ? Text(
                member.fullName.isNotEmpty
                    ? member.fullName[0].toUpperCase()
                    : '?',
              )
            : null,
      ),
      title: Text(member.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(member.loaiQuanHeTen),
          if (member.ngayBatDau != null)
            Text(
              'Từ ngày: ${_fmtDate(member.ngayBatDau!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
        ],
      ),
      isThreeLine: member.ngayBatDau != null,
      // ── Nút Sửa / Xóa ──────────────────────────────────────────────────
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Tạo yêu cầu sửa',
            onPressed: onSua,
          ),
          IconButton(
            icon: Icon(Icons.person_remove_outlined,
                size: 20, color: Colors.red.shade400),
            tooltip: 'Tạo yêu cầu xóa',
            onPressed: onXoa,
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}