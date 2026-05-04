// lib/features/cu_tru/screens/cu_tru_detail_screen.dart
//
// Layout screen duy nhất cho chi tiết cư trú.
// Nhận [initialMode] từ màn hình danh sách để biết mở tab nào trước.
// AppBar có nút toggle để chuyển qua lại giữa Thành viên ↔ Phương tiện.
// FAB (+) phân biệt hành động thêm theo mode hiện tại.
//
// Reload chain:
//   FAB → YeuCauCuTruFormScreen.pop(true) → _lichSuKey.currentState?.reload()

import 'package:flutter/material.dart';

import '../models/quan_he_cu_tru_model.dart';

// ── Thanh viên (nằm trong cu_tru/thanh_vien/) ────────────────────────────
import '../../thanh_vien/screens/tabs/thanh_vien_list_tab.dart';
import '../../thanh_vien/screens/tabs/tv_lich_su_yeu_cau_tab.dart';
import '../../thanh_vien/screens/yeu_cau_cu_tru_form_screen.dart';

// ── Phương tiện ───────────────────────────────────────────────────────────
import '../../phuong_tien/widgets/phuong_tien_list_tab.dart';
import '../../phuong_tien/widgets/pt_lich_su_yeu_cau_tab.dart';
import '../../phuong_tien/screens/tao_yeu_cau_phuong_tien_screen.dart';

// ── Enum mode ─────────────────────────────────────────────────────────────

enum CuTruDetailMode { thanhVien, phuongTien }

// ── Screen ────────────────────────────────────────────────────────────────

class CuTruDetailScreen extends StatefulWidget {
  final QuanHeCuTruModel item;
  final CuTruDetailMode initialMode;

  const CuTruDetailScreen({
    super.key,
    required this.item,
    required this.initialMode,
  });

  @override
  State<CuTruDetailScreen> createState() => _CuTruDetailScreenState();
}

class _CuTruDetailScreenState extends State<CuTruDetailScreen>
    with SingleTickerProviderStateMixin {
  late CuTruDetailMode _mode;
  late TabController _tabController;

  // GlobalKey để gọi reload trên tab lịch sử sau khi FAB tạo thành công.
  final _tvLichSuKey = GlobalKey<LichSuYeuCauThanhVienTabState>();
  final _ptLichSuKey = GlobalKey<LichSuYeuCauPhuongTienTabState>();

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Toggle mode ────────────────────────────────────────────────────────

  void _toggleMode() {
    setState(() {
      _mode = _mode == CuTruDetailMode.thanhVien
          ? CuTruDetailMode.phuongTien
          : CuTruDetailMode.thanhVien;
      _tabController.animateTo(0);
    });
  }

  // ── FAB action ─────────────────────────────────────────────────────────

  Future<void> _onFabPressed() async {
    if (_mode == CuTruDetailMode.thanhVien) {
      final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => YeuCauCuTruFormScreen(
            mode: YeuCauFormCreate(canHoInfo: widget.item),
          ),
        ),
      );
      // Tạo thành công → reload tab lịch sử thành viên
      if (created == true && mounted) {
        _tvLichSuKey.currentState?.reload();
      }
    } else {
      final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => TaoYeuCauPhuongTienScreen(canHoInfo: widget.item),
        ),
      );
      // Tạo thành công → reload tab lịch sử phương tiện
      if (created == true && mounted) {
        _ptLichSuKey.currentState?.reload();
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isThanhVien = _mode == CuTruDetailMode.thanhVien;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.maCanHo, style: const TextStyle(fontSize: 16)),
            Text(
              isThanhVien ? 'Thành viên' : 'Phương tiện',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: isThanhVien
                ? 'Chuyển sang Phương tiện'
                : 'Chuyển sang Thành viên',
            child: IconButton(
              icon: Icon(
                isThanhVien
                    ? Icons.directions_car_outlined
                    : Icons.people_outline,
              ),
              onPressed: _toggleMode,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(isThanhVien ? Icons.people : Icons.directions_car),
              text: isThanhVien ? 'Thành viên' : 'Phương tiện',
            ),
            const Tab(icon: Icon(Icons.history), text: 'Lịch sử yêu cầu'),
          ],
        ),
      ),

      // ── Tab content ──────────────────────────────────────────────────
      body: TabBarView(
        controller: _tabController,
        children: isThanhVien
            ? [
                ThanhVienListTab(item: widget.item),
                LichSuYeuCauThanhVienTab(key: _tvLichSuKey, item: widget.item),
              ]
            : [
                PhuongTienListTab(item: widget.item),
                LichSuYeuCauPhuongTienTab(key: _ptLichSuKey, item: widget.item),
              ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: isThanhVien ? 'Thêm thành viên' : 'Thêm phương tiện',
        child: const Icon(Icons.add),
      ),
    );
  }
}
