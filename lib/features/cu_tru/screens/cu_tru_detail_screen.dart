// lib/features/cu_tru/screens/cu_tru_detail_screen.dart
//
// Layout screen duy nhất cho chi tiết cư trú.
// Nhận [initialMode] từ màn hình danh sách để biết mở tab nào trước.
// AppBar có nút toggle để chuyển qua lại giữa Thành viên ↔ Phương tiện.
// FAB (+) phân biệt hành động thêm theo mode hiện tại.

import 'package:flutter/material.dart';

import '../models/quan_he_cu_tru_model.dart';

import '../../thanh_vien/widgets/thanh_vien_list_tab.dart';
import '../../thanh_vien/widgets/tv_lich_su_yeu_cau_tab.dart';
import '../../phuong_tien/widgets/phuong_tien_list_tab.dart';
import '../../phuong_tien/widgets/pt_lich_su_yeu_cau_tab.dart';

import '../../thanh_vien/screens/tao_yeu_cau_thanh_vien_screen.dart';
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

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    // Mỗi mode đều có 2 tab
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Toggle mode ────────────────────────────────────────────────────────
  // Khi toggle: giữ lại tab index (0 = list, 1 = lịch sử), chỉ đổi mode
  void _toggleMode() {
    setState(() {
      _mode = _mode == CuTruDetailMode.thanhVien
          ? CuTruDetailMode.phuongTien
          : CuTruDetailMode.thanhVien;
      // reset về tab đầu khi chuyển mode
      _tabController.animateTo(0);
    });
  }

  // ── FAB action ─────────────────────────────────────────────────────────
  // Trả về result = true nếu tạo thành công → tab lịch sử có thể refresh
  Future<void> _onFabPressed() async {
    if (_mode == CuTruDetailMode.thanhVien) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaoYeuCauThanhVienScreen(canHoInfo: widget.item),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaoYeuCauPhuongTienScreen(canHoInfo: widget.item),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isThanhVien = _mode == CuTruDetailMode.thanhVien;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
          // Nút toggle giữa thành viên và phương tiện
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

      // ── Tab content ─────────────────────────────────────────────────
      body: TabBarView(
        controller: _tabController,
        children: isThanhVien
            ? [
                // Tab 1: danh sách thành viên
                ThanhVienListTab(item: widget.item),
                // Tab 2: lịch sử yêu cầu liên quan thành viên
                LichSuYeuCauThanhVienTab(item: widget.item),
              ]
            : [
                // Tab 1: danh sách phương tiện
                PhuongTienListTab(item: widget.item),
                // Tab 2: lịch sử yêu cầu liên quan phương tiện
                LichSuYeuCauPhuongTienTab(item: widget.item),
              ],
      ),

      // ── FAB ─────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        tooltip: isThanhVien ? 'Thêm thành viên' : 'Thêm phương tiện',
        child: const Icon(Icons.add),
      ),
    );
  }
}
