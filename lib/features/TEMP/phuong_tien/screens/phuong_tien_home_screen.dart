// lib/features/phuong_tien/screens/phuong_tien_home_screen.dart
//
// Màn hình hub để test tất cả APIs.
// Gắn screen này vào router hoặc dùng trực tiếp trong main.dart.

import 'package:flutter/material.dart';
import 'danh_sach_phuong_tien_screen.dart';
import 'danh_sach_yeu_cau_screen.dart';
// import 'tao_yeu_cau_screen.dart';
import '../services/phuong_tien_service.dart';
import '../models/phuong_tien_models.dart';

class PhuongTienHomeScreen extends StatefulWidget {
  const PhuongTienHomeScreen({super.key});

  @override
  State<PhuongTienHomeScreen> createState() => _PhuongTienHomeScreenState();
}

class _PhuongTienHomeScreenState extends State<PhuongTienHomeScreen> {
  int _selectedIndex = 0;

  final _tabs = const [DanhSachPhuongTienScreen(), DanhSachYeuCauScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Phương tiện',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Yêu cầu',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Quick Test Panel - chỉ dùng để DEV, xóa khi release
// =============================================================================

class DevTestPanelScreen extends StatefulWidget {
  const DevTestPanelScreen({super.key});

  @override
  State<DevTestPanelScreen> createState() => _DevTestPanelScreenState();
}

class _DevTestPanelScreenState extends State<DevTestPanelScreen> {
  final _service = PhuongTienService();
  String _log = 'Chọn API để test...';
  bool _isLoading = false;

  Future<void> _run(Future<String> Function() action) async {
    setState(() {
      _isLoading = true;
      _log = 'Đang gọi API...';
    });
    try {
      final result = await action();
      setState(() => _log = result);
    } on AppException catch (e) {
      setState(() => _log = '❌ Lỗi: ${e.message}');
    } catch (e) {
      setState(() => _log = '❌ Unexpected: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔧 Dev Test Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _run(() async {
                    final result = await _service.getQuanHeCuTru();
                    return '✅ Quan hệ cư trú: ${result.length} căn hộ\n'
                        '${result.map((r) => '• ${r.diaChiDayDu}').join('\n')}';
                  }),
                  child: const Text('Quan hệ cư trú'),
                ),
                ElevatedButton(
                  onPressed: () => _run(() async {
                    final result = await _service.getLoaiPhuongTien();
                    return '✅ Loại xe: ${result.length} loại\n'
                        '${result.map((r) => '• ${r.name}').join('\n')}';
                  }),
                  child: const Text('Loại xe'),
                ),
                ElevatedButton(
                  onPressed: () => _run(() async {
                    final result = await _service.getTrangThaiPhuongTien();
                    return '✅ Trạng thái: ${result.length} loại\n'
                        '${result.map((r) => '• ${r.name}').join('\n')}';
                  }),
                  child: const Text('Trạng thái xe'),
                ),
                ElevatedButton(
                  onPressed: () => _run(() async {
                    final result = await _service.getListPhuongTien(
                      const GetListPhuongTienRequest(
                        pageNumber: 1,
                        pageSize: 5,
                      ),
                    );
                    return '✅ Phương tiện: ${result.pagingInfo.totalItems} tổng\n'
                        '${result.items.map((r) => '• ${r.tenPhuongTien} - ${r.bienSo}').join('\n')}';
                  }),
                  child: const Text('List xe (p1)'),
                ),
                ElevatedButton(
                  onPressed: () => _run(() async {
                    final result = await _service.getListYeuCau(
                      pageNumber: 1,
                      pageSize: 5,
                    );
                    return '✅ Yêu cầu: ${result.pagingInfo.totalItems} tổng\n'
                        '${result.items.map((r) => '• #${r.id} ${r.tenLoaiYeuCau} - ${r.tenTrangThai}').join('\n')}';
                  }),
                  child: const Text('List yêu cầu (p1)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _log,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
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
